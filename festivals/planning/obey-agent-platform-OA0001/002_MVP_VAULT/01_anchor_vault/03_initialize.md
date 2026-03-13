---
fest_type: task
fest_id: 03_initialize.md
fest_name: initialize
fest_parent: 01_anchor_vault
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.356104-06:00
fest_tracking: true
---

# Task: Implement Initialize Instruction

## Objective

Implement the `initialize` instruction that creates the vault state PDA, share token mint PDA, and vault USDC token account PDA, establishing the on-chain foundation for a single agent's vault.

## Requirements

- [ ] Creates `VaultState` PDA seeded by `["vault", admin.key()]`
- [ ] Creates share token mint as PDA seeded by `["share_mint", vault.key()]` with 6 decimals and vault PDA as mint authority
- [ ] Creates vault USDC associated token account as PDA owned by the vault state PDA
- [ ] Sets admin, agent_wallet, withdrawal_delay_secs, and all initial values
- [ ] Emits `VaultInitialized` event
- [ ] Only callable once per admin (PDA uniqueness enforces this)

## Implementation

File: `programs/obey-mvp-vault/src/instructions/initialize.rs`

```rust
use anchor_lang::prelude::*;
use anchor_spl::token::{Mint, Token, TokenAccount};
use anchor_spl::associated_token::AssociatedToken;

use crate::state::*;
use crate::events::*;

#[derive(Accounts)]
pub struct Initialize<'info> {
    /// The admin who will manage this vault. Pays for account creation.
    #[account(mut)]
    pub admin: Signer<'info>,

    /// The vault state PDA — one per admin.
    #[account(
        init,
        payer = admin,
        space = VaultState::SIZE,
        seeds = [VAULT_SEED, admin.key().as_ref()],
        bump,
    )]
    pub vault_state: Account<'info, VaultState>,

    /// The share token mint PDA — controlled by the vault.
    /// 6 decimals to match USDC precision.
    #[account(
        init,
        payer = admin,
        mint::decimals = 6,
        mint::authority = vault_state,
        seeds = [SHARE_MINT_SEED, vault_state.key().as_ref()],
        bump,
    )]
    pub share_mint: Account<'info, Mint>,

    /// USDC mint — passed in and validated against known USDC mint addresses.
    pub usdc_mint: Account<'info, Mint>,

    /// The vault's USDC token account — holds all deposited USDC.
    /// Owned by the vault_state PDA so only the program can move funds.
    #[account(
        init,
        payer = admin,
        associated_token::mint = usdc_mint,
        associated_token::authority = vault_state,
    )]
    pub vault_usdc_ata: Account<'info, TokenAccount>,

    pub system_program: Program<'info, System>,
    pub token_program: Program<'info, Token>,
    pub associated_token_program: Program<'info, AssociatedToken>,
    pub rent: Sysvar<'info, Rent>,
}

pub fn handler(ctx: Context<Initialize>, agent_wallet: Pubkey, withdrawal_delay_secs: i64) -> Result<()> {
    let vault = &mut ctx.accounts.vault_state;

    vault.admin = ctx.accounts.admin.key();
    vault.agent_wallet = agent_wallet;
    vault.share_mint = ctx.accounts.share_mint.key();
    vault.vault_usdc_ata = ctx.accounts.vault_usdc_ata.key();
    vault.usdc_mint = ctx.accounts.usdc_mint.key();
    vault.total_shares = 0;
    vault.total_nav = 0;
    vault.nav_last_updated = Clock::get()?.unix_timestamp;
    vault.all_time_high_nav = 0;
    vault.withdrawal_delay_secs = withdrawal_delay_secs;
    vault.paused = false;
    vault.bump = ctx.bumps.vault_state;
    vault.share_mint_bump = ctx.bumps.share_mint;
    // vault_usdc_ata bump is managed by the associated token program
    vault.vault_usdc_bump = 0;

    emit!(VaultInitialized {
        admin: vault.admin,
        agent_wallet: vault.agent_wallet,
        share_mint: vault.share_mint,
        vault_usdc_ata: vault.vault_usdc_ata,
    });

    Ok(())
}
```

### PDA Derivation Reference

These are the PDAs created during initialization. All subsequent instructions must derive them the same way:

| PDA | Seeds | Authority/Owner |
|-----|-------|-----------------|
| `vault_state` | `["vault", admin.key()]` | System (account owner is program) |
| `share_mint` | `["share_mint", vault_state.key()]` | Mint authority = vault_state PDA |
| `vault_usdc_ata` | ATA of vault_state for usdc_mint | Token owner = vault_state PDA |

### Signing with the vault PDA

Subsequent instructions (deposit, withdrawal) need the vault PDA to sign CPI calls. The signer seeds are:

```rust
let vault_seeds = &[
    VAULT_SEED,
    vault.admin.as_ref(),
    &[vault.bump],
];
let signer_seeds = &[&vault_seeds[..]];
```

This pattern is used in `mint_to` (deposit), `transfer` (execute_withdrawal), and `burn` (execute_withdrawal).

## Done When

- [ ] All requirements met
- [ ] `anchor build` passes with the initialize instruction fully implemented
- [ ] Calling `initialize` creates all three PDAs (vault_state, share_mint, vault_usdc_ata)
- [ ] `VaultState` fields are all correctly populated after initialization
- [ ] `VaultInitialized` event is emitted with correct data
- [ ] Calling `initialize` twice with the same admin fails (PDA already exists)
