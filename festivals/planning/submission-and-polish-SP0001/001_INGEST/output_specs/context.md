# Context: Get It Working, Record the Demo

## What Already Works

### Hedera Layer (Fully Operational)

- HCS publish/subscribe: coordinator publishes task assignments, agents receive them, agents report results
- HTS token transfer: coordinator pays agents on task completion
- Schedule Service heartbeat: implemented and tested
- Live testnet run 2026-02-21 confirmed all of the above

### Agent Communication (Fully Operational)

- Three agents communicate via HCS topics (task topic + status topic)
- Coordinator assigns tasks via `TaskAssignmentPayload` with extended fields (model_id, input, task_type)
- Agents report results via `TaskResultPayload` and `PnLReportPayload`
- Result handler processes results and triggers payment
- All tested with both mocks and live testnet

### Agent Code (Complete, Partially Blocked)

- **Coordinator:** Fully wired. Builds, tests pass, ran on testnet.
- **Inference:** HCS transport works. 0G pipeline code complete but blocked by missing contract.
- **DeFi:** HCS transport works. Trading strategy, PnL tracker, x402, ERC-8004, ERC-8021 all coded. Blocked by missing contract addresses.

## What Doesn't Work

### Dashboard

- Component stubs in `src/components/` are 1-line files
- `page.tsx` imports hooks and panels from paths that don't exist
- Would fail `next build`
- Needs either fixing or replacing with alternative visualization

### 0G Compute Execution

- `ZG_SERVING_CONTRACT` is empty
- Agent cannot discover compute providers
- All other 0G operations (storage, iNFT, DA) may work independently

### Base DEX Execution

- `DEFI_DEX_ROUTER` is zero address
- Agent cannot execute real swaps
- All other Base operations (identity, payment, attribution) are coded but untested against real contracts

## Testnet Accounts

| Entity | Account ID |
|--------|-----------|
| Coordinator | 0.0.7974114 |
| Inference Agent | 0.0.7984825 |
| DeFi Agent | 0.0.7985425 |
| HCS Task Topic | 0.0.7999404 |
| HCS Status Topic | 0.0.7999405 |
| HTS Payment Token | 0.0.7999406 |

## Project Build Status

| Project | Builds | Tests Pass | Testnet Verified |
|---------|--------|-----------|-----------------|
| agent-coordinator | Yes | Yes (all packages) | Yes (2/21) |
| agent-inference | Yes | Yes (63 tests) | HCS only |
| agent-defi | Yes | Yes (57 tests) | HCS only |
| dashboard | No | No tests | No |
| hiero-plugin | Yes | Yes (37 tests) | N/A |
| contracts | No (empty) | No | No |

## Key Files for Demo Work

| Purpose | File |
|---------|------|
| Coordinator entry point | `projects/agent-coordinator/cmd/coordinator/main.go` |
| Inference entry point | `projects/agent-inference/cmd/agent-inference/main.go` |
| DeFi entry point | `projects/agent-defi/cmd/agent-defi/main.go` |
| Dashboard page | `projects/dashboard/src/app/page.tsx` |
| Demo script | `workflow/design/ethdenver-agent-economy/04-demo-and-deliverables.md` |
| Integration plan | `projects/agent-coordinator/internal/coordinator/static_plan.go` |
| Coordinator config | `projects/agent-coordinator/.env` |
| Inference config | `projects/agent-inference/.env` |
| DeFi config | `projects/agent-defi/.env` |
