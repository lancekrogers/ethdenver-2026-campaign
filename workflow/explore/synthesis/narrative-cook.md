# Let the Agent Cook — OBEY Vault Agent

OBEY is an autonomous agent that doesn't just trade — it follows a structured decision framework with built-in safety rails, and every decision is auditable.

## The Autonomous Loop

The agent operates on a discover→plan→execute→verify loop driven by the Festival Methodology. Each trading cycle begins with a research ritual (RI-AM0001) that ingests live market data from Uniswap V3 pools, analyzes price deviation against a 30-period simple moving average, runs 8 CRE risk gates, and produces a structured GO/NO_GO decision — all without human intervention. The agent doesn't blindly execute; it exercises judgment. A NO_GO decision with strong rationale is just as valuable as a profitable trade.

## Multi-Tool Orchestration

In a single trading cycle, the agent orchestrates calls across four distinct systems: Uniswap V3 pool contracts for real-time price and liquidity data, the Uniswap Developer Platform API for optimal quote routing, the CRE Risk Router for 8-gate pre-trade evaluation (liquidity depth, volatility, signal confidence, drawdown risk, correlation, gas efficiency, net profit threshold, and position concentration), and the ObeyVault contract for boundary-enforced swap execution. Every tool call, every intermediate result, and every decision is logged in `agent_log.json` with timestamps and reasoning.

## Safety Guardrails

The vault contract enforces spending boundaries at the EVM level — not as suggestions the agent might ignore, but as immutable constraints. The token whitelist prevents trading unauthorized assets. Max swap size and daily volume caps limit exposure. Slippage limits protect against adverse fills. The CRE Risk Router adds 8 additional pre-trade gates that must pass before execution proceeds. The agent physically cannot violate these constraints, regardless of what its strategy suggests.

## Compute Budget Awareness

The Festival Methodology operates on steps-to-completion, not time estimates. A research ritual completes its full discover→plan→execute→verify cycle in seconds. The agent's `compute_constraints` in `agent.json` define its operational envelope: 300-second max trading interval, $10K daily volume cap, $1K max swap size, 100bps max slippage, and 8 mandatory risk gates. These aren't aspirational — they're enforced.

## Evidence

- `agent.json` — machine-readable capability manifest
- `agent_log.json` — structured execution log with 3+ complete autonomous loop iterations
- `SwapExecuted` events on Base Sepolia — on-chain proof of execution
- Festival ritual structure — auditable decision framework in `festivals/ritual/agent-market-research-RI-AM0001/`
