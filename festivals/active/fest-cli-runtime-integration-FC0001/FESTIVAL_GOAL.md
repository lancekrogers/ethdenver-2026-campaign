---
fest_type: festival
fest_id: FC0001
fest_name: fest-cli-runtime-integration
fest_status: active
fest_created: 2026-03-06T13:36:57.740491-07:00
fest_updated: 2026-03-06T15:26:22.799942-07:00
fest_tracking: true
---



# fest-cli-runtime-integration

**Status:** Planned | **Created:** 2026-03-06T13:36:57-07:00

## Festival Objective

**Primary Goal:** Integrate `fest` CLI as a true runtime data source for coordinator task planning and dashboard festival progress, with deterministic synthetic fallback in demo mode and strict fail-fast behavior in live mode.

**Vision:** The system must prove that festival progress and execution context are derived from real `fest` JSON outputs at runtime rather than static mock structures. The integration must be operationally safe for hackathon demos, while preserving strong correctness controls for live testnet mode.

## Success Criteria

### Functional Success

- [ ] Coordinator can parse `fest` JSON and derive executable plan/progress snapshots.
- [ ] Dashboard Festival View can render runtime `festival_progress` payloads sourced from `fest`.
- [ ] Root mode commands enforce `fest` availability and selector health in `live-testnet` mode.
- [ ] Demo mode runs with explicit synthetic fallback when `fest` is unavailable.

### Quality Success

- [ ] Every project change sequence starts with explicit `cgo <project-name>` navigation and `fest link .` instructions.
- [ ] Integration includes test coverage for parser, mapping, and fallback behavior.
- [ ] Demo evidence captures source labels (`fest` vs `synthetic`) and command artifacts.

## Progress Tracking

### Phase Completion

- [ ] 001_IMPLEMENT: Deliver runtime integration, fallback contracts, validation flows, and documentation.

## Complete When

- [ ] All phase sequences and quality gates are complete.
- [ ] Required project-switch navigation/link instructions are present at each project transition.
- [ ] Festival can be executed end-to-end using `fest next` without ambiguity.