# How Do You Trust an AI Agent With Your Money?

Today's agent-wallet integrations are black boxes. You can see on-chain *what* happened, but never *why*. There's no structured audit trail of agent reasoning, no quality gates before irreversible financial actions, and no way to build verifiable reputation across agents.

**OBEY solves this with three innovations:**

## 1. Human-Controlled Boundaries (ObeyVault)

An ERC-4626 vault where humans deposit USDC and set enforceable spending boundaries at the contract level. The agent can trade but never touch principal beyond what boundaries allow.

- Token whitelist, max swap size, daily volume cap, slippage limits
- Agent can ONLY call `executeSwap()` — cannot transfer, modify limits, or bypass guards
- Every swap emits `SwapExecuted(tokenIn, tokenOut, amountIn, amountOut, reason)` — rationale stored on-chain

## 2. Structured Decision Framework (Festival Methodology)

Every trading decision follows a discover→plan→execute→verify loop:

- **Discover**: Query Uniswap V3 pools for price, volume, liquidity
- **Plan**: Evaluate 8 CRE risk gates (liquidity, volatility, confidence, drawdown, correlation, gas, profit threshold, concentration)
- **Execute**: Vault-enforced swap with on-chain reason field
- **Verify**: Compare actual fill vs. expected, measure slippage

NO_GO decisions (agent choosing NOT to trade) demonstrate judgment, not just execution.

## 3. Verifiable Identity (ERC-8004)

The agent has a persistent, portable on-chain identity. Every trade builds a queryable track record: how many trades, what accuracy, what risk profile. Other agents or protocols can verify this before delegating tasks.

## On-Chain Evidence

- **80+ verified transactions** across Hedera, 0G, Base Sepolia, and Ethereum Sepolia
- ObeyVault deployed with real Uniswap V3 swaps
- ERC-8004 identity registered on Base
- CRE risk evaluations recorded on Ethereum Sepolia
- AgentIdentityRegistry deployed on Status Network Sepolia (gasless)

## Tech Stack

- **Go agents** orchestrated by the `obey` daemon
- **Solidity contracts** (Foundry) — ObeyVault, AgentIdentityRegistry, AgentSettlement, ReputationDecay
- **Festival Methodology** (`fest` CLI) for structured human-AI collaborative planning
- **Uniswap V3** for DEX trading on Base
- **Hedera Consensus Service** for immutable inter-agent messaging
- **ERC-8004** for agent identity, **ERC-8021** for builder attribution, **x402** for autonomous payments

## Links

- **GitHub**: [obey-agent-economy](https://github.com/obedience-corp/obey-agent-economy)
- **agent.json**: Machine-readable capability manifest (Protocol Labs DevSpot format)
- **agent_log.json**: Structured execution log with full reasoning chains

## Built With

- [obey](https://github.com/obedience-corp/obey) — Agent daemon for session orchestration
- [fest](https://github.com/obedience-corp/fest) — Festival methodology CLI
- [camp](https://github.com/obedience-corp/camp) — Campaign CLI for multi-project management

---

*OBEY: Verifiable Agent Autonomy. Every decision has a receipt. Every receipt builds reputation.*
