---
fest_type: task
fest_id: 02_verify_quickstarts.md
fest_name: verify quickstarts
fest_parent: 07_readme_polish
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:54.743162-07:00
fest_tracking: true
---

# Task: Verify Quick-Start Instructions in All READMEs

## Objective

Walk through each README's quick-start section step by step, running every command, and fix any instruction that fails or produces an unexpected result so that a developer following the README from scratch can successfully run each project.

## Requirements

- [ ] Root README quick-start (`just demo`) completes without error and the dashboard loads
- [ ] `agent-coordinator` quick-start compiles and starts the agent (mock or testnet)
- [ ] `agent-inference` quick-start compiles and starts the agent
- [ ] `agent-defi` quick-start compiles and starts the agent
- [ ] `dashboard` quick-start starts the dev server or Docker container
- [ ] `contracts` quick-start deploys (or explains testnet deployment) without error
- [ ] `hiero-plugin` quick-start installs the binary and successfully scaffolds a project with at least one template
- [ ] Every environment variable required for a quick-start is listed in the README with a description and example value

## Implementation

### Step 1: Define the test environment

All quick-starts should be tested assuming:
- A fresh clone of the repo (no pre-built binaries)
- Required tools installed: Go 1.22+, Node 20+, Docker, `just`, `golangci-lint`
- No live testnet credentials (use mock/local mode where available)

Document any tool version requirements that are not currently listed in the READMEs and add them.

### Step 2: Test root README quick-start

```bash
# From repo root
just demo
```

Verify: docker compose starts, dashboard loads at `http://localhost:3000`, all 5 panels render.

Fix: any `just` recipe errors, missing docker-compose file references, or port conflicts.

### Step 3: Test agent-coordinator quick-start

```bash
cd projects/agent-coordinator
cp .env.example .env
# Set MOCK_MODE=true or equivalent to avoid needing live Hedera credentials
just build
just run
```

Verify: binary builds to `bin/`, agent starts and prints a log line confirming it is running.

Fix: any missing `.env.example`, incorrect binary output path, or missing Justfile recipe.

### Step 4: Test agent-inference quick-start

```bash
cd projects/agent-inference
cp .env.example .env
just build
just run
```

Verify: binary builds to `bin/`, agent starts.

### Step 5: Test agent-defi quick-start

```bash
cd projects/agent-defi
cp .env.example .env
just build
just run
```

Verify: binary builds to `bin/`, agent starts.

### Step 6: Test dashboard quick-start

```bash
cd projects/dashboard
npm install
npm run dev
```

Or if Docker-based:

```bash
docker build -t dashboard .
docker run -p 3000:3000 dashboard
```

Verify: dev server starts and `http://localhost:3000` loads.

Fix: any missing Node version specification, missing `npm install` step, or broken dev script.

### Step 7: Test contracts quick-start

```bash
cd projects/contracts
just deploy   # or the equivalent deploy command
```

If the quick-start requires testnet credentials, ensure the README clearly states this and provides a link to obtain testnet tokens. The README should not silently fail with a cryptic RPC error.

If there is no `just deploy` recipe, check for `hardhat deploy`, `forge script`, or equivalent and document it.

### Step 8: Test hiero-plugin quick-start

```bash
cd projects/hiero-plugin
just build
# Install to PATH or use ./bin/hiero directly
./bin/hiero camp init --template 0g-agent --name /tmp/test-scaffold
ls /tmp/test-scaffold/
```

Verify: the scaffold directory is created with the expected files.

### Step 9: Fix and update each README

For each failure found in Steps 2-8:
1. Fix the underlying issue (missing recipe, wrong path, missing env var, etc.)
2. Update the README to reflect the correct commands or to document the requirement more clearly

### Step 10: Final pass

Re-read the quick-start section of each README one more time after fixes and confirm the instructions are clear, complete, and correct from the perspective of a developer seeing the project for the first time.

## Done When

- [ ] All requirements met
- [ ] Every quick-start command in every README has been executed and produces the documented result
