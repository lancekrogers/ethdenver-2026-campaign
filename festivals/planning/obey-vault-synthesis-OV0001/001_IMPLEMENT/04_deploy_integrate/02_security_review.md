---
fest_type: task
fest_id: 01_security_review.md
fest_name: 04_security_review
fest_parent: 04_deploy_integrate
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:25:34.304002-06:00
fest_tracking: true
---

# Task: Security Review

## Objective

Conduct a manual code review of ObeyVault.sol and the agent runtime to verify no critical vulnerabilities exist before mainnet deployment with real USDC.

## Requirements

- [ ] Review role assignment: only guardian can change agent, no privilege escalation paths
- [ ] Review token extraction: agent can only swap (never transfer/withdraw tokens directly)
- [ ] Review daily volume tracking: cannot be bypassed or reset by agent
- [ ] Review pause: stops all agent operations (executeSwap, deposit, redeem)
- [ ] Review TWAP oracle: 30-minute window resists short-term manipulation
- [ ] Run `forge test -vvv` to verify all tests pass with verbose output
- [ ] Optionally run slither if installed
- [ ] Document findings in `workflow/design/synthesis/security-review.md`

## Implementation

See implementation plan Task 17 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to review:**
- `projects/contracts/src/ObeyVault.sol`
- `projects/agent-defi/internal/vault/client.go`
- `projects/agent-defi/internal/risk/manager.go`

**Key files to create:**
- `workflow/design/synthesis/security-review.md`

## Done When

- [ ] All requirements met
- [ ] Security review document written with findings (or clean bill)
- [ ] No critical vulnerabilities identified (or all critical findings fixed)
