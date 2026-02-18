---
fest_type: task
fest_id: 10_code_review.md
fest_name: code_review
fest_parent: 02_defi_base
fest_order: 10
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Code Review

## Objective

Review all code changes in the 02_defi_base sequence for quality, correctness, and adherence to project standards. Special attention to financial accuracy in P&L tracking, security of private key handling, and correctness of on-chain transaction construction.

**Project:** `agent-defi` at `projects/agent-defi/`

## Requirements

- [ ] All files reviewed against project coding standards
- [ ] Financial calculations verified for accuracy
- [ ] Security of key material handling reviewed
- [ ] On-chain transaction construction reviewed for correctness
- [ ] Linting passes with zero warnings

## Implementation

### Step 1: Run automated checks

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go vet ./...
staticcheck ./...
gofmt -l .
```

All three must produce zero output.

### Step 2: Review code quality

For each file, verify:

- [ ] Functions focused on single responsibility
- [ ] Naming clear, consistent, and idiomatic Go
- [ ] Comments explain "why" not "what"
- [ ] No unnecessary complexity
- [ ] No dead code or TODO placeholders

### Step 3: Review financial accuracy

**P&L Tracker Review (CRITICAL):**

- [ ] Revenue calculations are correct (sell price - buy price for each trade)
- [ ] Gas costs are tracked for every transaction (including non-trade transactions like identity registration)
- [ ] DEX fees are accounted for (swap fees, protocol fees)
- [ ] No floating-point precision issues in financial calculations
- [ ] `IsSelfSustaining` correctly compares revenue vs costs
- [ ] Win rate calculation handles edge cases (zero trades, all wins, all losses)
- [ ] P&L report time filtering correctly includes/excludes trades by timestamp
- [ ] Thread safety of PnLTracker verified (mutex usage correct)

**Trading Strategy Review:**

- [ ] Strategy signals are consistent with market data
- [ ] Risk management limits (MaxPosition) are enforced
- [ ] Slippage protection (MinAmountOut) is calculated correctly
- [ ] No division by zero in price calculations

### Step 4: Review security

**Critical Security Review:**

- [ ] No private keys hardcoded anywhere in source
- [ ] Private keys loaded only from environment variables
- [ ] No private keys logged (check all slog/log calls)
- [ ] Transaction signing uses go-ethereum's standard signing
- [ ] ERC-20 token approvals are bounded (not unlimited)
- [ ] MaxGasPrice safety limit prevents overspending on gas
- [ ] No user funds can be permanently locked by agent errors

### Step 5: Review on-chain transaction construction

- [ ] Swap calldata is correctly encoded for the target DEX (Uniswap V3)
- [ ] ERC-8021 attribution is appended correctly (does not break swap execution)
- [ ] Gas estimation is done before signing
- [ ] Transaction nonce management prevents stuck transactions
- [ ] Chain ID is set correctly (Base Sepolia = 84532)
- [ ] Transaction deadlines prevent stale trades from executing

### Step 6: Review architecture and context propagation

- [ ] Package layout follows the design from task 02
- [ ] No circular dependencies
- [ ] All dependencies injected via constructors
- [ ] All I/O functions accept `context.Context` as first parameter
- [ ] Context cancellation respected in trading loop and all goroutines
- [ ] No goroutine leaks

### Step 7: Review error handling

- [ ] All errors wrapped with contextual information
- [ ] Sentinel errors defined for each package
- [ ] No panics in library code
- [ ] Resources cleaned up in error paths
- [ ] Trading errors do not crash the agent (logged and continued)

### Step 8: Document findings

**Critical Issues (Must Fix):**

| Issue | File | Line | Description | Priority |
|-------|------|------|-------------|----------|
| | | | | |

**Suggestions (Should Consider):**

| Suggestion | File | Line | Rationale |
|------------|------|------|-----------|
| | | | |

**Positive Observations:**

- (Note good patterns observed during review)

## Done When

- [ ] All files reviewed against every checklist above
- [ ] Financial calculations verified for accuracy
- [ ] Security review complete (no key material exposure)
- [ ] On-chain transactions verified for correctness
- [ ] `go vet`, `staticcheck`, `gofmt` produce zero output
- [ ] No critical issues remaining
- [ ] All suggestions documented
- [ ] Review verdict recorded

**Reviewer:** (name/agent)
**Date:** (date)
**Verdict:** [ ] Approved / [ ] Needs Changes
