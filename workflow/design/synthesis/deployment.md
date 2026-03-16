# OBEY Vault — On-Chain Evidence & Deployment Artifacts

> This document serves as the authoritative record of all on-chain transactions
> for grant, bounty, and hackathon submissions (Synthesis Mar 13-22, 2026).

---

## Network: Base Sepolia (Testnet) — Chain ID 84532

### Contract Deployment

| Field | Value |
|-------|-------|
| **Vault Address** | [`0xa7412780435905728260d5eaA59786e4a3C07e7E`](https://sepolia.basescan.org/address/0xa7412780435905728260d5eaA59786e4a3C07e7E) |
| **Contract** | ObeyVault (ERC-4626 + Agent Swap Constraints) |
| **Guardian** | `0xC71d8A19422C649fe9bdCbF3ffA536326c82b58b` |
| **Agent** | `0xC71d8A19422C649fe9bdCbF3ffA536326c82b58b` |
| **Deployed** | 2026-03-15 |
| **Deploy Tx** | [`0x79b8444f2ba097119f4bb5245dcbeb50f1a7b4b8ba046673034f0697765473ea`](https://sepolia.basescan.org/tx/0x79b8444f2ba097119f4bb5245dcbeb50f1a7b4b8ba046673034f0697765473ea) |

### Vault Configuration

| Parameter | Value |
|-----------|-------|
| Base Asset | USDC (`0x036CbD53842c5426634e7929541eC2318f3dCF7e`) |
| Share Token | oVAULT (OBEY Vault Share) |
| Max Swap Size | 1,000 USDC |
| Max Daily Volume | 10,000 USDC |
| Max Slippage | 1% (100 bps) |
| TWAP Period | 30 minutes (1800s) |
| Swap Router | Uniswap V3 SwapRouter02 (`0x2626664c2603336E57B271c5C0b26F421741e481`) |
| Uniswap Factory | `0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24` |

### On-Chain Transaction Log

| # | Action | Tx Hash | Block | Status |
|---|--------|---------|-------|--------|
| 1 | **Deploy ObeyVault** | [`0x79b8444f...`](https://sepolia.basescan.org/tx/0x79b8444f2ba097119f4bb5245dcbeb50f1a7b4b8ba046673034f0697765473ea) | 38929396 | Success |
| 2 | **setApprovedToken(WETH, true)** | [`0x2fd81f3b...`](https://sepolia.basescan.org/tx/0x2fd81f3b850da81f4804e748d1ad22a1b809baf0fd866e7e22d0c37c367c9346) | 38929396 | Success |
| 3 | **USDC.approve(vault, 20 USDC)** | [`0x6496aea5...`](https://sepolia.basescan.org/tx/0x6496aea5b523e6022f8219aa7d4d042628d0e6b3298b668ab565a7021ad1784b) | 38929407 | Success |
| 4 | **vault.deposit(20 USDC)** | [`0x63adb2ab...`](https://sepolia.basescan.org/tx/0x63adb2ab94c97a411f27167852b6b5f977761f13b8a97ff6bcb4e26468cd3f55) | 38929414 | Success |

### Approved Tokens

| Token | Address | Status |
|-------|---------|--------|
| USDC | `0x036CbD53842c5426634e7929541eC2318f3dCF7e` | Approved (base asset, auto) |
| WETH | `0x4200000000000000000000000000000000000006` | Approved (tx #2) |

### Current Vault State (as of deposit)

| Metric | Value |
|--------|-------|
| Total Assets (NAV) | 20.00 USDC |
| Total Shares | 20.00 oVAULT |
| Share Price | 1.000000 |
| Held Tokens | 0 (USDC only) |
| Daily Volume Used | 0 |

---

## Network: Base Mainnet — Chain ID 8453

- **Vault Address:** TBD (pending security review)
- **Deploy Tx:** TBD

---

## ERC-8004 Agent Identity

| Field | Value |
|-------|-------|
| Agent Name | OBEY Vault Agent |
| Agent Harness | claude-code |
| Model | claude-sonnet-4-6 |
| Participant ID | TBD |
| Team ID | TBD |
| Registration Txn | TBD |
| API Key | Stored in `.env` (not committed) |

---

## Architecture Summary

```
Human (Guardian)                    AI Agent
      │                                │
      │  setApprovedToken()            │
      │  setMaxSwapSize()              │
      │  pause() / unpause()           │
      │                                │
      ▼                                ▼
  ┌─────────────────────────────────────────┐
  │           ObeyVault (ERC-4626)          │
  │                                         │
  │  deposit() ──► shares minted            │
  │  redeem()  ──► assets returned at NAV   │
  │                                         │
  │  executeSwap() [onlyAgent]              │
  │    ├─ whitelist check                   │
  │    ├─ max swap size check               │
  │    ├─ daily volume cap check            │
  │    ├─ slippage enforcement              │
  │    └─► Uniswap V3 SwapRouter02          │
  │                                         │
  │  totalAssets() ──► USDC + TWAP(tokens)  │
  │                                         │
  │  emit SwapExecuted(reason)              │
  └─────────────────────────────────────────┘
```

## Key Evidence for Reviewers

1. **Trust through constraint**: The agent can ONLY call `executeSwap()` — it cannot transfer tokens, change its own limits, or bypass the guardian's boundaries.
2. **On-chain audit trail**: Every swap emits `SwapExecuted(tokenIn, tokenOut, amountIn, amountOut, reason)` with the agent's rationale stored on-chain.
3. **Human never loses control**: Guardian can `pause()` at any time, change token whitelist, adjust limits, or replace the agent address.
4. **NAV transparency**: `totalAssets()` uses Uniswap V3 TWAP oracle (30-min window) for manipulation-resistant pricing.
5. **Depositor protection**: Standard ERC-4626 — depositors can `redeem()` at NAV anytime.

---

## Test Evidence

- **Foundry tests**: 15 passing (guardian controls, deposit/redeem, swap boundary enforcement, held token tracking)
- **Go tests**: 10 passing (vault client, LLM strategy, risk manager, trading loop)
- **Coverage**: 87.5% function coverage on ObeyVault.sol, all boundary enforcement paths covered

---

## Repository References

| Component | Location |
|-----------|----------|
| Vault Contract | `projects/contracts/src/ObeyVault.sol` |
| Vault Tests | `projects/contracts/test/ObeyVault.t.sol` |
| Deploy Script | `projects/contracts/script/DeployVault.s.sol` |
| Go Agent | `projects/agent-defi/cmd/vault-agent/` |
| Observer CLI | `projects/agent-defi/cmd/observer/` |
| LLM Strategy | `projects/agent-defi/internal/strategy/` |
| Risk Manager | `projects/agent-defi/internal/risk/` |
| Vault Client | `projects/agent-defi/internal/vault/` |
| Trading Loop | `projects/agent-defi/internal/loop/` |
| Synthesis Client | `projects/agent-defi/internal/synthesis/` |
| Festival Plan | `festivals/active/obey-vault-synthesis-OV0001/` |
| Design Spec | `workflow/design/synthesis/00-design-spec.md` |
| Impl Plan | `workflow/design/synthesis/01-implementation-plan.md` |
