---
fest_type: task
fest_id: 01_synthesis_client.md
fest_name: 01_synthesis_client
fest_parent: 03_identity
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:25:32.402435-06:00
fest_tracking: true
---

# Task: Synthesis API Registration Client

## Objective

Create a Go client for the Synthesis API POST /register endpoint that registers the agent with ERC-8004 identity.

## Requirements

- [ ] Create `internal/synthesis/register.go` with RegisterRequest, RegisterResponse, HumanInfo types
- [ ] Implement Client struct with NewClient(baseURL) and Register(ctx, req) method
- [ ] RegisterRequest includes: name, description, agentHarness, model, humanInfo (fullName, email, background, cryptoExperience, aiExperience, codingComfort, problemStatement)
- [ ] RegisterResponse includes: participantId, teamId, name, apiKey, registrationTxn
- [ ] Check ctx.Err() before I/O, use http.NewRequestWithContext
- [ ] Create `internal/synthesis/register_test.go` with httptest mock server: test success (201 Created), test context cancellation

## Implementation

See implementation plan Task 13 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create:**
- `projects/agent-defi/internal/synthesis/register.go`
- `projects/agent-defi/internal/synthesis/register_test.go`

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go test ./internal/synthesis/... -v` passes all tests
