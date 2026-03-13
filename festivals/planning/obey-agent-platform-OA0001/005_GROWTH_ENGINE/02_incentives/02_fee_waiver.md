---
fest_type: task
fest_id: 02_fee_waiver.md
fest_name: fee_waiver
fest_parent: 02_incentives
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.549705-06:00
fest_tracking: true
---

# Task: Early Depositor Fee Waiver (First 30 Days)

## Objective

Implement a 30-day fee waiver in the vault's `execute_trade` instruction where platform fees are set to 0% for trades executed by agents funded during the waiver period, so agents keep 100% of trade value.

## Requirements

- [ ] Use the `IncentiveConfig` account (from bonus_shares task) with `fee_waiver_active` and `fee_waiver_deadline` fields
- [ ] Modify `execute_trade` in obey_vault to check if fee waiver is active
- [ ] When active: skip fee deduction, agent executes trade at full value
- [ ] When expired: normal fee deduction applies (fee_rate_bps from PlatformConfig)
- [ ] Admin instruction to activate fee waiver with a deadline timestamp
- [ ] Emit events distinguishing waived vs. normal fee trades for analytics
- [ ] Track total fees waived for internal metrics (foregone revenue reporting)

## Implementation

### Step 1: Add admin instruction to activate fee waiver

In `programs/obey_vault/src/instructions/`:

```rust
#[derive(Accounts)]
pub struct ActivateFeeWaiver<'info> {
    #[account(
        mut,
        constraint = admin.key() == incentive_config.admin @ ErrorCode::Unauthorized
    )]
    pub admin: Signer<'info>,

    #[account(
        mut,
        seeds = [IncentiveConfig::SEED_PREFIX],
        bump = incentive_config.bump,
    )]
    pub incentive_config: Account<'info, IncentiveConfig>,
}

pub fn activate_fee_waiver(
    ctx: Context<ActivateFeeWaiver>,
    deadline: i64,
) -> Result<()> {
    let config = &mut ctx.accounts.incentive_config;
    config.fee_waiver_active = true;
    config.fee_waiver_deadline = deadline;
    Ok(())
}
```

### Step 2: Modify execute_trade to check fee waiver

In `programs/obey_vault/src/instructions/execute_trade.rs`:

```rust
// Add IncentiveConfig to ExecuteTrade accounts:
#[account(
    seeds = [IncentiveConfig::SEED_PREFIX],
    bump = incentive_config.bump,
)]
pub incentive_config: Account<'info, IncentiveConfig>,

// In the execute_trade handler, modify fee calculation:
pub fn execute_trade(
    ctx: Context<ExecuteTrade>,
    agent_id: u64,
    trade_value: u64,
) -> Result<()> {
    let agent = &ctx.accounts.agent_state;
    let platform = &ctx.accounts.platform_config;
    let incentive = &ctx.accounts.incentive_config;
    let clock = Clock::get()?;

    // ... existing validation (signer, status, etc.) ...

    // Check if fee waiver is active
    let fee_waived = incentive.fee_waiver_active
        && clock.unix_timestamp < incentive.fee_waiver_deadline;

    let (net_value, fee) = if fee_waived {
        // No fee during waiver period
        (trade_value, 0u64)
    } else {
        // Normal fee deduction
        let fee = trade_value * platform.fee_rate_bps as u64 / 10_000;
        let net = trade_value - fee;
        // Transfer fee to treasury
        token::transfer(/* vault -> treasury */, fee)?;
        (net, fee)
    };

    // ... existing CPI to adapter, concentration check, drawdown check ...

    // Update stats
    agent.trade_count += 1;
    agent.last_trade_at = clock.unix_timestamp;
    if !fee_waived {
        vault.total_fees_collected += fee;
    }

    emit!(TradeExecutedEvent {
        agent_id,
        value: net_value,
        fee,
        fee_waived,
        nav: calculate_nav(/* ... */)?,
    });

    Ok(())
}
```

### Step 3: Add fee waiver tracking for analytics

Create a counter in VaultState or a separate account to track waived fees:

```rust
// Add to VaultState:
pub total_fees_waived: u64,  // track foregone revenue

// In execute_trade when fee_waived:
if fee_waived {
    vault.total_fees_waived += trade_value * platform.fee_rate_bps as u64 / 10_000;
}
```

This enables reporting like: "We waived $3,000 in fees during the first 30 days, acquiring $200K AUM."

### Step 4: Expose waiver status in API

In the Go platform API, read `IncentiveConfig` on-chain to display:

```go
type FeeWaiverStatus struct {
    Active       bool      `json:"active"`
    Deadline     time.Time `json:"deadline"`
    DaysLeft     int       `json:"daysLeft"`
    TotalWaived  float64   `json:"totalWaived"` // USD
}
```

Display on the deposit page: "Deposit now -- 0% platform fees for the next X days!"

### Step 5: Write tests

In `tests/test_fee_waiver.rs`:

1. `test_trade_with_fee_waiver_active` — verify fee is 0, full trade_value used
2. `test_trade_after_waiver_expires` — verify normal fee deduction
3. `test_waiver_not_active` — fee_waiver_active = false, verify normal fees even before deadline
4. `test_total_fees_waived_tracked` — verify total_fees_waived incremented correctly
5. `test_activate_fee_waiver_admin_only` — non-admin cannot activate
6. `test_trade_event_fee_waived_flag` — verify event emits fee_waived = true/false correctly

## Done When

- [ ] All requirements met
- [ ] Trades during active waiver period have 0% platform fees
- [ ] Trades after waiver expiry deduct normal fees
- [ ] Admin can activate waiver with specific deadline
- [ ] Foregone fee amount tracked in `total_fees_waived` for analytics
- [ ] Events clearly distinguish waived vs. normal fee trades
- [ ] `anchor test` passes with all fee waiver tests green
