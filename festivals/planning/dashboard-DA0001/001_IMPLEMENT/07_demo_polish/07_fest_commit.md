---
fest_type: gate
fest_id: 07_fest_commit.md
fest_name: Fest Commit Changes
fest_parent: 07_demo_polish
fest_order: 7
fest_status: pending
fest_gate_type: commit
fest_created: 2026-02-18T14:21:00.582563-07:00
fest_tracking: true
---

# Task: Fest Commit -- Final Dashboard Commit

**Task Number:** 07 | **Parallel Group:** None | **Dependencies:** Testing, Code Review, Iteration | **Autonomy:** medium

## Objective

Create the final commit that captures all dashboard changes and push the complete commit chain: fest commit, camp project commit, git push, camp push. This is the final task in the entire dashboard festival. After this, the dashboard is done.

## Pre-Commit Checklist

Before committing, verify:

- [ ] All tests pass: `cd $(fgo) && npm test`
- [ ] Linting is clean: `cd $(fgo) && npx eslint src/ --max-warnings 0`
- [ ] TypeScript compiles: `cd $(fgo) && npx tsc --noEmit`
- [ ] Build succeeds: `cd $(fgo) && npm run build`
- [ ] No debug code or temporary files included
- [ ] No secrets or credentials in staged changes
- [ ] `.env.local` is in `.gitignore` (only `.env.example` is committed)

## Commit Process

### Step 1: Review staged changes

```bash
cd $(fgo) && git status && git diff --staged
```

### Step 2: Stage all dashboard changes

```bash
cd $(fgo) && git add src/ package.json package-lock.json .env.example tsconfig.json
```

Do NOT stage `.env.local` or `node_modules/`.

### Step 3: Create the fest commit

```bash
fest commit -m "feat: implement complete observer dashboard with five panels

Implemented the real-time observer dashboard for the agent economy:

Data layer:
- WebSocket connector with auto-reconnect for daemon hub events
- gRPC/REST connector for dev mode with env-var toggle
- Hedera mirror node REST client with polling for HCS messages
- React hooks (useWebSocket, useGRPC, useMirrorNode) for panel consumption
- Complete TypeScript type definitions for all data sources

Five visualization panels:
- Festival View: hierarchical phase/sequence/task progress tree
- HCS Feed: real-time agent-to-agent message stream with filtering
- Agent Activity: three agent status cards with heartbeat indicators
- DeFi P&L: revenue vs costs chart with trade history table
- Inference Metrics: GPU gauge, storage bar, iNFT status, job history

Dashboard integration:
- 5-panel grid layout optimized for projector presentation
- Mock data providers for development and demo
- Dark theme with consistent styling
- All panels render within 2 seconds

The dashboard is strictly read-only and never writes to any chain or service.

Part of: 001_IMPLEMENT (dashboard-DA0001)"
```

### Step 4: Create the camp project commit

```bash
camp p commit -m "feat: implement dashboard observer with five panels and data layer"
```

### Step 5: Push the project repo

```bash
cd $(fgo) && git push
```

### Step 6: Push the campaign

```bash
camp push
```

### Step 7: Verify the commit chain

```bash
cd $(fgo) && git log -1 --stat
camp project list
```

## Ethical Requirements

- [ ] **NO** "Co-authored-by" tags for AI assistants
- [ ] **NO** advertisements or promotional content in commit messages

## Definition of Done

- [ ] Pre-commit checklist verified
- [ ] Commit message describes what changed and why
- [ ] Fest commit created
- [ ] Camp project commit created
- [ ] Project repo pushed to GitHub
- [ ] Campaign pushed with updated submodule refs
- [ ] Dashboard festival is COMPLETE

---

**Commit Status:**

- Pre-commit checks: [ ] Pass / [ ] Fail
- Fest commit created: [ ] Yes / [ ] No
- Commit hash: ________________
- Project pushed: [ ] Yes / [ ] No
- Campaign pushed: [ ] Yes / [ ] No
- Festival complete: [ ] Yes / [ ] No
