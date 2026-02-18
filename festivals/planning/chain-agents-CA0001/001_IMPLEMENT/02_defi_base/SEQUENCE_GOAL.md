---
fest_type: sequence
fest_id: 02_defi_base
fest_name: defi_base
fest_parent: 001_IMPLEMENT
fest_order: 2
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 02_defi_base

**Sequence:** 02_defi_base | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Build a complete Base DeFi agent that registers identity via ERC-8004, implements x402 payment protocol for machine-to-machine payments, includes ERC-8021 builder attribution, executes autonomous trading strategies on Base with net-positive economics, and reports P&L back to the coordinator via HCS.

**Contribution to Phase Goal:** This sequence delivers the DeFi agent -- the second specialized agent in the three-agent autonomous economy. The DeFi agent demonstrates that AI agents can operate autonomously on-chain, trade profitably, and communicate results through the shared HCS layer. It targets the Base bounty ($3k+, self-sustaining agent) by proving revenue exceeds operational costs.

**Project:** `agent-defi` at `projects/agent-defi/`

## Success Criteria

### Required Deliverables

- [ ] **Agent Architecture**: Clean package layout in `internal/agent/`, `internal/base/identity/`, `internal/base/payment/`, `internal/base/trading/`, `internal/base/attribution/`, `internal/hcs/`
- [ ] **ERC-8004 Identity**: Agent registers on-chain identity on Base for agent-to-agent recognition
- [ ] **x402 Payment Protocol**: Agent implements HTTP 402 payment flows for machine-to-machine payments
- [ ] **ERC-8021 Attribution**: Agent includes builder attribution codes in all transactions
- [ ] **Autonomous Trading**: Agent executes trading strategies on Base with accurate P&L tracking
- [ ] **Self-Sustaining Economics**: Revenue from trading demonstrably exceeds gas costs and fees
- [ ] **HCS Communication**: Agent subscribes to HCS for task assignments and publishes P&L reports

### Quality Standards

- [ ] **Context Propagation**: All I/O functions accept `context.Context` and respect cancellation
- [ ] **Error Wrapping**: All errors wrapped with operational context
- [ ] **Table-Driven Tests**: Unit tests cover happy path, error cases, and cancellation
- [ ] **Code Size**: No file exceeds 500 lines, no function exceeds 50 lines
- [ ] **Small Interfaces**: All interfaces kept to 3-5 methods maximum

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Agent can demonstrate profitable trading on Base testnet

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_link_project.md | Unlink agent-inference, link agent-defi | Enables `fgo` navigation for DeFi agent work |
| 02_design_agent_architecture.md | Design package layout and trading framework | Blueprint for all DeFi implementations |
| 03_implement_erc8004.md | Register agent identity on Base | On-chain identity for agent recognition |
| 04_implement_x402.md | Implement x402 payment protocol | Machine-to-machine payment capability |
| 05_implement_erc8021.md | Add builder attribution to transactions | Transaction attribution for Base bounty |
| 06_implement_trading.md | Autonomous trading with P&L tracking | Core trading strategy and revenue generation |
| 07_implement_hcs_integration.md | Subscribe to HCS and publish P&L | Connects agent to coordinator communication |
| 08_implement_agent_lifecycle.md | Wire everything into the DeFi agent loop | Integrates all packages into a running binary |
| 09_testing_and_verify.md | Test all integrations and trading | Quality gate: verification |
| 10_code_review.md | Review code quality and standards | Quality gate: code review |
| 11_review_results_iterate.md | Address findings and iterate | Quality gate: iteration |

## Dependencies

### Prerequisites (from other sequences/festivals)

- **hedera-foundation-HF0001**: HCS messaging and HTS payment infrastructure must be complete
- **01_inference_0g**: Not a hard dependency, but the same HCS message envelope format must be used for compatibility

### Provides (to other sequences)

- **Working DeFi Agent**: Used by 03_integration_verify to test the full three-agent cycle
- **P&L Demonstration**: Required proof that revenue exceeds costs for Base bounty

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Trading strategy loses money on testnet | Medium | High | Start with simple arbitrage, track every transaction, add circuit breakers |
| ERC-8004/x402 specs are immature or changed | Medium | Medium | Implement minimal viable version, iterate based on actual spec |
| Base testnet gas costs are unpredictable | Low | Medium | Track gas meticulously, factor into P&L calculations |
| ERC-8021 attribution format not well documented | Medium | Low | Use available examples, contact Base team if needed |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Project linked, architecture designed, identity registered on Base
- [ ] **Milestone 2**: Payment protocol and attribution implemented
- [ ] **Milestone 3**: Trading strategy executing with accurate P&L, HCS reporting working
- [ ] **Milestone 4**: All quality gates passed, agent demonstrates self-sustaining economics

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass with `go test ./...`
- [ ] Trading P&L calculations verified with known inputs
- [ ] Payment flow tested end-to-end
- [ ] Context cancellation tests verify graceful shutdown

### Code Review

- [ ] Code review conducted against project standards
- [ ] Review feedback addressed
- [ ] `go vet` and `staticcheck` pass with no warnings

### Iteration Decision

- [ ] Need another iteration? To be determined after code review
- [ ] If yes, new tasks created with specific findings to address
