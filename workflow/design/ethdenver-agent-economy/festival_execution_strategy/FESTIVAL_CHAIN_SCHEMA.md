# Festival Chain Schema — Design Document

## Problem Statement

The Festival Methodology handles **intra-festival** orchestration well: phases, sequences, tasks, quality gates, lifecycle states. But it has no formal mechanism for **inter-festival** orchestration — expressing that festival B depends on festival A, that festivals C and D can run in parallel after A completes, or that a final festival E gates on everything else.

Today this is handled with prose documentation. That works for humans reading a design doc but is:

- Not machine-parseable by `fest` or agents
- Not enforceable (nothing prevents activating a festival before its dependencies are met)
- Not portable (every initiative re-invents the dependency story)
- Disconnected from festival lifecycle states

## Key Insight: Campaign ≠ Initiative

A campaign is like a company — it can have **many concurrent initiatives**. A festival chain groups related festivals that depend on each other within a single initiative. Multiple chains can be active simultaneously, and completed chains archive like any other artifact.

**Hierarchy**: Campaign → Chain(s) → Festival(s) → Phase(s) → Sequence(s) → Task(s)

## Design Goals

1. **Human-readable**: Open the file, understand the dependency graph in seconds
2. **Agent-readable**: `fest` and AI agents parse it to determine what's unblocked
3. **First-class artifact**: Chains have IDs, lifecycle states, and archive to dungeon like festivals
4. **Multi-chain**: A campaign can have many chains running concurrently
5. **Non-breaking**: Existing `fest.yaml` files don't need to change (chain is additive)
6. **Minimal**: Only what's needed to fill the gap

## Proposed Schema

### Directory Structure

```
festivals/
├── chains/                             <── NEW: active chain files
│   └── ethdenver-agents-EC0001.yaml
│
├── planning/                           # Unchanged — festivals
├── active/                             # Unchanged — festivals
├── ready/                              # Unchanged — festivals
├── dungeon/
│   ├── completed/                      # Completed festivals
│   │   └── chains/                     <── NEW: completed chain files
│   ├── archived/
│   └── someday/
├── .festival/
│   └── chains/                         <── NEW: chain schema template + docs
│       ├── CHAIN_TEMPLATE.yaml
│       └── README.md
├── README.md
└── .gitignore
```

**Why `festivals/chains/` and not `festivals/.festival/chains/`?**

`.festival/` is methodology resources (templates, docs, reference). Chain files are **campaign artifacts** — they're authored content specific to the campaign, like festivals themselves. They belong alongside the lifecycle directories, not inside the methodology internals.

### File Naming Convention

```
<chain-name>-<CHAIN_ID>.yaml
```

Following the same pattern as festivals: `hedera-foundation-HF0001`, `chain-agents-CA0001`, etc.

Chain IDs use a two-letter prefix + 4-digit number: `EC0001`, `MG0001`, etc.

Examples:
- `ethdenver-agents-EC0001.yaml`
- `platform-migration-PM0001.yaml`
- `q1-infrastructure-QI0001.yaml`

### Schema Definition

```yaml
# festivals/chains/ethdenver-agents-EC0001.yaml
# ──────────────────────────────────────────────
# Festival Chain — inter-festival dependency graph
# for a single initiative within this campaign.

chain_version: "1.0"

# ─── Chain Identity ──────────────────────────────────────────────
metadata:
  id: EC0001
  name: ethdenver-agents
  goal: "Build a 3-agent autonomous economy on Hedera + 0G + Base for ETHDenver 2026"
  created_at: 2026-02-18T20:00:00Z
  status: active                     # planning | active | completed
  status_history:
    - status: planning
      timestamp: 2026-02-18T20:00:00Z
      notes: "Chain created during campaign planning"
    - status: active
      timestamp: 2026-02-20T10:00:00Z
      notes: "All festivals validated at 100/100, chain activated"

# ─── Festival Nodes ──────────────────────────────────────────────
# Each festival in this chain.
# `ref` is a short alias used in edges and waves below.
# `id` must match the festival's fest.yaml metadata.id.

festivals:
  - ref: hf
    id: HF0001
    name: hedera-foundation
    projects: [agent-coordinator]

  - ref: ca
    id: CA0001
    name: chain-agents
    projects: [agent-inference, agent-defi, agent-coordinator]

  - ref: hp
    id: HP0001
    name: hiero-plugin
    projects: [hiero-plugin]

  - ref: da
    id: DA0001
    name: dashboard
    projects: [dashboard]

  - ref: sp
    id: SP0001
    name: submission-and-polish
    projects: [agent-coordinator, agent-inference, agent-defi, hiero-plugin, dashboard, contracts]

# ─── Dependency Edges ────────────────────────────────────────────
# from → to: `from` must complete (or reach a gate) before `to` can activate.
#
# type:
#   hard — `to` cannot start ANY work until `from` completes
#   soft — `to` can start with mocks/stubs; full integration needs `from`
#
# gate (optional):
#   Unblock when `from` passes this gate instead of full completion.
#   Format: "sequence_name/gate_id" or omit for "completed" (default).

edges:
  - from: hf
    to: ca
    type: hard
    note: "Agents need HCS topics, HTS tokens, coordinator engine, daemon client"

  - from: hf
    to: da
    type: soft
    note: "Dashboard can scaffold with mock data; live panels need HCS/HTS/daemon APIs"

  - from: ca
    to: sp
    type: hard
    note: "Submission needs working agents for E2E testing and demo"

  - from: da
    to: sp
    type: hard
    note: "Submission needs dashboard for demo video and deployment"

  - from: hp
    to: sp
    type: hard
    note: "Submission packages all tracks including hiero-plugin"

# ─── Waves ───────────────────────────────────────────────────────
# Parallel execution groups. Derived from edges but stated explicitly
# for human readability and agent planning.
#
# unlock: condition expression using ref:status
#   "none"           — no prerequisites, start immediately
#   "hf:completed"   — single festival must complete
#   "ca:completed AND da:completed" — multiple must complete

waves:
  - id: 1
    name: "Foundation + Independent"
    unlock: "none"
    festivals: [hf, hp]

  - id: 2
    name: "Agents + Dashboard"
    unlock: "hf:completed"
    festivals: [ca, da]

  - id: 3
    name: "Final Assembly"
    unlock: "ca:completed AND da:completed AND hp:completed"
    festivals: [sp]

# ─── Sequence Hints (optional) ───────────────────────────────────
# For soft dependencies, specify which downstream sequences can
# start early vs which need the upstream to finish.
# Omit entirely if edge-level hard/soft is sufficient.

sequence_hints:
  - festival: da
    early_start:
      sequences: [01_data_layer, 02_festival_view, 03_hcs_feed]
      condition: "Can begin with mock data before hf completes"
    needs_upstream:
      sequences: [04_agent_activity, 05_defi_pnl, 06_inference_metrics, 07_demo_polish]
      condition: "Requires live agent data from ca"

  - festival: ca
    internal_parallelism:
      parallel: [01_inference_zerog, 02_defi_base]
      then: [03_integration_verify]
```

## Schema Field Reference

### Top-Level

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `chain_version` | yes | string | Schema version for forward compatibility |
| `metadata` | yes | object | Chain identity and lifecycle |
| `festivals` | yes | list | Festival nodes in the chain |
| `edges` | yes | list | Dependency relationships |
| `waves` | no | list | Parallel execution groups |
| `sequence_hints` | no | list | Intra-festival parallelism guidance |

### metadata

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `id` | yes | string | Unique chain ID (e.g., `EC0001`) |
| `name` | yes | string | Human-readable chain name |
| `goal` | no | string | What this initiative aims to achieve |
| `created_at` | yes | datetime | Creation timestamp |
| `status` | yes | enum | `planning`, `active`, `completed` |
| `status_history` | yes | list | Lifecycle audit trail |

### festivals[]

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `ref` | yes | string | Short alias used in edges/waves |
| `id` | yes | string | Must match `fest.yaml` `metadata.id` |
| `name` | yes | string | Must match `fest.yaml` `metadata.name` |
| `projects` | no | list | Projects this festival touches |

### edges[]

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `from` | yes | ref | Upstream festival |
| `to` | yes | ref | Downstream festival |
| `type` | yes | enum | `hard` or `soft` |
| `gate` | no | string | Specific gate that unblocks (default: full completion) |
| `note` | no | string | Why this dependency exists |

### Edge Type Semantics

| Type | Meaning | Agent Behavior |
|------|---------|----------------|
| `hard` | Downstream cannot start ANY work | Agent must wait; `fest promote` blocked |
| `soft` | Downstream can start with mocks | Agent may activate but must track upstream for integration |

## Chain Lifecycle

Chains follow the same lifecycle pattern as festivals but at a higher level:

```
festivals/chains/                        # Active chains live here
    ethdenver-agents-EC0001.yaml         # status: active

festivals/dungeon/completed/chains/      # Completed chains archive here
    ethdenver-agents-EC0001.yaml         # status: completed
```

### Lifecycle Flow

```
planning → active → completed → dungeon/completed/chains/
```

1. **planning**: Chain is being designed. Festivals may still be in planning/
2. **active**: Chain is executing. Festivals move through their own lifecycles
3. **completed**: All festivals in the chain have completed. Chain file moves to dungeon

### Chain Completion

A chain is complete when **every festival in its `festivals[]` list** has reached `dungeon/completed/`. At that point:

1. Update `metadata.status` to `completed`
2. Add a status_history entry
3. Move the chain file to `festivals/dungeon/completed/chains/`

### Multiple Concurrent Chains

```
festivals/chains/
    ethdenver-agents-EC0001.yaml         # Initiative 1: hackathon submission
    platform-migration-PM0001.yaml       # Initiative 2: infra migration
    q1-features-QF0001.yaml             # Initiative 3: quarterly feature work
```

Chains are independent. A festival can only belong to **one chain** (enforced by validation). This prevents conflicting dependency graphs.

## Integration with `fest.yaml` (Optional Backlink)

A single optional field in `fest.yaml` creates a bidirectional reference:

```yaml
# In fest.yaml (optional)
metadata:
  id: CA0001
  name: chain-agents
  chain: EC0001              # "I belong to this chain"
```

Not required — the chain file is the source of truth. But lets an agent reading a single festival know it's part of a chain without scanning all chain files.

## Integration with `fest` CLI (Future)

### New Subcommand: `fest chain`

```bash
# ─── Lifecycle ────────────────────────────────────
fest chain create                     # Interactive TUI to create a chain
fest chain list                       # List all active chains
fest chain status <chain-id>          # Show chain graph with festival statuses
fest chain complete <chain-id>        # Mark chain completed, move to dungeon

# ─── Validation ───────────────────────────────────
fest chain validate <chain-id>        # Validate chain against fest.yaml files
fest chain check <festival-ref>       # Is this festival unblocked?
  # → "ca (CA0001) BLOCKED by: hf (HF0001) [active, needs: completed]"
  # → "hp (HP0001) UNBLOCKED — no incoming edges"

# ─── Visualization ───────────────────────────────
fest chain graph <chain-id>           # ASCII dependency graph
fest chain graph <chain-id> --mermaid # Mermaid output
```

### Integration with `fest promote`

When promoting a festival to active:

1. Check if it belongs to a chain (via backlink or chain file scan)
2. If yes, verify hard dependencies are met
3. Warn on unmet hard deps, note soft deps
4. After a festival completes, report newly unblocked downstream festivals

### Validation Rules

```bash
fest chain validate EC0001
```

1. Every `festivals[].id` must match an existing `fest.yaml` `metadata.id`
2. Every `festivals[].name` must match the corresponding `fest.yaml` `metadata.name`
3. `edges[].from` and `edges[].to` must reference valid `festivals[].ref` values
4. No cycles in the edge graph (DAG enforcement)
5. Wave festivals must cover all nodes exactly once
6. Wave unlock conditions must be satisfiable by the edge graph
7. No festival appears in more than one active chain

## Template

The methodology resources would include a chain template:

```
festivals/.festival/chains/
├── CHAIN_TEMPLATE.yaml     # Blank chain with comments
└── README.md               # How to create and manage chains
```

## Open Questions

1. **Cross-chain dependencies?** Currently chains are independent. If chain A's output feeds chain B, that's a higher-level problem. Defer until needed.

2. **Partial completion gates?** The `gate` field on edges allows unblocking at a specific quality gate rather than full festival completion. Useful but adds complexity — keep optional.

3. **Validation strictness?** Should `fest chain validate` hard-block `fest promote`, or just warn? Suggest advisory first, opt-in enforcement later via a chain-level config flag.

4. **Wave auto-derivation?** Waves can be computed from edges (topological sort). Should `fest` auto-derive them? Suggest: author writes them explicitly for readability, `fest chain validate` verifies they match the edge graph.

5. **Chain in .festival/ or festivals/?** Resolved: chain *files* (campaign artifacts) go in `festivals/chains/`. Chain *templates and docs* (methodology resources) go in `festivals/.festival/chains/`.
