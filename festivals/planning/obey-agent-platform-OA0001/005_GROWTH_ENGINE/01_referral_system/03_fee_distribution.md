---
fest_type: task
fest_id: 03_fee_distribution.md
fest_name: fee_distribution
fest_parent: 01_referral_system
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.530632-06:00
fest_tracking: true
---

# Task: Referral Fee Distribution On-Chain

## Objective

Implement the on-chain `distribute_referral_fees` instruction that splits a portion of platform fees to L1 (10%) and L2 (3%) referrers every time fees are collected from a depositor's trades.

## Requirements

- [ ] `distribute_referral_fees` instruction in the obey_fees Anchor program
- [ ] L1 referrer receives 10% of the platform fee (1000 bps of fee amount)
- [ ] L2 referrer receives 3% of the platform fee (300 bps of fee amount)
- [ ] If no referrer exists, the full fee goes to the platform treasury
- [ ] If L2 referrer is None, L2 share goes to treasury
- [ ] Update `total_earned` on both referrer ReferralState accounts
- [ ] Instruction is called by the vault program via CPI during `execute_trade`
- [ ] Guard: only callable by the vault program (CPI origin check)

## Implementation

### Step 1: Define the instruction accounts

In `programs/obey_fees/src/instructions/distribute_referral_fees.rs`:

```rust
use anchor_lang::prelude::*;
use crate::state::ReferralState;

pub const L1_SHARE_BPS: u64 = 1000; // 10% of platform fee
pub const L2_SHARE_BPS: u64 = 300;  // 3% of platform fee
pub const BPS_DENOMINATOR: u64 = 10_000;

#[derive(Accounts)]
pub struct DistributeReferralFees<'info> {
    /// The vault program calling via CPI.
    pub vault_program: Signer<'info>,

    /// The depositor whose trade generated this fee.
    /// CHECK: Used only to derive the referral PDA.
    pub depositor: AccountInfo<'info>,

    /// The depositor's referral state (may not exist for organic users).
    #[account(
        mut,
        seeds = [ReferralState::SEED_PREFIX, depositor.key().as_ref()],
        bump = referral_state.bump,
    )]
    pub referral_state: Option<Account<'info, ReferralState>>,

    /// L1 referrer token account to receive fee share.
    /// CHECK: Validated against referral_state.referrer.
    #[account(mut)]
    pub l1_referrer_ata: Option<AccountInfo<'info>>,

    /// L2 referrer token account to receive fee share.
    /// CHECK: Validated against referral_state.referrer_l2.
    #[account(mut)]
    pub l2_referrer_ata: Option<AccountInfo<'info>>,

    /// L1 referrer's ReferralState to update total_earned.
    #[account(mut)]
    pub l1_referrer_state: Option<Account<'info, ReferralState>>,

    /// L2 referrer's ReferralState to update total_earned.
    #[account(mut)]
    pub l2_referrer_state: Option<Account<'info, ReferralState>>,

    /// Platform treasury to receive remaining fee.
    /// CHECK: Validated against platform config.
    #[account(mut)]
    pub treasury: AccountInfo<'info>,

    /// Fee source (vault's fee accumulator).
    /// CHECK: Must be the vault PDA token account.
    #[account(mut)]
    pub fee_source: AccountInfo<'info>,

    pub token_program: Program<'info, Token>,
}

pub fn handler(ctx: Context<DistributeReferralFees>, fee_amount: u64) -> Result<()> {
    let mut remaining = fee_amount;

    if let Some(ref referral) = ctx.accounts.referral_state {
        // L1 share: 10% of fee
        let l1_share = fee_amount
            .checked_mul(L1_SHARE_BPS)
            .unwrap()
            .checked_div(BPS_DENOMINATOR)
            .unwrap();

        if let Some(ref l1_ata) = ctx.accounts.l1_referrer_ata {
            // Transfer L1 share
            transfer_fee(&ctx, &ctx.accounts.fee_source, l1_ata, l1_share)?;
            remaining = remaining.checked_sub(l1_share).unwrap();

            // Update L1 referrer earnings
            if let Some(ref mut l1_state) = ctx.accounts.l1_referrer_state {
                l1_state.total_earned = l1_state.total_earned
                    .checked_add(l1_share)
                    .unwrap();
            }
        }

        // L2 share: 3% of fee
        if let Some(_l2_referrer) = referral.referrer_l2 {
            let l2_share = fee_amount
                .checked_mul(L2_SHARE_BPS)
                .unwrap()
                .checked_div(BPS_DENOMINATOR)
                .unwrap();

            if let Some(ref l2_ata) = ctx.accounts.l2_referrer_ata {
                transfer_fee(&ctx, &ctx.accounts.fee_source, l2_ata, l2_share)?;
                remaining = remaining.checked_sub(l2_share).unwrap();

                if let Some(ref mut l2_state) = ctx.accounts.l2_referrer_state {
                    l2_state.total_earned = l2_state.total_earned
                        .checked_add(l2_share)
                        .unwrap();
                }
            }
        }
    }

    // Send remaining fee to treasury
    if remaining > 0 {
        transfer_fee(&ctx, &ctx.accounts.fee_source, &ctx.accounts.treasury, remaining)?;
    }

    emit!(ReferralFeeDistributed {
        depositor: ctx.accounts.depositor.key(),
        fee_amount,
        l1_share: fee_amount - remaining, // approximation
        treasury_share: remaining,
    });

    Ok(())
}

fn transfer_fee<'info>(
    _ctx: &Context<DistributeReferralFees<'info>>,
    from: &AccountInfo<'info>,
    to: &AccountInfo<'info>,
    amount: u64,
) -> Result<()> {
    // SPL token transfer via CPI using vault PDA authority
    // Implementation depends on how the vault PDA signs
    Ok(())
}

#[event]
pub struct ReferralFeeDistributed {
    pub depositor: Pubkey,
    pub fee_amount: u64,
    pub l1_share: u64,
    pub treasury_share: u64,
}
```

### Step 2: Integrate with execute_trade in obey_vault

In the vault's `execute_trade` instruction, after calculating the platform fee, call `distribute_referral_fees` via CPI:

```rust
// In obey_vault execute_trade handler, after fee calculation:
let fee = trade_value * platform.fee_rate_bps as u64 / 10_000;

// CPI to obey_fees::distribute_referral_fees
let cpi_accounts = DistributeReferralFees {
    vault_program: ctx.accounts.vault_signer.to_account_info(),
    depositor: ctx.accounts.depositor.to_account_info(),
    referral_state: ctx.accounts.referral_state.clone(),
    l1_referrer_ata: ctx.accounts.l1_referrer_ata.clone(),
    l2_referrer_ata: ctx.accounts.l2_referrer_ata.clone(),
    l1_referrer_state: ctx.accounts.l1_referrer_state.clone(),
    l2_referrer_state: ctx.accounts.l2_referrer_state.clone(),
    treasury: ctx.accounts.treasury.to_account_info(),
    fee_source: ctx.accounts.vault_ata.to_account_info(),
    token_program: ctx.accounts.token_program.to_account_info(),
};
let cpi_program = ctx.accounts.fees_program.to_account_info();
let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
obey_fees::cpi::distribute_referral_fees(cpi_ctx, fee)?;
```

### Step 3: Write tests

In `tests/test_referral_fees.rs`:

1. `test_fee_distribution_with_l1_only` — user has referrer but no L2, verify 10% to L1, 90% to treasury
2. `test_fee_distribution_with_l1_and_l2` — verify 10% to L1, 3% to L2, 87% to treasury
3. `test_fee_distribution_no_referral` — organic user, verify 100% to treasury
4. `test_total_earned_updated` — verify both L1 and L2 ReferralState.total_earned incremented
5. `test_fee_math_precision` — verify no rounding errors with various fee amounts
6. `test_overflow_protection` — verify checked_mul/checked_div prevent overflow

## Done When

- [ ] All requirements met
- [ ] L1 referrer receives exactly 10% of platform fee on each trade
- [ ] L2 referrer receives exactly 3% of platform fee on each trade
- [ ] Missing referrers cause their share to flow to treasury
- [ ] `total_earned` is updated on both referrer accounts
- [ ] CPI from vault to fees program works correctly
- [ ] `anchor test` passes with all referral fee distribution tests green
