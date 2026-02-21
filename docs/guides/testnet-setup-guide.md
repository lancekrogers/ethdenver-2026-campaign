# Testnet Setup Guide — Three-Agent Integration Test

Blocked task: `001_IMPLEMENT/03_integration_verify/02_three_agent_cycle.md`

The integration test requires **three separate Hedera testnet accounts** (one per agent), **0G Galileo testnet credentials**, and a **funded Base Sepolia wallet**. This guide covers exactly what to set up, with env var names matching the actual code.

---

## 1. Hedera Testnet — 3 Accounts

The coordinator uses the `hiero-sdk-go` and expects three separate Hedera accounts. See `projects/agent-coordinator/internal/integration/testnet.go`:

```
HEDERA_COORDINATOR_ACCOUNT_ID  →  hiero.AccountIDFromString()
HEDERA_COORDINATOR_PRIVATE_KEY →  hiero.PrivateKeyFromString()
HEDERA_AGENT1_ACCOUNT_ID
HEDERA_AGENT1_PRIVATE_KEY
HEDERA_AGENT2_ACCOUNT_ID
HEDERA_AGENT2_PRIVATE_KEY
HEDERA_NETWORK=testnet
```

Both child agents also read generic Hedera vars from their `.env.example` files:

```
HEDERA_ACCOUNT_ID=0.0.xxx
HEDERA_PRIVATE_KEY=
```

### Setup Steps

1. Go to [portal.hedera.com](https://portal.hedera.com)
2. Create **3 testnet accounts** (coordinator, inference agent, defi agent)
3. Each account comes with a funded HBAR balance on testnet
4. Record the Account ID (format `0.0.NNNNN`) and ED25519 private key (DER hex string `302e...`) for each

### Additional Hedera Resources Needed

The coordinator config (`internal/coordinator/config.go`) also requires:

- **TaskTopicID** — an HCS topic for task assignments/results
- **StatusTopicID** — an HCS topic for agent health updates
- **PaymentTokenID** — an HTS fungible token for agent payments
- **TreasuryAccountID** — the account that holds the payment token supply

These will need to be created on testnet using the coordinator account. The coordinator may have a setup command, or you can create them via the Hedera SDK / HashScan.

---

## 2. 0G Galileo Testnet — Inference Agent

From `projects/agent-inference/internal/agent/config.go`:

```
# Required
INFERENCE_AGENT_ID=inference-001
ZG_COMPUTE_ENDPOINT=        # 0G Compute API endpoint
ZG_STORAGE_ENDPOINT=        # 0G Storage API endpoint
ZG_DA_ENDPOINT=             # 0G DA endpoint
ZG_INFT_CONTRACT=           # iNFT contract address on 0G Chain
ZG_CHAIN_PRIVATE_KEY=       # private key for 0G Chain transactions

# Optional (have defaults)
INFERENCE_DAEMON_ADDR=localhost:9090
INFERENCE_HEALTH_INTERVAL=30s
ZG_CHAIN_RPC=https://evmrpc-testnet.0g.ai   # default
ZG_DA_NAMESPACE=inference-audit              # default
ZG_ENCRYPTION_KEY_ID=default                 # default
ZG_ENCRYPTION_KEY=                           # hex-encoded AES key for iNFT encryption
```

### HCS topics (shared with coordinator)

```
HCS_TASK_TOPIC=             # same topic ID the coordinator publishes to
HCS_RESULT_TOPIC=           # same topic ID the coordinator reads from
```

### Setup Steps

1. Go to [faucet.0g.ai](https://faucet.0g.ai) — get testnet A0GI tokens for the wallet
2. Chain: Galileo testnet, Chain ID `16602`, RPC `https://evmrpc-testnet.0g.ai`
3. Check [0G docs](https://docs.0g.ai) for Compute, Storage, and DA endpoint URLs
4. You may need to deploy or find an existing iNFT (ERC-7857) contract on 0G testnet for `ZG_INFT_CONTRACT`

---

## 3. Base Sepolia — DeFi Agent

From `projects/agent-defi/internal/agent/config.go`:

```
# Required
DEFI_AGENT_ID=defi-001
DEFI_PRIVATE_KEY=           # wallet private key (used for identity, payment, and trading)
DEFI_WALLET_ADDRESS=        # wallet address derived from DEFI_PRIVATE_KEY
DEFI_ERC8004_CONTRACT=      # ERC-8004 identity registry address on Base Sepolia

# Optional (have defaults)
DEFI_DAEMON_ADDR=localhost:9090
DEFI_TRADING_INTERVAL=60s
DEFI_PNL_REPORT_INTERVAL=5m
DEFI_HEALTH_INTERVAL=30s
DEFI_BASE_RPC_URL=https://sepolia.base.org   # default
DEFI_DEX_ROUTER=0x0000000000000000000000000000000000000000  # default (needs real Uniswap V3 router)
DEFI_BUILDER_CODE=          # ERC-8021 builder code (20+ chars)
DEFI_ATTRIBUTION_ENABLED=true   # default
DEFI_TOKEN_IN=0x036CbD53842c5426634e7929541eC2318f3dCF7e   # USDC on Base Sepolia (default)
DEFI_TOKEN_OUT=0x4200000000000000000000000000000000000006   # WETH on Base Sepolia (default)
```

### HCS topics (shared with coordinator)

```
HCS_TASK_TOPIC=             # same as coordinator
HCS_RESULT_TOPIC=           # same as coordinator
```

### Setup Steps

1. Generate a wallet (or reuse one of the Hedera agent keys if compatible)
2. Get Base Sepolia ETH:
   - Option A: Get Sepolia ETH from [faucets.chain.link](https://faucets.chain.link) or Alchemy faucet, then bridge via [bridge.base.org](https://bridge.base.org)
   - Option B: Use a Base Sepolia faucet directly if available
3. Chain: Base Sepolia, Chain ID `84532`, RPC `https://sepolia.base.org`
4. The ERC-8004 registry address — check if there's a known deployment or if you need to deploy the contract from `projects/contracts/`
5. For `DEFI_DEX_ROUTER`, you need the Uniswap V3 SwapRouter address on Base Sepolia

---

## 4. Checklist

| Item                                                  | Status |
| ----------------------------------------------------- | ------ |
| Hedera testnet account #1 (coordinator)               |        |
| Hedera testnet account #2 (inference agent)           |        |
| Hedera testnet account #3 (defi agent)                |        |
| HCS task topic created                                |        |
| HCS status topic created                              |        |
| HTS payment token created                             |        |
| 0G Galileo wallet funded with A0GI                    |        |
| 0G Compute/Storage/DA endpoints confirmed             |        |
| 0G iNFT contract address                              |        |
| Base Sepolia wallet funded with ETH                   |        |
| ERC-8004 contract deployed/found on Base Sepolia      |        |
| Uniswap V3 router address on Base Sepolia             |        |
| `.env` files created for all 3 agents (not committed) |        |
