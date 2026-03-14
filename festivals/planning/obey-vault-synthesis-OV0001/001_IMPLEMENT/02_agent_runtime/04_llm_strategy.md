---
fest_type: task
fest_id: 01_llm_strategy.md
fest_name: 02_llm_strategy
fest_parent: 02_agent_runtime
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:24:37.75117-06:00
fest_tracking: true
---

# Task: LLM Trading Strategy

## Objective

Implement an LLM-based trading strategy using Claude API that analyzes market data and produces buy/sell/hold signals with JSON parsing, plus a real ClaudeClient for the Anthropic Messages API.

## Requirements

- [ ] Create `internal/strategy/llm.go` with LLMClient interface, LLMConfig, LLMStrategy struct
- [ ] Implement Evaluate() that sends market data prompt to LLM and parses JSON response (action, confidence, size, reason)
- [ ] Create `internal/strategy/claude.go` with ClaudeClient implementing LLMClient via Anthropic Messages API
- [ ] Create `internal/strategy/llm_test.go` with mockLLM: test buy signal, hold signal, context cancellation
- [ ] Strategy implements the existing trading.Strategy interface (Name, MaxPosition, Evaluate)

## Implementation

See implementation plan Task 9 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create:**
- `projects/agent-defi/internal/strategy/llm.go`
- `projects/agent-defi/internal/strategy/claude.go`
- `projects/agent-defi/internal/strategy/llm_test.go`

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go test ./internal/strategy/... -v` passes all 3 tests
