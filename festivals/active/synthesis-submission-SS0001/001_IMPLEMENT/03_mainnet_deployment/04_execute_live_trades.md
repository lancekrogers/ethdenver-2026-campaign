---
fest_type: task
fest_id: 04_execute_live_trades.md
fest_name: execute live trades
fest_parent: 03_mainnet_deployment
fest_order: 4
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-16T21:39:47.509822-06:00
fest_updated: 2026-03-17T00:16:17.408216-06:00
fest_tracking: true
---


# Task: Execute 2-3 Live Uniswap Trades via Vault

## Objective

Execute 2-3 real Uniswap V3 swaps on Base mainnet through the ObeyVault to produce verifiable on-chain trade evidence.

## Requirements

- [ ] Execute at least 2 swaps through vault.executeSwap() on Base mainnet
- [ ] Include both buy (USDC -> WETH) and sell (WETH -> USDC) directions
- [ ] Each swap must emit SwapExecuted events with encoded rationale
- [ ] All swaps must respect vault boundaries

## Implementation

1. Use the agent-defi Go agent or cast/forge to execute swaps through the vault
2. Trade 1 -- Buy WETH:
   - Amount: 20 USDC
   - Direction: USDC -> WETH via Uniswap V3
   - Rationale: "Mean reversion signal -- WETH deviated from 30-period MA"
3. Trade 2 -- Sell WETH:
   - Amount: sell portion of acquired WETH
   - Direction: WETH -> USDC via Uniswap V3
   - Rationale: "Take profit -- target price reached"
4. Trade 3 (optional) -- Buy WETH:
   - Amount: 15 USDC
   - Direction: USDC -> WETH
   - Rationale: "DCA entry -- scheduled position building"
5. For each trade:
   - Get quote from Uniswap Developer Platform API
   - Submit executeSwap() transaction through vault
   - Wait for confirmation
   - Record TxID
6. Use small amounts (20-25 USDC) to minimize trading losses

## Done When

- [ ] All requirements met
- [ ] 2-3 swaps executed on Base mainnet via vault
- [ ] SwapExecuted events emitted for each trade
- [ ] All TxIDs recorded
- [ ] Vault boundaries were respected (no boundary violations)