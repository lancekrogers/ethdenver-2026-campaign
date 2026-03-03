# Chainlink CRE Demo E2E (Live / Submission-Ready)

This guide runs the full local stack with live agent services plus CRE bridge wiring, and captures submission evidence.

## Audience

- Final demo run
- Submission evidence capture
- Judge walkthrough preparation

## Prerequisites

- Docker + Docker Compose
- `just`
- `.env.docker` configured with Hedera / Base / 0G values
- Optional for on-chain CRE write: CRE wallet secrets in `projects/cre-risk-router/.env`

Create env file if needed:

```bash
cp .env.docker.example .env.docker
```

If local ports are occupied, set custom values:

```bash
DASHBOARD_PORT=3001
CRE_BRIDGE_PORT=8081
```

## Step 1: Launch full live stack

```bash
just live
```

`just live` runs:

- `just docker build-all`
- `just docker up-all`

and now includes:

- `dashboard`
- `coordinator`
- `inference`
- `defi`
- `cre-bridge`

with `CRE_ENDPOINT` wiring to `http://cre-bridge:8080/evaluate-risk`.

## Step 2: Execute live CRE scenario flow

```bash
just chainlink demo
```

Confirm output contains:

- one approved decision (`approved=true`)
- one denied decision (`approved=false` + denial reason)

## Step 3: Capture evidence package

```bash
just evidence collect
just evidence validate
```

Artifacts appear in:

`workflow/explore/cre-demo/evidence/latest/`

## Step 4 (Optional but recommended): CRE on-chain broadcast proof

```bash
just chainlink broadcast
```

Capture in your submission notes:

- transaction hash
- network
- contract address
- timestamp

## Step 5: Teardown

```bash
just chainlink down
```

## Judge Walkthrough Checklist

1. Dashboard open with `CRE Decisions` panel visible
2. `HCS Feed` filtered to `risk_check_requested/approved/denied`
3. Approved and denied scenarios shown in terminal output
4. Evidence directory contents ready for inclusion in post
5. Optional broadcast tx hash captured and linked

## Requirement Mapping (Chainlink Convergence)

- CRE-based workflow execution: `just chainlink demo`
- End-to-end simulation proof: approved + denied outcomes
- Reproducible command path: root `just` workflows
- On-chain write evidence (optional step upgraded to required for final submission): `just chainlink broadcast`

Canonical requirements source:

- `docs/2026_requirements/moltbook/chainlink/clink-converge-hackathon.md`
