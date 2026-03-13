---
fest_type: task
fest_id: 03_fees_program.md
fest_name: fees_program
fest_parent: 03_full_vault
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.609041-06:00
fest_tracking: true
---

# Task: obey_fees Anchor Program

## Objective

Implement the `obey_fees` Anchor program that handles platform fee collection, fee accumulation, treasury claims, quarterly performance fee settlement (10% above high-water mark), and the referral fee distribution CPI entry point.

## Requirements

- [ ] `FeeAccumulator` PDA per agent: tracks pending fees before treasury claim
- [ ] `collect_trade_fee` instruction: deducts base+management fee (80 bps) from trade value, stores in accumulator
- [ ] `claim_fees` instruction: admin claims accumulated fees to treasury
- [ ] `quarterly_performance_settlement` instruction: calculates 10% performance fee on NAV above high-water mark
- [ ] `distribute_referral_fees` instruction: CPI entry point from vault for referral fee distribution (from Phase 5)
- [ ] Fee waiver integration: reads IncentiveConfig to skip fees during waiver period
- [ ] Emit events for every fee collection and distribution for analytics

## Implementation

### Step 1: State accounts

Create `programs/obey_fees/src/state.rs`:

```rust
use anchor_lang::prelude::*;

#[account]
pub struct FeeAccumulator {
    /// Agent this accumulator belongs to.
    pub agent_id: u64,
    /// Accumulated platform fees pending claim (USDC base units).
    pub pending_fees: u64,
    /// Total fees collected over lifetime.
    pub total_collected: u64,
    /// Total fees claimed to treasury.
    pub total_claimed: u64,
    /// Total performance fees collected.
    pub total_performance_fees: u64,
    /// Last quarterly settlement timestamp.
    pub last_settlement: i64,
    /// PDA bump.
    pub bump: u8,
}

impl FeeAccumulator {
    pub const SIZE: usize = 8 + 8 + 8 + 8 + 8 + 8 + 8 + 1; // 57 bytes
    pub const SEED: &'static [u8] = b"fee_accumulator";
}
```

### Step 2: Implement collect_trade_fee

In `programs/obey_fees/src/instructions/collect_trade_fee.rs`:

```rust
use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, TokenAccount, Transfer};

/// Fee rates in basis points.
pub const BASE_FEE_BPS: u64 = 50;       // 0.5% base fee
pub const MANAGEMENT_FEE_BPS: u64 = 30; // 0.3% management fee
pub const TOTAL_TRADE_FEE_BPS: u64 = 80; // 0.8% total per trade

#[derive(Accounts)]
#[instruction(agent_id: u64, trade_value: u64)]
pub struct CollectTradeFee<'info> {
    /// The vault's token account (source of fee).
    #[account(mut)]
    pub vault_token_account: Account<'info, TokenAccount>,

    /// The fee accumulator PDA for this agent.
    #[account(
        mut,
        seeds = [FeeAccumulator::SEED, &agent_id.to_le_bytes()],
        bump = fee_accumulator.bump,
    )]
    pub fee_accumulator: Account<'info, FeeAccumulator>,

    /// Accumulator token account to hold pending fees.
    #[account(mut)]
    pub fee_token_account: Account<'info, TokenAccount>,

    /// Vault PDA signer (authority over vault_token_account).
    /// CHECK: Seeds verified by vault program.
    pub vault_authority: AccountInfo<'info>,

    /// IncentiveConfig to check fee waiver status.
    /// CHECK: Optional, validated in handler.
    pub incentive_config: Option<AccountInfo<'info>>,

    pub token_program: Program<'info, Token>,
}

pub fn handler(
    ctx: Context<CollectTradeFee>,
    agent_id: u64,
    trade_value: u64,
) -> Result<u64> {
    let clock = Clock::get()?;

    // Check fee waiver (from IncentiveConfig if provided)
    let fee_waived = if let Some(ref incentive_info) = ctx.accounts.incentive_config {
        // Deserialize and check waiver status
        let data = incentive_info.try_borrow_data()?;
        // Parse fee_waiver_active and fee_waiver_deadline from data
        // (simplified — real impl would use Account deserialization)
        false // placeholder: implement actual waiver check
    } else {
        false
    };

    if fee_waived {
        emit!(FeeCollectedEvent {
            agent_id,
            trade_value,
            fee_amount: 0,
            fee_waived: true,
            timestamp: clock.unix_timestamp,
        });
        return Ok(0);
    }

    // Calculate fee: 80 bps (0.8%) of trade value
    let fee = trade_value
        .checked_mul(TOTAL_TRADE_FEE_BPS)
        .unwrap()
        .checked_div(10_000)
        .unwrap();

    // Transfer fee from vault to accumulator
    let transfer_ctx = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        Transfer {
            from: ctx.accounts.vault_token_account.to_account_info(),
            to: ctx.accounts.fee_token_account.to_account_info(),
            authority: ctx.accounts.vault_authority.to_account_info(),
        },
    );
    token::transfer(transfer_ctx, fee)?;

    // Update accumulator state
    let accumulator = &mut ctx.accounts.fee_accumulator;
    accumulator.pending_fees = accumulator.pending_fees.checked_add(fee).unwrap();
    accumulator.total_collected = accumulator.total_collected.checked_add(fee).unwrap();

    emit!(FeeCollectedEvent {
        agent_id,
        trade_value,
        fee_amount: fee,
        fee_waived: false,
        timestamp: clock.unix_timestamp,
    });

    Ok(fee)
}

#[event]
pub struct FeeCollectedEvent {
    pub agent_id: u64,
    pub trade_value: u64,
    pub fee_amount: u64,
    pub fee_waived: bool,
    pub timestamp: i64,
}
```

### Step 3: Implement claim_fees (admin claims to treasury)

```rust
#[derive(Accounts)]
pub struct ClaimFees<'info> {
    #[account(constraint = admin.key() == platform_config.admin @ ErrorCode::NotAdmin)]
    pub admin: Signer<'info>,

    #[account(seeds = [b"platform_config"], bump)]
    pub platform_config: Account<'info, PlatformConfig>,

    #[account(mut)]
    pub fee_accumulator: Account<'info, FeeAccumulator>,

    #[account(mut)]
    pub fee_token_account: Account<'info, TokenAccount>,

    #[account(mut)]
    pub treasury_token_account: Account<'info, TokenAccount>,

    /// PDA authority for the fee accumulator token account.
    /// CHECK: Seeds validated.
    pub fee_authority: AccountInfo<'info>,

    pub token_program: Program<'info, Token>,
}

pub fn claim_fees(ctx: Context<ClaimFees>) -> Result<()> {
    let amount = ctx.accounts.fee_accumulator.pending_fees;
    require!(amount > 0, ErrorCode::NothingToClaim);

    // Transfer from fee account to treasury
    let transfer_ctx = CpiContext::new_with_signer(
        ctx.accounts.token_program.to_account_info(),
        Transfer {
            from: ctx.accounts.fee_token_account.to_account_info(),
            to: ctx.accounts.treasury_token_account.to_account_info(),
            authority: ctx.accounts.fee_authority.to_account_info(),
        },
        &[/* PDA seeds */],
    );
    token::transfer(transfer_ctx, amount)?;

    let accumulator = &mut ctx.accounts.fee_accumulator;
    accumulator.pending_fees = 0;
    accumulator.total_claimed = accumulator.total_claimed.checked_add(amount).unwrap();

    emit!(FeesClaimedEvent { amount, timestamp: Clock::get()?.unix_timestamp });
    Ok(())
}
```

### Step 4: Implement quarterly performance settlement

```rust
pub fn quarterly_performance_settlement(
    ctx: Context<PerformanceSettlement>,
    agent_id: u64,
) -> Result<u64> {
    let vault = &ctx.accounts.vault_state;
    let accumulator = &mut ctx.accounts.fee_accumulator;
    let clock = Clock::get()?;

    // Only settle once per quarter (90 days minimum between settlements)
    let min_interval = 90 * 24 * 3600; // 90 days in seconds
    require!(
        clock.unix_timestamp - accumulator.last_settlement >= min_interval,
        ErrorCode::SettlementTooEarly
    );

    // Performance fee: 10% of NAV above high-water mark
    if vault.total_nav <= vault.all_time_high_nav {
        accumulator.last_settlement = clock.unix_timestamp;
        return Ok(0); // no performance fee if NAV hasn't exceeded previous high
    }

    let profit = vault.total_nav
        .checked_sub(vault.all_time_high_nav)
        .unwrap();
    let performance_fee = profit
        .checked_mul(1000) // 10% = 1000 bps
        .unwrap()
        .checked_div(10_000)
        .unwrap();

    // Mint performance fee as new shares to platform treasury
    // This dilutes existing shares proportionally
    // (Alternatively, deduct from vault assets)

    accumulator.total_performance_fees = accumulator
        .total_performance_fees
        .checked_add(performance_fee)
        .unwrap();
    accumulator.last_settlement = clock.unix_timestamp;

    emit!(PerformanceFeeEvent {
        agent_id,
        profit,
        performance_fee,
        new_high_water_mark: vault.total_nav,
        timestamp: clock.unix_timestamp,
    });

    Ok(performance_fee)
}
```

### Step 5: Implement distribute_referral_fees (CPI entry point)

```rust
/// CPI entry point called by the vault program to distribute referral fees.
/// The actual referral state and payout logic lives in the obey_referrals program
/// (Phase 5). This instruction accepts a trade fee amount and routes the referral
/// portion (configured in IncentiveConfig) to the referrer's token account via CPI.
pub fn distribute_referral_fees(
    ctx: Context<DistributeReferralFees>,
    agent_id: u64,
    fee_amount: u64,
) -> Result<()> {
    // Read referral config to determine referral share (e.g., 20% of trade fee)
    let referral_share = fee_amount
        .checked_mul(ctx.accounts.incentive_config.referral_fee_bps as u64)
        .unwrap()
        .checked_div(10_000)
        .unwrap();

    if referral_share == 0 {
        return Ok(());
    }

    // CPI to obey_referrals::distribute to split between L1 and L2 referrers
    // (Implementation depends on Phase 5 referral_system being deployed)

    emit!(ReferralFeeEvent {
        agent_id,
        fee_amount,
        referral_share,
        timestamp: Clock::get()?.unix_timestamp,
    });

    Ok(())
}

#[event]
pub struct ReferralFeeEvent {
    pub agent_id: u64,
    pub fee_amount: u64,
    pub referral_share: u64,
    pub timestamp: i64,
}
```

### Step 6: Write tests

In `tests/test_fees.rs`:

1. `test_collect_trade_fee` — 10,000 USDC trade, verify 80 USDC fee collected (0.8%)
2. `test_claim_fees_to_treasury` — accumulate 500 USDC, claim, verify treasury receives full amount
3. `test_claim_fees_non_admin_rejected` — non-admin cannot claim
4. `test_performance_settlement_profit` — NAV above HWM, verify 10% of profit taken
5. `test_performance_settlement_no_profit` — NAV below HWM, verify 0 fee
6. `test_performance_settlement_too_early` — less than 90 days since last, rejected
7. `test_fee_waiver_zero_fee` — waiver active, verify 0 fee collected
8. `test_fee_accumulation_overflow` — verify checked math prevents overflow

## Done When

- [ ] All requirements met
- [ ] Trade fees collected at 80 bps (0.8%) of trade value
- [ ] Accumulated fees claimable by admin to treasury
- [ ] Performance fee: 10% of NAV growth above high-water mark, quarterly
- [ ] Fee waiver integration skips collection during waiver period
- [ ] All fee operations emit events for analytics
- [ ] `anchor test` passes with all fees program tests green
