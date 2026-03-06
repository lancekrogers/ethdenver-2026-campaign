---
fest_type: task
fest_id: 02_implement_fest_command_executor_and_selector.md
fest_name: implement_fest_command_executor_and_selector
fest_parent: 02_coordinator_fest_adapter_core
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.945414-07:00
fest_tracking: true
---

# Task: Implement Fest Command Executor And Selector

## Objective
Build the coordinator festival adapter runtime primitives for command execution and selector resolution.

## Requirements

- [ ] Add a command execution abstraction with timeout support.
- [ ] Implement festival selector resolution using `fest show all --json`.
- [ ] Support explicit `FEST_SELECTOR` override and deterministic priority fallback.
- [ ] Return typed errors for missing fest, selector not found, and malformed output.

## Implementation

1. Ensure context:
```bash
cgo agent-coordinator
fest link .
fest link --show
```

2. Implement command executor in:
- `internal/festival/reader.go`

Add:
- `type CommandRunner interface { Run(ctx context.Context, name string, args ...string) ([]byte, []byte, error) }`
- default runner using `exec.CommandContext`.
- timeout via env (for example `FEST_COMMAND_TIMEOUT_SECONDS`, default 8s).

3. Implement selector resolution in festival package:
- Run and parse:
```bash
fest show all --json
```
- Resolution order:
  1. `FEST_SELECTOR` (if set)
  2. first festival in: `active`, `ready`, `planning`, `dungeon/someday`
- Ignore `dungeon/completed` unless `FEST_ALLOW_COMPLETED=true`.

4. Add typed error values in `internal/festival/protocol.go` or `messages.go`:
- `ErrFestBinaryMissing`
- `ErrSelectorNotFound`
- `ErrShowAllParse`

5. Add structured logging fields for:
- selector
- command name
- duration
- stderr summary (sanitized)

## Done When

- [ ] All requirements met
- [ ] Adapter can resolve selector deterministically with and without `FEST_SELECTOR`
- [ ] Command failures produce typed errors instead of generic strings
