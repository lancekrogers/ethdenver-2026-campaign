---
fest_type: task
fest_id: 02_vault_state.md
fest_name: vault_state
fest_parent: 01_anchor_vault
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.355802-06:00
fest_tracking: true
---

# Task: Define Vault State Accounts and Error Codes

## Objective

Define all on-chain account structs (`VaultState`, `WithdrawalRequest`), error codes, and events for the MVP vault program, establishing the data model that all instructions operate on.

## Requirements

- [ ] `VaultState` account struct with all fields needed for deposit/withdraw/NAV tracking
- [ ] `WithdrawalRequest` account struct for escrowed withdrawal state
- [ ] Custom error enum covering all failure modes
- [ ] Event structs for deposit, withdrawal request, withdrawal execution, and NAV update
- [ ] Account sizes documented and constants defined for PDA seeds

## Implementation

### Step 1: Restructure lib.rs into modules

Create a modular file layout under `programs/obey-mvp-vault/src/`:

```
programs/obey-mvp-vault/src/
  lib.rs          — program entry, declare_id, mod declarations
  state.rs        — VaultState, WithdrawalRequest
  errors.rs       — VaultError enum
  events.rs       — event structs
  instructions/
    mod.rs
    initialize.rs
    deposit.rs
    request_withdrawal.rs
    execute_withdrawal.rs
    update_nav.rs
```

### Step 2: Define state accounts

File: `programs/obey-mvp-vault/src/state.rs`

```rust
use anchor_lang::prelude::*;

/// Seeds for PDA derivation
pub const VAULT_SEED: &[u8] = b"vault";
pub const SHARE_MINT_SEED: &[u8] = b"share_mint";
pub const VAULT_USDC_SEED: &[u8] = b"vault_usdc";
pub const WITHDRAWAL_SEED: &[u8] = b"withdrawal";

/// Primary vault state — one per agent
#[account]
pub struct VaultState {
    /// Admin who can update NAV and pause the vault
    pub admin: Pubkey,
    /// The agent wallet that trades with deposited funds
    pub agent_wallet: Pubkey,
    /// The SPL token mint for vault share tokens (PDA-controlled)
    pub share_mint: Pubkey,
    /// The vault's USDC token account (PDA-controlled)
    pub vault_usdc_ata: Pubkey,
    /// USDC mint address
    pub usdc_mint: Pubkey,
    /// Total outstanding share tokens
    pub total_shares: u64,
    /// Current net asset value in USDC base units (6 decimals)
    pub total_nav: u64,
    /// Timestamp of last NAV update
    pub nav_last_updated: i64,
    /// Highest NAV ever recorded (for future performance fee use)
    pub all_time_high_nav: u64,
    /// Withdrawal delay in seconds (0 = instant for MVP)
    pub withdrawal_delay_secs: i64,
    /// Emergency pause flag — blocks deposits and new withdrawals
    pub paused: bool,
    /// PDA bump for the vault state account
    pub bump: u8,
    /// PDA bump for the share mint
    pub share_mint_bump: u8,
    /// PDA bump for the vault USDC ATA
    pub vault_usdc_bump: u8,
}

impl VaultState {
    /// Account discriminator (8) + all fields
    /// Pubkeys: 5 * 32 = 160
    /// u64: 4 * 8 = 32
    /// i64: 2 * 8 = 16
    /// bool: 1
    /// u8: 3
    /// Total: 8 + 160 + 32 + 16 + 1 + 3 = 220
    pub const SIZE: usize = 8 + 32 * 5 + 8 * 4 + 8 * 2 + 1 + 3;
}

/// Tracks a pending withdrawal request
#[account]
pub struct WithdrawalRequest {
    /// The user who requested the withdrawal
    pub user: Pubkey,
    /// Number of share tokens escrowed
    pub share_amount: u64,
    /// NAV at the time of request (for reference/auditing)
    pub nav_at_request: u64,
    /// Unix timestamp when request was created
    pub requested_at: i64,
    /// Unix timestamp after which withdrawal can be executed
    pub executable_after: i64,
    /// Whether this request has been executed
    pub executed: bool,
    /// PDA bump
    pub bump: u8,
}

impl WithdrawalRequest {
    /// 8 + 32 + 8 + 8 + 8 + 8 + 1 + 1 = 74
    pub const SIZE: usize = 8 + 32 + 8 * 4 + 1 + 1;
}
```

### Step 3: Define error codes

File: `programs/obey-mvp-vault/src/errors.rs`

```rust
use anchor_lang::prelude::*;

#[error_code]
pub enum VaultError {
    #[msg("Vault is paused")]
    VaultPaused,
    #[msg("Deposit amount must be greater than zero")]
    ZeroDeposit,
    #[msg("Share amount must be greater than zero")]
    ZeroShares,
    #[msg("Insufficient share balance")]
    InsufficientShares,
    #[msg("Withdrawal delay has not elapsed")]
    WithdrawalDelayActive,
    #[msg("Withdrawal request already executed")]
    AlreadyExecuted,
    #[msg("NAV must be greater than zero for deposits after initialization")]
    NavIsZero,
    #[msg("Arithmetic overflow")]
    MathOverflow,
    #[msg("Unauthorized — only admin can perform this action")]
    Unauthorized,
    #[msg("Invalid USDC mint")]
    InvalidUsdcMint,
    #[msg("Withdrawal request does not belong to this user")]
    WrongUser,
}
```

### Step 4: Define events

File: `programs/obey-mvp-vault/src/events.rs`

```rust
use anchor_lang::prelude::*;

#[event]
pub struct VaultInitialized {
    pub admin: Pubkey,
    pub agent_wallet: Pubkey,
    pub share_mint: Pubkey,
    pub vault_usdc_ata: Pubkey,
}

#[event]
pub struct DepositEvent {
    pub user: Pubkey,
    pub usdc_amount: u64,
    pub shares_minted: u64,
    pub nav_at_deposit: u64,
    pub total_shares_after: u64,
    pub total_nav_after: u64,
}

#[event]
pub struct WithdrawalRequestEvent {
    pub user: Pubkey,
    pub share_amount: u64,
    pub nav_at_request: u64,
    pub executable_after: i64,
}

#[event]
pub struct WithdrawalExecutedEvent {
    pub user: Pubkey,
    pub shares_burned: u64,
    pub usdc_returned: u64,
    pub total_shares_after: u64,
    pub total_nav_after: u64,
}

#[event]
pub struct NavUpdatedEvent {
    pub old_nav: u64,
    pub new_nav: u64,
    pub timestamp: i64,
}

#[event]
pub struct VaultPausedEvent {
    pub admin: Pubkey,
    pub timestamp: i64,
}

#[event]
pub struct VaultUnpausedEvent {
    pub admin: Pubkey,
    pub timestamp: i64,
}
```

### Step 5: Update lib.rs with module declarations

File: `programs/obey-mvp-vault/src/lib.rs`

```rust
use anchor_lang::prelude::*;

pub mod errors;
pub mod events;
pub mod instructions;
pub mod state;

use instructions::*;

declare_id!("YOUR_PROGRAM_ID_HERE");

#[program]
pub mod obey_mvp_vault {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, agent_wallet: Pubkey, withdrawal_delay_secs: i64) -> Result<()> {
        instructions::initialize::handler(ctx, agent_wallet, withdrawal_delay_secs)
    }

    pub fn deposit(ctx: Context<Deposit>, amount: u64) -> Result<()> {
        instructions::deposit::handler(ctx, amount)
    }

    pub fn request_withdrawal(ctx: Context<RequestWithdraw>, shares: u64) -> Result<()> {
        instructions::request_withdrawal::handler(ctx, shares)
    }

    pub fn execute_withdrawal(ctx: Context<ExecuteWithdraw>) -> Result<()> {
        instructions::execute_withdrawal::handler(ctx)
    }

    pub fn update_nav(ctx: Context<UpdateNav>, new_nav: u64) -> Result<()> {
        instructions::update_nav::handler(ctx, new_nav)
    }
}
```

Create `programs/obey-mvp-vault/src/instructions/mod.rs`:

```rust
pub mod initialize;
pub mod deposit;
pub mod request_withdrawal;
pub mod execute_withdrawal;
pub mod update_nav;

pub use initialize::*;
pub use deposit::*;
pub use request_withdrawal::*;
pub use execute_withdrawal::*;
pub use update_nav::*;
```

Each instruction module will be implemented in subsequent tasks. For now, create stub files that export the context struct and a handler returning `Ok(())`.

## Done When

- [ ] All requirements met
- [ ] `VaultState` has all fields: admin, agent_wallet, share_mint, vault_usdc_ata, usdc_mint, total_shares, total_nav, nav_last_updated, all_time_high_nav, withdrawal_delay_secs, paused, bump, share_mint_bump, vault_usdc_bump
- [ ] `WithdrawalRequest` has all fields: user, share_amount, nav_at_request, requested_at, executable_after, executed, bump
- [ ] `VaultError` enum has entries for every failure mode across all instructions
- [ ] All event structs defined with appropriate fields
- [ ] `lib.rs` dispatches to instruction modules
- [ ] `anchor build` compiles successfully with the new module structure
