# Chainlink Convergence Hackathon — Submission Checklist

**Deadline: 11:59 PM ET, March 8, 2026** (epoch ms: `1772945940000`)

This checklist documents all manual launch-day steps for submitting the CRE Risk Router to the Chainlink Convergence Hackathon — Agents Track.

---

## Pre-Launch Verification

Before performing any public actions, verify these:

- [ ] Go tests pass: `cd projects/cre-risk-router && go test ./...`
- [ ] No secrets in tracked files: `git grep -l "PRIVATE_KEY\|0x[a-f0-9]{64}" -- ':!secrets.yaml'`
- [ ] Moltbook draft has no placeholder text: `grep -c '\[YOUR_' projects/cre-risk-router/submission/moltbook-draft.md` (should be 0)
- [ ] Draft matches SUBMISSION_TEMPLATE.md section order exactly
- [ ] Evidence tx hashes resolve on Sepolia Etherscan

---

## Step 1: Make Repository Public

```bash
gh repo edit lancekrogers/cre-risk-router --visibility public
```

Verify:

```bash
gh repo view lancekrogers/cre-risk-router --json visibility -q '.visibility'
```

Expected output: `PUBLIC`

---

## Step 2: Push Latest Commits

```bash
cd projects/cre-risk-router
git status
git push origin main
```

Verify the repo is accessible:

```bash
gh repo view lancekrogers/cre-risk-router --json url -q '.url'
```

---

## Step 3: Complete Registration Form

Open this URL in your browser and fill it out:

```
https://forms.gle/xk1PcnRmky2k7yDF7
```

Required info:
- Email address (must be actively monitored — winner/prize info sent here)
- Project name: CRE Risk Router
- Agent platform: Moltbook

---

## Step 4: Post to Moltbook

1. Navigate to `m/chainlink-official` on Moltbook
2. Create a **new post**
3. Set the title to exactly:
   ```
   #chainlink-hackathon-convergence #cre-ai — CRE Risk Router
   ```
4. Copy the **Post Body** section from `projects/cre-risk-router/submission/moltbook-draft.md` (everything below the `---` separator after "# Post Body")
5. Verify the first line of the body is exactly: `#chainlink-hackathon-convergence #cre-ai`
6. Publish the post

---

## Step 5: Post-Submission Validation

After posting, verify every item:

### Title & Header
- [ ] Post title is `#chainlink-hackathon-convergence #cre-ai — CRE Risk Router`
- [ ] First line of body is `#chainlink-hackathon-convergence #cre-ai`
- [ ] No extra text/spaces on the body header line

### Content
- [ ] All sections present in correct order: Project Description, GitHub Repository, Setup Instructions, Simulation Commands, Workflow Description, On-Chain Write Explanation, Evidence Artifact, CRE Experience Feedback, Eligibility Confirmation
- [ ] No placeholder text (`[YOUR_...]`)
- [ ] GitHub repo link is clickable and repo is public
- [ ] Tx hash links resolve on Sepolia Etherscan
- [ ] No secrets or private keys anywhere in the post

### Technical
- [ ] Simulation commands are copy-pasteable and correct
- [ ] Evidence artifact includes tx hash
- [ ] CRE experience feedback is non-empty
- [ ] Eligibility confirmation statements are present

---

## Step 6: Optional — Run Fresh Simulation

If you want to capture fresh evidence before posting:

```bash
cd projects/cre-risk-router

# Dry-run (no on-chain write)
cre workflow simulate . --non-interactive --trigger-index=0 --target=staging-settings

# Broadcast (on-chain write, requires CRE_ETH_PRIVATE_KEY)
cre workflow simulate . --broadcast --non-interactive --trigger-index=0 --target=staging-settings
```

Save output to `evidence/latest-simulation.log` if desired.

---

## Rollback Instructions

### If repo was made public prematurely

```bash
gh repo edit lancekrogers/cre-risk-router --visibility private
```

### If wrong post was published

1. Edit the incorrect post
2. Prefix the body header line with `[SUPERSEDED]`
3. Create a corrected new post (only the most recent valid post before deadline counts)

### If secrets were accidentally committed

1. Immediately rotate the exposed key
2. Remove the secret: `git filter-branch` or `git rebase -i`
3. Force push (only if absolutely necessary and repo is not yet public)
4. If already public: rotate key immediately, then clean history

---

## Key Links

| Resource | URL |
|----------|-----|
| Registration form | https://forms.gle/xk1PcnRmky2k7yDF7 |
| Moltbook community | m/chainlink-official |
| Contract on Sepolia | https://sepolia.etherscan.io/address/0xfcA344515D72a05232DF168C1eA13Be22383cCB6 |
| Broadcast tx #1 | https://sepolia.etherscan.io/tx/0xd8505ff76caa1e2d17b2ee49b625048f353359fabf68f02abedc9fda87360458 |
| Broadcast tx #2 | https://sepolia.etherscan.io/tx/0x4cd1d6664747b5e2c53f1e10b819b50d437827d632212d204d941b1130c068f2 |
| Deploy tx | https://sepolia.etherscan.io/tx/0x36c066ba6a3d29abf6888382d5c44c014c7bff4443895cf6a7c84092c4314b46 |
| Hackathon rules | .claude/skills/chainlink-hackathon/RULES.md |
| Submission template | .claude/skills/chainlink-hackathon/SUBMISSION_TEMPLATE.md |
| Qualification checklist | .claude/skills/chainlink-hackathon/QUALIFICATION_CHECKLIST.md |

---

## Timeline

| Event | Date |
|-------|------|
| Hackathon start | Feb 23, 2026, 6:00 PM ET |
| **Submission deadline** | **March 8, 2026, 11:59 PM ET** |
| Post-deadline | No edits allowed |
