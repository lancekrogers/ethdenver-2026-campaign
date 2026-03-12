# 0G On-Chain Evidence Audit

**Date:** 2026-03-12 (updated for current Galileo evidence)
**Verdict:** 0G now has real write transactions and deployed contracts on Galileo. The remaining public evidence gap is not "does this wallet work on 0G?" but "can we document full runtime usage beyond deployment, especially authenticated inference?"

## Current Galileo Evidence

- **Address:** `0x38CB2E2eeb45E6F70D267053DcE3815869a8C44d` (derived from `ZG_CHAIN_PRIVATE_KEY`)
- **Nonce:** 4 (per `evidence-manifest.md`)
- **Verified deployment txs:**
  - `0x5a028b3fafd2179c3a453dd3f12b0cead16d86e3810e76b4776478dc06350c58` → `ReputationDecay` at `0xbdCdBfd93C4341DfE3408900A830CBB0560a62C4`
  - `0x30f03a1777ab8bb0c106260891ec69eb0c0226eaf9243b0456552825698ed89b` → `AgentSettlement` at `0x437c2bF7a00Da07983bc1eCaa872d9E2B27A3d40`
  - `0x929d4a74fd6a25ed34e1762181ba842edfa20f76b476a6adc1290db5175a88f4` → `AgentINFT` at `0x17F41075454cf268D0672dd24EFBeA29EF2Dc05b`
- **System contracts in use:**
  - Compute / InferenceServing: `0xa79F4c8311FF93C06b8CfB403690cc987c93F91E`
  - Storage / Flow: `0x22E03a6A89B950F1c82ec5e74F8eCa321a105296`
  - DA Entrance: `0xE75A073dA5bb7b0eC622170Fd268f35E675a957B`
- **Source of truth:** `workflow/explore/grant-research/2026-03-11/evidence-manifest.md`

This means the old "wallet empty / no write txs" state is no longer accurate.

---

## What Works (Verified)

| Component | Status | Evidence |
|-----------|--------|----------|
| Wallet can broadcast on Galileo | ✅ WORKS | Three verified deployment txs recorded in `evidence-manifest.md` |
| Contract deployments | ✅ WORKS | `ReputationDecay`, `AgentSettlement`, and `AgentINFT` deployed on Galileo |
| Provider discovery | ✅ WORKS | `getAllServices()` returns 4 active providers on Galileo (compute-metrics.md, 2026-02-21) |
| Endpoint probing | ✅ WORKS | HTTP 400 responses confirm endpoints are live and reachable |
| Go code compiles | ✅ WORKS | 60+ tests pass across all 0G packages |
| Contract ABIs | ✅ REAL | Hardcoded from actual Galileo deployments (InferenceServing, Flow, DA Entrance) |
| Session auth implementation | ✅ IN CODE | `internal/zerog/compute/session.go` now implements on-chain session setup and token generation |

## What Is Still Missing From The Public Evidence Set

| Component | Status | Gap | Impact |
|-----------|--------|-----|--------|
| Session auth | ⚠️ NOT DOCUMENTED | Code exists, but no public tx/log set proves provider session establishment end-to-end | Weakest part of the 0G story |
| Inference execution | ⚠️ NOT DOCUMENTED | No public successful provider-authenticated inference result captured yet | No direct proof of paid compute path |
| Storage anchoring | ⚠️ NO TX HASH RECORDED HERE | Code exists, but grant docs do not yet include a Galileo `submit()` tx hash | Missing result-storage evidence |
| iNFT minting runtime | ⚠️ CONTRACT DEPLOYED, MINT TX NOT RECORDED | `AgentINFT` is deployed, but no public mint tx is listed yet | Missing token-level provenance proof |
| DA submission | ⚠️ NO TX HASH RECORDED HERE | Code exists, but `submitOriginalData()` tx evidence is still missing from the grant packet | Missing audit-trail tx evidence |
| Full pipeline | ⚠️ NOT DOCUMENTED | Deployment evidence exists, but the full 7-stage run is not yet documented publicly | Cannot claim end-to-end proof cleanly |

**Legacy note:** `projects/agent-inference/docs/compute-metrics.md` was written before the Galileo contract deployments. Its limitation about "iNFT contract not yet deployed" is now outdated and should be read as historical context only.

**Still-current note from that report:**
> - Session auth not benchmarked

---

## What Needs to Happen Before Submission

### Minimum Credible Update (Recommended Before Submission)

These are the remaining runtime proofs that would materially strengthen the Guild application:

1. **Execute a Storage `submit()` call**
   ```bash
   # From agent-inference, with ZG_CHAIN_PRIVATE_KEY set
   go test -tags live -run TestLive_StorageSubmit -v ./internal/zerog/storage/
   ```
   - Produces: Transaction hash on Galileo chainscan
   - Time estimate: 5 minutes

2. **Execute a DA `submitOriginalData()` call**
   ```bash
   go test -tags live -run TestLive_DASubmit -v ./internal/zerog/da/
   ```
   - Produces: Transaction hash on Galileo chainscan
   - Time estimate: 5 minutes

3. **Mint an iNFT on the deployed Galileo contract**
   ```bash
   go test -tags live -run TestLive_MintINFT -v ./internal/zerog/inft/
   ```
   - Produces: Token ID + transaction hash
   - Use deployed contract: `0x17F41075454cf268D0672dd24EFBeA29EF2Dc05b`
   - Time estimate: 5 minutes

### Nice to Have

4. **Establish a provider session and execute inference**
   - This is still the hardest part and the biggest credibility unlock
   - If you can document this, you can claim the full pipeline much more confidently
   - Time estimate: 30-60 minutes (debugging session auth format)

5. **Full pipeline run (all 7 stages)**
   - Requires all of the above + HCS connectivity
   - Time estimate: 1-2 hours

---

## Pre-Submission Requirements

| Requirement | Status | Priority |
|-------------|--------|----------|
| Galileo wallet funded and active | ✅ COMPLETE | Done |
| AgentINFT deployed to Galileo | ✅ COMPLETE | Done |
| Storage submit tx hash | ❌ OPEN | Must have |
| DA submit tx hash | ❌ OPEN | Must have |
| iNFT mint tx hash | ❌ OPEN | Must have |
| Inference execution | ⚠️ OPEN | Nice to have but very valuable |
| All tx hashes documented in grant materials | ⚠️ PARTIAL | Must finish |

### Funding Note

The wallet is no longer in a "never funded" state. Only top up from https://faucet.0g.ai if the remaining gas balance is too low for the next evidence txs.

---

## Evidence Format For Guild Post

Existing deployment evidence can already be documented like this:

```markdown
## On-Chain Evidence (0G Galileo Testnet)

| Operation | Transaction | Contract |
|-----------|-------------|----------|
| ReputationDecay deployment | https://chainscan.0g.ai/tx/0x5a028b3fafd2179c3a453dd3f12b0cead16d86e3810e76b4776478dc06350c58 | 0xbdCdBfd93C4341DfE3408900A830CBB0560a62C4 |
| AgentSettlement deployment | https://chainscan.0g.ai/tx/0x30f03a1777ab8bb0c106260891ec69eb0c0226eaf9243b0456552825698ed89b | 0x437c2bF7a00Da07983bc1eCaa872d9E2B27A3d40 |
| AgentINFT deployment | https://chainscan.0g.ai/tx/0x929d4a74fd6a25ed34e1762181ba842edfa20f76b476a6adc1290db5175a88f4 | 0x17F41075454cf268D0672dd24EFBeA29EF2Dc05b |
| Storage anchoring | [chainscan link] | 0x22E03a... (Flow) |
| DA audit submission | [chainscan link] | 0xE75A07... (DA Entrance) |
| iNFT mint | [chainscan link] | 0x17F41075454cf268D0672dd24EFBeA29EF2Dc05b |

Chain scanner: https://chainscan.0g.ai
```
