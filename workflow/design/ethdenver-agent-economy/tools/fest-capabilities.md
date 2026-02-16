# fest CLI — Production Capabilities

> Source: `fest` v0.dev — Go, ~50 commands, 40 internal packages
> Part of the obey toolchain (`github.com/obedience-corp/fest`)

## What fest Is

fest manages **Festival Methodology** — a goal-oriented project management system designed for AI agent development workflows. It provides a hierarchical planning structure: **Festival → Phase → Sequence → Task**, with quality gates, progress tracking, and orchestrated execution.

fest is **production-ready** and already used to plan and execute real development work. The `agent-simulator-update-AS0003` festival completed 48 of 49 tasks (97%) — proof this isn't a prototype.

For the ETHDenver project, fest serves **two roles**:
1. **Build tool** — we use fest to plan and track the hackathon build itself
2. **Demo subject** — the agents use festival-structured plans for their work, published to HCS

---

## Hierarchy and Metadata

```
Festival                        # Top-level goal
├── fest.yaml                   # Festival metadata (id, status, created, etc.)
├── Phase 1: Research           # Major milestone
│   ├── Sequence 1.1: Data      # Ordered group of tasks
│   │   ├── Task 1.1.1          # Individual work unit (markdown file)
│   │   ├── Task 1.1.2
│   │   └── Task 1.1.3
│   └── Quality Gate            # Validation checkpoint at sequence boundary
├── Phase 2: Strategy
│   └── ...
└── Phase 3: Execution
    └── ...
```

- **fest.yaml** — metadata per festival: ID, name, status, creation date, linked projects
- **Task files** — markdown documents with structured frontmatter (status, assignee, dependencies)
- **Quality gates** — validation steps evaluated at sequence boundaries before proceeding

---

## Command Reference (Hackathon-Relevant)

### Creation

| Command | Purpose |
|---------|---------|
| `fest create festival` | Create new festival (interactive TUI) |
| `fest create phase` | Add phase to existing festival |
| `fest create sequence` | Add sequence to a phase |
| `fest scaffold` | Generate festival structures from a plan document |
| `fest tui` | Interactive UI (Charm) for creation and editing |
| `fest wizard` | Interactive guidance for festival creation |
| `fest insert` | Insert new elements at specific positions |

### Execution and Task Management

| Command | Purpose |
|---------|---------|
| `fest execute` | Orchestrated execution guidance for current task |
| `fest next` | Find the next actionable task |
| `fest task show` | Display task details |
| `fest task completed` | Mark task as completed |
| `fest task block` | Mark task as blocked |
| `fest task reset` | Reset task status |
| `fest commit` | Git commit with task reference ID |

### Progress and Status

| Command | Purpose |
|---------|---------|
| `fest progress` | Tree view with completion percentages per phase/sequence |
| `fest status` | Query entity states (festivals, phases, sequences, tasks) |
| `fest gates` | View and manage quality gate checkpoints |
| `fest deps` | Show task dependency graph |

### Navigation

| Command | Purpose |
|---------|---------|
| `fest go` | Navigate to festivals directory |
| `fest explore` | Interactive hierarchy drilldown (TUI) |
| `fest link` | Link festival to a project directory |
| `fest links` | List all festival-project links |
| `fest unlink` | Remove festival-project link |
| `fgo` / `fls` | Shell shortcuts (via `eval "$(fest shell-init zsh)"`) |

### Context and Query

| Command | Purpose |
|---------|---------|
| `fest context` | Get context for current location or task |
| `fest count` | Token counting for files/directories |
| `fest show` | Display festival information |
| `fest list` | List festivals by status |
| `fest parse` | Parse festival documents into structured output |
| `fest commits` | Query commits by festival element |
| `fest rules` | Display festival-specific rules |

### Structure Management

| Command | Purpose |
|---------|---------|
| `fest remove` | Remove elements and renumber |
| `fest renumber` | Renumber festival elements |
| `fest reorder` | Reorder festival elements |
| `fest validate` | Check structure, find missing tasks (`--fix` to auto-repair) |

### Learning (for AI agents)

| Command | Purpose |
|---------|---------|
| `fest understand methodology` | Learn core principles |
| `fest understand structure` | Understand the 3-level hierarchy |
| `fest understand tasks` | Learn task file conventions |
| `fest intro` | Getting started guide |

### System

| Command | Purpose |
|---------|---------|
| `fest system sync` | Download latest templates |
| `fest system update` | Update methodology files |
| `fest config` | Manage configuration repositories |
| `fest init` | Initialize festival directory structure |
| `fest shell-init` | Output shell integration code |

---

## Hackathon Relevance

**For the build process:**
- `fest create` + `fest scaffold` to set up each project festival
- `fest next` + `fest task completed` to track progress
- `fest progress` to show completion state (useful for demo)
- `fest commit` to maintain audit trail of task-linked commits

**For the agent economy demo:**
- Festival structure becomes the on-chain protocol (published to HCS)
- `fest progress` output maps to dashboard visualization
- Quality gates become on-chain checkpoints
- Task status transitions generate daemon events

**Production proof:**
- `agent-simulator-update-AS0003`: 48/49 tasks completed (97%)
- fest has been used across multiple campaigns with hundreds of tasks
- Not a hackathon prototype — this is the real tool
