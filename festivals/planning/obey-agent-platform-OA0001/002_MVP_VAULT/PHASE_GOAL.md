---
fest_type: phase
fest_id: 002_MVP_VAULT
fest_name: MVP_VAULT
fest_parent: obey-agent-platform-OA0001
fest_order: 2
fest_status: pending
fest_created: 2026-03-13T02:20:18.399213-06:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 002_MVP_VAULT

**Phase:** 002_MVP_VAULT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Deliver an on-chain deposit/withdraw system (Anchor/Rust) that enables users to fund the prediction market agent with USDC, receive proportional share tokens, and withdraw at current NAV. Revenue generation begins here via 0.8% trade fees.

**Context:** Phase 001 produces a working agent trading with platform-owned funds. This phase adds smart contract custody so external users can deposit capital. The MVP vault is intentionally simple (~200 LOC) with admin-controlled NAV updates, acceptable for <$50K AUM. The full vault with oracle-only NAV and anti-gaming comes in Phase 006. This phase is the bridge between "internal prototype" and "product with real users."

## Required Outcomes

Deliverables this phase must produce:

- [ ] Anchor program with VaultState account (authority, agent_wallet, share_mint, usdc_vault, total_nav, total_shares, withdrawal_delay)
- [ ] Initialize instruction creating vault PDA, share token mint (PDA-controlled), and USDC vault account
- [ ] Deposit instruction transferring USDC to vault PDA and minting shares proportional to deposit/NAV (1:1 bootstrap for first deposit)
- [ ] Request + execute withdrawal with share escrow, configurable delay enforcement, proportional USDC transfer, and share burning
- [ ] Admin-only NAV update instruction (verified off-chain against Drift positions)
- [ ] Full lifecycle test: initialize, multi-depositor deposits, NAV updates, proportional withdrawals
- [ ] Attack tests: unauthorized NAV update, unauthorized withdrawal, zero-amount edge cases
- [ ] Devnet deployment with full flow verification using test wallets
- [ ] Go client for vault program: read vault state, submit NAV updates from agent portfolio tracker
- [ ] Agent periodically updating on-chain NAV from Drift position values

## Quality Standards

Quality criteria for all work in this phase:

- [ ] Anchor program compiles with zero warnings under `anchor build`
- [ ] All math uses checked arithmetic (no overflow/underflow possible)
- [ ] PDA seeds are deterministic and documented
- [ ] Access control enforced on every instruction (admin-only, user-only, permissionless as designed)
- [ ] Share token math verified: multi-depositor proportional withdrawal matches expected values within rounding tolerance
- [ ] Go vault client passes context through all RPC calls

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_anchor_vault | Implement the MVP vault Anchor program | Deployed program with deposit, withdraw, and NAV update instructions |
| 02_vault_tests | Verify correctness and security of vault program | Passing lifecycle, attack, and devnet deployment tests |
| 03_agent_vault_client | Connect agent to vault for automated NAV reporting | Go client updating on-chain NAV from Drift positions |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_anchor_vault
- [ ] 02_vault_tests
- [ ] 03_agent_vault_client

## Notes

- This is NOT the full vault contract from design doc 02. It is the minimal version from doc 11 (Fast-Path MVP). The full vault with trade routing, concentration limits, oracle-only NAV, and anti-gaming is Phase 006.
- Trust model: users trust the platform to report accurate NAV. This is acceptable because all Drift BET trades are on-chain and NAV can be independently verified against public Drift positions.
- The share token is an SPL token with PDA-controlled mint authority. Only the vault program can mint/burn.
- Creator ownership shares are deferred to the full vault. In the MVP, the platform operates the agent directly.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
