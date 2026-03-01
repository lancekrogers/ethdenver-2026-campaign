---
fest_type: task
fest_id: 02_configure_live_data.md
fest_name: configure_live_data
fest_parent: 01_dashboard_verify
fest_order: 2
fest_status: pending
fest_autonomy: high
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Configure Live Data

## Objective

Create `.env.local` with live Hedera data sources. Verify the HCS feed panel shows historical messages from prior testnet runs.

## Context

After confirming the build and mock mode work (task 01), the dashboard must be connected to live Hedera testnet data. The HCS topic IDs from prior testnet runs already have messages — the mirror node should serve them without any agents running.

## Implementation Steps

1. Create `projects/dashboard/.env.local` with the following content:
   ```
   NEXT_PUBLIC_USE_MOCK=false
   NEXT_PUBLIC_HEDERA_TOPIC_IDS=0.0.7999404,0.0.7999405
   NEXT_PUBLIC_HEDERA_MIRROR_NODE_URL=https://testnet.mirrornode.hedera.com
   ```

2. Start the dashboard in live mode:
   ```bash
   cd projects/dashboard && npm run dev
   ```

3. Verify the HCS feed panel:
   - Panel should show real messages from the mirror node
   - Messages from prior testnet runs should appear immediately on load
   - No authentication errors in the browser console

4. Verify other panels handle live mode gracefully:
   - Panels that depend on running agents (agent activity, DeFi P&L, inference metrics) may show empty or zero states — this is expected
   - No crashes or unhandled promise rejections in the console
   - Festival progress panel should display whatever state is available

## Notes

- Do not commit `.env.local` — it should be in `.gitignore` already
- If topic IDs need to be updated, check the Hedera testnet account used for the chain-agents campaign run
- Mirror node URL is public and requires no authentication for read operations

## Done When

Dashboard runs in live mode. HCS feed panel shows real messages from the Hedera testnet mirror node.
