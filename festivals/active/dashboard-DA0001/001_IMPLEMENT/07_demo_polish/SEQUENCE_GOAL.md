---
fest_type: sequence
fest_id: 07_demo_polish
fest_name: demo_polish
fest_parent: 001_IMPLEMENT
fest_order: 7
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 07_demo_polish

**Sequence:** 07_demo_polish | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Integrate all five dashboard panels into a polished, demo-ready layout optimized for projector/large-screen presentation. Create mock data providers for development and demo without live agents. Verify the 2-second render target and WebSocket reconnection. Execute the final fest commit to complete the festival.

**Contribution to Phase Goal:** This is the final sequence that brings everything together. It takes the five individually-built panels and wires them into a cohesive dashboard layout with the data layer. It also provides mock data so the dashboard can be demonstrated even without live agents running. The output of this sequence is the final demo artifact for ETHDenver judges.

## Success Criteria

### Required Deliverables

- [ ] **Dashboard Layout**: 5-panel grid layout in `src/app/page.tsx` and `src/components/DashboardLayout.tsx`
- [ ] **Mock Data Provider**: Realistic mock data generator in `src/lib/data/mock.ts` toggled via env var
- [ ] **Performance Verified**: All panels render within 2 seconds, WebSocket reconnects automatically
- [ ] **Final Commit**: Complete fest commit chain pushed to remote

### Quality Standards

- [ ] **Presentation Quality**: Layout is readable from 10+ feet on a projector
- [ ] **Dark Theme**: Consistent dark theme throughout all panels
- [ ] **Responsive**: Panels fill the screen without horizontal scrolling on 1920x1080+
- [ ] **TypeScript Strict Mode**: Zero type errors across the entire project

### Completion Criteria

- [ ] All tasks completed
- [ ] All quality gates passed
- [ ] Final commit pushed
- [ ] Dashboard ready for demo

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_layout_tuning.md | Design and implement the final 5-panel grid layout | Dashboard layout ready for demo |
| 02_mock_data.md | Create mock data providers for all 5 panels | Dashboard works without live agents |
| 03_performance_verify.md | Verify render time, reconnection, and optimization | Performance meets requirements |
| 04_fest_commit.md | Final fest commit with full commit chain | Changes tracked and pushed |
| 05_testing_and_verify.md | Test the integrated dashboard | Quality gate |
| 06_code_review.md | Review all integration code | Quality gate |
| 07_review_results_iterate.md | Address findings | Quality gate |

## Dependencies

### Prerequisites (from other sequences)

- **01_data_layer**: All data connectors and hooks
- **02_festival_view**: FestivalView component
- **03_hcs_feed**: HCSFeed component
- **04_agent_activity**: AgentActivity component
- **05_defi_pnl**: DeFiPnL component
- **06_inference_metrics**: InferenceMetrics component

### Provides (to other sequences)

- None. This is the final sequence.

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Dashboard layout renders all 5 panels in grid
- [ ] **Milestone 2**: Mock data makes dashboard look alive without agents
- [ ] **Milestone 3**: Performance verified, final commit pushed
