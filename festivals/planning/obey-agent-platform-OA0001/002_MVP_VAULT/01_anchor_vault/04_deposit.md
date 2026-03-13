---
fest_type: task
fest_id: 04_deposit.md
fest_name: deposit
fest_parent: 01_anchor_vault
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.356374-06:00
fest_tracking: true
---

# Task: Implement Deposit Instruction

## Objective

Implement the `deposit` instruction that accepts USDC from a user, transfers it to the vault PDA, and mints proportional share tokens to the depositor based on the current NAV.

## Requirements

- [ ] Transfers `amount` USDC from user's ATA to the vault's USDC ATA
- [ ] Mints share tokens proportional to `deposit_amount / current_nav * total_shares`
- [ ] First deposit bootstraps at 1:1 ratio (1 USDC = 1 share, both 6 decimals)
- [ ] Rejects deposits when vault is paused
- [ ] Rejects zero-amount deposits
- [ ] Rejects deposits when NAV is zero but shares exist (corrupt state guard)
- [ ] Emits `DepositEvent` with full context
- [ ] Uses checked math throughout to prevent overflow

## Implementation

File: `programs/obey-mvp-vault/src/instructions/deposit.rs`

```rust
use anchor_lang::prelude::*;
use anchor_spl::token::{self, Mint, MintTo, Token, TokenAccount, Transfer};

use crate::errors::VaultError;
use crate::events::DepositEvent;
use crate::state::*;

#[derive(Accounts)]
pub struct Deposit<'info> {
    /// The depositor
    #[account(mut)]
    pub user: Signer<'info>,

    /// Vault state — must not be paused
    #[account(
        mut,
        seeds = [VAULT_SEED, vault_state.admin.as_ref()],
        bump = vault_state.bump,
        constraint = !vault_state.paused @ VaultError::VaultPaused,
    )]
    pub vault_state: Account<'info, VaultState>,

    /// The vault's USDC token account — destination for deposited funds
    #[account(
        mut,
        constraint = vault_usdc_ata.key() == vault_state.vault_usdc_ata @ VaultError::InvalidUsdcMint,
    )]
    pub vault_usdc_ata: Account<'info, TokenAccount>,

    /// The user's USDC token account — source of deposited funds
    #[account(
        mut,
        associated_token::mint = usdc_mint,
        associated_token::authority = user,
    )]
    pub user_usdc_ata: Account<'info, TokenAccount>,

    /// USDC mint — validated against vault state
    #[account(
        constraint = usdc_mint.key() == vault_state.usdc_mint @ VaultError::InvalidUsdcMint,
    )]
    pub usdc_mint: Account<'info, Mint>,

    /// Share token mint — PDA controlled by vault
    #[account(
        mut,
        seeds = [SHARE_MINT_SEED, vault_state.key().as_ref()],
        bump = vault_state.share_mint_bump,
    )]
    pub share_mint: Account<'info, Mint>,

    /// User's share token account — receives minted shares.
    /// init_if_needed so first-time depositors don't need a separate tx.
    #[account(
        init_if_needed,
        payer = user,
        associated_token::mint = share_mint,
        associated_token::authority = user,
    )]
    pub user_share_ata: Account<'info, TokenAccount>,

    pub token_program: Program<'info, Token>,
    pub associated_token_program: Program<'info, anchor_spl::associated_token::AssociatedToken>,
    pub system_program: Program<'info, System>,
}

pub fn handler(ctx: Context<Deposit>, amount: u64) -> Result<()> {
    require!(amount > 0, VaultError::ZeroDeposit);

    let vault = &mut ctx.accounts.vault_state;

    // Calculate shares to mint
    let shares_to_mint = if vault.total_shares == 0 {
        // Bootstrap: 1 USDC (1_000_000 base units) = 1_000_000 shares
        // Both use 6 decimals, so it's 1:1
        amount
    } else {
        // Proportional: shares = amount * total_shares / total_nav
        require!(vault.total_nav > 0, VaultError::NavIsZero);

        // Use u128 intermediate to prevent overflow
        // amount and total_shares are u64, product could exceed u64
        let numerator = (amount as u128)
            .checked_mul(vault.total_shares as u128)
            .ok_or(VaultError::MathOverflow)?;
        let shares = numerator
            .checked_div(vault.total_nav as u128)
            .ok_or(VaultError::MathOverflow)?;

        // Safe downcast — shares can't exceed total_shares proportionally
        u64::try_from(shares).map_err(|_| VaultError::MathOverflow)?
    };

    require!(shares_to_mint > 0, VaultError::ZeroDeposit);

    // 1. Transfer USDC from user to vault
    let transfer_ctx = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        Transfer {
            from: ctx.accounts.user_usdc_ata.to_account_info(),
            to: ctx.accounts.vault_usdc_ata.to_account_info(),
            authority: ctx.accounts.user.to_account_info(),
        },
    );
    token::transfer(transfer_ctx, amount)?;

    // 2. Mint shares to user (vault PDA signs as mint authority)
    let vault_seeds = &[
        VAULT_SEED,
        vault.admin.as_ref(),
        &[vault.bump],
    ];
    let signer_seeds = &[&vault_seeds[..]];

    let mint_ctx = CpiContext::new_with_signer(
        ctx.accounts.token_program.to_account_info(),
        MintTo {
            mint: ctx.accounts.share_mint.to_account_info(),
            to: ctx.accounts.user_share_ata.to_account_info(),
            authority: ctx.accounts.vault_state.to_account_info(),
        },
        signer_seeds,
    );
    token::mint_to(mint_ctx, shares_to_mint)?;

    // 3. Update vault state
    vault.total_shares = vault.total_shares
        .checked_add(shares_to_mint)
        .ok_or(VaultError::MathOverflow)?;
    vault.total_nav = vault.total_nav
        .checked_add(amount)
        .ok_or(VaultError::MathOverflow)?;

    if vault.total_nav > vault.all_time_high_nav {
        vault.all_time_high_nav = vault.total_nav;
    }

    // 4. Emit event
    emit!(DepositEvent {
        user: ctx.accounts.user.key(),
        usdc_amount: amount,
        shares_minted: shares_to_mint,
        nav_at_deposit: vault.total_nav,
        total_shares_after: vault.total_shares,
        total_nav_after: vault.total_nav,
    });

    Ok(())
}
```

### Share Pricing Math

The share pricing formula ensures fair entry at current NAV:

```
First deposit:   shares = amount (1:1 bootstrap)
Subsequent:      shares = amount * total_shares / total_nav
```

Example with numbers:
1. Alice deposits 1000 USDC. `total_shares=0` -> she gets 1000 shares. NAV=1000.
2. Agent trades well, admin updates NAV to 1200. Share price = 1200/1000 = 1.2 USDC/share.
3. Bob deposits 600 USDC. `shares = 600 * 1000 / 1200 = 500 shares`. NAV=1800, total_shares=1500.
4. Each share is still worth 1800/1500 = 1.2 USDC. Bob's entry was fair.

### MVP Simplification vs Full Vault

The MVP vault does NOT implement creator share minting (the `owner_pct_bps` split from doc 02). All shares go to the depositor. Creator fees will be added when migrating to the full vault contracts.

## Done When

- [ ] All requirements met
- [ ] First deposit mints shares 1:1 with USDC amount
- [ ] Subsequent deposits mint shares proportional to current NAV
- [ ] USDC is transferred from user ATA to vault ATA
- [ ] Share tokens are minted to user's share ATA (created if needed)
- [ ] Vault state (total_shares, total_nav, all_time_high_nav) updates correctly
- [ ] Deposit with paused vault reverts with `VaultPaused`
- [ ] Deposit of 0 amount reverts with `ZeroDeposit`
- [ ] `DepositEvent` emitted with all fields populated
