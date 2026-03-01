---
fest_type: gate
fest_id: 06_testing.md
fest_name: testing
fest_parent: 03_unblock_base
fest_order: 6
fest_status: pending
fest_gate_type: testing
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Gate: Testing

## Objective

Run the full test suite for `projects/agent-defi` and verify that all executor and identity fixes are covered by passing tests.

## Test Checklist

### Unit Tests: Executor

- [ ] `go test ./internal/base/trading/...` passes with no failures
- [ ] Test confirms generated calldata starts with selector `0x414bf389` (not `0xa9059cbb`)
- [ ] Test confirms an approve call is present before the swap call
- [ ] Test confirms `GetMarketState` returns data from a mocked QuoterV2 call (not a hardcoded constant)
- [ ] No test uses hardcoded calldata hex strings that could mask a regression

### Unit Tests: Identity

- [ ] `go test ./internal/base/identity/...` passes with no failures
- [ ] Test confirms `GetIdentity` calldata starts with the correct `getIdentity` function selector
- [ ] Test confirms the agentID is correctly left-padded to 32 bytes in the encoded calldata
- [ ] Test confirms `Register` calldata encodes all parameters in the correct ABI order
- [ ] No test uses `"0x" + agentID` string concatenation (confirms the bug is not re-introduced)

### Full Suite

- [ ] `go test ./...` in `projects/agent-defi` passes with no failures
- [ ] `go build ./...` produces no compile errors
- [ ] `go vet ./...` reports no issues

### Integration Smoke Test

- [ ] Agent starts without panicking on Base Sepolia config
- [ ] Agent wallet balances are non-zero at startup
- [ ] At least one swap and one identity registration have confirmed on-chain (from task 05)

## Pass Criteria

All checkboxes above must be checked before proceeding to the review gate. If any unit test is failing, fix it before marking this gate complete — do not skip to iterate.
