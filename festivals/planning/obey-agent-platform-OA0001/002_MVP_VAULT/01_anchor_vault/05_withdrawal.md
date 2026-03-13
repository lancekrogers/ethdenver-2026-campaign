---
fest_type: task
fest_id: 05_withdrawal.md
fest_name: withdrawal
fest_parent: 01_anchor_vault
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.356603-06:00
fest_tracking: true
---

# Task: Implement Withdrawal Instructions (Request + Execute)

## Objective

Implement the two-phase withdrawal flow: `request_withdrawal` escrows user shares and records a `WithdrawalRequest` PDA, then `execute_withdrawal` burns the escrowed shares and returns proportional USDC after the delay has elapsed.

## Requirements

- [ ] `request_withdrawal` transfers share tokens from user to an escrow token account
- [ ] `request_withdrawal` creates a `WithdrawalRequest` PDA with timestamp and delay
- [ ] `execute_withdrawal` checks the delay has elapsed
- [ ] `execute_withdrawal` calculates proportional USDC based on current NAV and total shares
- [ ] `execute_withdrawal` burns escrowed shares and transfers USDC to user
- [ ] `execute_withdrawal` updates vault state (total_shares, total_nav)
- [ ] Both instructions reject zero-share amounts
- [ ] `request_withdrawal` rejects if vault is paused
- [ ] `execute_withdrawal` works even if vault is paused (users must always be able to exit)
- [ ] Events emitted for both steps

## Implementation

### Part 1: Request Withdrawal

File: `programs/obey-mvp-vault/src/instructions/request_withdrawal.rs`

```rust
use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, TokenAccount, Transfer, Mint};

use crate::errors::VaultError;
use crate::events::WithdrawalRequestEvent;
use crate::state::*;

#[derive(Accounts)]
pub struct RequestWithdraw<'info> {
    #[account(mut)]
    pub user: Signer<'info>,

    #[account(
        mut,
        seeds = [VAULT_SEED, vault_state.admin.as_ref()],
        bump = vault_state.bump,
        constraint = !vault_state.paused @ VaultError::VaultPaused,
    )]
    pub vault_state: Account<'info, VaultState>,

    /// Share token mint
    #[account(
        constraint = share_mint.key() == vault_state.share_mint,
    )]
    pub share_mint: Account<'info, Mint>,

    /// User's share token account — source of shares to escrow
    #[account(
        mut,
        associated_token::mint = share_mint,
        associated_token::authority = user,
    )]
    pub user_share_ata: Account<'info, TokenAccount>,

    /// Escrow token account for the shares — PDA owned by withdrawal_request.
    /// Created fresh for each withdrawal request.
    #[account(
        init,
        payer = user,
        token::mint = share_mint,
        token::authority = withdrawal_request,
    )]
    pub escrow_share_ata: Account<'info, TokenAccount>,

    /// The withdrawal request PDA — unique per user + timestamp combo.
    /// Using user key + requested_at prevents collisions for multiple requests.
    #[account(
        init,
        payer = user,
        space = WithdrawalRequest::SIZE,
        seeds = [
            WITHDRAWAL_SEED,
            vault_state.key().as_ref(),
            user.key().as_ref(),
            &Clock::get()?.unix_timestamp.to_le_bytes(),
        ],
        bump,
    )]
    pub withdrawal_request: Account<'info, WithdrawalRequest>,

    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
}

pub fn handler(ctx: Context<RequestWithdraw>, shares: u64) -> Result<()> {
    require!(shares > 0, VaultError::ZeroShares);

    let vault = &ctx.accounts.vault_state;
    let now = Clock::get()?.unix_timestamp;

    // Transfer shares from user to escrow
    let transfer_ctx = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        Transfer {
            from: ctx.accounts.user_share_ata.to_account_info(),
            to: ctx.accounts.escrow_share_ata.to_account_info(),
            authority: ctx.accounts.user.to_account_info(),
        },
    );
    token::transfer(transfer_ctx, shares)?;

    // Populate withdrawal request
    let request = &mut ctx.accounts.withdrawal_request;
    request.user = ctx.accounts.user.key();
    request.share_amount = shares;
    request.nav_at_request = vault.total_nav;
    request.requested_at = now;
    request.executable_after = now
        .checked_add(vault.withdrawal_delay_secs)
        .ok_or(VaultError::MathOverflow)?;
    request.executed = false;
    request.bump = ctx.bumps.withdrawal_request;

    emit!(WithdrawalRequestEvent {
        user: request.user,
        share_amount: shares,
        nav_at_request: vault.total_nav,
        executable_after: request.executable_after,
    });

    Ok(())
}
```

### Part 2: Execute Withdrawal

File: `programs/obey-mvp-vault/src/instructions/execute_withdrawal.rs`

```rust
use anchor_lang::prelude::*;
use anchor_spl::token::{self, Burn, Mint, Token, TokenAccount, Transfer};

use crate::errors::VaultError;
use crate::events::WithdrawalExecutedEvent;
use crate::state::*;

#[derive(Accounts)]
pub struct ExecuteWithdraw<'info> {
    /// Can be the user or any permissionless cranker
    #[account(mut)]
    pub payer: Signer<'info>,

    /// The original user who requested the withdrawal
    /// CHECK: Validated against withdrawal_request.user
    pub user: UncheckedAccount<'info>,

    #[account(
        mut,
        seeds = [VAULT_SEED, vault_state.admin.as_ref()],
        bump = vault_state.bump,
        // NOTE: No pause check here — withdrawals must always execute
    )]
    pub vault_state: Account<'info, VaultState>,

    /// The withdrawal request PDA
    #[account(
        mut,
        constraint = withdrawal_request.user == user.key() @ VaultError::WrongUser,
        constraint = !withdrawal_request.executed @ VaultError::AlreadyExecuted,
    )]
    pub withdrawal_request: Account<'info, WithdrawalRequest>,

    /// Share token mint — shares will be burned
    #[account(
        mut,
        constraint = share_mint.key() == vault_state.share_mint,
    )]
    pub share_mint: Account<'info, Mint>,

    /// Escrow token account holding the escrowed shares
    #[account(
        mut,
        token::mint = share_mint,
        token::authority = withdrawal_request,
    )]
    pub escrow_share_ata: Account<'info, TokenAccount>,

    /// Vault USDC token account — source of USDC to return
    #[account(
        mut,
        constraint = vault_usdc_ata.key() == vault_state.vault_usdc_ata,
    )]
    pub vault_usdc_ata: Account<'info, TokenAccount>,

    /// User's USDC token account — destination for returned USDC
    #[account(
        mut,
        token::mint = vault_state.usdc_mint,
        token::authority = user,
    )]
    pub user_usdc_ata: Account<'info, TokenAccount>,

    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
}

pub fn handler(ctx: Context<ExecuteWithdraw>) -> Result<()> {
    let now = Clock::get()?.unix_timestamp;
    let request = &ctx.accounts.withdrawal_request;

    // Check withdrawal delay has elapsed
    require!(
        now >= request.executable_after,
        VaultError::WithdrawalDelayActive
    );

    let vault = &ctx.accounts.vault_state;
    let shares = request.share_amount;

    // Calculate proportional USDC to return
    // usdc_amount = shares * total_nav / total_shares
    let usdc_amount = (shares as u128)
        .checked_mul(vault.total_nav as u128)
        .ok_or(VaultError::MathOverflow)?
        .checked_div(vault.total_shares as u128)
        .ok_or(VaultError::MathOverflow)?;
    let usdc_amount = u64::try_from(usdc_amount).map_err(|_| VaultError::MathOverflow)?;

    // Cap at available USDC in vault (safety — agent may have funds deployed)
    let available_usdc = ctx.accounts.vault_usdc_ata.amount;
    let transfer_amount = usdc_amount.min(available_usdc);

    // 1. Burn escrowed shares (withdrawal_request PDA signs)
    let wr_seeds = &[
        WITHDRAWAL_SEED,
        ctx.accounts.vault_state.to_account_info().key.as_ref(),
        request.user.as_ref(),
        &request.requested_at.to_le_bytes(),
        &[request.bump],
    ];
    let wr_signer = &[&wr_seeds[..]];

    let burn_ctx = CpiContext::new_with_signer(
        ctx.accounts.token_program.to_account_info(),
        Burn {
            mint: ctx.accounts.share_mint.to_account_info(),
            from: ctx.accounts.escrow_share_ata.to_account_info(),
            authority: ctx.accounts.withdrawal_request.to_account_info(),
        },
        wr_signer,
    );
    token::burn(burn_ctx, shares)?;

    // 2. Transfer USDC from vault to user (vault PDA signs)
    let vault_seeds = &[
        VAULT_SEED,
        vault.admin.as_ref(),
        &[vault.bump],
    ];
    let vault_signer = &[&vault_seeds[..]];

    if transfer_amount > 0 {
        let transfer_ctx = CpiContext::new_with_signer(
            ctx.accounts.token_program.to_account_info(),
            Transfer {
                from: ctx.accounts.vault_usdc_ata.to_account_info(),
                to: ctx.accounts.user_usdc_ata.to_account_info(),
                authority: ctx.accounts.vault_state.to_account_info(),
            },
            vault_signer,
        );
        token::transfer(transfer_ctx, transfer_amount)?;
    }

    // 3. Update vault state
    let vault = &mut ctx.accounts.vault_state;
    vault.total_shares = vault.total_shares
        .checked_sub(shares)
        .ok_or(VaultError::MathOverflow)?;
    vault.total_nav = vault.total_nav
        .checked_sub(transfer_amount)
        .ok_or(VaultError::MathOverflow)?;

    // 4. Mark request as executed
    let request = &mut ctx.accounts.withdrawal_request;
    request.executed = true;

    emit!(WithdrawalExecutedEvent {
        user: request.user,
        shares_burned: shares,
        usdc_returned: transfer_amount,
        total_shares_after: vault.total_shares,
        total_nav_after: vault.total_nav,
    });

    Ok(())
}
```

### Withdrawal Math

The proportional withdrawal formula:

```
usdc_returned = shares_burned * total_nav / total_shares
```

Example:
1. Vault has 1500 shares, NAV = 1800 USDC. Price per share = 1.2 USDC.
2. Alice holds 1000 shares, requests withdrawal of 500 shares.
3. `usdc = 500 * 1800 / 1500 = 600 USDC`. Alice gets 600 USDC, her 500 shares are burned.
4. Vault now: 1000 shares, NAV = 1200 USDC. Price per share = still 1.2. Fair exit.

### Important Design Decisions

1. **Two-phase withdrawal**: Even with `withdrawal_delay_secs = 0`, the two-step flow exists. This is for forward-compatibility with the full vault that enforces real delays. With delay=0, both transactions can happen in the same block.

2. **Permissionless execution**: `execute_withdrawal` does not require the user to sign. Anyone (a cranker, the admin, or the user) can execute it after the delay. This enables automated withdrawal processing.

3. **USDC cap at available**: If the agent has deployed funds to Drift, the vault USDC ATA might hold less than the proportional amount. `transfer_amount = usdc_amount.min(available_usdc)` ensures the tx does not revert. The agent must return funds to the vault before large withdrawals.

4. **Withdrawals work when paused**: The `ExecuteWithdraw` context does NOT check `vault_state.paused`. Users must always be able to exit, even during emergencies.

## Done When

- [ ] All requirements met
- [ ] `request_withdrawal` escrows shares and creates `WithdrawalRequest` PDA
- [ ] `execute_withdrawal` burns shares and returns proportional USDC
- [ ] Attempting execution before delay elapsed reverts with `WithdrawalDelayActive`
- [ ] Attempting double-execution reverts with `AlreadyExecuted`
- [ ] Zero-share requests revert with `ZeroShares`
- [ ] Withdrawal works when vault is paused
- [ ] Request blocked when vault is paused
- [ ] Events emitted for both request and execution
- [ ] `anchor build` passes
