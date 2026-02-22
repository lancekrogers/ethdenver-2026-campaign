---
fest_type: sequence
fest_id: 02_base_tx_signing
fest_name: base tx signing
fest_parent: bounty-completion-BC0001
fest_order: 2
fest_status: pending
fest_created: 2026-02-21T16:43:00.349488-07:00
fest_tracking: true
---

# Sequence Goal: 02_base_tx_signing

**Sequence:** 02_base_tx_signing | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T16:43:00-07:00

## Sequence Objective

**Primary Goal:** Add go-ethereum to agent-defi and wire real transaction signing in the 3 stub points (executor, register, x402) plus live Uniswap V3 market data so the Base DeFi agent sends actual on-chain transactions on Base Sepolia.

**Contribution to Phase Goal:** The Base Agent bounty requires demonstrable on-chain activity. Currently executor.go, register.go, and x402.go all have stub implementations that log but never send transactions. Replacing these stubs with real go-ethereum signing code produces verifiable tx hashes on Base Sepolia, qualifying the Base bounty track and providing the on-chain evidence judges expect.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **ethutil package**: `internal/base/ethutil/client.go` with `LoadKey`, `MakeTransactOpts`, `DialClient`, and `AddressFromKey` functions — go-ethereum dependency in go.mod
- [ ] **executor.go real txs**: `executor.Execute` sends real Uniswap V3 swap transactions on Base Sepolia and returns tx hashes
- [ ] **register.go real txs**: `register.Register` sends real ERC-8004 registration transactions on Base Sepolia and returns tx hashes
- [ ] **x402.go real txs**: `x402.Pay` sends real payment transactions on Base Sepolia and returns tx hashes
- [ ] **Live market data**: `GetMarketState` fetches real sqrtPriceX96 and TWAP from on-chain Uniswap V3 pools

### Quality Standards

- [ ] **Build passes**: `just build` exits 0 in projects/agent-defi after all changes
- [ ] **Tests pass**: `just test` exits 0 in projects/agent-defi with no failures
- [ ] **Context propagation**: All new functions accept and forward `context.Context` as first parameter
- [ ] **Error wrapping**: All errors wrapped with operation context, no bare `fmt.Errorf`

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_add_ethutil_package.md | Add go-ethereum dep and create ethutil package | Foundation for all signing tasks |
| 02_wire_executor_signing.md | Replace executor.go stub with real Uniswap V3 swap tx | Delivers executor deliverable |
| 03_wire_register_signing.md | Replace register.go stub with real ERC-8004 registration tx | Delivers register deliverable |
| 04_wire_x402_signing.md | Replace x402.go stub with real payment tx | Delivers x402 deliverable |
| 05_wire_market_state.md | Implement on-chain Uniswap V3 pool queries in GetMarketState | Delivers live market data deliverable |
| 06_testing.md | Run full test suite and verify txs on testnet explorer | Confirms all deliverables work |
| 07_review.md | Code review all changes | Ensures quality standards |
| 08_iterate.md | Address review feedback | Final iteration gate |
| 09_fest_commit.md | Commit and record completion | Marks sequence done |

## Dependencies

### Prerequisites (from other sequences)

- None: This sequence is standalone. Tasks 02–05 depend on task 01 (ethutil must exist first), but the sequence itself has no dependency on other sequences.

### Provides (to other sequences)

- Base Agent bounty qualification: On-chain tx evidence consumed by 002_REVIEW phase

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| go-ethereum version conflicts with existing deps | Med | Med | Run `go mod tidy` after `go get`, resolve conflicts before proceeding |
| Base Sepolia RPC rate limits during testing | Med | Low | Use a dedicated Alchemy/Infura endpoint, not a public RPC |
| Uniswap V3 pool address differs from assumed | Low | Med | Look up WETH/USDC pool on Base Sepolia explorer before hardcoding |
| Private key not available in test env | Low | High | Document required env vars in README, use a dedicated test wallet |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: ethutil package created, go-ethereum in go.mod, `just build` passes
- [ ] **Milestone 2**: All three signing stubs replaced with real tx code, builds pass
- [ ] **Milestone 3**: Live tx hashes confirmed on Base Sepolia explorer for executor, register, and x402

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] Performance benchmarks met

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed
- [ ] Standards compliance verified

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A
