---
fest_type: task
fest_id: 02_nav_program.md
fest_name: nav_program
fest_parent: 03_full_vault
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.608718-06:00
fest_tracking: true
---

# Task: obey_nav Anchor Program (Oracle & Valuation)

## Objective

Implement the `obey_nav` Anchor program that reads Pyth price feeds with staleness and confidence checks, calculates tiered NAV for vault token holdings, and enforces concentration limits.

## Requirements

- [ ] `get_validated_price` instruction: reads Pyth price feed with configurable max age and confidence threshold
- [ ] Staleness check: reject prices older than `max_age_secs` (default 60 seconds)
- [ ] Confidence check: reject prices where confidence interval exceeds `max_confidence_pct` of price
- [ ] `calculate_nav` function: sums value of all token holdings using validated Pyth prices
- [ ] No-feed fallback: tokens without a valid Pyth price feed are valued at $0 (anti-gaming)
- [ ] `check_concentration` function: verify no single non-base token exceeds max_concentration_bps of NAV
- [ ] Return `ValidatedPrice` struct with price, confidence, exponent, publish_time
- [ ] Pyth integration using `pyth-solana-receiver-sdk` for pull oracle

## Implementation

### Step 1: Program structure

Create `programs/obey_nav/src/lib.rs`:

```rust
use anchor_lang::prelude::*;
use pyth_solana_receiver_sdk::price_update::PriceUpdateV2;

declare_id!("...");

pub mod errors;

#[program]
pub mod obey_nav {
    use super::*;

    /// Reads and validates a Pyth price feed.
    /// Returns error if price is stale or confidence interval is too wide.
    pub fn get_validated_price(
        ctx: Context<GetValidatedPrice>,
        max_age_secs: u64,
        max_confidence_pct: u64,
    ) -> Result<()> {
        let price_update = &ctx.accounts.price_update;
        let clock = Clock::get()?;

        // Get price no older than max_age_secs
        let price_data = price_update.get_price_no_older_than(
            &clock,
            max_age_secs,
            None, // feed_id verified by account constraint
        ).map_err(|_| errors::ErrorCode::PriceStale)?;

        // Confidence check: reject if confidence interval > max_confidence_pct of price
        let abs_price = price_data.price.unsigned_abs() as u128;
        if abs_price > 0 {
            let confidence_pct = (price_data.conf as u128)
                .checked_mul(100)
                .unwrap()
                .checked_div(abs_price)
                .unwrap();
            require!(
                confidence_pct <= max_confidence_pct as u128,
                errors::ErrorCode::PriceConfidenceTooLow
            );
        }

        // Store the validated price in a return account or emit as event
        emit!(ValidatedPriceEvent {
            price: price_data.price,
            confidence: price_data.conf,
            exponent: price_data.exponent,
            publish_time: price_data.publish_time,
        });

        Ok(())
    }
}

#[derive(Accounts)]
pub struct GetValidatedPrice<'info> {
    pub price_update: Account<'info, PriceUpdateV2>,
}

#[event]
pub struct ValidatedPriceEvent {
    pub price: i64,
    pub confidence: u64,
    pub exponent: i32,
    pub publish_time: i64,
}
```

### Step 2: Implement NAV calculation as a reusable function

This is used by the vault program via CPI or as a helper library:

```rust
/// Calculates NAV for a vault by reading Pyth prices for all held tokens.
/// Tokens without valid price feeds are valued at $0 (anti-gaming measure).
///
/// Arguments:
/// - `token_balances`: pairs of (mint, balance) for each token in the vault
/// - `price_feeds`: corresponding Pyth price feed accounts
/// - `max_age_secs`: maximum acceptable price staleness
/// - `max_confidence_pct`: maximum acceptable confidence interval as % of price
///
/// Returns: total NAV in USD with 6 decimal places (matching USDC)
pub fn calculate_nav(
    token_balances: &[(Pubkey, u64)],  // (mint, balance)
    price_feeds: &[AccountInfo],
    base_asset: &Pubkey,               // USDC mint (always $1)
    max_age_secs: u64,
    max_confidence_pct: u64,
    clock: &Clock,
) -> Result<u64> {
    let mut nav: u128 = 0;

    for (i, (mint, balance)) in token_balances.iter().enumerate() {
        if *balance == 0 {
            continue;
        }

        // Base asset (USDC) is always valued at $1.00
        if mint == base_asset {
            nav = nav.checked_add(*balance as u128).unwrap();
            continue;
        }

        // Try to read Pyth price feed
        if i >= price_feeds.len() {
            // No feed provided = $0 (anti-gaming)
            continue;
        }

        match try_get_validated_price(&price_feeds[i], max_age_secs, max_confidence_pct, clock) {
            Ok(price) => {
                // price.price is in fixed-point with price.exponent
                // balance is in token base units (e.g., lamports for SOL)
                // NAV needs to be in USDC base units (6 decimals)
                let value = compute_token_value(*balance, price.price, price.exponent);
                nav = nav.checked_add(value as u128).unwrap();
            }
            Err(_) => {
                // No valid price = $0 valuation
                // This prevents gaming via illiquid/manipulated tokens
            }
        }
    }

    Ok(nav as u64)
}

/// Computes the USD value of a token holding.
/// Returns value in USDC base units (6 decimals).
fn compute_token_value(balance: u64, price: i64, exponent: i32) -> u64 {
    if price <= 0 {
        return 0;
    }
    // price = price_value * 10^exponent
    // value = balance * price * 10^exponent
    // Normalize to USDC 6 decimals
    let price_abs = price as u128;
    let balance_u128 = balance as u128;
    let raw = balance_u128.checked_mul(price_abs).unwrap();

    // Adjust for exponent (typically negative, e.g., -8)
    // We want 6 decimal places in output
    let target_decimals: i32 = 6;
    let shift = target_decimals + exponent; // e.g., 6 + (-8) = -2

    if shift >= 0 {
        (raw.checked_mul(10u128.pow(shift as u32)).unwrap()) as u64
    } else {
        (raw / 10u128.pow((-shift) as u32)) as u64
    }
}
```

### Step 3: Implement concentration check

```rust
/// Checks that no single non-base token exceeds the concentration limit.
/// Returns false if any token exceeds max_concentration_bps of total NAV.
pub fn check_concentration(
    token_balances: &[(Pubkey, u64)],
    price_feeds: &[AccountInfo],
    base_asset: &Pubkey,
    total_nav: u64,
    max_concentration_bps: u16,
    clock: &Clock,
) -> Result<bool> {
    if total_nav == 0 {
        return Ok(true);
    }

    for (i, (mint, balance)) in token_balances.iter().enumerate() {
        if *balance == 0 || mint == base_asset {
            continue; // USDC exempt from concentration limit
        }

        if i >= price_feeds.len() {
            continue;
        }

        let price = match try_get_validated_price(&price_feeds[i], 60, 5, clock) {
            Ok(p) => p,
            Err(_) => continue, // $0 tokens can't violate concentration
        };

        let token_value = compute_token_value(*balance, price.price, price.exponent);
        let concentration_bps = (token_value as u128)
            .checked_mul(10_000)
            .unwrap()
            .checked_div(total_nav as u128)
            .unwrap();

        if concentration_bps > max_concentration_bps as u128 {
            return Ok(false);
        }
    }

    Ok(true)
}
```

### Step 4: Error codes

In `programs/obey_nav/src/errors.rs`:

```rust
use anchor_lang::prelude::*;

#[error_code]
pub enum ErrorCode {
    #[msg("Price feed is stale (exceeds max_age_secs)")]
    PriceStale,
    #[msg("Price confidence interval too wide")]
    PriceConfidenceTooLow,
    #[msg("NAV calculation overflow")]
    NAVOverflow,
    #[msg("Token concentration exceeds limit")]
    ConcentrationExceeded,
}
```

### Step 5: Write tests

In `tests/test_nav.rs`:

1. `test_validated_price_success` — valid Pyth feed within age/confidence bounds
2. `test_stale_price_rejected` — Pyth feed older than max_age_secs
3. `test_low_confidence_rejected` — confidence interval > max_confidence_pct
4. `test_calculate_nav_usdc_only` — vault with only USDC, NAV = balance
5. `test_calculate_nav_with_tokens` — USDC + SOL, verify correct USD valuation
6. `test_no_feed_valued_at_zero` — token without Pyth feed gets $0
7. `test_concentration_check_pass` — all tokens below limit
8. `test_concentration_check_fail` — one token exceeds max_concentration_bps
9. `test_compute_token_value_precision` — verify decimal handling with various exponents

## Done When

- [ ] All requirements met
- [ ] Pyth price validation rejects stale and low-confidence prices
- [ ] NAV calculation correctly values multi-token vaults using oracle prices
- [ ] Tokens without valid feeds valued at $0
- [ ] Concentration check catches over-concentration of non-base assets
- [ ] `anchor build` compiles successfully
- [ ] `anchor test` passes with all NAV program tests green
