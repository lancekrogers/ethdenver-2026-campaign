# Evidence Manifest — Grant Submission GS0003

**Generated:** 2026-03-11
**Campaign:** ethdenver2026 / Obey Agent Economy

---

## Hedera Testnet

**Mirror Node:** https://testnet.mirrornode.hedera.com

### Accounts

| Account | Role | Txs | Explorer |
|---------|------|-----|----------|
| `0.0.7974114` | Coordinator | 24+ | [mirror](https://testnet.mirrornode.hedera.com/api/v1/transactions?account.id=0.0.7974114&limit=25&order=desc) |
| `0.0.7984825` | Inference Agent | 25+ | [mirror](https://testnet.mirrornode.hedera.com/api/v1/transactions?account.id=0.0.7984825&limit=25&order=desc) |
| `0.0.7985425` | DeFi Agent | 24+ | [mirror](https://testnet.mirrornode.hedera.com/api/v1/transactions?account.id=0.0.7985425&limit=25&order=desc) |

### HCS Topics

| Topic | Purpose |
|-------|---------|
| `0.0.7999404` | Task assignment messages |
| `0.0.7999405` | Status reporting messages |

### Token

| Token ID | Purpose |
|----------|---------|
| `0.0.7999406` | Agent economy payment token (coordinator → agents) |

### Verified Transaction Types

- **CONSENSUSSUBMITMESSAGE** — HCS task assignment and status reporting (70+ messages)
- **CRYPTOTRANSFER** — Token `0.0.7999406` transfers (100 units coordinator → defi agent)
- **SCHEDULECREATE** — Scheduled payment operations

---

## 0G Galileo (Chain ID 16602)

**Wallet:** `0x38CB2E2eeb45E6F70D267053DcE3815869a8C44d`
**Explorer:** https://chainscan.0g.ai
**Nonce:** 4 (4 transactions confirmed)

### Contract Deployments

| # | Contract | Tx Hash | Contract Address | Status |
|---|----------|---------|------------------|--------|
| 1 | ReputationDecay | `0x5a028b3fafd2179c3a453dd3f12b0cead16d86e3810e76b4776478dc06350c58` | `0xbdCdBfd93C4341DfE3408900A830CBB0560a62C4` | Verified |
| 2 | AgentSettlement | `0x30f03a1777ab8bb0c106260891ec69eb0c0226eaf9243b0456552825698ed89b` | `0x437c2bF7a00Da07983bc1eCaa872d9E2B27A3d40` | Verified |
| 3 | AgentINFT (ERC-7857) | `0x929d4a74fd6a25ed34e1762181ba842edfa20f76b476a6adc1290db5175a88f4` | `0x17F41075454cf268D0672dd24EFBeA29EF2Dc05b` | Verified |

### 0G System Contracts Used

| Service | Contract Address |
|---------|-----------------|
| Compute (InferenceServing) | `0xa79F4c8311FF93C06b8CfB403690cc987c93F91E` |
| Storage (Flow) | `0x22E03a6A89B950F1c82ec5e74F8eCa321a105296` |
| Data Availability (DA Entrance) | `0xE75A073dA5bb7b0eC622170Fd268f35E675a957B` |

---

## Base Sepolia (Chain ID 84532)

**Wallet:** `0xc71d8a19422c649fe9bdcbf3ffa536326c82b58b`
**Explorer:** https://sepolia.basescan.org
**Nonce:** 5 (5 transactions confirmed)
**Balance:** 0.4999 ETH

### Contract Deployments

| # | Contract | Tx Hash | Contract Address | Status |
|---|----------|---------|------------------|--------|
| 1 | AgentIdentityRegistry (ERC-8004) | `0x21c52923db732f0b79e0488c8af64fb26fae07b4fd843b8400f9cf7ef872b739` | `0x0C97820abBdD2562645DaE92D35eD581266CCe70` | Verified |
| 2 | AgentSettlement | `0xa52f45a1d4fd1347512da079340f3699f4e7cee7e286e9d46445bb7856d6f8fe` | `0xa5378FbDCD2799C549A559C1C7c1F91D7C983A44` | Verified |
| 3 | ReputationDecay | `0xbb0b9a2b8fc0dedf5c811e89a8e34e73531c9c077d5c3b11e711f2fb0aa1f97e` | `0x54734cC3AF4Db984cD827f967BaF6C64DEAEd0B1` | Verified |
| 4 | AgentINFT (ERC-7857) | `0x653d47b30ebc91f870ea302103b743cd7f30a722649b1af67ebe8a9e40af9c92` | `0xfcA344515D72a05232DF168C1eA13Be22383cCB6` | Verified |

### Agent Operations

| # | Operation | Tx Hash | Status |
|---|-----------|---------|--------|
| 5 | ERC-8004 identity registration (defi-001) | `0x9b31bd785dd7b12649d9d12379546c268aea1da6e0060777bed6276cf8e4002a` | Verified |

### Funding

| Source | Method | Tx Hash |
|--------|--------|---------|
| Ethereum Sepolia → Base Sepolia | L1StandardBridge `depositETH` | `0xfebaae44845667ac09c39b19db4a2b259d85881274e70c3ca41f79245a4cad2c` ([etherscan](https://sepolia.etherscan.io/tx/0xfebaae44845667ac09c39b19db4a2b259d85881274e70c3ca41f79245a4cad2c)) |

---

## Ethereum Sepolia (Chain ID 11155111)

**Wallet:** `0xc71d8a19422c649fe9bdcbf3ffa536326c82b58b`
**Explorer:** https://sepolia.etherscan.io

### CRE Risk Router

| # | Operation | Tx Hash | Status |
|---|-----------|---------|--------|
| 1 | CRE risk evaluation tx | `0xea6784a79fd108cfb4fc07127ab19b2c9f2a90867fcccc47b339e685fe3169c4` | [Verified](https://sepolia.etherscan.io/tx/0xea6784a79fd108cfb4fc07127ab19b2c9f2a90867fcccc47b339e685fe3169c4) |
| 2 | CRE risk evaluation tx | `0x0c72922fd8e31f859dc5ce30364d87e86c939f7c2a2282899db11b65242dabd1` | [Verified](https://sepolia.etherscan.io/tx/0x0c72922fd8e31f859dc5ce30364d87e86c939f7c2a2282899db11b65242dabd1) |

---

## Summary

| Chain | Transactions | Contracts Deployed | Agent Operations |
|-------|-------------|-------------------|------------------|
| Hedera Testnet | 70+ | — (native services) | HCS messaging, token transfers, scheduling |
| 0G Galileo | 3 | 3 (Settlement, Reputation, iNFT) | Contract deployment |
| Base Sepolia | 5 | 4 (Settlement, Reputation, iNFT, Identity) | ERC-8004 identity registration |
| Ethereum Sepolia | 2+ | CRE Risk Router | Risk evaluation with DON consensus |

**Total on-chain transactions across 4 chains: 80+**
