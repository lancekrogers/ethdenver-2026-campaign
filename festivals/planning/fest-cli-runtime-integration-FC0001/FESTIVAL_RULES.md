# Festival Rules: fest-cli-runtime-integration

## Purpose
These rules govern implementation of runtime `fest` integration across campaign root, coordinator, and dashboard.

## Hard Rule: Project Switch Protocol
Before editing files in a different project directory, the assigned worker must execute:

1. `cgo <project-name>` to navigate to the target project.
2. `fest link .` from that project directory.
3. `fest link --show` to verify the active link.

No code edits should begin until these three steps are complete.

## Project Names for This Festival
- Campaign root: `cgo obey-agent-economy`
- Coordinator: `cgo agent-coordinator`
- Dashboard: `cgo dashboard`

If a local alias differs, use an equivalent `cgo` target, then verify with `pwd` and `fest link --show`.

## Engineering Rules
- Integrate through `fest` CLI JSON output, not internal/private package imports.
- Preserve deterministic synthetic fallback for demo mode.
- Enforce fail-fast behavior in live mode unless override is explicit.
- Keep backward compatibility for existing dashboard message handling while adding canonical path.

## Testing Rules
- Add/maintain tests for parser and mapping logic in coordinator.
- Validate dashboard parsing and rendering behavior for both `source=fest` and `source=synthetic`.
- Run root-level validation commands for demo/live mode contracts before finishing sequence quality gates.

## Documentation Rules
- Update runtime guides and README as part of this festival.
- Document exact commands and expected outputs for proof of real integration.

## Completion Rules
A sequence is not complete until:
- Implementation tasks are complete.
- Testing/review/iterate/fest_commit gates are complete.
- Required project switch protocol was followed and recorded.
