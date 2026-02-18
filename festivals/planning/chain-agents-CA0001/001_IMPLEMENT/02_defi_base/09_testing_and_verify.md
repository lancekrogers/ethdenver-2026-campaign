---
fest_type: task
fest_id: 09_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 02_defi_base
fest_order: 9
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

## Objective

Verify that all functionality implemented in the 02_defi_base sequence works correctly through comprehensive testing. This quality gate ensures the DeFi agent's Base integrations (identity, payment, trading, attribution) and HCS communication are reliable before proceeding to code review.

**Project:** `agent-defi` at `projects/agent-defi/`

## Requirements

- [ ] All unit tests pass across every package
- [ ] P&L calculations verified with known inputs
- [ ] Trading strategy produces correct signals for test market data
- [ ] Attribution codes verified in transaction calldata
- [ ] Context cancellation tests confirm graceful shutdown
- [ ] No data races in concurrent code (P&L tracker, trading loop)

## Implementation

### Step 1: Run all unit tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go test ./... -v -count=1 -race
```

The `-race` flag is critical for this agent because the P&L tracker and trading loop run concurrently. Every test must pass with zero data races.

### Step 2: Verify package-level tests

Run tests for each package individually:

```bash
go test ./internal/base/identity/... -v
go test ./internal/base/payment/... -v
go test ./internal/base/trading/... -v -race
go test ./internal/base/attribution/... -v
go test ./internal/hcs/... -v
go test ./internal/agent/... -v -race
```

For each package, verify:

- [ ] **identity**: Registration, verification, retrieval, already-registered handling
- [ ] **payment**: ETH and ERC-20 payments, 402 handshake, gas tracking, verification
- [ ] **trading/strategy**: Buy/sell/hold signals for various market states
- [ ] **trading/executor**: Swap execution, balance queries, market state queries, attribution inclusion
- [ ] **trading/pnl**: Trade recording, report generation, self-sustaining flag, concurrent access
- [ ] **attribution**: Encode/decode roundtrip, disabled mode, edge cases
- [ ] **hcs**: Message serialization, subscription, P&L publishing, health publishing
- [ ] **agent**: Full lifecycle, trading loop, P&L reporting, graceful shutdown

### Step 3: Verify P&L calculations

This is the most important verification for the Base bounty. Create or run dedicated P&L tests:

1. Record a series of known trades with known costs:
   - Trade 1: Buy 1 ETH at $2000, gas cost $0.50
   - Trade 2: Sell 1 ETH at $2050, gas cost $0.50, DEX fee $1.00
   - Expected: Revenue $50, Gas $1.00, Fees $1.00, Net P&L $48.00, IsSelfSustaining=true

2. Record a losing scenario:
   - Trade 1: Buy 1 ETH at $2000, gas cost $0.50
   - Trade 2: Sell 1 ETH at $1990, gas cost $0.50
   - Expected: Revenue -$10, Gas $1.00, Fees $0, Net P&L -$11.00, IsSelfSustaining=false

3. Verify win rate calculation with mixed results

```bash
go test ./internal/base/trading/... -v -run TestPnL
```

### Step 4: Verify attribution in trade calldata

Run specific tests that verify ERC-8021 attribution is present in executed trades:

```bash
go test ./internal/base/trading/... -v -run TestAttribution
go test ./internal/base/attribution/... -v
```

Verify:
- [ ] Every trade calldata ends with the ERC-8021 marker and builder code
- [ ] Decoding the calldata recovers the correct builder attribution
- [ ] Attribution is correctly appended even to empty calldata

### Step 5: Check test coverage

```bash
go test ./... -coverprofile=coverage.out
go tool cover -func=coverage.out
```

Target minimum 70% coverage for new code. Critical areas that must be covered:

- P&L calculation logic (100% coverage recommended)
- Strategy signal generation
- Attribution encode/decode
- Error handling paths in payment and trading

### Step 6: Verify context cancellation

- [ ] `identity.Register` exits cleanly when context cancelled during transaction
- [ ] `payment.Pay` exits cleanly when context cancelled
- [ ] `trading.Execute` exits cleanly when context cancelled during swap
- [ ] `agent.tradingLoop` exits when context cancelled
- [ ] `agent.pnlReportLoop` exits when context cancelled
- [ ] `agent.Run` exits cleanly on SIGTERM simulation

### Step 7: Run static analysis

```bash
go vet ./...
staticcheck ./...
```

Both must produce zero warnings.

### Step 8: Verify the binary builds and starts

```bash
go build -o /tmp/agent-defi ./cmd/agent-defi/
```

Verify it exits gracefully with a config error when no environment variables are set.

### Step 9: Document results

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Race detector: [ ] Pass / [ ] Fail
- P&L calculations: [ ] Pass / [ ] Fail
- Attribution: [ ] Pass / [ ] Fail
- Context cancellation: [ ] Pass / [ ] Fail
- Static analysis: [ ] Pass / [ ] Fail
- Binary build: [ ] Pass / [ ] Fail
- Coverage: ____%

## Done When

- [ ] All automated tests pass with `go test ./... -v -count=1 -race`
- [ ] P&L calculations verified with known trade data
- [ ] Attribution verified in trade calldata
- [ ] Coverage meets 70% minimum for new code
- [ ] All context cancellation tests pass
- [ ] `go vet` and `staticcheck` produce zero warnings
- [ ] Binary builds successfully
- [ ] No data races detected
- [ ] Test results documented
