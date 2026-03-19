# Synthesis Hackathon Design Snapshot

## fest-Native Ritual Runtime for OBEY Vault Agent

**Date:** 2026-03-18  
**Status:** Proposed  
**Scope:** Synthesis hackathon submission runtime, ritual execution, artifact generation, and submission-readiness  
**Primary repos:** `obey-agent-economy` campaign root, `projects/agent-defi` submodule

## Summary

OBEY should submit a focused vault-agent project to Synthesis, but the runtime must use the real `fest` CLI and the real `obey` daemon agent runtime rather than a custom reimplementation.

The market research ritual stays in the campaign workspace under `festivals/ritual/`. Each trading cycle creates a real ritual run in `festivals/active/`, starts a real agent session through `obey`, binds that session to the ritual run, and instructs the agent to execute the actual `fest next` loop until the ritual produces `decision.json` and `agent_log_entry.json`.

The hackathon runtime must integrate `fest`; it must not copy or rebuild the `fest` engine inside an MIT-licensed project.

## Why This Design

- `fest` is the real product and should receive product exposure in the hackathon submission.
- `fest` is functional-source licensed and source-available, not open source. Rebuilding its core engine inside an MIT project is the wrong legal and product move.
- The campaign workspace is already the real operating environment for OBEY.
- Protocol Labs wants a structured autonomous loop with real decision artifacts, not a synthetic log.
- The current `agent_log.json` is thin because the ritual was planned but never actually wired into runtime execution.

## Problem Statement

Current state:

- The ritual template exists at `festivals/ritual/agent-market-research-RI-AM0001/`.
- The synthesis submission festival assumes the ritual will be run and will emit `agent_log_entry.json`.
- `projects/agent-defi/cmd/loggen` already knows how to aggregate ritual artifacts and on-chain swap events into `agent_log.json`.
- The actual runtime in `projects/agent-defi/cmd/vault-agent` does not run the ritual. It directly evaluates strategy and executes swaps.
- No completed ritual runs or `agent_log_entry.json` files currently exist in the campaign workspace.

Desired state:

- Every trading cycle can optionally or always create a real ritual run with `fest ritual run`.
- A real `obey` agent session executes the ritual from within the created run directory.
- The ritual's own workflow produces `decision.json` and `agent_log_entry.json`.
- The trading runtime consumes the ritual result and only executes trades when the ritual returns `GO`.
- The runtime refreshes `agent_log.json` from real ritual artifacts and real swap history.
- The final submission can truthfully claim that OBEY uses Festival Methodology as an actual runtime decision framework.

## Primary Goals

1. Use the real `fest` CLI at runtime, not a copy of its workflow engine.
2. Keep the ritual template and run history in the campaign workspace.
3. Use a real `obey` daemon-backed agent session for ritual execution.
4. Produce real `decision.json` and `agent_log_entry.json` artifacts from the ritual workflow.
5. Produce a richer, truthful `agent_log.json` for Protocol Labs.
6. Make the hackathon submission clearly showcase `fest` as part of the OBEY product story.

## Non-Goals

- Do not create a separate `festivals/` workspace inside `projects/agent-defi`.
- Do not reimplement `fest next`, ritual orchestration, quality gates, or festival state transitions in Go.
- Do not duplicate ritual templates across repositories.
- Do not make the dashboard a blocker for submission.
- Do not force mainnet deployment to unblock Protocol Labs or Uniswap, since testnet is sufficient for the minimum claim set.

## Hard Constraints

### Product and licensing constraints

- `fest` remains an external product dependency.
- No `fest` core engine code should be copied into `agent-defi`.
- Runtime integration must be a thin adapter around the actual CLI.

### Runtime constraints

- The runtime must use the actual `fest` binary.
- The runtime must use the actual `obey` daemon agent runtime.
- Ritual execution must be non-deterministic agent execution, not a local deterministic script path.
- The system must verify that the agent is connected to the daemon and that the ritual run completes through real session execution.

### Workspace constraints

- The ritual source of truth must live in the campaign root.
- Ritual runs must be created in `festivals/active/`.
- Completed ritual runs must archive into `festivals/dungeon/completed/`.
- `projects/agent-defi` must operate against the campaign workspace, not its own isolated festival tree.

## Source of Truth and Repository Boundaries

### Campaign repo responsibilities

The campaign repo remains the system of record for:

- ritual template definition
- ritual workflow files
- run history
- archived ritual artifacts
- synthesis design docs
- submission festival planning

Concrete paths:

- `festivals/ritual/agent-market-research-RI-AM0001/`
- `festivals/active/agent-market-research-RI-AM0001-XXXX/`
- `festivals/dungeon/completed/...`

### agent-defi responsibilities

`projects/agent-defi` should only contain:

- a thin runtime bridge to `fest`
- a thin runtime bridge to `obey`
- parsing and validation for ritual outputs
- runtime orchestration logic that decides whether to trade
- aggregation logic for `agent_log.json`

### What not to do

- Do not run `fest init` inside `projects/agent-defi`.
- Do not vendor or port `fest` workflow logic into Go.
- Do not rely on user-local `fest link` state for core runtime correctness. `fest link` can remain optional convenience, but the runtime should not require it because links are stored in `~/.config/fest/navigation.yaml`.

## Current Gap Analysis

### What exists today

- Ritual template: `festivals/ritual/agent-market-research-RI-AM0001/`
- Submission planning that expects ritual-generated artifacts
- `loggen` aggregator in `projects/agent-defi/cmd/loggen`
- `obey` session wrapper in `projects/agent-defi/internal/strategy/obey.go`
- Vault runtime binary in `projects/agent-defi/cmd/vault-agent`

### What is missing

- No real ritual runs have been executed.
- No real `agent_log_entry.json` artifacts exist.
- The runtime loop bypasses `fest`.
- The current `ObeyClient` supports `--festival` but not `--workdir`.
- There is no runtime contract that validates daemon connectivity before a cycle starts.
- There is no code that maps ritual `decision.json` into a trade signal.
- There is no automatic post-cycle refresh of `agent_log.json`.

## Proposed Runtime Architecture

### High-level flow

1. `vault-agent` begins a cycle.
2. The runtime bridge calls `fest ritual run agent-market-research-RI-AM0001 --json` from the campaign root.
3. `fest` creates a real run in `festivals/active/` with a hex counter.
4. The runtime bridge parses the returned run identifier and run path.
5. The runtime bridge creates a real `obey` session bound to:
   - campaign: `Obey-Agent-Economy`
   - festival: the created ritual run ID
   - workdir: the created ritual run directory
6. The runtime bridge sends an instruction to the agent to execute the actual `fest next` loop until the ritual is complete.
7. The agent performs the ritual tasks using the custom workflow defined in the ritual template.
8. The ritual produces:
   - `decision.json`
   - `agent_log_entry.json`
9. The runtime bridge verifies those artifacts exist and parses them.
10. If the result is `GO`, the runtime continues into risk check and trade execution.
11. Whether the decision is `GO` or `NO_GO`, the runtime refreshes `agent_log.json` from ritual artifacts plus on-chain events.

### Architectural rule

The runtime owns orchestration around `fest`.  
`fest` owns ritual lifecycle and workflow semantics.  
`obey` owns agent session execution.  
The ritual workflow owns the content of the decision artifacts.

## Daemon-Backed Agent Runtime Requirement

This is a hard requirement.

The ritual must not be executed by:

- a local deterministic parser
- a hardcoded Go decision tree
- a fake "auto-complete" helper
- a direct shell loop that marks tasks done without a real agent session

The ritual must be executed by a real agent session created through `obey`, using a real provider/model runtime.

### Minimum daemon verification requirements

For every runtime-started ritual:

1. Session creation must succeed through `obey session create`.
2. The created session ID must be captured in logs.
3. The session must be bound to the ritual run ID.
4. The session must start in the ritual run directory via `--workdir`.
5. The runtime must fail closed if daemon session creation or messaging fails.

### Verification outputs to log

- campaign ID
- ritual template ID
- ritual run ID
- ritual run path
- obey session ID
- provider
- model
- daemon socket path
- ritual completion status
- artifact paths found

## CLI Contracts

### fest commands used by runtime

Creation:

```bash
fest ritual run agent-market-research-RI-AM0001 --json
```

Task discovery and ritual progression:

```bash
fest next --json
```

Optional verification and inspection:

```bash
fest show --festival <run-id> --json --roadmap
```

### obey commands used by runtime

Session creation:

```bash
obey session create \
  --campaign Obey-Agent-Economy \
  --festival <run-id> \
  --workdir <run-path> \
  --provider <provider> \
  --model <model> \
  --agent vault-trader
```

Session message:

```bash
obey session send <session-id> "<instruction>"
```

## Required Artifact Contract

The ritual run must produce, at minimum:

- `003_DECIDE/01_synthesize_decision/results/decision.json`
- `003_DECIDE/01_synthesize_decision/results/agent_log_entry.json`

The runtime should not infer success from task status alone. It should require these files to exist and parse cleanly.

### decision.json requirements

`decision.json` should be treated as the machine-readable trading decision. It must contain enough information to determine:

- `GO` vs `NO_GO`
- token pair
- size guidance
- rationale
- confidence
- any relevant guardrail or risk outputs

### agent_log_entry.json requirements

`agent_log_entry.json` is the discover-phase audit artifact for Protocol Labs. It must reflect actual tools used, actual reasoning summary, errors, retries, and duration from the ritual run.

## Proposed Code Changes

### Campaign repo changes

#### 1. Keep the ritual in the campaign root

No new festival workspace should be added to `projects/agent-defi`.

The existing ritual template remains the only ritual template:

- `festivals/ritual/agent-market-research-RI-AM0001/`

#### 2. Harden the ritual template for unattended agent execution

Update the ritual so it is safe for daemon-driven unattended runs:

- remove ambiguity from task instructions
- make output file locations explicit
- ensure `decision.json` and `agent_log_entry.json` are required outputs
- ensure a `NO_GO` path still counts as successful ritual completion
- make validation steps explicit and machine-checkable

#### 3. Add a small runtime-focused note to synthesis docs

Document that the Synthesis runtime uses:

- campaign-root ritual templates
- real `fest ritual run`
- real `obey` sessions
- archived ritual artifacts as submission evidence

### agent-defi changes

#### 1. Add a thin `fest` runtime bridge

Add a package such as:

- `internal/festruntime/`

Responsibilities:

- invoke `fest ritual run --json`
- parse run ID and path
- optionally inspect run status with `fest show --festival ... --json --roadmap`
- locate expected artifact files
- return structured results to the runtime loop

This package must not implement festival logic itself.

#### 2. Promote `ObeyClient` into a reusable session bridge

Current wrapper:

- `internal/strategy/obey.go`

Required updates:

- support `--workdir`
- support dynamic per-cycle festival IDs
- expose provider/model/session metadata for logs
- be reusable outside plain strategy evaluation

Whether this stays in `strategy/` or moves to a more general package is an implementation choice. Functionally, it becomes a runtime session client rather than only an LLM helper.

#### 3. Replace direct LLM-only decisioning with ritual-backed decisioning

Current loop shape:

- market fetch
- strategy evaluate
- risk check
- swap

New loop shape:

- ritual run create
- daemon-backed agent execution of ritual
- parse `decision.json`
- map ritual decision to signal
- risk check as defense-in-depth
- swap if `GO`
- aggregate logs

#### 4. Add a ritual decision parser

Add a small parser that converts ritual outputs into the runtime's in-memory signal representation.

Responsibilities:

- parse `decision.json`
- normalize decision types
- derive `trading.Signal`
- preserve reason text for vault `reason` bytes and submission artifacts

#### 5. Trigger `agent_log.json` refresh after ritual completion

Preferred approach:

- refactor `cmd/loggen` logic into an internal package shared by the CLI and runtime

Fallback approach:

- shell out to the existing `loggen` binary or `go run ./cmd/loggen`

Preferred output:

- refresh `projects/agent-defi/agent_log.json` after each completed ritual cycle

## Suggested Runtime Interfaces

### Fest runtime bridge

```text
type RitualRun struct {
  FestivalID string
  RunPath string
  DecisionPath string
  AgentLogEntryPath string
}
```

### Daemon session bridge

```text
type SessionInfo struct {
  SessionID string
  Provider string
  Model string
  WorkDir string
}
```

### Ritual result

```text
type RitualResult struct {
  Run RitualRun
  Session SessionInfo
  Decision string
  Signal trading.Signal
}
```

These are orchestration contracts only. They are not substitutes for `fest`.

## Expected Code Touch Points

### Campaign repo

- `festivals/ritual/agent-market-research-RI-AM0001/`
- `workflow/design/2026-03-18-synthesis-fest-ritual-runtime/README.md`
- `docs/2026_requirements/synthesis/submission-guide.md`
- `festivals/active/synthesis-submission-SS0001/`

### agent-defi repo

- `cmd/vault-agent/main.go`
- `internal/loop/runner.go`
- `internal/strategy/obey.go`
- `cmd/loggen/main.go`
- new package: `internal/festruntime/`
- optional shared package extracted from `cmd/loggen`

## Runtime Configuration Contract

The runtime needs explicit configuration for both the campaign workspace and the agent runtime. The first implementation should prefer environment variables so the hackathon setup stays simple and inspectable.

### Required configuration

- `OBEY_CAMPAIGN_ROOT`
  - absolute path to the campaign workspace root
  - example: `/Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy`
- `FEST_BIN`
  - path or command name for the real `fest` binary
  - default: `fest`
- `OBEY_BIN`
  - path or command name for the real `obey` CLI
  - default: `obey`
- `OBEY_PROVIDER`
  - provider name passed to the daemon-backed session
- `OBEY_MODEL`
  - model name passed to the daemon-backed session

### Strongly recommended configuration

- `OBEY_DAEMON_SOCKET`
  - explicit daemon socket path if the runtime needs to verify daemon connectivity
- `OBEY_AGENT_NAME`
  - agent identity used by `obey session create`
  - default can remain `vault-trader`
- `OBEY_RITUAL_ID`
  - ritual template selector
  - default: `agent-market-research-RI-AM0001`
- `OBEY_RITUAL_TIMEOUT`
  - bounded wait time for a ritual run to complete
- `OBEY_LOGGEN_CMD`
  - optional override if the first implementation shells out to the existing `loggen`

### Configuration rules

- The runtime must fail closed if `OBEY_CAMPAIGN_ROOT` is missing or invalid.
- The runtime must fail closed if `fest` or `obey` is not available.
- The runtime must fail closed if provider/model configuration is missing for daemon-backed execution.
- The runtime must log the effective configuration values needed for debugging, excluding secrets.

## Step-by-Step Implementation Plan

### Phase 1: Lock the campaign-side ritual contract

1. Review the existing ritual workflow files.
2. Make output file guarantees explicit.
3. Ensure the `NO_GO` path still writes valid artifacts.
4. Ensure every required task can be executed autonomously by an agent.
5. Confirm the ritual does not depend on interactive human-only steps.

### Phase 2: Add the `fest` bridge in `agent-defi`

1. Create the thin bridge package.
2. Implement `fest ritual run --json` invocation from campaign root.
3. Parse returned run metadata.
4. Add post-run inspection via `fest show --festival <run-id> --json --roadmap`.
5. Add artifact path resolution helpers.

### Phase 3: Add the daemon-backed session path

1. Extend the current `obey` wrapper to support `--workdir`.
2. Pass dynamic ritual run IDs into session creation.
3. Log session metadata.
4. Fail closed when the daemon cannot be reached.
5. Prove a real session can be created from runtime code.

### Phase 4: Replace the runtime decision path

1. Insert ritual creation at the start of each cycle.
2. Execute the ritual through `obey`.
3. Parse `decision.json`.
4. Convert ritual output into a runtime signal.
5. Keep risk manager as defense-in-depth rather than primary decision-maker.

### Phase 5: Generate submission artifacts continuously

1. Refresh `agent_log.json` after each completed cycle.
2. Confirm `agent_log_entry.json` is archived in the completed ritual run.
3. Confirm the aggregate log contains both:
   - discover entries from ritual artifacts
   - execute/verify entries from on-chain swap events
4. Verify that three or more cycles produce a believable Protocol Labs trail.

### Phase 6: End-to-end validation

1. Start the daemon.
2. Start the vault agent.
3. Confirm a ritual run appears in `festivals/active/`.
4. Confirm an `obey` session is created and bound to the ritual run.
5. Confirm the ritual completes via real agent execution.
6. Confirm artifacts are produced.
7. Confirm `agent_log.json` refreshes.
8. Confirm trade execution happens only after a real ritual `GO`.

## Implementation Deliverables

### Deliverable 1: campaign ritual hardening

- ritual instructions are safe for unattended agent execution
- output paths are explicit
- both `GO` and `NO_GO` paths produce valid artifacts

### Deliverable 2: fest bridge

- runtime can create a ritual run through `fest ritual run --json`
- runtime can inspect progress and resolve artifact paths

### Deliverable 3: daemon-backed obey bridge

- runtime can create a real session through `obey`
- runtime binds the session to the created ritual run and run directory
- runtime logs the real session metadata

### Deliverable 4: ritual-backed vault decision loop

- runtime blocks trade execution until a ritual result is available
- runtime parses `decision.json`
- runtime continues to risk and execution only on ritual `GO`

### Deliverable 5: artifact aggregation

- runtime refreshes `agent_log.json`
- at least three real ritual runs exist for submission evidence

## Acceptance Criteria

The design is not complete until all of the following are true:

1. Starting the vault runtime creates a real ritual run under `festivals/active/`.
2. The ritual run is created by the real `fest` binary, not synthetic file creation.
3. A real `obey` session is created for that run and logged with a session ID.
4. The session is bound to the ritual run directory via `--workdir`.
5. The ritual completes through repeated real `fest next` execution from inside that run context.
6. The ritual emits both `decision.json` and `agent_log_entry.json`.
7. A `NO_GO` outcome results in no trade execution and still counts as a successful ritual run.
8. A `GO` outcome can proceed to risk checks and then a real swap path.
9. `projects/agent-defi/agent_log.json` refreshes from ritual artifacts plus execution evidence.
10. At least three runtime-driven ritual runs can be demonstrated before submission.

## Verification Commands

These are the concrete checks the implementation should support during development and demo rehearsal.

### Binary availability

```bash
fest --help
obey --help
```

### Daemon availability

```bash
obey session create --help
```

If the runtime has a daemon health check command available, that check should be added to the implementation and documented beside the runtime startup instructions.

### Ritual creation and inspection

```bash
fest ritual run agent-market-research-RI-AM0001 --json
fest show --festival <run-id> --json --roadmap
```

### Artifact checks

```bash
find festivals/active -name decision.json
find festivals/active -name agent_log_entry.json
```

### Aggregate log checks

```bash
test -f projects/agent-defi/agent_log.json
jq '.' projects/agent-defi/agent_log.json >/dev/null
```

## Verification Plan

### Runtime verification

- daemon reachable
- session creation succeeds
- session ID logged
- ritual run path exists
- ritual run status progresses
- output artifacts exist

### Artifact verification

- `decision.json` parses
- `agent_log_entry.json` parses
- `projects/agent-defi/agent_log.json` parses
- discover entries come from ritual artifacts
- execute entries come from real swap events

### Submission verification

- at least 3 complete ritual runs exist
- at least 1 `GO` and at least 1 `NO_GO`
- Protocol Labs narrative can honestly cite real ritual execution
- the demo can show a run appearing in `festivals/active/` and later in `dungeon/completed/`

## Submission Impact

This design directly improves:

- Protocol Labs Cook: real discover to plan to execute to verify loop
- Protocol Labs Receipts: stronger, structured evidence trail
- Open Track: clearer product differentiation around `fest`

This design indirectly improves:

- Uniswap, if the execution path also proves the real API integration claim

This design is more valuable than building more dashboard scope because it changes the truthfulness and competitiveness of the submission itself.

## Risks

### Risk: daemon session path is flaky

Impact:

- runtime cannot claim real agent execution

Mitigation:

- fail closed
- add explicit daemon verification before each cycle
- log session metadata for debugging

### Risk: ritual workflow is too ambiguous for unattended execution

Impact:

- inconsistent outputs or stuck runs

Mitigation:

- tighten workflow instructions
- make artifact requirements explicit
- validate with at least three manual runtime-driven runs

### Risk: runtime loops forever waiting on the ritual

Impact:

- trading cycle stalls

Mitigation:

- add bounded timeouts
- inspect ritual status with `fest show --festival ... --json --roadmap`
- treat incomplete artifact generation as failure

### Risk: hackathon reviewers interpret the system as hand-wavy

Impact:

- weaker Protocol Labs scoring

Mitigation:

- show the real `fest ritual run`
- show the real `obey` session
- show the real generated artifacts
- show the aggregated `agent_log.json`

## Demo Readiness Checklist

- a daemon-backed session can be started on demand
- a ritual run appears live in `festivals/active/`
- at least one completed run is visible in archived history
- a `NO_GO` run can be shown
- a `GO` run can be shown
- `agent_log.json` contains multiple believable entries
- the demo script explains that `fest` is the real runtime product and not a mocked subsystem

## Decision Summary

The ritual lives in the campaign workspace.  
`projects/agent-defi` integrates with the real `fest` CLI and the real `obey` daemon.  
No duplicate `festivals/` tree is created in the submodule.  
No `fest` core engine is reimplemented.  
The hackathon submission becomes stronger because the runtime story is finally true.
