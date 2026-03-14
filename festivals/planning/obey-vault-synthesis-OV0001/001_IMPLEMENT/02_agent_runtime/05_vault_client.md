---
fest_type: task
fest_id: 01_vault_client.md
fest_name: 01_vault_client
fest_parent: 02_agent_runtime
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:24:37.731196-06:00
fest_tracking: true
---

# Task: Vault Client Go Bindings

## Objective

Generate Go bindings from ObeyVault ABI via abigen and implement a VaultClient interface for reading vault state and submitting swaps.

## Requirements

- [ ] Generate ABI bindings: extract ABI from Foundry output, run abigen to create `internal/vault/bindings.go`
- [ ] Create `internal/vault/client.go` with Client interface (USDCBalance, TotalAssets, SharePrice, ExecuteSwap, HeldTokens)
- [ ] Define SwapParams and Config structs
- [ ] Implement ExecuteSwap using abigen-generated transactor
- [ ] Create `internal/vault/client_test.go` with context cancellation tests
- [ ] All functions check ctx.Err() before starting I/O

## Implementation

See implementation plan Task 8 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create:**
- `projects/agent-defi/internal/vault/bindings.go` (generated)
- `projects/agent-defi/internal/vault/client.go`
- `projects/agent-defi/internal/vault/client_test.go`

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go test ./internal/vault/... -v` passes
