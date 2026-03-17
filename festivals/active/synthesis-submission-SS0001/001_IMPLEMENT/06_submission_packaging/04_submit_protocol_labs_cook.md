---
fest_type: task
fest_id: 04_submit_protocol_labs_cook.md
fest_name: submit protocol labs cook
fest_parent: 06_submission_packaging
fest_order: 4
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-16T21:39:51.881479-06:00
fest_updated: 2026-03-17T00:22:51.470413-06:00
fest_tracking: true
---


# Task: Submit to Protocol Labs "Let the Agent Cook" Track

## Objective

Submit OBEY to the Protocol Labs "Let the Agent Cook" track via Synthesis API, using the autonomy-focused narrative.

## Requirements

- [ ] Submit via Synthesis API with correct track identifier
- [ ] Include agent.json and agent_log.json as required artifacts
- [ ] Use the "Cook" narrative (autonomy + multi-tool orchestration focus)
- [ ] Include all required metadata (repo URL, video, conversationLog)

## Implementation

1. Prepare submission payload:
   - Track: "Protocol Labs -- Let the Agent Cook"
   - Name: "OBEY -- Verifiable Agent Autonomy"
   - Description: Use the "Cook" narrative from `workflow/explore/synthesis/` (autonomy story)
   - Repo URL: `https://github.com/obedience-corp/obey-agent-economy`
   - Video URL: from task 01
   - agent.json: from sequence 02 artifacts
   - agent_log.json: from sequence 02 artifacts
   - conversationLog: from task 02
   - Submission metadata: harness, model, skills, tools (from design spec section 9)
2. Submit via Synthesis API
3. Record confirmation response (submission ID or confirmation)
4. Verify submission appears in Synthesis dashboard

## Done When

- [ ] All requirements met
- [ ] Submission confirmed via Synthesis API
- [ ] Submission ID recorded
- [ ] "Cook" narrative emphasizes Festival Methodology autonomous loop