---
fest_type: gate
fest_id: 03_testing.md
fest_name: testing
fest_parent: 01_dashboard_verify
fest_order: 3
fest_status: pending
fest_gate_type: testing
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Gate: Testing

## Objective

Verify the dashboard build passes, mock mode shows all panels, and live mode connects to Hedera data.

## Test Checklist

### Build Verification

- [ ] `npx next build` exits with code 0
- [ ] No TypeScript type errors in build output
- [ ] No missing module errors

### Mock Mode

- [ ] Dashboard starts with `NEXT_PUBLIC_USE_MOCK=true npm run dev`
- [ ] Festival progress panel is visible and shows mock data
- [ ] HCS feed panel is visible and shows mock messages
- [ ] Agent activity panel is visible and shows mock agent states
- [ ] DeFi P&L panel is visible and shows mock trade data
- [ ] Inference metrics panel is visible and shows mock inference data
- [ ] No console errors in the browser

### Live Mode

- [ ] `.env.local` created with correct topic IDs and mirror node URL
- [ ] Dashboard starts with `npm run dev` (no MOCK override)
- [ ] HCS feed panel connects to mirror node without auth errors
- [ ] HCS feed panel shows at least one historical message from testnet
- [ ] No unhandled promise rejections in browser console
- [ ] Empty-state panels (agent activity, DeFi P&L, inference metrics) handle missing data gracefully — no crashes

## Pass Criteria

All checkboxes above must be checked before proceeding to the review gate.
