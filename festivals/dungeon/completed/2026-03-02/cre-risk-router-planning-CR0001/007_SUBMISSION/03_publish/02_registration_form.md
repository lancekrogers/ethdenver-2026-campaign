---
fest_type: task
fest_id: 01_registration_form.md
fest_name: registration form
fest_parent: 03_publish
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:45:34.422325-07:00
fest_updated: 2026-03-02T01:19:53.726527-07:00
fest_tracking: true
---


# Task: registration form

## Objective

Complete the Chainlink Convergence hackathon registration form (Google Form) with all required project details, team information, and submission links before the March 8, 2026 deadline.

## Requirements

- [ ] Google Form registration completed with all required fields (Req P0.22)
- [ ] GitHub repo URL submitted (must be public or shared with judges)
- [ ] Moltbook post URL included
- [ ] Team member information provided
- [ ] Project category and track selected correctly

## Implementation

1. **Gather all required information** before opening the form:
   - **Project Name**: CRE Risk Router
   - **Project Description**: On-chain risk decision layer for autonomous DeFi agents using Chainlink CRE and oracle data
   - **GitHub Repo**: `https://github.com/lancekrogers/cre-risk-router` (ensure public or judges have access)
   - **Moltbook Post URL**: From the published post in task 04_publish
   - **Team Members**: Lance Rogers (and any other team members)
   - **Track/Category**: Chainlink CRE / DeFi / Infrastructure (select the most appropriate)
   - **Contract Address**: From Phase 002 deployment
   - **Testnet**: The CRE-supported EVM testnet used for deployment

2. **Verify GitHub repo visibility**:
   ```bash
   # Ensure repo is public or judges can access it
   gh repo view lancekrogers/cre-risk-router --json visibility
   ```
   If private, either make public or add judge GitHub handles as collaborators.

3. **Open the registration form** (URL from hackathon announcements or Moltbook platform).

4. **Fill in all fields** carefully:
   - Double-check URLs are correct and accessible
   - Ensure the project description matches the Moltbook post summary
   - Select the correct hackathon track
   - Provide accurate contact information

5. **Screenshot the confirmation page** after submission for records.

6. **Save the confirmation email** or submission ID.

## Done When

- [ ] All requirements met
- [ ] Registration form submitted with all fields completed
- [ ] GitHub repo is accessible to judges
- [ ] Confirmation received (screenshot or email saved)