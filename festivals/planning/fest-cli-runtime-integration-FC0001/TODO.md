# Festival TODO - fest-cli-runtime-integration

**Goal**: Integrate fest CLI as a runtime source for coordinator and dashboard, with strict live-mode checks and demo fallback.
**Status**: Planning

---

## Festival Progress Overview

### Phase Completion Status

- [ ] 001_IMPLEMENT: Runtime integration and validation rollout

### Current Work Status

```
Active Phase: 001_IMPLEMENT
Active Sequences: N/A (planning)
Blockers: None
```

---

## Phase Progress

### 001_IMPLEMENT

**Status**: Not Started

#### Sequences

- [ ] 01_campaign_root_mode_and_preflight
- [ ] 02_coordinator_fest_adapter_core
- [ ] 03_coordinator_festival_progress_events
- [ ] 04_dashboard_festival_progress_consumer
- [ ] 05_docs_demo_evidence_updates
- [ ] 06_cross_project_validation_release

---

## Blockers

None currently.

---

## Decision Log

- Runtime integration uses `fest` CLI JSON contracts instead of private internal imports.
- Project-switch protocol (`cgo` + `fest link`) is mandatory before each project change.

---

*Detailed progress available via `fest status`*
