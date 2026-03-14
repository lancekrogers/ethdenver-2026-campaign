# Base On-Chain Evidence Audit

> Track: External Proof. Use evidence-backed wording only.

**Date:** 2026-03-12 (updated for current Base evidence)
**Verdict:** The wallet is now funded and active on Base Sepolia with contract deployments and an ERC-8004 identity registration. The remaining evidence gap is not "does anything exist on Base?" but "do we have public tx evidence for trading, x402 payments, and ERC-8021 attribution?"

## Current Wallet State

- **Address:** `0xc71d8a19422c649fe9bdcbf3ffa536326c82b58b` (from `DEFI_WALLET_ADDRESS`)
- **Nonce:** 5 (per `evidence-manifest.md`)
- **Funding tx:** `0xfebaae44845667ac09c39b19db4a2b259d85881274e70c3ca41f79245a4cad2c` via `depositETH`
- **Verified deployment txs:**
  - `0x21c52923db732f0b79e0488c8af64fb26fae07b4fd843b8400f9cf7ef872b739` → `AgentIdentityRegistry` at `0x0C97820abBdD2562645DaE92D35eD581266CCe70`
  - `0xa52f45a1d4fd1347512da079340f3699f4e7cee7e286e9d46445bb7856d6f8fe` → `AgentSettlement` at `0xa5378FbDCD2799C549A559C1C7c1F91D7C983A44`
  - `0xbb0b9a2b8fc0dedf5c811e89a8e34e73531c9c077d5c3b11e711f2fb0aa1f97e` → `ReputationDecay` at `0x54734cC3AF4Db984cD827f967BaF6C64DEAEd0B1`
  - `0x653d47b30ebc91f870ea302103b743cd7f30a722649b1af67ebe8a9e40af9c92` → `AgentINFT` at `0xfcA344515D72a05232DF168C1eA13Be22383cCB6`
- **Agent operation tx:** `0x9b31bd785dd7b12649d9d12379546c268aea1da6e0060777bed6276cf8e4002a` → ERC-8004 identity registration (`defi-001`)
- **Source of truth:** `workflow/explore/grant-research/2026-03-11/evidence-manifest.md`

The old "wallet has never interacted on Base" state is no longer accurate.

---

## Contract Status (Current)

| Contract | Address | Deployer | Txs |
|----------|---------|----------|-----|
| AgentIdentityRegistry (ERC-8004) | `0x0C97820abBdD2562645DaE92D35eD581266CCe70` | Our Base wallet | Verified deploy tx |
| AgentSettlement | `0xa5378FbDCD2799C549A559C1C7c1F91D7C983A44` | Our Base wallet | Verified deploy tx |
| ReputationDecay | `0x54734cC3AF4Db984cD827f967BaF6C64DEAEd0B1` | Our Base wallet | Verified deploy tx |
| AgentINFT (ERC-7857) | `0xfcA344515D72a05232DF168C1eA13Be22383cCB6` | Our Base wallet | Verified deploy tx |

---

## What's Built (Code Level)

| Component | Implementation | File |
|-----------|---------------|------|
| ERC-8004 Identity | Real — `Register()`, `Verify()`, `GetIdentity()` via JSON-RPC to Base Sepolia | `internal/base/identity/register.go` |
| x402 Payments | Real — HTTP 402 handshake, on-chain USDC payment, receipt verification (445 lines) | `internal/base/payment/x402.go` |
| ERC-8021 Attribution | Real — 20-byte builder code appended to every tx calldata | `internal/base/attribution/` |
| Uniswap V3 Trading | Real — `exactInputSingle` swaps USDC→WETH on Base Sepolia | `internal/base/trading/executor.go` |
| Mean Reversion Strategy | Real — configurable thresholds, position sizing, confidence scaling | `internal/base/trading/` |

**Mocks exist but are test-only:** `identity/mock.go` and `payment/mock.go` are only imported by `*_test.go` files.

---

## On-Chain Evidence Status

### What We Have

- Base Sepolia funding tx via bridge ✅
- 4 Base Sepolia contract deployments from our wallet ✅
- ERC-8004 identity registration tx ✅
- CRE Risk Router on Ethereum Sepolia: 2 confirmed transactions ✅
- 40+ passing tests ✅

### What We Still Need To Document

| Evidence | Status | Action |
|----------|--------|--------|
| ERC-8004 registration tx on Base Sepolia | ✅ EXECUTED | `0x9b31bd785dd7b12649d9d12379546c268aea1da6e0060777bed6276cf8e4002a` |
| x402 payment tx on Base Sepolia | ❌ OPEN | Capture one live payment or a minimal proof flow with tx hash |
| Uniswap V3 swap tx on Base Sepolia | ❌ OPEN | Capture one live swap tx |
| ERC-8021 attributed tx on Base Sepolia | ❌ OPEN | Capture one tx whose calldata suffix can be decoded publicly |

### How To Generate Evidence (If Missing)

1. **Reuse the existing deployment and identity tx hashes**
   - Pull them from `evidence-manifest.md` and link them in the grant materials

2. **Top up Base Sepolia wallet only if needed**
   - Use a faucet or bridge more ETH/USDC if you need gas or swap inventory

3. **Execute a Uniswap V3 swap**
   ```bash
   cd projects/agent-defi
   go test -tags live -run TestLive_Swap -v ./internal/base/trading/
   ```

4. **Execute x402 payment**
   - Requires a service that accepts x402 payments
   - Alternatively: demonstrate the protocol flow with logs

5. **Capture one explicit ERC-8021-attributed tx**
   - Use the transaction input data field on Basescan or Base.dev analytics to verify the suffix

6. **Document all transactions**
   - Base Sepolia scanner: https://sepolia.basescan.org
   - Save tx hashes for nomination form

---

## What The Base Team Sees

The Base grants team scouts builders on Twitter/Farcaster. They're looking for:

1. **Shipped code** — not proposals, not mockups
2. **Base-native integration** — using Base-specific standards/infra
3. **Visibility** — active on social, showing work publicly

Your advantages:

- **3 Base-native standards** (ERC-8004, ERC-8021, x402) in one project
- **These are new standards** with very few live implementations
- **Real on-chain Base evidence** — 4 contract deployments plus identity registration from your own wallet

Your gaps:

- **Repo visibility must be verified** — if the repo is still private, Base team cannot review it
- **Social presence still matters** — they discover via Twitter/Farcaster
- **Trading / x402 / ERC-8021 runtime txs are still missing from the public packet**

---

## Obey Agent / Daemon Note

The full agent pipeline requires the `obeyd` daemon to orchestrate all three agents. This still does not matter much for the Base grant. Base cares more about the Base-specific integrations and proof that they exist onchain than it does about the full cross-chain orchestration story.
