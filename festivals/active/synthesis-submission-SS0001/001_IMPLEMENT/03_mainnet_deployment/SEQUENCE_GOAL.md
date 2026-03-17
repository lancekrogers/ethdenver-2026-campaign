---
fest_type: sequence
fest_id: 03_mainnet_deployment
fest_name: 03_mainnet_deployment
fest_parent: 001_IMPLEMENT
fest_order: 3
fest_status: completed
fest_created: 2026-03-16T21:31:58.073409-06:00
fest_updated: 2026-03-17T00:16:17.486517-06:00
fest_tracking: true
fest_working_dir: projects/contracts
---


# Sequence Goal: 03_mainnet_deployment

**Sequence:** 03_mainnet_deployment | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-16T21:31:58-06:00

## Sequence Objective

**Primary Goal:** Deploy ObeyVault to Base mainnet, fund with USDC, and execute 2-3 real Uniswap trades to produce verifiable on-chain evidence for hackathon submissions.

**Contribution to Phase Goal:** Mainnet deployment with live trades provides the strongest on-chain evidence for Uniswap, Protocol Labs, and Open Track submissions. Real TxIDs on mainnet are significantly more compelling to judges than testnet evidence.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Funded vault**: ObeyVault deployed to Base mainnet with USDC deposited and WETH approved
- [ ] **Live trades**: 2-3 real Uniswap V3 swaps executed through the vault on Base mainnet
- [ ] **Transaction record**: All deployment and trade TxIDs documented with Basescan links
- [ ] **Vault configuration**: Agent address set, token whitelist configured, boundary parameters active

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] All transactions verified on Basescan
- [ ] Vault boundaries are enforced (maxSwapSize, dailyVolume, slippage)
- [ ] SwapExecuted events emitted with encoded rationale

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_source_mainnet_funds | Acquire USDC + ETH on Base mainnet | Enables vault funding and gas |
| 02_deploy_vault | Deploy ObeyVault contract to Base mainnet | Creates the on-chain vault |
| 03_configure_vault | Set agent, approve tokens, set boundaries | Makes vault operational |
| 04_execute_live_trades | Execute 2-3 Uniswap trades via vault | Produces live trade evidence |
| 05_verify_transactions | Verify all txns on Basescan and record TxIDs | Creates submission-ready evidence |

## Dependencies

### Prerequisites (from other sequences)

- 01_verify_uniswap_api: Must know if the API integration is correct before deploying to mainnet -- determines whether mainnet trades qualify for Uniswap bounty

### Provides (to other sequences)

- Mainnet TxIDs and Basescan links: Used by 06_submission_packaging (all track submissions)
- Deployed contract address: Used by 06_submission_packaging (repo README, video demo)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| USDC sourcing takes too long (bridging delays) | Medium | Medium -- blocks all mainnet work | Start sourcing early, have multiple bridge options ready |
| Deployment fails on mainnet | Low | Medium -- blocks live trades | Test deployment script on Sepolia fork first |
| Live trades lose money | Low | Low -- small amounts, demo cost | Use 20-50 USDC per trade max |
| Base mainnet gas prices spike | Low | Low -- Base L2 gas is typically cheap | Budget extra ETH for gas |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: USDC + ETH acquired on Base mainnet
- [ ] **Milestone 2**: ObeyVault deployed and configured on Base mainnet
- [ ] **Milestone 3**: 2-3 live trades executed and verified on Basescan