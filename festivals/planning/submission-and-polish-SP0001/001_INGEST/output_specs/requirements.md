# Requirements: Get It Working, Record the Demo

## P0 — Must Work

### R-01: Three-Agent Economy Cycle Runs End-to-End

- Coordinator starts, loads integration plan, publishes task assignments to HCS
- Inference agent receives task via HCS, processes it, reports result via HCS
- DeFi agent receives task via HCS, executes trade logic, reports result via HCS
- Coordinator receives results, triggers HTS token payment to completing agents
- All three agents shut down gracefully

**Current state:** Single live testnet run completed 2026-02-21. HCS transport verified. HTS payment triggered. Inference blocked by missing 0G contract. DeFi trades stubbed. The cycle works at the HCS/HTS layer — the blockers are in chain-specific execution (0G compute, Base DEX).

### R-02: Dashboard or Visualization

The demo needs something visual — terminal logs alone won't convey the system. Options:

1. **Fix the dashboard** — implement the panel components so Next.js compiles and shows live data
2. **Minimal dashboard** — strip `page.tsx` to only show working panels (HCS feed + agent status), skip broken ones
3. **Terminal dashboard** — use a TUI or structured log output that shows agent activity in real-time

**Current state:** Dashboard does not compile. `page.tsx` imports from paths that don't exist. Component files are 1-line stubs.

### R-03: Demo Video

- Under 3 minutes
- Shows agents starting, communicating, completing tasks, and settling payments
- Includes visual component (dashboard, TUI, or terminal with clear formatting)
- Captures the narrative: "Three agents, three chains, one orchestrator"

**Current state:** Not started. Requires R-01 and R-02 working first.

## P1 — Should Work (Makes Demo Stronger)

### R-04: 0G Inference Pipeline Live

- Deploy or configure 0G Serving contract on Galileo testnet
- Inference agent discovers providers, submits job, receives result
- Store result on 0G Storage
- Mint or update ERC-7857 iNFT

**Current state:** All code exists and tests pass with mocks. `ZG_SERVING_CONTRACT` env var is empty. Need to either deploy the contract or find an existing one.

### R-05: Base DeFi Trades Live

- Configure a real DEX router on Base Sepolia (Uniswap V3 or similar)
- DeFi agent executes real swaps, records P&L
- ERC-8004 identity registration on-chain
- ERC-8021 builder code on transactions

**Current state:** All code exists. `DEFI_DEX_ROUTER` is zero address. `DEFI_ERC8004_CONTRACT` is empty. Need real contract addresses on Base Sepolia.

### R-06: P&L Proof

- DeFi agent demonstrates revenue exceeding costs over a test period
- PnL tracker captures trades, gas costs, net profit

**Current state:** PnL tracker code complete and tested. Needs real trades to produce real data.

## P2 — Nice to Have

### R-07: Project READMEs

- Update agent-coordinator, agent-inference, agent-defi READMEs with architecture and setup
- Root campaign README with project overview

### R-08: Architecture Diagram

- System-level diagram for the demo video or README

## Priority Order

| Priority | Requirement | Blocker |
|----------|------------|---------|
| P0 | R-01: E2E cycle | None (already works at HCS/HTS layer) |
| P0 | R-02: Visualization | Dashboard broken, needs fix or alternative |
| P0 | R-03: Demo video | Depends on R-01 + R-02 |
| P1 | R-04: 0G inference live | Missing serving contract |
| P1 | R-05: Base trades live | Missing DEX router address |
| P1 | R-06: P&L proof | Depends on R-05 |
| P2 | R-07: READMEs | No blocker |
| P2 | R-08: Architecture diagram | No blocker |
