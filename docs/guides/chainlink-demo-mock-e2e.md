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

## What This Proves

- Dashboard renders CRE-related UI (`CRE Decisions` panel + risk events in `HCS Feed`)
- CRE risk engine produces both approved and denied outcomes deterministically
- Evidence bundle generation works from campaign root

## Step 1: Start mock dashboard

```bash
just demo
```

Open `http://localhost:3000` and confirm the 6 panels render, including `CRE Decisions`.

## Step 2: Run deterministic CRE integration scenarios

If ports `3000` or `8080` are occupied, override them inline:

```bash
DASHBOARD_PORT=3001 CRE_BRIDGE_PORT=8081 just chainlink demo
```

Expected output includes two responses:

- approved decision (`"approved": true`)
- denied decision (`"approved": false`, reason such as `signal_confidence_below_threshold`)

## Step 3: Generate and validate evidence

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

## Step 4: Teardown

```bash
DASHBOARD_PORT=3001 CRE_BRIDGE_PORT=8081 just chainlink down
```

## Requirement Mapping (Chainlink Convergence)

- CRE workflow simulation proof: demonstrated by deterministic risk responses + evidence artifacts
- Meaningful decision logic: approved and denied scenario outputs
- Reproducibility: one-command root workflows (`just chainlink demo`, `just evidence collect`)

For formal hackathon requirements, see:

- `docs/2026_requirements/moltbook/chainlink/clink-converge-hackathon.md`
