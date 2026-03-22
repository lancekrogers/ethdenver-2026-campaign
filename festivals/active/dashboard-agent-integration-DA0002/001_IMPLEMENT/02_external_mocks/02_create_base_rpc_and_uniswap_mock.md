---
fest_type: task
fest_id: 01_create_base_rpc_and_uniswap_mock.md
fest_name: create base rpc and uniswap mock
fest_parent: 02_external_mocks
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.12355-06:00
fest_updated: 2026-03-22T16:20:47.539013-06:00
fest_tracking: true
---


# Task: Create Base RPC and Uniswap Mock

## Objective

Create mock implementations for Base Sepolia RPC and Uniswap V3 pool queries so agent-defi can run its trading loop in demo mode with realistic but simulated market data.

## Requirements

- [ ] Mock ethclient that returns simulated block numbers, balances, and gas prices
- [ ] Mock Uniswap V3 pool query that returns realistic WETH/USDC prices with random walk
- [ ] Mock vault contract interaction that simulates swap execution and emits events
- [ ] Toggled by DEFI_MOCK_MODE=true (already exists in docker-compose)

## Implementation

1. Read `projects/agent-defi/internal/base/` to understand the existing ethclient usage
2. Create mock implementations behind the same interfaces
3. The mock pool should maintain a price state with mean-reversion random walk (same pattern as existing synthetic-events.ts but in Go)
4. Mock vault swap should return realistic amounts based on the mock pool price
5. All mock implementations go in an `internal/mock/` package or alongside the real implementations with build tags/interface switching

## Done When

- [ ] All requirements met
- [ ] Agent-defi trading loop runs continuously with DEFI_MOCK_MODE=true
- [ ] Mock produces realistic trade events (varying prices, occasional losses)
- [ ] No network calls to Base Sepolia RPC in mock mode