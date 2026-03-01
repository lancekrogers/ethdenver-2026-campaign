---
fest_type: gate
fest_id: 07_review.md
fest_name: Code Review
fest_parent: 02_unblock_0g
fest_order: 7
fest_status: pending
fest_gate_type: review
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Code Review

**Task Number:** 07 | **Parallel Group:** None | **Dependencies:** Testing (06) | **Autonomy:** low

## Objective

Review all code changes made in this sequence for correctness, safety, and adherence to project standards. The primary focus is the ABI fix in `broker.go`, but any other changes (storage, iNFT, config) must also be reviewed.

## Review Checklist

### ABI Correctness (Primary Focus)

- [ ] The `servingABIJSON` constant matches the real contract — method names, parameter types, and return types are accurate
- [ ] The `getAllServices` call passes `big.NewInt(0)` and `big.NewInt(100)` (or a configured limit) — not hardcoded magic numbers without comment
- [ ] The type assertion on the returned tuple slice is correct and handles the fallback case
- [ ] `getService(address)` signature in the ABI is correct and available for future use

### Code Quality

- [ ] `listFromChain` is under 50 lines (per project standards)
- [ ] No magic numbers or strings without explanation
- [ ] Naming is clear and consistent with existing code
- [ ] No dead code left over from the old `getServiceCount` implementation

### Architecture & Design

- [ ] ABI is declared as a constant — not loaded from file, not hardcoded inline in the function
- [ ] `serviceStruct` (if added) is unexported — it is an internal decoding detail
- [ ] Error wrapping uses the existing pattern (not `fmt.Errorf` with bare strings)
- [ ] Context is propagated through all call paths unchanged

### Standards Compliance

```bash
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
go vet ./... && staticcheck ./...
```

- [ ] No vet warnings
- [ ] No staticcheck warnings (if staticcheck is available)

### Error Handling

- [ ] Empty service list does not panic — returns nil or `ErrNoModels` as appropriate
- [ ] Failed ABI decode does not panic — returns a clear error
- [ ] Context cancellation propagates correctly to the RPC call via `bind.CallOpts{Context: ctx}`
- [ ] No resources leak (connections, goroutines) in any error path

### Security

- [ ] No private keys or secrets introduced in any modified file
- [ ] Contract address is read from config/env — not hardcoded in source
- [ ] No user-controlled input passed to ABI call without validation

### Testing Quality

- [ ] New or updated tests exercise the `getAllServices` path specifically
- [ ] Mock/stub behavior accurately reflects the real ABI (offset+limit in, tuple[] out)
- [ ] Test names describe what they verify

## Review Process

1. Read the sequence goal and task descriptions for context
2. Review `broker.go` diff focusing on `servingABIJSON` and `listFromChain`
3. Run `go vet ./...` and review output
4. Review any new test files for correctness
5. Review `results/*.md` documents for completeness

## Findings

### Critical Issues (Must Fix)

1. [ ] [Issue description and recommendation]

### Suggestions (Should Consider)

1. [ ] [Suggestion and rationale]

### Positive Observations

- [Note good patterns or practices observed]

## Definition of Done

- [ ] `broker.go` ABI section reviewed and confirmed accurate
- [ ] `listFromChain` reviewed for correctness and style
- [ ] Linting passes
- [ ] No critical issues remaining open
- [ ] Suggestions documented for iterate gate

## Review Summary

**Reviewer:** [Name/Agent]
**Date:** [Date]
**Verdict:** [ ] Approved / [ ] Needs Changes

**Notes:**
[Summary of the review and any outstanding concerns]
