# Chainlink CRE Demo E2E (Mocked / Deterministic)

This guide demonstrates the Chainlink hackathon feature set without relying on live wallets or on-chain broadcasts.

## Audience

- Local development
- Demo rehearsal
- CI-style reproducibility checks

## Prerequisites

- Docker + Docker Compose
- `just`
- Campaign dependencies installed (`just install`)
- Optional but recommended: `fest` binary available for runtime diagnostics (`just fest status`)

## What This Proves

- Dashboard renders CRE-related UI (`CRE Decisions` panel + risk events in `HCS Feed`)
- CRE risk engine produces both approved and denied outcomes deterministically
- Runtime source behavior is explicit in dashboard (`Source: fest` or `Source: synthetic (fallback)`)
- Evidence bundle generation works from campaign root

## Step 1: Check mode and fest diagnostics (optional but recommended)

```bash
just mode status
just fest status || true
```

Expected:

- demo mode command path is visible
- if `fest` is unavailable, demo can still proceed with synthetic fallback

## Step 2: Start mock dashboard

```bash
just demo
```

Open `http://localhost:3000` and confirm the 6 panels render, including `CRE Decisions`.

## Step 3: Run deterministic CRE integration scenarios

If ports `3000` or `8080` are occupied, override them inline:

```bash
DASHBOARD_PORT=3001 CRE_BRIDGE_PORT=8081 just chainlink demo
```

Expected output includes two responses:

- approved decision (`"approved": true`)
- denied decision (`"approved": false`, reason such as `signal_confidence_below_threshold`)

## Step 4: Verify Festival View source label

```bash
just chainlink status
```

In dashboard `Festival View`, capture which label is visible:

- `Source: fest`
- or `Source: synthetic (fallback)`

Record the run context (`demo`) and timestamp in your notes.

## Step 5: Generate and validate evidence

```bash
DASHBOARD_PORT=3001 CRE_BRIDGE_PORT=8081 just evidence collect
just evidence validate
```

Artifacts are written to:

`workflow/explore/cre-demo/evidence/latest/`

Expected files:

- `approved.json`
- `denied.json`
- `scenario-results.json`
- `run.log`
- `dashboard-checklist.json`
- `submission-ready.md`

## Step 6: Teardown

```bash
DASHBOARD_PORT=3001 CRE_BRIDGE_PORT=8081 just chainlink down
```

## Evidence Checklist

- [ ] Approved and denied scenario outputs captured
- [ ] `Festival View` source label captured (`fest` or `synthetic`)
- [ ] Run context noted (`demo`) with timestamp
- [ ] Evidence files archived under `workflow/explore/cre-demo/evidence/latest/`

## Requirement Mapping (Chainlink Convergence)

- CRE workflow simulation proof: demonstrated by deterministic risk responses + evidence artifacts
- Meaningful decision logic: approved and denied scenario outputs
- Reproducibility: one-command root workflows (`just chainlink demo`, `just evidence collect`)

For formal hackathon requirements, see:

- `docs/2026_requirements/moltbook/chainlink/clink-converge-hackathon.md`
