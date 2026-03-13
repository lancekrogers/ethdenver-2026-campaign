---
fest_type: task
fest_id: 01_referral_state.md
fest_name: referral_state
fest_parent: 01_referral_system
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.529983-06:00
fest_tracking: true
---

# Task: Referral State Account (Anchor Program)

## Objective

Implement the `ReferralState` on-chain account and initialization instruction in the Anchor contracts that tracks referral relationships (2-level deep) and lifetime earnings per wallet.

## Requirements

- [ ] `ReferralState` PDA account seeded by `["referral", user_pubkey]`
- [ ] Fields: `referrer` (Pubkey), `referrer_l2` (Option<Pubkey>), `referred_users` (u32), `total_earned` (u64), `bump` (u8)
- [ ] `initialize_referral` instruction: creates ReferralState, links to referrer and referrer_l2
- [ ] Constraint: referrer_l2 is auto-populated by reading the referrer's own ReferralState
- [ ] Constraint: a wallet cannot refer itself
- [ ] Constraint: ReferralState can only be initialized once per wallet (PDA uniqueness)
- [ ] Account sizing: calculate exact byte size for rent exemption

## Implementation

### Step 1: Define the ReferralState account

In `programs/obey_registry/src/state/referral.rs` (create this file):

```rust
use anchor_lang::prelude::*;

#[account]
pub struct ReferralState {
    /// The wallet that referred this user (L1 referrer).
    pub referrer: Pubkey,
    /// The wallet that referred the referrer (L2 referrer), if any.
    pub referrer_l2: Option<Pubkey>,
    /// Number of users this wallet has directly referred.
    pub referred_users: u32,
    /// Lifetime referral earnings in lamports.
    pub total_earned: u64,
    /// PDA bump seed.
    pub bump: u8,
}

impl ReferralState {
    /// Account discriminator (8) + pubkey (32) + option<pubkey> (1+32) + u32 (4) + u64 (8) + u8 (1) = 86 bytes
    pub const SIZE: usize = 8 + 32 + 33 + 4 + 8 + 1;

    pub const SEED_PREFIX: &'static [u8] = b"referral";
}
```

### Step 2: Implement initialize_referral instruction

In `programs/obey_registry/src/instructions/initialize_referral.rs`:

```rust
use anchor_lang::prelude::*;
use crate::state::ReferralState;

#[derive(Accounts)]
pub struct InitializeReferral<'info> {
    #[account(mut)]
    pub user: Signer<'info>,

    /// The referrer's wallet. Must be different from user.
    /// CHECK: We only read this pubkey for the referral link.
    pub referrer: AccountInfo<'info>,

    /// The referrer's own ReferralState, used to look up L2.
    /// If the referrer has no ReferralState, referrer_l2 will be None.
    #[account(
        seeds = [ReferralState::SEED_PREFIX, referrer.key().as_ref()],
        bump,
    )]
    pub referrer_state: Option<Account<'info, ReferralState>>,

    #[account(
        init,
        payer = user,
        space = ReferralState::SIZE,
        seeds = [ReferralState::SEED_PREFIX, user.key().as_ref()],
        bump,
    )]
    pub referral_state: Account<'info, ReferralState>,

    pub system_program: Program<'info, System>,
}

pub fn handler(ctx: Context<InitializeReferral>) -> Result<()> {
    let user_key = ctx.accounts.user.key();
    let referrer_key = ctx.accounts.referrer.key();

    // Cannot refer yourself
    require!(user_key != referrer_key, ErrorCode::SelfReferral);

    let referral = &mut ctx.accounts.referral_state;
    referral.referrer = referrer_key;
    referral.referred_users = 0;
    referral.total_earned = 0;
    referral.bump = ctx.bumps.referral_state;

    // Look up L2 referrer from the referrer's own state
    referral.referrer_l2 = ctx.accounts.referrer_state
        .as_ref()
        .map(|rs| rs.referrer);

    // Increment the referrer's referred_users count
    // This requires the referrer_state to be mutable — if it exists
    // Note: if referrer has no state (organic user), we skip this

    Ok(())
}
```

### Step 3: Add error codes

In `programs/obey_registry/src/errors.rs`:

```rust
#[error_code]
pub enum ErrorCode {
    // ... existing errors ...

    #[msg("Cannot refer yourself")]
    SelfReferral,
}
```

### Step 4: Register the instruction in the program module

In `programs/obey_registry/src/lib.rs`:

```rust
pub mod instructions;
pub mod state;
pub mod errors;

use anchor_lang::prelude::*;
use instructions::*;

declare_id!("..."); // program ID

#[program]
pub mod obey_registry {
    use super::*;

    // ... existing instructions ...

    pub fn initialize_referral(ctx: Context<InitializeReferral>) -> Result<()> {
        instructions::initialize_referral::handler(ctx)
    }
}
```

### Step 5: Write tests

In `tests/test_referral.rs`:

1. `test_initialize_referral_success` — user A refers user B, verify referrer set, L2 is None
2. `test_initialize_referral_with_l2` — A refers B, B refers C, verify C's referrer_l2 = A
3. `test_self_referral_rejected` — user tries to refer themselves, expect SelfReferral error
4. `test_double_init_rejected` — user tries to init referral twice, expect PDA constraint error
5. `test_referral_state_size` — verify SIZE constant matches actual serialized size

## Done When

- [ ] All requirements met
- [ ] `ReferralState` PDA is created with correct seeds `["referral", user_pubkey]`
- [ ] L2 referrer is auto-populated from the referrer's own ReferralState
- [ ] Self-referral is rejected
- [ ] Double initialization is prevented by PDA uniqueness
- [ ] `anchor test` passes with all referral state tests green
