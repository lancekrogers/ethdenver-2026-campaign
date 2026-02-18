---
fest_type: gate
fest_id: 03_testing.md
fest_name: Testing and Verification
fest_parent: 06_inference_metrics
fest_order: 3
fest_status: pending
fest_gate_type: testing
fest_created: 2026-02-18T14:21:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 03 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify the Inference Metrics panel works correctly. Focus on compute gauge, storage bar, iNFT card, and job table.

## Test Categories

### Unit Tests

```bash
cd $(fgo) && npm test -- --testPathPattern="InferenceMetrics"
```

**Specific tests:**

1. **ComputeGauge**: 0% green, 50% yellow, 90% red. Null state skeleton. Stats display.
2. **StorageUsage**: Correct percentage calculation. Progress bar width. Null skeleton. GB formatting.
3. **INFTCard**: Token ID, model name, status badges. Null skeleton. Inference count formatting.
4. **JobTable**: Correct row count (up to 30). Running jobs show "..." for output/latency. Status badges. Empty message.
5. **InferenceMetrics integration**: Loading/empty/data states.

### Manual Verification

1. [ ] **Gauge animation**: Circular progress ring renders correctly.
2. [ ] **Color transitions**: 30%, 60%, 90% utilization show green, yellow, red.
3. [ ] **Storage bar**: Test at 25%, 70%, 95% usage.
4. [ ] **iNFT statuses**: Test active, minting, inactive badges.
5. [ ] **Running job**: Status='running' shows "..." for pending values.

## Coverage Requirements

- Minimum coverage: 70% for new component code

## Error Handling Verification

- [ ] Null compute/storage/iNFT handled
- [ ] Zero total storage (division by zero) handled
- [ ] Negative utilization clamped to 0

## Definition of Done

- [ ] All tests pass, manual verification complete, coverage met

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
