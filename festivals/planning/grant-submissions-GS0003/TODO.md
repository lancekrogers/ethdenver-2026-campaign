# Festival TODO - grant-submissions

**Goal**: Submit grant applications to 0G Guild and Base Builder Grants with verified on-chain evidence
**Status**: Planning

---

## Festival Progress Overview

### Phase Completion Status

- [ ] 001_INGEST: Consolidate research and evidence audit (mostly done via workflow/explore/)
- [ ] 002_PLAN: Validate prerequisites and pre-flight checks
- [ ] 003_EVIDENCE: Close on-chain evidence gaps (BLOCKER — no 0G Galileo txs exist)
- [ ] 004_PUBLISH: Make repos public, submit applications
- [ ] 005_SOCIAL: Post social media, join communities

### Current Work Status

```
Active Phase: 002_PLAN (validating prerequisites)
Active Sequences: Pre-flight checks
Blockers: Need funded Galileo wallet + Base Sepolia wallet
```

---

## Phase Progress

### 001_INGEST

**Status**: Mostly Complete (research done in workflow/explore/grant-research/)

#### Key Inputs Identified
- [x] Grant programs researched (13 programs evaluated)
- [x] Odds assessed honestly (50-65% Base, 35-50% 0G)
- [x] 0G evidence gaps documented
- [x] Base evidence gaps documented
- [x] Hall post content drafted
- [x] Self-nomination content drafted
- [x] Social media content drafted
- [x] Step-by-step guides created

### 002_PLAN

**Status**: In Progress

#### Pre-Flight Checks
- [ ] Galileo faucet working (https://faucet.0g.ai)
- [ ] Galileo wallet private key available
- [ ] Base Sepolia wallet funded (ETH + USDC)
- [ ] Repos audited for secrets in git history
- [ ] agent-inference builds cleanly (`just build`)
- [ ] agent-defi builds cleanly (`just build`)
- [ ] contracts compile (`forge build`)

### 003_EVIDENCE

**Status**: Not Started (blocked on 002_PLAN)

#### 0G Galileo Transactions Needed
- [ ] Deploy AgentINFT.sol → contract address
- [ ] Storage submit() → tx hash
- [ ] DA submitOriginalData() → tx hash
- [ ] iNFT mint() → tx hash + token ID
- [ ] (Optional) Session auth + inference execution

#### Base Sepolia Transactions Needed
- [ ] ERC-8004 identity registration → tx hash
- [ ] Uniswap V3 swap → tx hash
- [ ] (Optional) x402 payment → tx hash

#### Evidence Manifest
- [ ] All tx hashes documented in evidence-manifest.md
- [ ] All txs verified on block explorers

### 004_PUBLISH

**Status**: Not Started (blocked on 003_EVIDENCE)

#### Repos
- [ ] Audit repos for secrets
- [ ] agent-inference → public
- [ ] agent-defi → public
- [ ] contracts → public

#### Applications
- [ ] hall.0g.ai account created
- [ ] Hall post published (Guild on 0G 2.0 category)
- [ ] 0G Guild application submitted (5-step form)
- [ ] Base self-nomination submitted
- [ ] builderscore.xyz registered

### 005_SOCIAL

**Status**: Not Started (blocked on 004_PUBLISH)

#### Immediate Posts
- [ ] Twitter thread — 0G inference pipeline
- [ ] Twitter thread — Base DeFi agent
- [ ] Farcaster post — Base agent
- [ ] 0G Discord builder channel post
- [ ] Base Discord builder channel post

#### Ongoing (Weekly)
- [ ] Week 2: Technical deep-dive post
- [ ] Week 3: Progress update
- [ ] Week 4: Community engagement

---

## Blockers

1. **No funded Galileo wallet** — need testnet tokens from faucet.0g.ai
2. **No funded Base Sepolia wallet** — need ETH + USDC
3. **Repos are private** — must audit for secrets before publishing
4. **No hall.0g.ai account** — need to create before posting

---

## Decision Log

- 2026-03-11: Prioritized 0G Guild and Base Builder Grants as highest expected value
- 2026-03-11: Chainlink BUILD deprioritized (requires token commitment we don't have)
- 2026-03-11: Hedera deferred to separate effort (longer timeline)
- 2026-03-11: Obey daemon testing NOT required for either grant submission
- 2026-03-11: 0G ask set at $40K (competitive with TradeOS's $30K, justified by 4-service integration)
- 2026-03-11: Base ask is retroactive (1-5 ETH, no milestone negotiation)

---

## Reference Materials

All content in: `workflow/explore/grant-research/2026-03-11/`

| Directory | Contains |
|-----------|----------|
| `0g/` | Hall post, evidence gaps, step-by-step, one-pager |
| `base/` | Self-nomination, social posts, evidence gaps, step-by-step |
| Root | Grant opportunities, odds assessment, all one-pagers |

---

*Detailed progress available via `fest status`*
