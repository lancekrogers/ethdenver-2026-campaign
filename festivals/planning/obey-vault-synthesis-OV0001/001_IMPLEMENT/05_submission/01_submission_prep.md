---
fest_type: task
fest_id: 01_submission_prep.md
fest_name: 02_submission_prep
fest_parent: 05_submission
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:25:35.216458-06:00
fest_tracking: true
---

# Task: Submission Preparation

## Objective

Prepare all Synthesis hackathon submission artifacts: demo recording, conversation logs, and submission metadata with on-chain references.

## Requirements

- [ ] Verify all on-chain artifacts exist: vault contract (verified on Basescan), ERC-8004 agent identity, at least 2-3 SwapExecuted events
- [ ] Export Claude Code conversation logs for submission
- [ ] Record demo showing: (1) agent registration, (2) human deposits USDC, (3) agent trades autonomously, (4) trades visible on-chain with rationale, (5) boundary enforcement (rejected swap), (6) exit at NAV
- [ ] Prepare submissionMetadata: agentHarness "claude-code", model "claude-sonnet-4-6", conversation logs, on-chain artifacts (vault address, agent NFT, trade tx hashes)

## Implementation

See implementation plan Task 20 (`workflow/design/synthesis/01-implementation-plan.md`).

Script the demo flow before recording. Key checkpoints:
1. Show agent registration tx on Basescan
2. Deposit USDC via cast or UI
3. Run vault-agent, show logs
4. Show SwapExecuted event on Basescan with reason bytes
5. Attempt oversized swap, show revert
6. Redeem shares at NAV

## Done When

- [ ] All requirements met
- [ ] Demo recording captures all 6 checkpoints
- [ ] Submission metadata complete with all on-chain references
