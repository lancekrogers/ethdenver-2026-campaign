---
fest_type: task
fest_id: 01_build_dashboard.md
fest_name: build_dashboard
fest_parent: 01_dashboard_verify
fest_order: 1
fest_status: pending
fest_autonomy: high
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Build Dashboard

## Objective

Run `next build` in the dashboard project. If the build fails, investigate and fix the issues. Then run the dashboard in mock mode and verify all 5 panels render correctly.

## Context

The dashboard at `projects/dashboard` is a Next.js app that is expected to be fully implemented. All panel components, hooks, and data connectors should already exist. The goal here is verification and any minor fixes — not a rewrite.

## Implementation Steps

1. Install dependencies if not already installed:
   ```bash
   cd projects/dashboard && npm install
   ```

2. Run the production build:
   ```bash
   npx next build
   ```
   The build must pass with zero errors. Warnings are acceptable.

3. If the build fails:
   - Read the error output carefully
   - Identify the failing file(s) and error type
   - Fix only what is broken — do not refactor working code
   - Re-run the build until it passes

4. Run the dashboard in mock mode:
   ```bash
   NEXT_PUBLIC_USE_MOCK=true npm run dev
   ```

5. Verify all 5 panels render with mock data:
   - Festival progress panel
   - HCS feed panel
   - Agent activity panel
   - DeFi P&L panel
   - Inference metrics panel

## Expected Outcome

- `next build` exits with code 0
- Mock mode starts without runtime errors
- All 5 panels are visible and populated with mock data

## Done When

Build passes. Mock mode shows all 5 panels with data.
