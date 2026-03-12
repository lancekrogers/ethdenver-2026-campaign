# 0G Guild — Step-by-Step Submission Guide

## Pre-Submission Work (Do This First)

### Step 0: Refresh Evidence And Close The Remaining Gaps (~1-2 hours)

The old "wallet empty / nothing deployed" blocker is gone. The current job is to reuse the deployment evidence you already have and add the missing runtime txs.

1. **Copy existing Galileo deployment evidence into the submission materials**
   - `ReputationDecay` → `0x5a028b3fafd2179c3a453dd3f12b0cead16d86e3810e76b4776478dc06350c58`
   - `AgentSettlement` → `0x30f03a1777ab8bb0c106260891ec69eb0c0226eaf9243b0456552825698ed89b`
   - `AgentINFT` → `0x929d4a74fd6a25ed34e1762181ba842edfa20f76b476a6adc1290db5175a88f4`

2. **Top up Galileo wallet only if needed**
   - If gas balance is low, use https://faucet.0g.ai

3. **Execute Storage submit() transaction**
   - Either write a live test or run the agent with ZG_CHAIN_PRIVATE_KEY set
   - Save the transaction hash

4. **Execute DA submitOriginalData() transaction**
   - Same approach
   - Save the transaction hash

5. **Mint an iNFT on the deployed contract**
   - Use deployed contract `0x17F41075454cf268D0672dd24EFBeA29EF2Dc05b`
   - Call mint() with test metadata
   - Save the transaction hash + token ID

6. **Optional but high-value: capture one successful provider-authenticated inference run**
   - Save request logs, provider selected, and any resulting tx or audit evidence

7. **Document all tx hashes** in the hall post and one-pager

### Step 0.5: Make Repos Public

- [ ] agent-inference → public on GitHub
- [ ] contracts → public on GitHub (or at minimum the 0G-relevant parts)

---

## Submission Steps

### Step 1: Create hall.0g.ai Account (~5 min)

1. Go to https://hall.0g.ai
2. Click "Sign Up"
3. Create account (email or social login)
4. Verify email if required

### Step 2: Post on hall.0g.ai (~15 min)

1. Navigate to https://hall.0g.ai/c/guildon0g/10 (Guild on 0G 2.0 category)
2. Click "New Topic"
3. Title: **"Obey Agent Economy: Decentralized Inference Pipeline on 0G"**
4. Copy-paste the content from `hall-post.md` (with [PLACEHOLDER] values filled in)
5. Preview to confirm formatting is clean
6. Post
7. **Copy the URL** — you'll need it for the application form

### Step 3: Fill Out Application Form (~20 min)

Go to https://guild.0gfoundation.ai/apply

**Page 1: Contact Information**
- Full Name: Lance Rogers
- Email: [your email]
- Telegram ID: [your telegram]
- 0G Hall Submission URL: [paste the URL from Step 2]
- Region: North America (USA, Canada)
- How did you hear: [choose appropriate — if ETHDenver, pick "0G Events / Conferences"]

**Page 2: Project Info**
- Project Name: Obey Agent Economy
- Category: AI Agents (their HIGHEST PRIORITY category)
  - Project Description: "Decentralized inference pipeline using all 4 0G services — Compute for GPU provider discovery, Storage for result anchoring, Chain for ERC-7857 iNFT minting, and DA for immutable audit trails. Galileo deployment evidence is already live; the remaining milestone is authenticated inference execution."
- Website/GitHub: github.com/lancekrogers
- Stage: Working prototype on Galileo testnet

**Page 3: Team**
- Team size: 1 (solo builder)
- Background: Full-stack engineer, Go/Solidity/TypeScript, distributed systems
- Note: Be honest about solo status. Frame it as: "Built the entire multi-chain system solo — demonstrates execution velocity and deep technical capability."

**Page 4: Technical / 0G Integration**
- This is where you shine. List all 4 services with contract addresses:
  - Compute: InferenceServing at 0xa79F...
  - Storage: Flow contract at 0x22E0...
  - DA: DA Entrance at 0xE75A...
  - Chain: AgentINFT deployed at [your address]
- Include chainscan links to your transactions

**Page 5: Review & Submit**

### Step 4: Social Media (~30 min)

This is important for visibility. The 0G team scouts Twitter and Discord.

**Twitter/X Post (post same day as application):**

```
Built a decentralized inference pipeline on @0aboratory using all 4 services:

🔹 Compute — GPU provider discovery on-chain
🔹 Storage — Result anchoring via Flow contract
🔹 Chain — ERC-7857 iNFT with encrypted metadata
🔹 DA — Immutable audit trail

Every inference result has verifiable provenance.

Applied to Guild on 0G 2.0 — here's the full proposal:
[hall.0g.ai link]

Thread 🧵👇
```

**Thread continues:**

```
1/ The agent discovers GPU providers by reading the InferenceServing contract on Galileo. Found 4 active providers running models from 7B-27B params.

2/ After inference, the result gets anchored on 0G Storage with SHA-256 data root verification. Then an ERC-7857 iNFT is minted with AES-256-GCM encrypted metadata — only the owner can decrypt.

3/ Finally, an immutable audit event goes to 0G DA: agent ID, task ID, inference job ID, storage ref, iNFT token ID. Full provenance chain.

4/ This is part of Obey Agent Economy — a multi-agent system across 4 chains:
- Hedera: coordination + payment
- 0G: inference + provenance
- Base: DeFi trading
- Ethereum: risk controls via Chainlink CRE

5/ Open-sourcing the inference pipeline as a reusable framework. If you're building on 0G, the agent templates are ready: `0g-agent` and `0g-inft-build`.

GitHub: [link]
```

**Tag:** @0G_labs, @0G_Foundation

**0G Discord Post:**

Join https://discord.gg/0glabs and post in the builders or showcase channel:
- Brief description + hall.0g.ai link
- Mention all 4 services
- Include chainscan links

---

## Timeline

| Step | Time | Depends On |
|------|------|-----------|
| Refresh evidence + close remaining gaps | 1-2 hours | Existing Galileo deploy txs |
| Make repos public | 5 min | — |
| Create hall.0g.ai account | 5 min | — |
| Post on hall.0g.ai | 15 min | Deployment evidence copied, placeholders filled |
| Fill application form | 20 min | Hall post URL |
| Twitter thread | 30 min | Hall post URL |
| Discord post | 10 min | Hall post URL |
| **Total** | **~3-4 hours** | |

**Expected response:** 1-2 weeks from submission to decision (per their FAQ).
