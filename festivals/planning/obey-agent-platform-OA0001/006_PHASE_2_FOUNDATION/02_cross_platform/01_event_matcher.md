---
fest_type: task
fest_id: 01_event_matcher.md
fest_name: event_matcher
fest_parent: 02_cross_platform
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.587939-06:00
fest_tracking: true
---

# Task: Cross-Platform Event Matcher

## Objective

Implement the `EventMatcher` component that identifies equivalent prediction markets across Polymarket, Limitless, and Drift BET using LLM-assisted semantic matching with resolution rule verification.

## Requirements

- [ ] `EventMatcher` struct that ingests `NormalizedMarket` arrays from all platform adapters
- [ ] Stage 1: Group markets by category and expiry time window (within 7 days of each other)
- [ ] Stage 2: LLM-assisted semantic matching — compare market questions within groups for equivalence
- [ ] Stage 3: Resolution rule verification — confirm resolution criteria are compatible for arbitrage
- [ ] Output `EquivalentGroup` structs with match confidence score and resolution compatibility flag
- [ ] Caching: cache matched groups to avoid re-running LLM on every cycle (TTL 1 hour)
- [ ] Performance: process 500+ markets in under 10 seconds using batched LLM calls

## Implementation

### Step 1: Define types

Create `projects/agent-prediction/internal/engine/matcher.go`:

```go
package engine

import (
    "context"
    "sync"
    "time"
)

// EquivalentGroup represents a set of markets across platforms asking about the same event.
type EquivalentGroup struct {
    // A descriptive label for the underlying event.
    EventDescription string
    // Markets from different platforms about this event.
    Markets          []NormalizedMarket
    // Confidence that these markets are truly about the same event (0.0-1.0).
    MatchConfidence  float64
    // Whether the resolution rules are compatible for arbitrage.
    ResolutionMatch  bool
    // Explanation of any resolution rule differences.
    ResolutionNotes  string
}

// EventMatcher finds equivalent markets across platforms.
type EventMatcher struct {
    llm   LLMClient
    cache *matchCache
}

type matchCache struct {
    mu      sync.RWMutex
    groups  []EquivalentGroup
    updated time.Time
    ttl     time.Duration
}

// NewEventMatcher creates a new cross-platform event matcher.
func NewEventMatcher(llm LLMClient) *EventMatcher {
    return &EventMatcher{
        llm: llm,
        cache: &matchCache{
            ttl: 1 * time.Hour,
        },
    }
}
```

### Step 2: Implement the matching pipeline

```go
// FindEquivalentMarkets matches markets across platforms for the same underlying events.
func (m *EventMatcher) FindEquivalentMarkets(
    ctx context.Context,
    markets []NormalizedMarket,
) ([]EquivalentGroup, error) {
    if err := ctx.Err(); err != nil {
        return nil, err
    }

    // Check cache
    m.cache.mu.RLock()
    if time.Since(m.cache.updated) < m.cache.ttl && len(m.cache.groups) > 0 {
        cached := m.cache.groups
        m.cache.mu.RUnlock()
        return cached, nil
    }
    m.cache.mu.RUnlock()

    // Stage 1: Group by category + expiry window
    candidateGroups := groupByCategoryAndExpiry(markets)

    // Stage 2: LLM-assisted semantic matching
    matchedGroups, err := m.semanticMatch(ctx, candidateGroups)
    if err != nil {
        return nil, fmt.Errorf("semantic matching: %w", err)
    }

    // Stage 3: Resolution rule verification
    verifiedGroups, err := m.verifyResolutionRules(ctx, matchedGroups)
    if err != nil {
        return nil, fmt.Errorf("resolution verification: %w", err)
    }

    // Update cache
    m.cache.mu.Lock()
    m.cache.groups = verifiedGroups
    m.cache.updated = time.Now()
    m.cache.mu.Unlock()

    return verifiedGroups, nil
}

// groupByCategoryAndExpiry creates candidate groups of potentially equivalent markets.
func groupByCategoryAndExpiry(markets []NormalizedMarket) [][]NormalizedMarket {
    type groupKey struct {
        category string
        weekOf   string // ISO week for expiry date grouping
    }

    groups := map[groupKey][]NormalizedMarket{}
    for _, m := range markets {
        if m.Status != MarketStatusOpen {
            continue
        }
        // Use the expiry week as a grouping key (markets about the same event
        // usually expire within 7 days of each other)
        year, week := m.ExpiresAt.ISOWeek()
        key := groupKey{
            category: m.Category,
            weekOf:   fmt.Sprintf("%d-W%02d", year, week),
        }
        groups[key] = append(groups[key], m)
    }

    // Only return groups with markets from multiple platforms
    var result [][]NormalizedMarket
    for _, group := range groups {
        platforms := map[string]bool{}
        for _, m := range group {
            platforms[m.Platform] = true
        }
        if len(platforms) >= 2 {
            result = append(result, group)
        }
    }
    return result
}
```

### Step 3: LLM-assisted semantic matching

```go
// semanticMatch uses LLM to determine if markets within a candidate group
// are asking about the same real-world event.
func (m *EventMatcher) semanticMatch(
    ctx context.Context,
    candidateGroups [][]NormalizedMarket,
) ([]EquivalentGroup, error) {
    var results []EquivalentGroup

    // Batch markets for efficient LLM calls
    for _, group := range candidateGroups {
        if len(group) < 2 {
            continue
        }

        // Build comparison prompt
        var marketDescs []string
        for i, mkt := range group {
            marketDescs = append(marketDescs, fmt.Sprintf(
                "[%d] Platform: %s | Question: %s | Expires: %s",
                i, mkt.Platform, mkt.Question, mkt.ExpiresAt.Format("2006-01-02"),
            ))
        }

        prompt := fmt.Sprintf(`You are matching prediction markets across platforms.
Below are markets in the same category with similar expiry dates.
Identify which markets are about the SAME underlying real-world event.

Markets:
%s

For each group of equivalent markets, output JSON:
[
  {
    "event": "brief event description",
    "market_indices": [0, 3],
    "confidence": 0.95
  }
]

Rules:
- Only match markets if you are >80%% confident they are about the SAME event
- Markets with different time horizons are NOT equivalent
- "Will X happen by March 31?" is NOT equivalent to "Will X happen by June 30?"
- Be conservative: false positives are worse than false negatives for arbitrage

Output only valid JSON array.`, strings.Join(marketDescs, "\n"))

        response, err := m.llm.Complete(ctx, prompt)
        if err != nil {
            continue // skip this group on LLM error
        }

        // Parse LLM response
        var matches []struct {
            Event         string  `json:"event"`
            MarketIndices []int   `json:"market_indices"`
            Confidence    float64 `json:"confidence"`
        }
        if err := json.Unmarshal([]byte(response), &matches); err != nil {
            continue
        }

        for _, match := range matches {
            if match.Confidence < 0.8 {
                continue
            }
            var matched []NormalizedMarket
            for _, idx := range match.MarketIndices {
                if idx < len(group) {
                    matched = append(matched, group[idx])
                }
            }
            if len(matched) >= 2 {
                results = append(results, EquivalentGroup{
                    EventDescription: match.Event,
                    Markets:          matched,
                    MatchConfidence:  match.Confidence,
                })
            }
        }
    }

    return results, nil
}
```

### Step 4: Resolution rule verification

```go
// verifyResolutionRules uses LLM to check if matched markets have compatible
// resolution criteria (critical for safe arbitrage).
func (m *EventMatcher) verifyResolutionRules(
    ctx context.Context,
    groups []EquivalentGroup,
) ([]EquivalentGroup, error) {
    for i := range groups {
        group := &groups[i]

        var ruleDescs []string
        for _, mkt := range group.Markets {
            ruleDescs = append(ruleDescs, fmt.Sprintf(
                "Platform: %s\nQuestion: %s\nResolution Rules: %s",
                mkt.Platform, mkt.Question, mkt.ResolutionRules,
            ))
        }

        prompt := fmt.Sprintf(`Compare these prediction market resolution rules.
These markets appear to be about the same event: "%s"

%s

Answer in JSON:
{
  "compatible": true/false,
  "notes": "explanation of any differences that could cause different resolutions"
}

Two markets are compatible if: a YES on one guarantees YES on the other (and vice versa).
They are NOT compatible if edge cases exist where one resolves YES and the other NO.`,
            group.EventDescription, strings.Join(ruleDescs, "\n---\n"))

        response, err := m.llm.Complete(ctx, prompt)
        if err != nil {
            group.ResolutionMatch = false
            group.ResolutionNotes = "unable to verify: LLM error"
            continue
        }

        var result struct {
            Compatible bool   `json:"compatible"`
            Notes      string `json:"notes"`
        }
        if err := json.Unmarshal([]byte(response), &result); err != nil {
            group.ResolutionMatch = false
            continue
        }

        group.ResolutionMatch = result.Compatible
        group.ResolutionNotes = result.Notes
    }

    return groups, nil
}
```

### Step 5: Write tests

1. `TestGroupByCategoryAndExpiry` — verify markets grouped by category + week, multi-platform filter works
2. `TestSemanticMatchSameEvent` — mock LLM returns match for "Fed rate cut" markets on 2 platforms
3. `TestSemanticMatchDifferentEvents` — mock LLM returns no match for unrelated markets
4. `TestResolutionRuleCompatible` — mock LLM confirms compatible rules
5. `TestResolutionRuleIncompatible` — mock LLM flags incompatible rules (different deadlines)
6. `TestCacheHit` — run FindEquivalentMarkets twice, verify second call uses cache
7. `TestCacheExpiry` — set short TTL, verify re-computation after expiry

## Done When

- [ ] All requirements met
- [ ] Markets are grouped by category and expiry week
- [ ] LLM semantic matching identifies equivalent markets with >80% confidence threshold
- [ ] Resolution rule verification flags incompatible markets as unsafe for arbitrage
- [ ] Results are cached with configurable TTL (default 1 hour)
- [ ] `go test ./internal/engine/...` passes with all event matcher tests green
