---
fest_type: task
fest_id: 03_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 06_inference_metrics
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 03 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify the Inference Metrics panel component works correctly through testing. Focus on the compute gauge, storage bar, iNFT card, and job table rendering.

## Requirements

- [ ] All unit tests pass
- [ ] Gauge renders correct percentage and color
- [ ] Storage bar calculates percentage correctly
- [ ] Job table handles all status states

## Test Categories

### Unit Tests

```bash
cd $(fgo) && npm test -- --testPathPattern="InferenceMetrics"
```

**Specific tests to write or verify:**

1. **ComputeGauge tests**:
   - Renders 0% utilization with green color
   - Renders 50% utilization with yellow color
   - Renders 90% utilization with red color
   - Renders null state (skeleton)
   - Shows memory, active jobs, latency, and total stats

2. **StorageUsage tests**:
   - Calculates correct percentage from used/total
   - Renders progress bar at correct width
   - Handles null storage (skeleton)
   - Formats GB values to 1 decimal place

3. **INFTCard tests**:
   - Renders token ID and model name
   - Shows correct status badge for each status
   - Formats inference count with locale string
   - Handles null iNFT (skeleton)

4. **JobTable tests**:
   - Renders correct number of job rows (up to 30)
   - Running jobs show "..." for output tokens and latency
   - Completed jobs show actual values
   - Failed jobs show red status badge
   - Empty jobs array shows empty message

5. **InferenceMetrics integration tests**:
   - Loading state renders skeletons
   - Empty state renders message
   - Data state renders all four sub-components

### Manual Verification

1. [ ] **Gauge animation**: Provide compute data. Verify circular progress ring renders correctly.
2. [ ] **Color transitions**: Test gauge with 30%, 60%, and 90% utilization. Verify green, yellow, red colors.
3. [ ] **Storage bar**: Provide storage data at 25%, 70%, and 95% usage. Verify bar and colors.
4. [ ] **iNFT statuses**: Test with active, minting, and inactive iNFT. Verify badges.
5. [ ] **Running job**: Include a job with status='running'. Verify "..." displays.

## Coverage Requirements

- Minimum coverage: 70% for new component code

## Error Handling Verification

- [ ] Component does not crash with null compute, storage, or iNFT
- [ ] Zero total storage (division by zero) is handled
- [ ] Empty jobs array does not crash
- [ ] Negative utilization values clamped to 0

## Definition of Done

- [ ] All automated tests pass
- [ ] Manual verification complete
- [ ] Coverage meets requirement
- [ ] Edge cases handled

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
