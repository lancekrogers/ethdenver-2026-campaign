---
fest_type: task
fest_id: 06_nav_update.md
fest_name: nav_update
fest_parent: 01_anchor_vault
fest_order: 6
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.356821-06:00
fest_tracking: true
---

# Task: Implement NAV Update and Pause/Unpause Instructions

## Objective

Implement the `update_nav` instruction (admin-only) that sets the current net asset value of the vault, and add `pause`/`unpause` admin instructions for emergency control.

## Requirements

- [ ] `update_nav` sets `total_nav` to a new value provided by the admin
- [ ] Only the vault admin can call `update_nav`
- [ ] Updates `nav_last_updated` timestamp
- [ ] Updates `all_time_high_nav` if new NAV exceeds it
- [ ] Emits `NavUpdatedEvent`
- [ ] `pause` sets `vault_state.paused = true` (admin-only)
- [ ] `unpause` sets `vault_state.paused = false` (admin-only)
- [ ] Both pause/unpause emit events

## Implementation

### Part 1: NAV Update

File: `programs/obey-mvp-vault/src/instructions/update_nav.rs`

```rust
use anchor_lang::prelude::*;

use crate::errors::VaultError;
use crate::events::NavUpdatedEvent;
use crate::state::*;

#[derive(Accounts)]
pub struct UpdateNav<'info> {
    /// Must be the vault admin
    #[account(
        constraint = admin.key() == vault_state.admin @ VaultError::Unauthorized,
    )]
    pub admin: Signer<'info>,

    #[account(
        mut,
        seeds = [VAULT_SEED, vault_state.admin.as_ref()],
        bump = vault_state.bump,
    )]
    pub vault_state: Account<'info, VaultState>,
}

pub fn handler(ctx: Context<UpdateNav>, new_nav: u64) -> Result<()> {
    let vault = &mut ctx.accounts.vault_state;
    let old_nav = vault.total_nav;
    let now = Clock::get()?.unix_timestamp;

    vault.total_nav = new_nav;
    vault.nav_last_updated = now;

    if new_nav > vault.all_time_high_nav {
        vault.all_time_high_nav = new_nav;
    }

    emit!(NavUpdatedEvent {
        old_nav,
        new_nav,
        timestamp: now,
    });

    Ok(())
}
```

### Part 2: Pause and Unpause

Add these to `lib.rs` program block:

```rust
pub fn pause(ctx: Context<AdminAction>) -> Result<()> {
    instructions::pause::handler(ctx)
}

pub fn unpause(ctx: Context<AdminAction>) -> Result<()> {
    instructions::unpause::handler(ctx)
}
```

File: `programs/obey-mvp-vault/src/instructions/pause.rs`

```rust
use anchor_lang::prelude::*;

use crate::errors::VaultError;
use crate::events::VaultPausedEvent;
use crate::state::*;

#[derive(Accounts)]
pub struct AdminAction<'info> {
    #[account(
        constraint = admin.key() == vault_state.admin @ VaultError::Unauthorized,
    )]
    pub admin: Signer<'info>,

    #[account(
        mut,
        seeds = [VAULT_SEED, vault_state.admin.as_ref()],
        bump = vault_state.bump,
    )]
    pub vault_state: Account<'info, VaultState>,
}

pub fn handler(ctx: Context<AdminAction>) -> Result<()> {
    let vault = &mut ctx.accounts.vault_state;
    vault.paused = true;

    emit!(VaultPausedEvent {
        admin: ctx.accounts.admin.key(),
        timestamp: Clock::get()?.unix_timestamp,
    });

    Ok(())
}
```

File: `programs/obey-mvp-vault/src/instructions/unpause.rs`

```rust
use anchor_lang::prelude::*;

use crate::errors::VaultError;
use crate::events::VaultUnpausedEvent;
use crate::state::*;

pub fn handler(ctx: Context<super::pause::AdminAction>) -> Result<()> {
    let vault = &mut ctx.accounts.vault_state;
    vault.paused = false;

    emit!(VaultUnpausedEvent {
        admin: ctx.accounts.admin.key(),
        timestamp: Clock::get()?.unix_timestamp,
    });

    Ok(())
}
```

Update `programs/obey-mvp-vault/src/instructions/mod.rs` to include the new modules:

```rust
pub mod initialize;
pub mod deposit;
pub mod request_withdrawal;
pub mod execute_withdrawal;
pub mod update_nav;
pub mod pause;
pub mod unpause;

pub use initialize::*;
pub use deposit::*;
pub use request_withdrawal::*;
pub use execute_withdrawal::*;
pub use update_nav::*;
pub use pause::*;
pub use unpause::*;
```

### MVP Trust Model

The `update_nav` instruction is admin-only and accepts any `u64` value. This is the MVP trust tradeoff from doc 11:

> Users trust the platform to report accurate NAV. This is acceptable because:
> 1. All Drift BET trades are on-chain and verifiable
> 2. NAV can be independently calculated from public Drift positions
> 3. The full anti-gaming vault replaces this in Phase 2
> 4. $5K-$50K AUM does not justify the complexity of full custody yet

In the full vault (Phase 2), NAV is computed on-chain from Pyth oracle feeds, not set by an admin. The MVP's off-chain verification flow:

```
Agent trades on Drift BET
  -> Agent calculates NAV from Drift positions
  -> Backend independently queries Drift API to verify
  -> If within tolerance (< 1% deviation), backend calls update_nav
  -> If deviation exceeds threshold, alert and do NOT update
```

### When NAV Changes Affect Share Pricing

NAV updates directly change share pricing for both deposits and withdrawals:

```
share_price = total_nav / total_shares
```

- If agent profits and NAV goes up: new deposits get fewer shares per USDC (fair — they did not participate in gains)
- If agent loses and NAV goes down: new deposits get more shares per USDC (fair — they are entering at lower value)
- Withdrawals always get proportional USDC at current NAV

## Done When

- [ ] All requirements met
- [ ] `update_nav` sets new NAV value, updates timestamp
- [ ] `update_nav` updates `all_time_high_nav` when appropriate
- [ ] Non-admin caller reverts with `Unauthorized`
- [ ] `pause` sets paused flag, deposits are blocked, withdrawals still work
- [ ] `unpause` clears paused flag, deposits resume
- [ ] All events emitted correctly
- [ ] `anchor build` passes with all instructions implemented
