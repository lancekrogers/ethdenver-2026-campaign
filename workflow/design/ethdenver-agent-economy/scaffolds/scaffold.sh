#!/usr/bin/env bash
set -euo pipefail

# Scaffold all ETHDenver agent economy projects.
#
# Creates each project as a private GitHub repo via `gh repo create`, adds it
# to the campaign via `camp project add`, builds out the internal directory
# structure with Go/Node/Foundry boilerplate, and pushes the scaffold commit.
#
# The .tree files in this directory document the intended structure but are NOT
# fed to t2s — t2s has depth-tracking bugs with nested directories. Instead,
# this script uses mkdir -p + touch + heredocs directly.
#
# Usage:
#   ./scaffold.sh           # Create all projects
#   ./scaffold.sh --dry-run # Preview only
#
# Prerequisites:
#   - camp CLI and gh CLI available and authenticated
#   - Run from campaign root (ethdenver2026/)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAMPAIGN_ROOT="$(camp run pwd 2>/dev/null || pwd)"
DRY_RUN="${1:-}"

GITHUB_ORG="lancekrogers"

info()  { printf "==> %s\n" "$*"; }
skip()  { printf "  ⊘ %s (already exists, skipping)\n" "$*"; }

run() {
    if [[ "$DRY_RUN" == "--dry-run" ]]; then
        printf "  [dry-run] %s\n" "$*"
        return 0
    fi
    eval "$@"
}

project_exists() {
    [[ -d "$CAMPAIGN_ROOT/projects/$1" ]]
}

# Create a private GitHub repo and add it to the campaign as a submodule.
# Usage: create_project <name>
create_project() {
    local name="$1"
    run "gh repo create $GITHUB_ORG/$name --private --add-readme"
    run "camp project add git@github.com:$GITHUB_ORG/$name.git --no-commit"
}

# Commit scaffold inside a project and push to GitHub.
# Usage: commit_and_push <dir> <name>
commit_and_push() {
    local dir="$1"
    local name="$2"
    cd "$dir" && git add -A && git commit -m "Scaffold $name project structure" && git push && cd "$CAMPAIGN_ROOT"
}

# ─── Go project: agent-coordinator ───────────────────────────────────

scaffold_agent_coordinator() {
    local name="agent-coordinator"
    local dir="$CAMPAIGN_ROOT/projects/$name"

    if project_exists "$name"; then skip "$name"; return; fi
    info "Creating project: $name"

    create_project "$name"
    if [[ "$DRY_RUN" == "--dry-run" ]]; then return; fi

    # Directory structure
    mkdir -p "$dir/cmd/coordinator"
    mkdir -p "$dir/internal/hedera"
    mkdir -p "$dir/internal/festival"
    mkdir -p "$dir/internal/coordinator"
    mkdir -p "$dir/internal/daemon"
    mkdir -p "$dir/internal/config"

    # Stub Go files
    touch "$dir/cmd/coordinator/main.go"
    touch "$dir/internal/hedera/hcs.go"
    touch "$dir/internal/hedera/hts.go"
    touch "$dir/internal/hedera/schedule.go"
    touch "$dir/internal/hedera/account.go"
    touch "$dir/internal/festival/protocol.go"
    touch "$dir/internal/festival/messages.go"
    touch "$dir/internal/festival/reader.go"
    touch "$dir/internal/coordinator/coordinator.go"
    touch "$dir/internal/coordinator/assigner.go"
    touch "$dir/internal/coordinator/monitor.go"
    touch "$dir/internal/coordinator/gates.go"
    touch "$dir/internal/daemon/client.go"
    touch "$dir/internal/config/config.go"

    # go.mod
    cat > "$dir/go.mod" << GOMOD
module github.com/$GITHUB_ORG/$name

go 1.23
GOMOD

    write_go_boilerplate "$dir" "$name" \
        "Coordinator agent — reads festival plans, assigns tasks via HCS, monitors progress, enforces quality gates, manages HTS payments. Uses daemon Execute RPC to run fest commands within the campaign sandbox. fest detects campaign root and festivals/ automatically."

    commit_and_push "$dir" "$name"
}

# ─── Go project: agent-inference ─────────────────────────────────────

scaffold_agent_inference() {
    local name="agent-inference"
    local dir="$CAMPAIGN_ROOT/projects/$name"

    if project_exists "$name"; then skip "$name"; return; fi
    info "Creating project: $name"

    create_project "$name"
    if [[ "$DRY_RUN" == "--dry-run" ]]; then return; fi

    mkdir -p "$dir/cmd/agent"
    mkdir -p "$dir/internal/zerog"
    mkdir -p "$dir/internal/inft"
    mkdir -p "$dir/internal/agent"
    mkdir -p "$dir/internal/daemon"
    mkdir -p "$dir/internal/config"

    touch "$dir/cmd/agent/main.go"
    touch "$dir/internal/zerog/compute.go"
    touch "$dir/internal/zerog/storage.go"
    touch "$dir/internal/zerog/da.go"
    touch "$dir/internal/inft/contract.go"
    touch "$dir/internal/inft/metadata.go"
    touch "$dir/internal/agent/agent.go"
    touch "$dir/internal/agent/tasks.go"
    touch "$dir/internal/daemon/client.go"
    touch "$dir/internal/config/config.go"

    cat > "$dir/go.mod" << GOMOD
module github.com/$GITHUB_ORG/$name

go 1.23
GOMOD

    write_go_boilerplate "$dir" "$name" \
        "Inference agent — routes inference to 0G Compute (REST API), stores results on 0G Storage, maintains ERC-7857 iNFT on 0G Chain via go-ethereum, uses 0G DA for audit trail. Receives tasks from coordinator via HCS."

    commit_and_push "$dir" "$name"
}

# ─── Go project: agent-defi ──────────────────────────────────────────

scaffold_agent_defi() {
    local name="agent-defi"
    local dir="$CAMPAIGN_ROOT/projects/$name"

    if project_exists "$name"; then skip "$name"; return; fi
    info "Creating project: $name"

    create_project "$name"
    if [[ "$DRY_RUN" == "--dry-run" ]]; then return; fi

    mkdir -p "$dir/cmd/agent"
    mkdir -p "$dir/internal/strategy"
    mkdir -p "$dir/internal/identity"
    mkdir -p "$dir/internal/payments"
    mkdir -p "$dir/internal/attribution"
    mkdir -p "$dir/internal/agent"
    mkdir -p "$dir/internal/daemon"
    mkdir -p "$dir/internal/config"

    touch "$dir/cmd/agent/main.go"
    touch "$dir/internal/strategy/engine.go"
    touch "$dir/internal/strategy/pnl.go"
    touch "$dir/internal/identity/erc8004.go"
    touch "$dir/internal/payments/x402.go"
    touch "$dir/internal/attribution/erc8021.go"
    touch "$dir/internal/agent/agent.go"
    touch "$dir/internal/agent/tasks.go"
    touch "$dir/internal/daemon/client.go"
    touch "$dir/internal/config/config.go"

    cat > "$dir/go.mod" << GOMOD
module github.com/$GITHUB_ORG/$name

go 1.23
GOMOD

    write_go_boilerplate "$dir" "$name" \
        "DeFi agent — executes trading strategies on Base via go-ethereum, registers identity via ERC-8004, pays for compute via x402, attributes transactions via ERC-8021. Reports P&L to coordinator via HCS."

    commit_and_push "$dir" "$name"
}

# ─── Node.js project: hiero-plugin ──────────────────────────────────

scaffold_hiero_plugin() {
    local name="hiero-plugin"
    local dir="$CAMPAIGN_ROOT/projects/$name"

    if project_exists "$name"; then skip "$name"; return; fi
    info "Creating project: $name"

    create_project "$name"
    if [[ "$DRY_RUN" == "--dry-run" ]]; then return; fi

    mkdir -p "$dir/src/commands"
    mkdir -p "$dir/src/templates/hedera-project"

    touch "$dir/src/index.js"
    touch "$dir/src/commands/init.js"
    touch "$dir/src/commands/status.js"
    touch "$dir/src/commands/navigate.js"
    touch "$dir/src/templates/hedera-project/README.md"

    cat > "$dir/package.json" << 'PACKAGE'
{
  "name": "hiero-plugin-camp",
  "version": "0.1.0",
  "description": "Hiero CLI plugin — camp workspace management for Hedera developers",
  "main": "src/index.js",
  "hiero": {
    "type": "plugin",
    "commands": ["camp"]
  },
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "license": "MIT"
}
PACKAGE

    cat > "$dir/justfile" << 'JUSTFILE'
@default:
    just --list --justfile {{source_file()}}

install:
    npm install

dev:
    node src/index.js

test:
    npm test
JUSTFILE

    cat > "$dir/.gitignore" << 'GITIGNORE'
node_modules/
dist/
.env
.env.local
.DS_Store
*.log
GITIGNORE

    cat > "$dir/.env.example" << 'ENVEXAMPLE'
# hiero-plugin configuration
CAMP_BINARY_PATH=camp
ENVEXAMPLE

    cat > "$dir/CLAUDE.md" << 'CLAUDE'
# hiero-plugin

Hiero CLI plugin — Node.js wrapper around camp for Hedera developer workspaces.
Registers commands under `hiero camp` namespace. Follows PLUGIN_ARCHITECTURE_GUIDE.md.

## Build

```bash
just install  # Install dependencies
just dev      # Run plugin
just test     # Run tests
```

## Structure

- `src/index.js` — Plugin manifest and entry point
- `src/commands/` — Plugin commands (init, status, navigate)
- `src/templates/` — Hedera project templates bundled with plugin
CLAUDE

    cat > "$dir/README.md" << 'README'
# hiero-plugin-camp

Hiero CLI plugin providing camp workspace management for Hedera developers.
README

    commit_and_push "$dir" "$name"
}

# ─── Next.js project: dashboard ──────────────────────────────────────

scaffold_dashboard() {
    local name="dashboard"
    local dir="$CAMPAIGN_ROOT/projects/$name"

    if project_exists "$name"; then skip "$name"; return; fi
    info "Creating project: $name"

    create_project "$name"
    if [[ "$DRY_RUN" == "--dry-run" ]]; then return; fi

    mkdir -p "$dir/src/app"
    mkdir -p "$dir/src/components/festival-view"
    mkdir -p "$dir/src/components/hcs-feed"
    mkdir -p "$dir/src/components/agent-activity"
    mkdir -p "$dir/src/components/defi-pnl"
    mkdir -p "$dir/src/components/inference-metrics"
    mkdir -p "$dir/src/lib"
    mkdir -p "$dir/public"

    touch "$dir/src/app/layout.tsx"
    touch "$dir/src/app/page.tsx"
    touch "$dir/src/app/globals.css"
    touch "$dir/src/components/festival-view/index.tsx"
    touch "$dir/src/components/hcs-feed/index.tsx"
    touch "$dir/src/components/agent-activity/index.tsx"
    touch "$dir/src/components/defi-pnl/index.tsx"
    touch "$dir/src/components/inference-metrics/index.tsx"
    touch "$dir/src/lib/daemon.ts"
    touch "$dir/src/lib/hedera.ts"
    touch "$dir/public/.gitkeep"

    cat > "$dir/justfile" << 'JUSTFILE'
@default:
    just --list --justfile {{source_file()}}

install:
    npm install

dev:
    npm run dev

build:
    npm run build

lint:
    npm run lint

clean:
    rm -rf .next/ out/ node_modules/
JUSTFILE

    cat > "$dir/.gitignore" << 'GITIGNORE'
node_modules/
.next/
out/
dist/
.env
.env.local
.DS_Store
*.log
GITIGNORE

    cat > "$dir/.env.example" << 'ENVEXAMPLE'
# Dashboard configuration

# Daemon connection (for direct gRPC — dev only)
OBEY_DAEMON_SOCKET=${XDG_RUNTIME_DIR}/obey/daemon.sock

# Hub WebSocket (for production)
NEXT_PUBLIC_HUB_WS_URL=wss://api.obey.app/v1/events

# Hedera mirror node
NEXT_PUBLIC_HEDERA_MIRROR_URL=https://testnet.mirrornode.hedera.com
ENVEXAMPLE

    cat > "$dir/CLAUDE.md" << 'CLAUDE'
# dashboard

Observer dashboard — festival progress, agent activity, HCS message feed,
DeFi P&L, 0G inference metrics. Read-only, consumes daemon events via hub WebSocket.

## Build

```bash
just install  # Install dependencies
just dev      # Development server
just build    # Production build
```

## Structure

- `src/app/` — Next.js app router pages
- `src/components/` — React components organized by data source
- `src/lib/` — Client libraries (daemon gRPC, hedera mirror node)

## Development

- Dashboard is read-only — it observes, never acts
- All data comes from daemon events via hub WebSocket or direct gRPC
- Components are organized by data source (festival, HCS, agent, DeFi, inference)
CLAUDE

    cat > "$dir/README.md" << 'README'
# dashboard

ETHDenver agent economy observer dashboard.
README

    commit_and_push "$dir" "$name"
}

# ─── Foundry project: contracts ──────────────────────────────────────

scaffold_contracts() {
    local name="contracts"
    local dir="$CAMPAIGN_ROOT/projects/$name"

    if project_exists "$name"; then skip "$name"; return; fi
    info "Creating project: $name"

    create_project "$name"
    if [[ "$DRY_RUN" == "--dry-run" ]]; then return; fi

    mkdir -p "$dir/src"
    mkdir -p "$dir/test"
    mkdir -p "$dir/script"

    touch "$dir/src/AgentSettlement.sol"
    touch "$dir/src/ReputationDecay.sol"
    touch "$dir/test/.gitkeep"
    touch "$dir/script/.gitkeep"

    cat > "$dir/foundry.toml" << 'TOML'
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
TOML

    cat > "$dir/justfile" << 'JUSTFILE'
@default:
    just --list --justfile {{source_file()}}

build:
    forge build

test:
    forge test

clean:
    forge clean
JUSTFILE

    cat > "$dir/.gitignore" << 'GITIGNORE'
out/
cache/
lib/
.env
.DS_Store
GITIGNORE

    cat > "$dir/.env.example" << 'ENVEXAMPLE'
# Contract deployment
BASE_RPC_URL=https://sepolia.base.org
PRIVATE_KEY=
ENVEXAMPLE

    cat > "$dir/CLAUDE.md" << 'CLAUDE'
# contracts

Optional Solidity contracts for agent settlement and reputation decay.
Track 2 submission if time permits.

## Build

```bash
just build  # Compile contracts
just test   # Run Forge tests
```

## Structure

- `src/` — Solidity contracts
- `test/` — Forge tests
- `script/` — Deploy scripts
CLAUDE

    cat > "$dir/README.md" << 'README'
# contracts

Solidity contracts for the ETHDenver agent economy.
README

    commit_and_push "$dir" "$name"
}

# ─── Shared helpers ──────────────────────────────────────────────────

write_go_boilerplate() {
    local dir="$1"
    local name="$2"
    local description="$3"

    cat > "$dir/.gitignore" << 'GITIGNORE'
bin/
dist/
*.exe
*.dll
*.so
*.dylib
.env
.env.local
.DS_Store
coverage.out
coverage.html
GITIGNORE

    cat > "$dir/.env.example" << ENVEXAMPLE
# $name configuration
# Copy to .env and fill in values

# Hedera testnet
HEDERA_ACCOUNT_ID=0.0.xxx
HEDERA_PRIVATE_KEY=

# Daemon connection
OBEY_DAEMON_SOCKET=\${XDG_RUNTIME_DIR}/obey/daemon.sock
ENVEXAMPLE

    cat > "$dir/justfile" << 'JUSTFILE'
@default:
    just --list --justfile {{source_file()}}

build:
    go build -o bin/ ./cmd/...

run *ARGS:
    go run ./cmd/... {{ARGS}}

test *ARGS:
    go test ./... {{ARGS}}

test-cover:
    go test -coverprofile=coverage.out ./...
    go tool cover -html=coverage.out -o coverage.html

lint:
    golangci-lint run ./...

tidy:
    go mod tidy

clean:
    rm -rf bin/ coverage.out coverage.html
JUSTFILE

    cat > "$dir/CLAUDE.md" << CLAUDE
# $name

$description

## Build

\`\`\`bash
just build   # Build binary to bin/
just run     # Run the agent
just test    # Run tests
\`\`\`

## Structure

- \`cmd/\` — Entry point
- \`internal/\` — Private packages
- \`justfile\` — Build recipes

## Development

- Follow Go conventions from root CLAUDE.md
- Always pass context.Context as first parameter for I/O
- Use the project's error framework, not fmt.Errorf
- Keep files under 500 lines, functions under 50 lines
CLAUDE

    cat > "$dir/README.md" << README
# $name

$description
README
}

# ─── Main ────────────────────────────────────────────────────────────

cd "$CAMPAIGN_ROOT"

info "Scaffolding ETHDenver agent economy projects"
info "Campaign root: $CAMPAIGN_ROOT"
[[ "$DRY_RUN" == "--dry-run" ]] && info "DRY RUN — no changes will be made"
echo ""

scaffold_agent_coordinator
scaffold_agent_inference
scaffold_agent_defi
scaffold_hiero_plugin
scaffold_dashboard
scaffold_contracts

if [[ "$DRY_RUN" != "--dry-run" ]]; then
    echo ""
    info "All projects scaffolded. Committing and pushing campaign-level changes..."
    camp commit -m "Add scaffolded projects: coordinator, inference, defi, hiero-plugin, dashboard, contracts"
    camp push
    info "Done. Projects:"
    camp project list
else
    echo ""
    info "Dry run complete. Run without --dry-run to execute."
fi
