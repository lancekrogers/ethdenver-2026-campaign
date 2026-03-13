---
fest_type: task
fest_id: 01_bonus_shares.md
fest_name: bonus_shares
fest_parent: 02_incentives
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.549334-06:00
fest_tracking: true
---

# Task: Early Depositor Bonus Shares

## Objective

Implement the 15% bonus share multiplier in the vault deposit instruction for deposits made within the first 14 days of platform launch, where the platform absorbs the dilution cost rather than the creator.

## Requirements

- [ ] `IncentiveConfig` account storing `bonus_deadline` (unix timestamp = launch + 14 days) and `bonus_multiplier_bps` (11500 = 1.15x)
- [ ] Modify `deposit` instruction in obey_vault to check if current time < bonus_deadline
- [ ] If bonus active: mint `base_shares * 11500 / 10000` to depositor instead of `base_shares`
- [ ] Creator's ownership share is calculated on the pre-bonus amount (creator not diluted by bonus)
- [ ] Platform absorbs dilution: total_shares increases by the bonus, reducing per-share NAV slightly
- [ ] `IncentiveConfig` is a PDA seeded by `["incentive_config"]`, initialized once by admin
- [ ] Admin instruction to set/update the bonus deadline and multiplier

## Implementation

### Step 1: Define IncentiveConfig account

In `programs/obey_vault/src/state/incentive.rs`:

```rust
use anchor_lang::prelude::*;

#[account]
pub struct IncentiveConfig {
    /// Admin who can update incentive parameters.
    pub admin: Pubkey,
    /// Unix timestamp: deposits before this time get bonus shares.
    pub bonus_deadline: i64,
    /// Bonus multiplier in basis points (11500 = 1.15x = 15% bonus).
    pub bonus_multiplier_bps: u16,
    /// Whether fee waivers are active (separate task).
    pub fee_waiver_active: bool,
    /// Unix timestamp: fee waiver end date.
    pub fee_waiver_deadline: i64,
    /// PDA bump.
    pub bump: u8,
}

impl IncentiveConfig {
    pub const SIZE: usize = 8 + 32 + 8 + 2 + 1 + 8 + 1; // 60 bytes
    pub const SEED_PREFIX: &'static [u8] = b"incentive_config";
    pub const NO_BONUS_BPS: u16 = 10_000; // 1.0x = no bonus
}
```

### Step 2: Initialize incentive config instruction

```rust
#[derive(Accounts)]
pub struct InitializeIncentiveConfig<'info> {
    #[account(mut)]
    pub admin: Signer<'info>,

    #[account(
        init,
        payer = admin,
        space = IncentiveConfig::SIZE,
        seeds = [IncentiveConfig::SEED_PREFIX],
        bump,
    )]
    pub incentive_config: Account<'info, IncentiveConfig>,

    pub system_program: Program<'info, System>,
}

pub fn initialize_incentive_config(
    ctx: Context<InitializeIncentiveConfig>,
    bonus_deadline: i64,
    bonus_multiplier_bps: u16,
) -> Result<()> {
    let config = &mut ctx.accounts.incentive_config;
    config.admin = ctx.accounts.admin.key();
    config.bonus_deadline = bonus_deadline;
    config.bonus_multiplier_bps = bonus_multiplier_bps;
    config.fee_waiver_active = false;
    config.fee_waiver_deadline = 0;
    config.bump = ctx.bumps.incentive_config;
    Ok(())
}
```

### Step 3: Modify the deposit instruction

In `programs/obey_vault/src/instructions/deposit.rs`, update the share calculation:

```rust
// Add IncentiveConfig to Deposit accounts:
#[account(
    seeds = [IncentiveConfig::SEED_PREFIX],
    bump = incentive_config.bump,
)]
pub incentive_config: Account<'info, IncentiveConfig>,

// In the deposit handler, replace the share calculation:
pub fn deposit(ctx: Context<Deposit>, agent_id: u64, amount: u64) -> Result<()> {
    let vault = &mut ctx.accounts.vault_state;
    let agent = &ctx.accounts.agent_state;
    let incentive = &ctx.accounts.incentive_config;

    // ... existing validation ...

    // Calculate base shares (before bonus)
    let deposit_value = get_asset_value(&ctx.accounts.pyth_feed, amount)?;
    let base_shares = if vault.total_shares == 0 {
        deposit_value
    } else {
        (deposit_value as u128 * vault.total_shares as u128
            / vault.total_nav as u128) as u64
    };

    // Creator gets ownership % of base shares (not affected by bonus)
    let creator_shares = base_shares * agent.owner_pct_bps as u64 / 10_000;

    // Depositor gets remaining base shares, potentially with bonus
    let user_base_shares = base_shares - creator_shares;
    let clock = Clock::get()?;
    let bonus_multiplier = if clock.unix_timestamp < incentive.bonus_deadline {
        incentive.bonus_multiplier_bps
    } else {
        IncentiveConfig::NO_BONUS_BPS
    };

    let user_shares = (user_base_shares as u128 * bonus_multiplier as u128
        / IncentiveConfig::NO_BONUS_BPS as u128) as u64;

    // Total shares minted = creator_shares + user_shares (may be > base_shares if bonus active)
    let total_minted = creator_shares + user_shares;

    // Mint shares
    token::mint_to(/* share_mint -> creator ATA */, creator_shares)?;
    token::mint_to(/* share_mint -> user ATA */, user_shares)?;

    // Update state
    vault.total_shares += total_minted;
    vault.total_nav += deposit_value;

    emit!(DepositEvent {
        agent_id,
        user: ctx.accounts.user.key(),
        amount,
        shares: user_shares,
        bonus_applied: bonus_multiplier > IncentiveConfig::NO_BONUS_BPS,
    });

    Ok(())
}
```

### Step 4: Write tests

In `tests/test_bonus_shares.rs`:

1. `test_deposit_with_bonus_active` — deposit before deadline, verify user gets 1.15x shares
2. `test_deposit_after_bonus_expires` — deposit after deadline, verify user gets 1.0x shares
3. `test_creator_shares_not_affected` — verify creator gets the same ownership % regardless of bonus
4. `test_bonus_multiplier_math` — deposit 1000 USDC with 15% bonus, verify exact share count
5. `test_total_shares_updated` — verify vault total_shares includes the bonus shares
6. `test_nav_per_share_dilution` — verify NAV per share is slightly lower when bonus is active (platform absorbs cost)

## Done When

- [ ] All requirements met
- [ ] Deposits before `bonus_deadline` receive 15% more shares (1.15x multiplier)
- [ ] Deposits after deadline receive standard 1.0x shares
- [ ] Creator ownership share is based on pre-bonus calculation
- [ ] IncentiveConfig PDA is initialized once by admin with deadline and multiplier
- [ ] `anchor test` passes with all bonus share tests green
