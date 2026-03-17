---
fest_type: task
fest_id: 08_submit_status_markee.md
fest_name: submit status markee
fest_parent: 06_submission_packaging
fest_order: 8
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-16T21:39:51.882389-06:00
fest_updated: 2026-03-17T00:23:08.00952-06:00
fest_tracking: true
---


# Task: Submit to Status Network and Markee Tracks

## Objective

Submit OBEY to the Status Network and Markee bounty tracks via Synthesis API using the deployment evidence from sequence 04.

## Requirements

- [ ] Submit to Status Network track with deployment tx hash proof
- [ ] Submit to Markee track with integration confirmation
- [ ] Both submissions reference the OBEY agent as the AI component

## Implementation

1. **Status Network submission:**
   - Track: "Status Network -- Go Gasless"
   - Include:
     - Status Sepolia contract deployment tx hash (from sequence 04, task 01)
     - Gasless transaction tx hash
     - Reference to OBEY agent as AI component
     - Short description of the deployed contract
   - Submit via Synthesis API

2. **Markee submission:**
   - Track: "Markee Github Integration"
   - Include:
     - Repo with Markee integration (claude-code-go)
     - Confirmation that Markee shows "Live" status
     - Link to the repo with Markee delimiter text
   - Submit via Synthesis API

3. Record confirmation responses for both submissions

## Done When

- [ ] All requirements met
- [ ] Status Network submission confirmed with tx hash proof
- [ ] Markee submission confirmed with Live integration proof
- [ ] Both submission IDs recorded