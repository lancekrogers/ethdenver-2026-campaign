---
fest_type: task
fest_id: 02_setup_markee.md
fest_name: setup markee
fest_parent: 04_low_effort_bounties
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-16T21:39:48.851393-06:00
fest_updated: 2026-03-17T00:24:58.517247-06:00
fest_tracking: true
---



# Task: Set Up Markee GitHub Integration

## Objective

Set up Markee integration on the claude-code-go repo (already public, 36 stars) to qualify for the Markee proportional bounty.

## Requirements

- [ ] Grant OAuth permissions via Markee app
- [ ] Add Markee delimiter text to a visible markdown file in the repo
- [ ] Verify "Live" status on Markee GitHub integrations page

## Implementation

1. Navigate to: https://www.markee.xyz/ecosystem/platforms/github
2. Click **"Create a Markee"**
3. Connect GitHub via OAuth — this grants Markee read access to verify repo ownership
4. Select the **festival repo** (not claude-code-go) — an upcoming video with viral potential makes this the better target for a proportional views-based payout
   - If the bounty allows multiple repos, also set up claude-code-go (36 stars, steady organic traffic) as a second integration
5. Deploy your Markee "sign" on-chain (requires wallet connection — MetaMask or similar)
6. After deploying, the sign's page shows **address-specific delimiter tags** — copy these exactly
7. Add the delimiter tags to README.md in the festival repo:
   - Place near the bottom of the file (visible but not intrusive)
   - Commit and push
8. Verify "Live" status at: https://www.markee.xyz/ecosystem/platforms/github
   - Your repo must show as "Live" on this page to qualify
   - If not showing: check delimiter format, repo visibility (must be public), OAuth still active
9. **Post-hackathon cleanup:** Revoke OAuth at GitHub Settings → Applications → Authorized OAuth Apps → Markee

**Disqualification threshold:** <10 unique views AND no funds added. The festival repo should clear this easily once the video is posted.

## Done When

- [ ] All requirements met
- [ ] OAuth granted for festival repo (and optionally claude-code-go)
- [ ] Markee sign deployed on-chain
- [ ] Address-specific delimiter tags added to README.md
- [ ] Markee integrations page shows "Live" status for the repo