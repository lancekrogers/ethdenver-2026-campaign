---
fest_type: task
fest_id: 01_entry_point.md
fest_name: 05_entry_point
fest_parent: 02_agent_runtime
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:24:37.807432-06:00
fest_tracking: true
---

# Task: vault-agent Entry Point

## Objective

Create the vault-agent binary entry point that wires all components (vault client, strategy, risk manager, trading loop) with environment-based configuration and graceful shutdown.

## Requirements

- [ ] Create `cmd/vault-agent/main.go`
- [ ] Load config from environment: VAULT_RPC_URL, VAULT_ADDRESS, AGENT_PRIVATE_KEY, ANTHROPIC_API_KEY, TOKEN_IN, TOKEN_OUT, LLM_MODEL
- [ ] Wire vault.NewClient, strategy.NewLLMStrategy with ClaudeClient, risk.NewManager, loop.New
- [ ] Default parameters: 5-minute interval, 1000 USD max position, 10000 USD daily volume, 10% drawdown halt
- [ ] Graceful shutdown via signal.NotifyContext (SIGINT, SIGTERM)
- [ ] Add justfile recipe: `vault-agent: go run ./cmd/vault-agent/`

## Implementation

See implementation plan Task 12 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create:**
- `projects/agent-defi/cmd/vault-agent/main.go`

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go build ./cmd/vault-agent/` compiles successfully
