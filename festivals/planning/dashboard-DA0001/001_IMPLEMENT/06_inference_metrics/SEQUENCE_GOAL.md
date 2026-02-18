---
fest_type: sequence
fest_id: 06_inference_metrics
fest_name: inference_metrics
fest_parent: 001_IMPLEMENT
fest_order: 6
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 06_inference_metrics

**Sequence:** 06_inference_metrics | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Build the Inference Metrics panel component that displays 0G compute utilization, storage usage, iNFT status, and recent inference job history.

**Contribution to Phase Goal:** The Inference Metrics panel is one of five required dashboard panels. It shows judges the AI compute layer of the agent economy -- GPU utilization from 0G, storage capacity usage, iNFT lifecycle status, and inference job throughput. This panel demonstrates that the system uses decentralized AI infrastructure (0G) rather than centralized cloud providers.

## Success Criteria

### Required Deliverables

- [ ] **InferenceMetrics Component**: Working panel component at `src/components/panels/InferenceMetrics.tsx`
- [ ] **Compute Gauge**: GPU utilization and memory utilization displays
- [ ] **Storage Bar**: Used vs total storage capacity bar
- [ ] **iNFT Status Card**: Current iNFT status with metadata
- [ ] **Job History Table**: Recent inference jobs with model, status, tokens, latency

### Quality Standards

- [ ] **TypeScript Strict Mode**: No type errors
- [ ] **Read-Only**: Component only displays metrics, never submits inference jobs
- [ ] **Visual Clarity**: Gauge and bar charts are immediately readable at demo distance

### Completion Criteria

- [ ] All tasks completed
- [ ] Quality gates passed
- [ ] Code review completed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_design_component.md | Design the panel wireframe | Establishes visual and API contract |
| 02_implement_panel.md | Build the React component | Delivers the working panel |
| 03_testing_and_verify.md | Test the component | Quality gate |
| 04_code_review.md | Review code quality | Quality gate |
| 05_review_results_iterate.md | Address findings | Quality gate |

## Dependencies

### Prerequisites (from other sequences)

- **01_data_layer**: ComputeMetrics, StorageMetrics, INFTStatus, InferenceJob types

### Provides (to other sequences)

- **InferenceMetrics component**: Used by 07_demo_polish for the final dashboard layout
