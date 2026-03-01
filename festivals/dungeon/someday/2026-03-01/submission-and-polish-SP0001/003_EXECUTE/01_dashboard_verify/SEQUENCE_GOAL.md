---
fest_type: sequence
fest_id: 01_dashboard_verify
fest_name: dashboard_verify
fest_parent: 003_EXECUTE
fest_order: 1
fest_status: pending
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Sequence Goal: 01_dashboard_verify

## Objective

Confirm the dashboard compiles, runs in mock mode showing all 5 panels (festival progress, HCS feed, agent activity, DeFi P&L, inference metrics), then configure for live Hedera data.

The dashboard at `projects/dashboard` is a Next.js app that is fully implemented — all panel components, hooks, and data connectors exist. The prior assessment that it was "stub only" was incorrect. This sequence verifies that reality by running the build and connecting to live data.

## Contribution

Dashboard visualization is required for the demo video and validates the full system is observable. Without a working dashboard, the 04_e2e_testing sequence cannot demonstrate system observability, and 11_demo_video cannot show the live agent economy.

## Tasks

| Order | File | Description |
|-------|------|-------------|
| 1 | 01_build_dashboard.md | Run next build, verify mock mode, confirm all 5 panels |
| 2 | 02_configure_live_data.md | Create .env.local with live Hedera sources, verify HCS feed |

## Quality Gates

| Order | File | Type | Description |
|-------|------|------|-------------|
| 3 | 03_testing.md | testing | Verify build, mock mode, live mode |
| 4 | 04_review.md | review | Code review of any fixes made |
| 5 | 05_iterate.md | iterate | Address review findings |
| 6 | 06_fest_commit.md | fest_commit | Commit all changes |

## Dependencies

None. This sequence can run in parallel with:
- `02_unblock_0g`
- `03_unblock_base`

## Provides

- `04_e2e_testing` — working dashboard for system observability during end-to-end testing
- `11_demo_video` — verified dashboard to record for submission

## Definition of Done

- `next build` passes with zero errors
- Mock mode shows all 5 panels with data
- Live mode connects to Hedera testnet mirror node
- HCS feed panel displays historical messages from prior testnet runs
