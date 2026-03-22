---
fest_type: task
fest_id: 01_verify_live_mode_connects_to_real_services.md
fest_name: verify live mode connects to real services
fest_parent: 06_end_to_end_verification
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_tracking: true
---

# Task: Verify Live Mode Connects to Real Services

## Objective

Verify that `just live up` connects to real Hedera Mirror Node, real Base Sepolia RPC, and real obey daemon without mock fallbacks.

## Requirements

- [ ] Dashboard connects to real Hedera Mirror Node and polls HCS topics
- [ ] Festival View shows "Source: fest" (not synthetic)
- [ ] Agents connect to real obey daemon (not mock)
- [ ] Agent-defi connects to real Base Sepolia RPC
- [ ] Preflight checks pass before stack starts

## Implementation

1. Ensure .env.live has all real credentials configured
2. Start obey daemon on host: `obey serve`
3. Run `just live up`
4. Verify preflight passes
5. Check dashboard shows real HCS data from Hedera testnet

## Done When

- [ ] All requirements met
- [ ] Live mode runs without mock fallbacks
- [ ] Real HCS messages appear in the dashboard
