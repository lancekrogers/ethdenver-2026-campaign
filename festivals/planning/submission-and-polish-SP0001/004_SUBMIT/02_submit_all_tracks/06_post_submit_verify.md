---
fest_type: task
fest_id: 06_post_submit_verify.md
fest_name: post_submit_verify
fest_parent: 02_submit_all_tracks
fest_order: 6
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Post-Submission Verification

**Task Number:** 06 | **Sequence:** 02_submit_all_tracks | **Autonomy:** medium

## Objective

After all five bounty tracks are submitted, perform a final verification to confirm judges can access everything. Check all submission links are accessible, verify repos are visible, demos are playable, and documentation is reachable. This is the last sanity check.

## Requirements

- [ ] All five submission confirmations verified
- [ ] Every link in every submission verified accessible from an incognito browser
- [ ] All GitHub repos are public (or accessible to judges)
- [ ] Demo video plays correctly
- [ ] Dashboard is live
- [ ] Agents are still running
- [ ] Verification results documented

## Implementation

### Step 1: Verify submission confirmations

For each bounty track, confirm the submission was accepted:

| Track | Submitted | Confirmation ID | Portal Status |
|-------|-----------|-----------------|---------------|
| Hedera Track 3 | [ ] Yes | [ID] | [Confirmed/Pending] |
| Hedera Track 4 | [ ] Yes | [ID] | [Confirmed/Pending] |
| 0G Track 2 | [ ] Yes | [ID] | [Confirmed/Pending] |
| 0G Track 3 | [ ] Yes | [ID] | [Confirmed/Pending] |
| Base | [ ] Yes | [ID] | [Confirmed/Pending] |

### Step 2: Test all links from judge perspective

Open an incognito/private browser window (simulating a judge with no cookies/auth):

For each submission, open every link and verify:

- [ ] Repository URL loads and README is visible
- [ ] Demo video URL plays
- [ ] Dashboard URL loads with live data
- [ ] Documentation URLs (architecture, compute metrics, P&L proof, iNFT showcase) are accessible
- [ ] Block explorer links show real transaction data

### Step 3: Verify GitHub repo visibility

For each project repo:

```bash
# Test from an unauthenticated perspective
curl -s -o /dev/null -w "%{http_code}" https://github.com/[org]/[repo]
```

All repos must return 200 (public) or be accessible to judges via the ETHDenver organization.

### Step 4: Final system check

- [ ] Coordinator agent still running and producing heartbeats
- [ ] Inference agent still running
- [ ] DeFi agent still running and trading
- [ ] Dashboard showing live data
- [ ] No critical errors in any agent logs in the last hour

### Step 5: Document the final state

Create a final verification document:

```markdown
# Post-Submission Verification

## Date: [date and time]

## Submission Status
[Table from Step 1]

## Link Accessibility
| Link | Source Submission | Status |
|------|-----------------|--------|
| [url] | [track] | [OK/Broken] |

## System Status
| Component | Status |
|-----------|--------|
| Coordinator Agent | [Running/Down] |
| Inference Agent | [Running/Down] |
| DeFi Agent | [Running/Down] |
| Dashboard | [Accessible/Down] |
| Demo Video | [Playable/Broken] |

## Verdict
[ ] All submissions verified accessible
[ ] All systems running
[ ] Ready for judging
```

## Done When

- [ ] All five submissions verified on the portal
- [ ] All links verified accessible from incognito browser
- [ ] All repos confirmed public/accessible
- [ ] All agents confirmed running
- [ ] Dashboard confirmed live
- [ ] Demo video confirmed playable
- [ ] Final verification document created
