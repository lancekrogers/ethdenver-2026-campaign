# 0G On-Chain Evidence Audit

**Date:** 2026-03-11 (Updated with wallet verification)
**Verdict:** Code is real and integration-tested, but NO write transactions exist on 0G Galileo. Wallet confirmed empty via chainscan-galileo.0g.ai.

## Wallet Verification (2026-03-11)

- **Address:** `0x38CB2E2eeb45E6F70D267053DcE3815869a8C44d` (derived from `ZG_CHAIN_PRIVATE_KEY`)
- **Balance:** 0
- **Nonce:** 0
- **Transactions:** 0 — "There are no matching entries"
- **Verified via:** Playwright browser automation on chainscan-galileo.0g.ai
- **Note:** Same key is active on Hedera as account `0.0.7984825` with 25+ consensus message transactions

**The wallet has NEVER been funded on 0G Galileo.** All evidence gaps remain open.

---

## What Works (Verified)

| Component | Status | Evidence |
|-----------|--------|----------|
| Provider discovery | ✅ WORKS | `getAllServices()` returns 4 active providers on Galileo (compute-metrics.md, 2026-02-21) |
| Endpoint probing | ✅ WORKS | HTTP 400 responses confirm endpoints are live and reachable |
| Go code compiles | ✅ WORKS | 60+ tests pass across all 0G packages |
| Contract ABIs | ✅ REAL | Hardcoded from actual Galileo deployments (InferenceServing, Flow, DA Entrance) |

## What Does NOT Work Yet

| Component | Status | Gap | Impact |
|-----------|--------|-----|--------|
| Session auth | ❌ NOT DONE | Need to establish funded on-chain session with a provider | Cannot execute actual inference |
| Inference execution | ❌ NOT DONE | Blocked by session auth | No inference result to store |
| Storage anchoring | ❌ NO TX | Code exists but `submit()` has not been broadcast | No storage content ID to reference |
| iNFT minting | ❌ CONTRACT NOT DEPLOYED | `AgentINFT.sol` exists but not deployed to Galileo | No mint transaction, no token ID |
| DA submission | ❌ NO TX | Code exists but `submitOriginalData()` not broadcast | No DA reference |
| Full pipeline | ❌ NOT RUN | 7-stage pipeline never executed end-to-end | No end-to-end evidence |

**Source:** `projects/agent-inference/docs/compute-metrics.md` lines 166-170:
> - Session auth not benchmarked
> - iNFT contract: Not yet deployed on Galileo; minting metrics are estimates from gas simulation

---

## What Needs to Happen Before Submission

### Minimum Viable Evidence (Must Have)

These are the transactions you need to be able to link in your Guild post:

1. **Deploy AgentINFT.sol to Galileo**
   ```bash
   cd projects/contracts
   forge script script/Deploy.s.sol --rpc-url https://evmrpc-testnet.0g.ai --broadcast
   ```
   - Produces: Contract address on Galileo chainscan
   - Time estimate: 10 minutes (if you have a funded Galileo wallet)

2. **Execute a Storage `submit()` call**
   ```bash
   # From agent-inference, with ZG_CHAIN_PRIVATE_KEY set
   go test -tags live -run TestLive_StorageSubmit -v ./internal/zerog/storage/
   ```
   - Produces: Transaction hash on Galileo chainscan
   - Time estimate: 5 minutes

3. **Execute a DA `submitOriginalData()` call**
   ```bash
   go test -tags live -run TestLive_DASubmit -v ./internal/zerog/da/
   ```
   - Produces: Transaction hash on Galileo chainscan
   - Time estimate: 5 minutes

4. **Mint an iNFT on the deployed contract**
   ```bash
   go test -tags live -run TestLive_MintINFT -v ./internal/zerog/inft/
   ```
   - Produces: Token ID + transaction hash
   - Time estimate: 5 minutes (after contract deployment)

### Nice to Have

5. **Establish a provider session and execute inference**
   - This is the hardest part — requires on-chain session funding with a provider
   - If you can do this, you have a COMPLETE end-to-end pipeline
   - Time estimate: 30-60 minutes (debugging session auth format)

6. **Full pipeline run (all 7 stages)**
   - Requires all of the above + HCS connectivity
   - Time estimate: 1-2 hours

---

## Pre-Submission Requirements

| Requirement | Status | Priority |
|-------------|--------|----------|
| Funded Galileo wallet | ❌ CONFIRMED EMPTY | **BLOCKER** — need testnet 0G tokens from faucet.0g.ai |
| AgentINFT deployed to Galileo | ❌ | Must have |
| Storage submit tx hash | ❌ | Must have |
| DA submit tx hash | ❌ | Must have |
| iNFT mint tx hash | ❌ | Must have |
| Inference execution | ❌ | Nice to have |
| All tx hashes documented | ❌ | Must have |

### Get Galileo Testnet Tokens

Faucet: https://faucet.0g.ai

---

## Evidence Format for Guild Post

Once you have transactions, document them like this:

```markdown
## On-Chain Evidence (0G Galileo Testnet)

| Operation | Transaction | Contract |
|-----------|-------------|----------|
| AgentINFT deployment | [chainscan link] | 0x... |
| Storage anchoring | [chainscan link] | 0x22E03a... (Flow) |
| DA audit submission | [chainscan link] | 0xE75A07... (DA Entrance) |
| iNFT mint | [chainscan link] | [deployed address] |

Chain scanner: https://chainscan.0g.ai
```
