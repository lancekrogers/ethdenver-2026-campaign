# Base Builder Grant — Step-by-Step Submission Guide

## How Base Grants Work (Different From Other Programs)

Base grants are **retroactive and scout-based**. There is no formal application form with milestone proposals. The process is:

1. You ship code on Base
2. You make it visible (public repo + social media)
3. You self-nominate OR get discovered by the Base grants team
4. They review your shipped work and decide

**No pitch deck. No milestones. No committees. Ship and be seen.**

---

## Pre-Submission Work

### Step 0: Verify/Generate On-Chain Evidence (~30-60 min)

You need Base Sepolia transaction hashes to link publicly.

1. **Check existing wallet history**
   - Go to https://sepolia.basescan.org
   - Search your agent wallet address
   - Check if ERC-8004, Uniswap, or x402 transactions already exist

2. **If no transactions exist, generate them:**

   a. Fund Base Sepolia wallet:
   - Get Sepolia ETH from a faucet
   - Bridge to Base Sepolia or use a Base Sepolia faucet
   - Get USDC from Base Sepolia faucet (0x036CbD53842c5426634e7929541eC2318f3dCF7e)

   b. Execute ERC-8004 registration:
   ```bash
   cd projects/agent-defi
   export BASE_PRIVATE_KEY=<your-key>
   export BASE_RPC=https://sepolia.base.org
   go run cmd/main.go --register-identity
   # Or: go test -tags live -run TestLive_Register -v ./internal/base/identity/
   ```

   c. Execute a Uniswap V3 swap:
   ```bash
   go run cmd/main.go --execute-trade
   # Or: go test -tags live -run TestLive_Swap -v ./internal/base/trading/
   ```

3. **Save all transaction hashes** and verify on basescan

### Step 1: Make Repos Public (~5 min)

**This is non-negotiable.** Base team discovers builders through public code.

- [ ] Make `agent-defi` repo public on GitHub
- [ ] Ensure README has clear description of Base integrations
- [ ] Remove any secrets from repo history (check .env files)

---

## Submission Steps

### Step 2: Self-Nominate via Base Grants Form (~10 min)

1. Go to: https://paragraph.com/@grants.base.eth/calling-based-builders
2. Find the nomination/submission link (typically a Google Form or similar)
3. Fill out:
   - **Project name:** Obey Agent Economy — Autonomous DeFi Agent
   - **What it does:** "Autonomous trading agent on Base Sepolia integrating ERC-8004 (trustless identity), ERC-8021 (builder attribution), and x402 (machine payments). Trades Uniswap V3 with Chainlink CRE risk controls. Self-sustaining — covers its own gas costs from trading profits."
   - **GitHub:** [your public repo link]
   - **On-chain evidence:** [basescan tx links]
   - **Social:** [your Twitter/Farcaster handles]

Keep it SHORT. They read hundreds of these. One paragraph + links.

### Step 3: Register on builderscore.xyz (~5 min)

1. Go to https://www.builderscore.xyz/
2. Connect wallet
3. Link GitHub account
4. This enrolls you in the **weekly 2 ETH builder rewards** (separate from grants)

### Step 4: Post on Twitter/X (~20 min)

1. Post the main thread from `social-post.md`
2. Tag @base @jessepollak @BuildOnBase
3. Include:
   - GitHub repo link
   - Basescan transaction links
   - Screenshot of code or architecture diagram
4. Pin the thread on your profile

### Step 5: Post on Farcaster (~10 min)

1. Create account on Warpcast if you don't have one
2. Post the Farcaster content from `social-post.md`
3. Follow and engage with @base, @jessepollak, other Base builders
4. Join Base-related channels

### Step 6: Join Base Discord (~5 min)

1. Join the Base Discord server
2. Introduce yourself in the builders/showcase channel
3. Link your project with a brief description

---

## After Submission

### Ongoing Visibility (Do Weekly)

The Base grants team continuously scouts. A single post isn't enough.

- [ ] **Week 1:** Initial thread (submission day)
- [ ] **Week 2:** Technical deep-dive — "How I implemented x402 in Go"
- [ ] **Week 3:** Progress update — any new features or mainnet prep
- [ ] **Week 4:** Engage with other Base builders' posts (comment, share)

### What to Expect

- **Timeline:** 2-6 weeks for grant decision (if selected)
- **Amount:** 1-5 ETH (~$2K-$10K at current prices)
- **Payment:** Direct to your wallet
- **No milestones:** It's retroactive. They pay for what you already built.

---

## Complete Timeline

| Step | Time | Depends On |
|------|------|-----------|
| Verify/generate on-chain evidence | 30-60 min | Funded Base Sepolia wallet |
| Make repos public | 5 min | — |
| Self-nominate | 10 min | Public repo + tx evidence |
| Register builderscore.xyz | 5 min | Wallet |
| Twitter thread | 20 min | Repo + tx links |
| Farcaster post | 10 min | Repo + tx links |
| Join Base Discord | 5 min | — |
| **Total** | **~1.5-2 hours** | |

---

## Key Differences From 0G Submission

| Factor | 0G Guild | Base Builder Grant |
|--------|----------|-------------------|
| Process | Formal application + forum post | Self-nominate + be visible |
| Decision basis | Proposal quality + milestones | Shipped code + social presence |
| Amount | $10K-$1M+ | 1-5 ETH |
| Timeline | 1-2 weeks formal review | 2-6 weeks (scout-based) |
| Ongoing work | Milestone delivery | Weekly social visibility |
| Formality | High (5-step form) | Low (one nomination + social) |
