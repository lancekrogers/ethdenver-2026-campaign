---
fest_type: task
fest_id: 02_implement_root_fest_just_commands.md
fest_name: implement_root_fest_just_commands
fest_parent: 01_campaign_root_mode_and_preflight
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.929424-07:00
fest_tracking: true
---

# Task: Implement Root Fest Just Commands

## Objective
Add a dedicated root-level `just` command surface for runtime fest operations so operators can run health/status checks without remembering raw `fest` commands.

## Requirements

- [ ] Add a new `.justfiles/fest.just` module with at least `status` and `doctor` recipes.
- [ ] Register the new module in root `justfile` and expose it through `just --list`.
- [ ] Ensure commands run from campaign root and return actionable output.

## Implementation

1. Confirm you are in campaign root and linked:
```bash
cgo obey-agent-economy
fest link .
fest link --show
pwd
```

2. Create/update module file:
- Target file: `.justfiles/fest.just`
- Add recipes:
  - `status`: run `fest version`, `fest show all --json | jq` summary, and selector diagnostics.
  - `doctor`: verify `fest` exists, run `fest show all --json`, and return non-zero on failure.

3. Register module in root `justfile`:
- Target file: `justfile`
- Add:
```just
mod fest '.justfiles/fest.just'
```

4. Update mode help output so users can discover the new commands:
- Target file: `.justfiles/mode.just`
- Add `just fest status` and `just fest doctor` to status matrix output.

5. Verify command surface:
```bash
just --list --list-submodules
just fest status
just fest doctor
```

## Done When

- [ ] All requirements met
- [ ] `just fest status` and `just fest doctor` execute successfully from campaign root
- [ ] `just --list --list-submodules` shows `fest` module recipes
