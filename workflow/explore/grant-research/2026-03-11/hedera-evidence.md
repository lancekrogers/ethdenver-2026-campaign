# Hedera On-Chain Evidence Audit

> Track: External Proof. Use evidence-backed wording only.

**Date:** 2026-03-11
**Verdict:** CONFIRMED — Real transactions verified on Hedera Testnet via mirror node API.

---

## Verified Accounts

| Account | Role | Balance | Token Balance | Txs |
|---------|------|---------|---------------|-----|
| `0.0.7974114` | Coordinator | 251,894 HBAR | 998,200 of `0.0.7999406` | 24+ |
| `0.0.7984825` | Agent (inference) | ~84.7 HBAR | 0 of `0.0.7999406` | 25+ |
| `0.0.7985425` | Agent (defi) | ~97.7 HBAR | 1,800 of `0.0.7999406` | 24+ |

## HCS Topics

| Topic | Purpose |
|-------|---------|
| `0.0.7999404` | Task messages |
| `0.0.7999405` | Status messages |

## Token

| Token ID | Purpose |
|----------|---------|
| `0.0.7999406` | Agent economy token |

## Verified Transaction Types

### Coordinator (`0.0.7974114`)
- **CONSENSUSSUBMITMESSAGE** to `0.0.7999404` — task assignment via HCS
- **CRYPTOTRANSFER** — token `0.0.7999406` transfers (100 units to `0.0.7985425`)
- **SCHEDULECREATE** — multiple scheduled operations
- Failed scheduled CRYPTOTRANSFERs (INSUFFICIENT_TX_FEE) — evidence of real usage

### Inference Agent (`0.0.7984825`)
- **25+ CONSENSUSSUBMITMESSAGE** to `0.0.7999405` — status reporting via HCS
- EVM Address: `0x38CB2E2eeb45E6F70D267053DcE3815869a8C44d`

### DeFi Agent (`0.0.7985425`)
- **24+ CONSENSUSSUBMITMESSAGE** to `0.0.7999405` — status reporting via HCS
- **CRYPTOTRANSFER** — received 100 token units from coordinator
- EVM Address: `0xc71d8a19422c649fe9bdcbf3ffa536326c82b58b`

## Mirror Node Links

- Coordinator: `https://testnet.mirrornode.hedera.com/api/v1/accounts/0.0.7974114`
- Inference Agent: `https://testnet.mirrornode.hedera.com/api/v1/accounts/0.0.7984825`
- DeFi Agent: `https://testnet.mirrornode.hedera.com/api/v1/accounts/0.0.7985425`
- Coordinator Txs: `https://testnet.mirrornode.hedera.com/api/v1/transactions?account.id=0.0.7974114&limit=25&order=desc`

## Evidence Quality

- All transactions verified via Hedera mirror node REST API (not just claimed from logs)
- Transaction types are WRITE operations (consensus messages, token transfers)
- Multiple accounts interacting demonstrates multi-agent coordination
- Token transfers between accounts demonstrate the agent economy model
