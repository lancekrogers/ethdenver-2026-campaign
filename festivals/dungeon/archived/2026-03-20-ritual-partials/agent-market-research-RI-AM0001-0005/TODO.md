# Festival TODO - agent-market-research

**Goal**: Evaluate current market conditions and produce a structured go/no-go trading decision with full rationale
**Status**: Planning

---

## Festival Progress Overview

### Phase Completion Status

- [ ] 001_INGEST: Collect market data from on-chain and API sources
- [ ] 002_RESEARCH: Analyze data, evaluate risk, score opportunity
- [ ] 003_DECIDE: Produce structured go/no-go decision with rationale

### Current Work Status

```
Active Phase: None (ritual not yet executed)
Active Sequences: N/A (ritual uses phases, not sequences)
Blockers: None
```

---

## Phase Progress

### 001_INGEST

**Status**: Not Started

- [ ] Query Uniswap V3 pool state (USDC/WETH)
- [ ] Collect 30-point price history
- [ ] Get volume metrics and gas price
- [ ] Validate data freshness (< 5 min)
- [ ] Save market_snapshot.json and price_history.json

### 002_RESEARCH

**Status**: Not Started

- [ ] Calculate moving average from price history
- [ ] Compute price deviation percentage
- [ ] Run CRE Risk Router 8-gate evaluation
- [ ] Score opportunity (confidence 0.0-1.0)
- [ ] Estimate cost-benefit (profit vs gas + fees + slippage)
- [ ] Save findings as structured JSON

### 003_DECIDE

**Status**: Not Started

- [ ] Synthesize research into GO/NO_GO decision
- [ ] Document rationale with specific numbers
- [ ] Generate decision.json
- [ ] Generate agent_log_entry.json (DevSpot format)

---

## Blockers

None currently.

---

## Decision Log

*Each ritual execution adds a dated entry here.*

---

*Detailed progress available via `fest status`*
