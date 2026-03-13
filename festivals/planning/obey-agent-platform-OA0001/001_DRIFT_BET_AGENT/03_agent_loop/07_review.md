---
fest_type: gate
fest_id: 07_review.md
fest_name: Code Review
fest_parent: 03_agent_loop
fest_order: 7
fest_status: pending
fest_autonomy: low
fest_gate_type: review
fest_created: 2026-03-13T02:27:19.942953-06:00
fest_tracking: true
---

# Task: Code Review

**Task Number:** 7 | **Parallel Group:** None | **Dependencies:** Testing and Verification | **Autonomy:** low

## Objective

Review all code changes in this sequence for quality, correctness, and adherence to project standards.

## Review Checklist

### Code Quality

- [ ] Code is readable and well-organized
- [ ] Functions/methods are focused (single responsibility)
- [ ] No unnecessary complexity
- [ ] Naming is clear and consistent
- [ ] Comments explain "why" not "what"

### Architecture & Design

- [ ] Changes align with project architecture
- [ ] No unnecessary coupling introduced
- [ ] Dependencies are appropriate
- [ ] Interfaces are clean and focused
- [ ] No code duplication

### Standards Compliance

```bash
golangci-lint run ./internal/agent/... ./internal/risk/... ./internal/portfolio/... ./cmd/pred-agent/...
```

- [ ] Linting passes without warnings
- [ ] Formatting is consistent
- [ ] Project conventions are followed

### Sequence-Specific Review Focus

**Files/packages to review:**
- `cmd/pred-agent/main.go` - Agent binary entry point and config loading
- `internal/agent/loop.go` - Goroutine-based execution loop with trading/P&L/health cycles
- `internal/risk/manager.go` - Position sizing, drawdown limits, concentration checks
- `internal/portfolio/tracker.go` - Position tracking, NAV calculation, P&L reports
- `internal/agent/mock/` - Mock adapters for dry-run testing

**Design patterns to verify:**
- [ ] All goroutines tied to context cancellation (no leaks)
- [ ] SIGTERM/SIGINT handler cancels root context and calls shutdown with timeout
- [ ] Risk manager uses config values, not hardcoded thresholds
- [ ] Mock adapters implement identical interfaces as real adapters
- [ ] Execution loop follows existing agent-defi patterns (3 cycles: trading, P&L, health)
- [ ] No shared mutable state without proper synchronization

### Error Handling

- [ ] Errors are handled appropriately
- [ ] Error messages are helpful
- [ ] No panic/crash scenarios
- [ ] Resources are properly cleaned up

### Security Considerations

- [ ] No secrets in code
- [ ] Wallet path loaded from env, not hardcoded
- [ ] Risk parameters validated at startup (no zero/negative limits)
- [ ] Daily loss limit cannot be bypassed

### Performance

- [ ] No obvious performance issues
- [ ] Goroutines properly managed
- [ ] No memory leaks
- [ ] Health check monitors memory usage

### Testing

- [ ] Tests are meaningful
- [ ] Edge cases covered
- [ ] Test data is appropriate
- [ ] Mocks used correctly

## Review Process

1. **Read the sequence goal** - Understand what was being built
2. **Review file by file** - Check each modified file
3. **Run the code** - Verify functionality works
4. **Document findings** - Note issues and suggestions

## Findings

### Critical Issues (Must Fix)

1. [ ] [Issue description and recommendation]

### Suggestions (Should Consider)

1. [ ] [Suggestion and rationale]

### Positive Observations

- [Note good patterns or practices observed]

## Definition of Done

- [ ] All files reviewed
- [ ] Linting passes
- [ ] No critical issues remaining
- [ ] Suggestions documented
- [ ] Knowledge shared with team (if applicable)

## Review Summary

**Reviewer:** [Name/Agent]
**Date:** [Date]
**Verdict:** [ ] Approved / [ ] Needs Changes

**Notes:**
[Summary of the review and any outstanding concerns]
