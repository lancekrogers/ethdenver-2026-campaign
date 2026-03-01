# Constraints: Get It Working, Record the Demo

## Technical Constraints

### C-01: 0G Serving Contract Not Deployed

The inference agent's compute pipeline requires `ZG_SERVING_CONTRACT` on 0G Galileo testnet. Without it, the agent receives tasks via HCS and reports results, but cannot run actual GPU inference.

**Impact:** Demo shows inference agent receiving/reporting tasks but not executing real AI inference.

**Workaround:** The agent still participates in the economy cycle (receives task, reports result). The 0G compute step is skipped but the HCS/HTS flow is real.

### C-02: Base Contract Addresses Missing

- `DEFI_DEX_ROUTER`: zero address — trade execution stubbed
- `DEFI_ERC8004_CONTRACT`: empty — identity registration cannot execute
- `DEFI_BUILDER_CODE`: not configured — attribution disabled

**Impact:** Demo shows DeFi agent with stub trades. P&L data is simulated.

**Workaround:** Agent still participates in economy cycle. Mean reversion strategy runs, trades are logged, PnL is reported via HCS. The on-chain execution is stubbed but the agent behavior is real.

### C-03: Dashboard Does Not Compile

`page.tsx` imports from `@/components/panels/*` and `@/hooks/*` that don't exist. Components are 1-line stubs.

**Impact:** Cannot show a visual dashboard in the demo.

**Options (choose one):**

1. Fix imports and implement minimal panel components
2. Build a stripped-down page that only uses what exists
3. Use terminal-based visualization instead

### C-04: No Submission Deadline Pressure

The deadline has passed. This removes time pressure but also removes the bounty incentive structure. Focus purely on making the system work and recording a good demo.

## Process Constraints

### C-05: No New Features

Fix what's broken, wire what's disconnected, but don't add new capabilities. The architecture is set.

### C-06: Submodule Workflow

Changes require commit + push per submodule, then `camp commit` in campaign repo. This is the established flow.

## Resource Constraints

### C-07: Testnet Funds

Hedera testnet accounts may need HBAR refills. Base Sepolia needs SepoliaETH. 0G Galileo may need faucet tokens.
