# Agents With Receipts — OBEY Vault Agent

Every decision has a receipt. Every receipt builds reputation. Every reputation is verifiable on-chain.

## On-Chain Identity

The OBEY Vault Agent has a persistent, portable identity registered via ERC-8004 on Base (tx: `0x9b31bd785dd7b12649d9d12379546c268aea1da6e0060777bed6276cf8e4002a`). This isn't a throwaway address — it's a registry entry that follows the agent across platforms and interactions. Any system can query the agent's identity contract at `0x0C97820abBdD2562645DaE92D35eD581266CCe70` to verify who it is, what it does, and what tools it supports.

## Verifiable Receipts

Every vault swap emits a `SwapExecuted(tokenIn, tokenOut, amountIn, amountOut, reason)` event on-chain. The `reason` field is the critical differentiator — it contains the agent's encoded rationale, not just what happened but WHY. Anyone can inspect a trade on Basescan and see not only the token amounts but the decision context that led to execution. These aren't retroactive explanations; they're committed at transaction time.

## Trust Model

OBEY implements a guardian/agent trust separation enforced at the contract level. The guardian (human operator) sets boundaries: which tokens are approved, maximum swap size, daily volume caps, slippage tolerances. The agent operates freely within those boundaries. The separation is structural — the agent role can ONLY call `executeSwap()`. It cannot modify its own limits, pause the vault, approve new tokens, or change its own address. The guardian can pause operations, update limits, or replace the agent at any time. Trust is granted within bounds, not assumed wholesale.

## Reputation Accumulation

Each trade creates a verifiable record: pre-trade analysis (CRE 8-gate evaluation, confidence score, deviation percentage), execution (on-chain swap with reason), and post-trade verification (actual fill vs. expected, slippage measurement). Over time, these receipts accumulate into a queryable track record. Other agents or protocols can assess: how many trades has this agent executed? What's its accuracy against pre-trade predictions? What risk profile does it maintain? The ERC-8004 identity anchors this history to a single, verifiable entity.

## Structured Proof

`agent_log.json` provides the complete reasoning chain for every decision. Not just "bought WETH" but "price deviated -2.3% from 30-period SMA, confidence 0.72, 7/8 CRE gates passed (signal_confidence at 0.525 below 0.6 threshold), estimated net profit $12.50, executed 20 USDC → 0.0062 WETH, actual slippage 15bps within 100bps tolerance." Every step from observation to action to verification is documented, timestamped, and machine-readable.

## Evidence

- ERC-8004 registration transaction on Base Sepolia
- `SwapExecuted` events with encoded `reason` field
- `agent_log.json` with full reasoning chains per decision
- Guardian/agent role separation in `ObeyVault.sol` contract
- `agent.json` manifest with identity, tools, and constraints
