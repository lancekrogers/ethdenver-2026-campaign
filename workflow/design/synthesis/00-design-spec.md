# OBEY Vault — Design Specification

## Synthesis Hackathon Submission (Mar 13–22, 2026)

**Track:** Agents that Pay
**Chain:** Base (mainnet)
**Partners Used:** Uniswap (swap infrastructure), ERC-8004 (agent identity)

---

## Pitch

On-chain vault custody where AI agents trade via Uniswap within human-defined spending boundaries — they can swap but never extract funds. Deposit USDC, receive share tokens, exit at NAV anytime.

**The question Synthesis asks:** "Your agent moves money on your behalf. But how do you know it did what you asked?"

**Our answer:** A vault smart contract that enforces spending scope, settles on-chain, and produces an auditable transaction history. The agent is powerful (LLM-driven, autonomous) but the human never loses control. The vault enforces the rules, not the agent's good behavior.

---

## Architecture

Four components, each independently testable:

```
┌─────────────────────────────────────────────────┐
│                  OBEY VAULT                      │
│                                                  │
│  ┌────────────┐     ┌─────────────────────────┐ │
│  │ Vault.sol  │◄────│ Go Agent Runtime        │ │
│  │ (Base)     │     │ (off-chain)             │ │
│  │            │     │                         │ │
│  │ Deposit    │     │ Market analysis (LLM)   │ │
│  │ Swap (Uni) │     │ Swap decision engine    │ │
│  │ NAV calc   │     │ Risk controls           │ │
│  │ Burn/exit  │     │ Uniswap API integration │ │
│  │ Share token│     │ Vault interaction (eth)  │ │
│  └────────────┘     └─────────────────────────┘ │
│                                                  │
│  ┌────────────┐     ┌─────────────────────────┐ │
│  │ ERC-8004   │     │ Observer UI / CLI       │ │
│  │ Identity   │     │                         │ │
│  │ (Base)     │     │ Vault state dashboard   │ │
│  │            │     │ Trade history           │ │
│  │ Agent NFT  │     │ NAV chart               │ │
│  │ Metadata   │     │ Agent identity          │ │
│  │ Reputation │     │                         │ │
│  └────────────┘     └─────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Component 1: Vault.sol (Solidity, Base)

The core deliverable. ERC-4626 vault with agent trading constraints.

**Roles:**
- `agent` — single authorized address, can execute swaps through Uniswap, nothing else. Set by guardian at deployment via constructor parameter `agent_`. Guardian can update via `setAgent(address)`.
- `guardian` — human owner (deployer), can pause, configure boundaries, manage token whitelist, change agent address

**Human-Defined Spending Boundaries:**
- `approvedTokens` — whitelist of tokens the agent can swap into
- `maxSwapSize` — maximum USDC value per single swap
- `maxDailyVolume` — daily trading cap
- `maxSlippageBps` — maximum allowed slippage in basis points

**Core Operations:**

| Operation | Who | What |
|-----------|-----|------|
| `deposit(assets, receiver)` | Anyone | Deposit USDC, receive ERC-20 share tokens |
| `redeem(shares, receiver, owner)` | Share holder | Burn shares, receive USDC at NAV |
| `executeSwap(tokenIn, tokenOut, amountIn, minAmountOut, reason)` | Agent only | Swap via Uniswap V3 SwapRouter02 within boundaries. Emits `SwapExecuted` event with all params + `reason` bytes for audit trail |
| `setAgent(address)` | Guardian only | Change authorized agent address |
| `setApprovedToken(token, approved)` | Guardian only | Manage token whitelist |
| `setMaxSwapSize(amount)` | Guardian only | Set per-swap limit |
| `setMaxDailyVolume(amount)` | Guardian only | Set daily volume cap |
| `pause()` / `unpause()` | Guardian only | Emergency stop |

**Token Tracking:**
- Vault maintains an `EnumerableSet.AddressSet heldTokens` updated by `executeSwap()`
- When swapping into a new token, it's added to `heldTokens`
- When a token balance reaches zero, it's removed from `heldTokens`
- `totalAssets()` iterates `heldTokens` to sum mark-to-market values
- Whitelist is expected to be small (5-10 tokens max) so gas is manageable

**NAV Calculation:**
- `totalAssets()` sums USDC balance + mark-to-market of all tokens in `heldTokens`
- Token pricing via Uniswap V3 TWAP oracle with a **30-minute observation window** (manipulation-resistant)
- Requires `v3-core` and `v3-periphery` Foundry dependencies: `forge install uniswap/v3-core uniswap/v3-periphery`
- Uses `OracleLibrary.consult()` from v3-periphery to read TWAP from Uniswap V3 pools on Base
- No external oracle dependency — everything reads from on-chain Uniswap pool state

**What the agent CAN do:**
- Swap approved tokens via Uniswap within size/slippage limits
- Read vault state and balances

**What the agent CANNOT do:**
- Transfer USDC or tokens to any arbitrary address
- Swap unapproved tokens
- Exceed daily volume cap
- Trade when paused
- Change its own permissions

**Design Decisions:**

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Vault standard | ERC-4626 | Standard interface, composable, wallet support out of the box |
| Swap router | Uniswap V3 SwapRouter02 (`0x2626664c2603336E57B271c5C0b26F421741e481` on Base) | Simpler ABI (`exactInputSingle`), deepest Base liquidity, avoids Universal Router command encoding complexity |
| NAV pricing | Uniswap V3 TWAP oracle | On-chain, manipulation-resistant, no external dependency |
| Token whitelist | Guardian-managed | Human controls what agent can trade — core "scoped permissions" |
| Emergency stop | Guardian pause | Human always has the kill switch |
| Share token | Built into ERC-4626 | Depositors get transferable ERC-20 shares |

### Component 2: Go Agent Runtime (off-chain)

Reuses patterns from the existing `agent-prediction` codebase. Simplified for Uniswap DeFi trading.

**Core loop (every 5 minutes):**
1. Read vault state (holdings, USDC balance, NAV)
2. Fetch market data (token prices, volume, momentum)
3. LLM analysis: "Given these holdings and market conditions, should I swap? What and why?"
4. Risk filter: check against limits (max position, concentration, drawdown)
5. If signal passes → build Uniswap swap tx → call `vault.executeSwap()`
6. Trade rationale is captured in the vault's `SwapExecuted` event (emitted on every swap with tokenIn, tokenOut, amounts, and a `bytes reason` field). This is the on-chain audit trail — indexed and visible on Basescan without any external storage dependency.

**Strategy (simple for hackathon):**
- Momentum/mean-reversion on a small set of Base tokens (ETH, USDC, cbBTC, 2-3 others)
- LLM decides direction and sizing based on price action + news sentiment
- Not a quant fund — demonstrating the custody model works

**Reused from existing code:**
- `risk.Manager` pattern (position limits, drawdown halt, daily loss limit)
- Strategy interface (`Name()`, `Evaluate()`)
- Execution loop structure (fetch → analyze → filter → execute)
- Config pattern with sensible defaults

**New code:**
- Uniswap V3 SwapRouter02 integration — agent builds `exactInputSingle` calldata and submits via `vault.executeSwap()`
- go-ethereum vault bindings (generated from Vault.sol ABI via `abigen`)
- Trade rationale passed as `bytes reason` parameter to `executeSwap()`, emitted in vault event

**Uniswap integration path:**
- The vault calls Uniswap V3 SwapRouter02 directly on-chain (address `0x2626664c2603336E57B271c5C0b26F421741e481` on Base)
- The Go agent uses the Uniswap Trading API (`trade-api.gateway.uniswap.org/v1/`) for off-chain quote/routing, then builds the on-chain swap parameters
- Endpoints: `check_approval` → `quote` → build `executeSwap()` tx
- **Dev tooling note:** Uniswap Claude Code plugin (`/plugin install uniswap-trading`) can assist during development but is not a runtime dependency

### Component 3: ERC-8004 Identity (Base)

- Agent registers via Synthesis API (`POST https://synthesis.devfolio.co/register`)
- Required fields: `name`, `description`, `agentHarness: "claude-code"`, `model`, `humanInfo` (see `docs/2026_requirements/synthesis/api-reference.md` for full schema)
- Registration returns `participantId`, `teamId`, `apiKey` (format: `sk-synth-...`), and `registrationTxn` (Base mainnet ERC-8004 NFT mint)
- Agent wallet from the ERC-8004 NFT is set to the same address used as the vault's authorized `agent` role
- Depositors can leave reputation feedback via the ERC-8004 feedback registry

### Component 4: Observer (minimal)

- CLI or minimal Next.js page — whatever ships fastest
- Shows: vault USDC balance, held token positions, share price/NAV, recent trades with rationale, agent ERC-8004 identity link
- This is the cut-line item — if it threatens the core, ship without it

---

## Demo Flow

1. **Agent registers** — ERC-8004 identity minted on Base, visible on Basescan
2. **Human deposits** — 100 USDC into vault, receives share tokens
3. **Agent trades** — makes 2-3 Uniswap swaps autonomously within boundaries
4. **Audit trail** — every trade visible on-chain via vault `SwapExecuted` events with rationale in the `reason` field
5. **Boundary enforcement** — show agent CANNOT exceed limits (rejected swap)
6. **Exit at NAV** — burn shares, receive USDC back at current vault value

**Story arc:** Trust through constraint. The agent is powerful but the human never loses control.

---

## Build Sequence

Ordered by dependency, not time:

1. **Vault.sol** — ERC-4626 + agent swap constraints + guardian controls
2. **Vault tests** — deposit/redeem, swap enforcement, boundary rejection, NAV calculation
3. **Deploy vault to Base Sepolia**
4. **Go agent scaffold** — config, vault bindings from ABI, execution loop skeleton
5. **Uniswap integration** — quote → swap calldata → vault.executeSwap()
6. **LLM strategy** — market analysis, swap decisions, rationale generation
7. **Risk manager** — position limits, drawdown halt, daily volume cap
8. **ERC-8004 registration** — mint agent identity, post metadata
9. **End-to-end integration on testnet** — agent trading through vault
10. **Security checkpoint** — manual review of vault boundaries, role assignments, and swap constraints before mainnet
11. **Base mainnet deployment** — real trades with real USDC
12. **Observer** (CLI or minimal UI) — vault state, trade history, NAV
13. **Submission** — docs, conversation logs, demo recording

**Cut line:** Steps 1-11 are the minimum viable submission. Steps 12-13 are polish.

---

## Submission Requirements Checklist

- [ ] Deployed vault contract on Base (verified on Basescan)
- [ ] ERC-8004 agent identity on Base
- [ ] Open source repository
- [ ] Conversation logs (human-agent collaboration, required by Synthesis)
- [ ] Working demo (live session or recorded walkthrough)
- [ ] Agent registered via Synthesis API with `agentHarness: "claude-code"`
- [ ] On-chain artifacts (vault address, agent NFT, trade tx hashes)

---

## Technical Stack

| Layer | Technology |
|-------|------------|
| Vault contracts | Solidity, Foundry, ERC-4626 |
| Chain | Base (mainnet + Sepolia testnet) |
| Swap infrastructure | Uniswap V3 SwapRouter02, Trading API |
| NAV oracle | Uniswap V3 TWAP |
| Agent runtime | Go |
| LLM | Claude (via Anthropic API) |
| Vault bindings | go-ethereum, abigen |
| Agent identity | ERC-8004 (Base) |
| Testing | Foundry (Solidity), Go test |
| Observer | CLI (minimum) or Next.js (stretch) |

---

## What We DON'T Build

- Fancy UI (CLI is fine)
- Complex quant strategy (simple momentum is enough)
- Multiple agents (one agent, one vault, clean demo)
- Cross-chain anything (Base only)
- Custom oracle infrastructure (Uniswap TWAP is sufficient)
- Token launch / tokenomics (not relevant to this submission)
