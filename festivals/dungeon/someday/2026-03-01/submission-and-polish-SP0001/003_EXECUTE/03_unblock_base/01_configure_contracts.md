---
fest_type: task
fest_id: 01_configure_contracts.md
fest_name: configure_contracts
fest_parent: 03_unblock_base
fest_order: 1
fest_status: pending
fest_autonomy: high
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Configure Contracts

## Objective

Set the known Base Sepolia contract addresses in `projects/agent-defi/.env` so the agent targets the correct on-chain deployments for all subsequent tasks in this sequence.

## Context

The contract addresses are already deployed and verified on Base Sepolia. Nothing needs to be deployed. The only work here is ensuring the environment file has the correct values so `executor.go` and `register.go` load them at startup.

## Contract Addresses

| Variable | Address | Contract |
|----------|---------|---------|
| `DEFI_DEX_ROUTER` | `0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4` | Uniswap V3 SwapRouter02 |
| `DEFI_ERC8004_CONTRACT` | `0x8004A818BFB912233c491871b3d84c89A494BD9e` | ERC-8004 IdentityRegistry |
| `DEFI_BUILDER_CODE` | `<agent-wallet-address>` | Agent wallet address (builder attribution) |

The QuoterV2 address (`0xC5290058841028F1614F3A6F0F5816cAd0df5E27`) should also be added as `DEFI_QUOTER_V2` if that variable does not already exist.

## Implementation Steps

1. Open `projects/agent-defi/.env` (or `.env.example` if `.env` does not exist — copy it first).

2. Set or update the following values:
   ```
   DEFI_DEX_ROUTER=0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4
   DEFI_ERC8004_CONTRACT=0x8004A818BFB912233c491871b3d84c89A494BD9e
   DEFI_QUOTER_V2=0xC5290058841028F1614F3A6F0F5816cAd0df5E27
   DEFI_BUILDER_CODE=<agent-wallet-address>
   ```
   Replace `<agent-wallet-address>` with the actual address of the DeFi agent's hot wallet (the same address that will be funded in task 04).

3. Confirm `BASE_SEPOLIA_RPC_URL` is set to a working Base Sepolia RPC endpoint. If it is missing or blank, add one (e.g., the public Alchemy or Infura Base Sepolia endpoint).

4. Confirm `BASE_CHAIN_ID` is set to `84532` (Base Sepolia chain ID).

5. Verify `.env` is listed in `.gitignore` and will not be committed.

## Done When

- `DEFI_DEX_ROUTER`, `DEFI_ERC8004_CONTRACT`, `DEFI_QUOTER_V2`, and `DEFI_BUILDER_CODE` are all set with correct values in `projects/agent-defi/.env`
- `BASE_SEPOLIA_RPC_URL` points to a live endpoint
- `.env` is gitignored
