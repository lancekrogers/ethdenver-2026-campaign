---
fest_type: sequence
fest_id: 06_end_to_end_verification
fest_name: end to end verification
fest_parent: 001_IMPLEMENT
fest_order: 6
fest_status: pending
fest_tracking: true
fest_working_dir: "."
---

# Sequence Goal: 06_end_to_end_verification

**Sequence:** 06_end_to_end_verification | **Phase:** 001_IMPLEMENT | **Status:** Pending

## Sequence Objective

**Primary Goal:** Verify that all 7 dashboard panels show data from real agent binaries in demo mode, and that live mode connects to real external services.

**Contribution to Phase Goal:** This is the acceptance test — if all panels show real agent data after `just demo up`, the integration is complete.

## Success Criteria

### Required Deliverables

- [ ] **Demo mode verified**: All 7 panels populated with real agent events
- [ ] **Live mode verified**: Dashboard connects to real Hedera Mirror Node and coordinator WebSocket
- [ ] **Demo gif captured**: Screenshot or gif showing all panels with real data for submission

### Completion Criteria

- [ ] All tasks in sequence completed
- [ ] No client-side synthetic generators running when agents are active
- [ ] Demo gif ready for hackathon submission update

## Dependencies

### Prerequisites

- All previous sequences (01-05): Full integration must be complete
