---
fest_type: festival
fest_id: SF0002
fest_name: synthesis-fest-ritual-runtime
fest_status: completed
fest_created: 2026-03-18T07:25:57.504332-06:00
fest_updated: 2026-03-22T15:58:43.091698-06:00
fest_tracking: true
---




# synthesis-fest-ritual-runtime

**Status:** Planned | **Created:** 2026-03-18T07:25:57-06:00

## Festival Objective

**Primary Goal:** Implement the real fest-native ritual runtime and daemon-backed obey execution path needed to make the OBEY Vault Agent submission truthful and competitive for Synthesis.

**Vision:** The vault agent should no longer make trade decisions in a synthetic local path. Instead, every cycle should create a real ritual run, execute through a real `obey` daemon session inside the ritual workdir, and emit auditable artifacts that support Protocol Labs judging and the broader Synthesis story.

## Success Criteria

### Functional Success

- [ ] `projects/agent-defi` creates real ritual runs through `fest ritual run --json` and consumes the resulting artifacts.
- [ ] `obey session create` is used with dynamic festival IDs and `--workdir` for runtime-started ritual sessions.
- [ ] `decision.json`, `agent_log_entry.json`, and refreshed aggregate `agent_log.json` are produced by real runtime-driven cycles.

### Quality Success

- [ ] At least three end-to-end ritual-backed cycles can be demonstrated, including at least one `GO` and one `NO_GO` outcome.
- [ ] The implementation fails closed if `fest`, `obey`, or daemon connectivity is unavailable.
- [ ] All festival markers are resolved and `fest validate` passes for the planning scaffold.

## Progress Tracking

### Phase Completion

- [ ] 001_IMPLEMENT: Build the runtime bridge, daemon execution path, artifact aggregation, and submission-ready verification flow.

## Complete When

- [ ] All phases completed
- [ ] The Synthesis submission can honestly show `fest` and `obey` as real runtime dependencies, not mocked subsystems.
- [ ] The Protocol Labs evidence trail is strong enough to attach directly to the live submission package.