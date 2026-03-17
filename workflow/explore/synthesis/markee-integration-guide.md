# Markee GitHub Integration — Step-by-Step Guide

**Bounty:** Markee Github Integration ($800 proportional pool)
**Primary Target Repo:** festival repo (9 stars + upcoming video with viral potential — higher ceiling)
**Backup Repo:** claude-code-go (36 stars, steady organic traffic — safer floor)
**Estimated Time:** 15 minutes per repo
**Payout Model:** Proportional — your share of unique views and funds across all eligible submissions

**Strategy:** If the bounty allows multiple repos, do both. If limited to one, go with festival repo — a viral video spike beats steady trickle in a proportional payout model.

---

## How It Works

Markee lets you add a sponsored message slot to any markdown file in your GitHub repo. Buyers compete to set the message that viewers see. You earn revenue from message purchases, and the bounty pays out proportionally based on views and funds.

Two prize categories:
- **Top Views ($400):** Your unique views / total unique views across all eligible submissions × $1,000
- **Top Monetization ($400):** Your funds added / total funds added across all eligible submissions × $1,000

---

## Step-by-Step

### Step 1: Go to Markee GitHub Integration Page

1. Navigate to: https://www.markee.xyz/ecosystem/platforms/github
2. Click **"Create a Markee"**

### Step 2: Connect GitHub via OAuth

1. You'll be prompted to authenticate with GitHub
2. Grant OAuth permissions — this gives Markee **read access** to verify repo ownership
3. Select the `claude-code-go` repository

**Security note:** You can revoke OAuth access at any time via GitHub Settings → Applications → Authorized OAuth Apps → Markee. Do this after the hackathon if you want.

### Step 3: Deploy Your Sign On-Chain

1. Markee will prompt you to deploy a "sign" on-chain
2. This likely requires a wallet connection (MetaMask or similar)
3. Confirm the transaction to create your Markee sign
4. This is what ties your GitHub repo to the Markee network

### Step 4: Get Your Address-Specific Tags

1. After deploying, your sign's page will show the **exact delimiter tags** to add to your markdown
2. These tags are unique to your address/sign — they cannot be guessed in advance
3. Copy the tags exactly as shown

### Step 5: Add Tags to Your README

1. Open `claude-code-go/README.md`
2. Paste the Markee delimiter tags where you want the sponsored message to appear
3. Good placement: near the bottom of the README (visible but not intrusive)
4. Commit and push

### Step 6: Verify "Live" Status

1. Go to: https://www.markee.xyz/ecosystem/platforms/github
2. Confirm your repo shows as **"Live"** on the integrations page
3. If not showing, check that:
   - The delimiter text is in the correct format
   - The repo is public
   - OAuth permissions are still active

### Step 7: Done

Payout is automatic based on metrics. No further action needed.

---

## Qualification Requirements (Must Meet ALL)

- [x] Own a GitHub repo — festival repo (primary) / claude-code-go (backup)
- [ ] Grant OAuth via Markee — Step 2
- [ ] Add Markee delimiter text to a markdown file — Step 5
- [ ] Appear as "Live" on Markee GitHub integrations page — Step 6
- [ ] Repo must be genuine, not throwaway — claude-code-go has 36 stars, clearly genuine

## Disqualification Criteria

You are disqualified if BOTH of these are true:
- Fewer than 10 unique views on the integrated Markee message
- No funds added to the message

With 36 stars and organic traffic, claude-code-go should clear 10 unique views easily.

---

## When to Do This

**Anytime — no dependencies.** claude-code-go is already public. This is completely independent of all other hackathon work. Do it first to maximize view accumulation time.

---

## After the Hackathon

1. Go to GitHub Settings → Applications → Authorized OAuth Apps
2. Find Markee and click **Revoke**
3. Optionally remove the delimiter text from your README
