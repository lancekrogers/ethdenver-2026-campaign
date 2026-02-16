# camp CLI — Production Capabilities

> Source: `camp` v0.dev — Go, 35+ commands, 32 internal packages
> Part of the obey toolchain (`github.com/obedience-corp/camp`)

## What camp Is

camp manages **multi-project AI workspaces** with fast navigation. It creates standardized campaign directories, manages git submodules as projects, and enables instant navigation through category shortcuts and TUI fuzzy finding.

This ETHDenver repository IS a camp campaign. The directory structure, project management, and navigation all run through camp.

---

## Campaign Structure

```
ethdenver2026/                   # Campaign root
├── .campaign/                   # Camp metadata
│   ├── campaign.yaml            # Campaign config (name, projects, settings)
│   └── jumps.yaml               # Navigation shortcuts and bookmarks
├── projects/                    # Git submodules and repos
│   └── worktrees/               # Git worktrees for parallel dev
├── festivals/                   # Festival methodology planning (via fest)
├── workflow/                    # Development workflow artifacts
│   ├── design/                  # Design documents
│   ├── code_reviews/            # Code review notes
│   ├── pipelines/               # CI/CD automation
│   └── intents/                 # Future work items
├── ai_docs/                     # AI-generated documentation
├── docs/                        # Human-authored documentation
├── dungeon/                     # Archived/paused work
├── justfile                     # Root build recipes
└── CLAUDE.md                    # AI agent instructions
```

---

## Command Reference (Hackathon-Relevant)

### Navigation (`cgo` shell function)

| Command | Destination |
|---------|-------------|
| `cgo` | Campaign root |
| `cgo p` | `projects/` |
| `cgo pw` | `projects/worktrees/` |
| `cgo f` | `festivals/` |
| `cgo w` | `workflow/` |
| `cgo d` | `docs/` |
| `cgo a` | `ai_docs/` |
| `cgo du` | `dungeon/` |
| `cgo cr` | `workflow/code_reviews/` |
| `cgo pi` | `workflow/pipelines/` |
| `cgo de` | `workflow/design/` |
| `cgo i` | `workflow/intents/` |
| `cgo <name>` | Fuzzy find any target |

Requires: `eval "$(camp shell-init zsh)"` in shell config.

### Project Management

| Command | Purpose |
|---------|---------|
| `camp project list` | List all projects in the campaign |
| `camp project add <url>` | Add git repo as submodule |
| `camp project remove` | Remove a project |
| `camp project new` | Create a new project from scratch |

Projects are managed as git submodules. Worktrees enable parallel branch development.

### Intent System

| Command | Purpose |
|---------|---------|
| `camp intent list` | List all intents |
| `camp intent add` | Add a new intent |
| `camp intent show` | Show intent details |
| `camp intent move` | Move intent through status flow |

Status flow: `inbox → active → ready → dungeon`

### Git Integration

| Command | Purpose |
|---------|---------|
| `camp commit` | Commit changes in campaign root |
| `camp push` | Push campaign changes to remote |
| `camp log` | Show campaign git log |
| `camp status` | Show campaign git status |
| `camp sync` | Safely synchronize submodules |

### Campaign Registry (Global)

| Command | Purpose |
|---------|---------|
| `camp list` | List all registered campaigns |
| `camp switch` | Switch to a different campaign |
| `camp transfer` | Copy files between campaigns |
| `camp register` | Register campaign in global registry |
| `camp clone` | Clone a campaign with full submodule setup |

### Utilities

| Command | Purpose |
|---------|---------|
| `camp doctor` | Diagnose and fix campaign health issues |
| `camp run` | Execute command from campaign root, or just recipe in a project |
| `camp copy` / `camp move` | File operations within campaign |
| `camp pin` / `camp pins` | Bookmark directories |
| `camp shortcuts` | View all available navigation shortcuts |
| `camp dungeon` | Manage archived/paused work |
| `camp leverage` | Compute leverage scores for projects |

### Planning

| Command | Purpose |
|---------|---------|
| `camp flow` | Manage status workflows |
| `camp gather` | Import external data into intent system |
| `camp intent` | Manage campaign intents |

---

## Hackathon Relevance

**For the build process:**
- Campaign structure organizes all 6+ projects (coordinator, inference, defi, dashboard, hiero-plugin, contracts)
- `cgo` navigation enables instant switching between projects during rapid development
- `camp sync` keeps submodules aligned
- `camp run` dispatches just recipes across projects

**For the Hiero CLI plugin (Track 4):**
- The `hiero camp` plugin wraps camp's Go binary in a Node.js Hiero CLI plugin
- Any Hedera developer can use `hiero camp init` to get a structured workspace
- This is a real developer tool, not a hackathon toy

**For demo and exposure:**
- Campaign structure is visible in the GitHub repo — judges see organized multi-project workspace
- `camp shortcuts` output demonstrates professional tooling
- `camp doctor` shows the tool maintains workspace health

**Production proof:**
- camp manages the obey-campaign (the parent campaign for all obey tools) with multiple subprojects
- Used daily across campaigns with dozens of projects
- Navigation shortcuts eliminate context-switching friction
