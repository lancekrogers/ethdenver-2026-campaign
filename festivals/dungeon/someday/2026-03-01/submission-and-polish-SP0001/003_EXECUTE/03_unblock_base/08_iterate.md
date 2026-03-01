---
fest_type: gate
fest_id: 08_iterate.md
fest_name: iterate
fest_parent: 03_unblock_base
fest_order: 8
fest_status: pending
fest_gate_type: iterate
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Gate: Iterate

## Objective

Address any findings raised during the review gate (07_review). If the review found no issues, this gate passes immediately with no action required.

## Process

1. Read all findings from 07_review.
2. For each finding, determine if it is a blocker (must fix before commit) or a note (can defer).
3. Fix all blockers. Apply targeted, minimal changes — do not expand scope.
4. Re-run `go test ./...` after any code change to confirm no regressions.
5. Re-run `go vet ./...` to confirm no new issues.

## Common Findings to Expect

### If selector or ABI encoding is wrong

- Re-inspect the Uniswap V3 SwapRouter02 ABI JSON to confirm `exactInputSingle` selector
- Use `crypto.Keccak256` on the canonical function signature to derive the selector independently and cross-check

### If approve flow has a race condition

- Ensure `approve` receipt is awaited synchronously before the swap call is made
- Add a receipt-polling helper if not already present

### If context is missing from RPC calls

- Add `ctx context.Context` parameter to any function that was missing it
- Pass the context through to all `ethclient` calls

### If tests are shallow (no calldata assertion)

- Add a test helper that decodes the packed calldata and asserts field-by-field
- This is the only reliable way to catch ABI encoding regressions

## Done When

- All blocking findings from 07_review are resolved
- `go test ./...` passes with no failures
- Changes are staged for commit in 09_fest_commit
- If no findings: this gate is marked complete with note "no findings from review"
