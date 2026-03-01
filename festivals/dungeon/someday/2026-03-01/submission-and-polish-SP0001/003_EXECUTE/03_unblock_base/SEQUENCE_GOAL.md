---
fest_type: sequence
fest_id: 03_unblock_base
fest_name: unblock_base
fest_parent: 003_EXECUTE
fest_order: 3
fest_status: pending
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Sequence Goal: 03_unblock_base

## Objective

Get the DeFi agent executing real trades on Base Sepolia by configuring the known contract addresses, fixing the executor to use the correct Uniswap V3 ABI, fixing malformed identity registration calldata, funding the agent wallet, and running end-to-end verification with real transaction hashes.

The DeFi agent at `projects/agent-defi` has two critical code defects blocking live Base Sepolia trades:

1. `executor.go` uses function selector `0xa9059cbb` (ERC-20 transfer) instead of `0x414bf389` (Uniswap V3 `exactInputSingle`), and has no ERC-20 approve flow before swaps. Market state is hardcoded instead of queried from QuoterV2.
2. `register.go` builds calldata as `"0x" + agentID` (string concatenation) instead of proper ABI encoding, causing identity registration to revert on-chain.

Contract addresses are known and deployed on Base Sepolia — no contract work is required. This sequence is purely a code-fix and integration-verification effort.

## Contribution

Without working Base Sepolia trades, the 04_e2e_testing sequence cannot demonstrate the full three-agent economy loop on Base. The 08_base_package submission requires documented trade history with real transaction hashes. This sequence unblocks both.

## Tasks

| Order | File | Description |
|-------|------|-------------|
| 1 | 01_configure_contracts.md | Set contract addresses in agent-defi .env |
| 2 | 02_fix_executor.md | Fix Uniswap V3 ABI, add approve flow, wire real QuoterV2 queries |
| 3 | 03_fix_identity.md | Fix ABI encoding in identity register.go |
| 4 | 04_fund_wallet.md | Fund agent wallet with SepoliaETH and test USDC |
| 5 | 05_test_base_trades.md | Run agent, verify real swaps execute, document tx hashes |

## Quality Gates

| Order | File | Type | Description |
|-------|------|------|-------------|
| 6 | 06_testing.md | testing | Run go test ./... for executor and identity fixes |
| 7 | 07_review.md | review | Code review of ABI encoding and calldata fixes |
| 8 | 08_iterate.md | iterate | Address review findings |
| 9 | 09_fest_commit.md | fest_commit | Commit all changes |

## Dependencies

None. This sequence can run in parallel with:
- `01_dashboard_verify`
- `02_unblock_0g`

## Provides

- `04_e2e_testing` — working Base Sepolia trades for full three-agent economy loop
- `08_base_package` — documented swap transactions and profitability data for submission

## Definition of Done

- DeFi agent registers its ERC-8004 identity on Base Sepolia without reverting
- At least one real Uniswap V3 swap executes on Base Sepolia with a valid transaction hash
- PnL tracker records the trade
- ERC-8021 attribution bytes are present in swap calldata
- All `go test ./...` tests pass in `projects/agent-defi`
