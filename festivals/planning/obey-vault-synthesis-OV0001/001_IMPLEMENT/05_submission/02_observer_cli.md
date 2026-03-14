---
fest_type: task
fest_id: 01_observer_cli.md
fest_name: 01_observer_cli
fest_parent: 05_submission
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:25:35.194708-06:00
fest_tracking: true
---

# Task: Observer CLI

## Objective

Create a CLI tool that queries vault on-chain state and displays USDC balance, total assets (NAV), share price, held tokens, and trade history for monitoring and demo purposes.

## Requirements

- [ ] Create `cmd/observer/main.go` using vault.NewClient to read state
- [ ] Display: vault address, USDC balance, total assets (NAV), share price, held tokens list
- [ ] Read VAULT_ADDRESS and RPC_URL from environment
- [ ] Format USDC values with proper decimal handling (6 decimals)
- [ ] Add placeholder for SwapExecuted event history (can be filled later)
- [ ] Add justfile recipe: `observer: go run ./cmd/observer/`

## Implementation

See implementation plan Task 19 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create:**
- `projects/agent-defi/cmd/observer/main.go`

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go build ./cmd/observer/` compiles successfully
- [ ] Running with VAULT_ADDRESS and RPC_URL displays vault state
