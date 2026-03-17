---
fest_type: task
fest_id: 05_submit_protocol_labs_receipts.md
fest_name: submit protocol labs receipts
fest_parent: 06_submission_packaging
fest_order: 5
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-16T21:39:51.881736-06:00
fest_updated: 2026-03-17T00:22:51.486443-06:00
fest_tracking: true
---


# Task: Submit to Protocol Labs "Agents With Receipts" Track

## Objective

Submit OBEY to the Protocol Labs "Agents With Receipts" track via Synthesis API, using the identity/trust-focused narrative.

## Requirements

- [ ] Submit via Synthesis API with correct track identifier
- [ ] Include agent.json and agent_log.json as required artifacts
- [ ] Use the "Receipts" narrative (identity + trust + reputation focus)
- [ ] Narrative is genuinely distinct from the "Cook" submission

## Implementation

1. Prepare submission payload:
   - Track: "Protocol Labs -- Agents With Receipts"
   - Name: "OBEY -- Verifiable Agent Autonomy"
   - Description: Use the "Receipts" narrative from `workflow/explore/synthesis/` (identity/trust story)
   - Same repo URL, video URL, agent.json, agent_log.json, conversationLog as Cook submission
   - Submission metadata: same as Cook submission
2. Key narrative differences from Cook submission:
   - Lead with ERC-8004 on-chain identity, not Festival Methodology
   - Emphasize SwapExecuted events as verifiable receipts
   - Highlight guardian/agent trust model
   - Focus on portable reputation building
3. Submit via Synthesis API
4. Record confirmation response

## Done When

- [ ] All requirements met
- [ ] Submission confirmed via Synthesis API
- [ ] Submission ID recorded
- [ ] "Receipts" narrative is distinct from "Cook" narrative -- different lead, different emphasis