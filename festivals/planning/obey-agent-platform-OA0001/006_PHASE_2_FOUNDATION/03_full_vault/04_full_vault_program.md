---
fest_type: task
fest_id: 04_full_vault_program.md
fest_name: full_vault_program
fest_parent: 03_full_vault
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.60933-06:00
fest_tracking: true
---

# Task: obey_vault Anchor Program (Deposits, Trades, Withdrawals)

## Objective

Implement the `obey_vault` Anchor program with deposit (share minting), burn request/execute (withdrawal with optional delay), trade execution (via whitelisted routers with fee deduction and concentration check), and NAV update instructions.

## Requirements

- [ ] `VaultState` PDA per agent: share_mint, total_shares, total_nav, base_asset, nav_last_updated, all_time_high_nav, total_fees_collected, bumps
- [ ] `BurnRequest` PDA: user, agent_id, share_amount, nav_at_request, requested_at, executable_after, executed, bump
- [ ] `deposit` instruction: transfer asset to vault, calculate shares at current NAV, mint creator and depositor shares
- [ ] `request_burn` instruction: lock shares in escrow, snapshot NAV, start withdrawal delay
- [ ] `execute_burn` instruction: verify delay elapsed, calculate proportional assets, transfer to user, burn shares
- [ ] `execute_trade` instruction: verify agent_signer, deduct fee via CPI to obey_fees, CPI to whitelisted router, post-trade concentration check, drawdown circuit breaker
- [ ] `update_nav` instruction: read Pyth feeds for all held tokens via CPI to obey_nav, update VaultState
- [ ] Share mint is a PDA-controlled SPL token mint unique per agent
- [ ] All state transitions emit events

## Implementation

### Step 1: State accounts

Create `programs/obey_vault/src/state.rs`:

```rust
use anchor_lang::prelude::*;

#[account]
pub struct VaultState {
    pub agent_id: u64,
    pub share_mint: Pubkey,
    pub total_shares: u64,
    pub total_nav: u64,             // in USDC base units (6 decimals)
    pub base_asset: Pubkey,         // USDC mint
    pub nav_last_updated: i64,
    pub all_time_high_nav: u64,
    pub total_fees_collected: u64,
    pub total_fees_waived: u64,
    pub bump: u8,
    pub share_mint_bump: u8,
}

impl VaultState {
    pub const SIZE: usize = 8 + 8 + 32 + 8 + 8 + 32 + 8 + 8 + 8 + 8 + 1 + 1; // 130 bytes
    pub const SEED: &'static [u8] = b"vault";
    pub const SHARE_MINT_SEED: &'static [u8] = b"share_mint";
}

#[account]
pub struct BurnRequest {
    pub user: Pubkey,
    pub agent_id: u64,
    pub share_amount: u64,
    pub nav_at_request: u64,
    pub requested_at: i64,
    pub executable_after: i64,
    pub executed: bool,
    pub bump: u8,
}

impl BurnRequest {
    pub const SIZE: usize = 8 + 32 + 8 + 8 + 8 + 8 + 8 + 1 + 1; // 90 bytes
    pub const SEED: &'static [u8] = b"burn_request";
}
```

### Step 2: Implement deposit instruction

```rust
#[derive(Accounts)]
#[instruction(agent_id: u64, amount: u64)]
pub struct Deposit<'info> {
    #[account(mut)]
    pub user: Signer<'info>,

    #[account(
        seeds = [b"agent", &agent_id.to_le_bytes()],
        bump,
        constraint = agent_state.status == AgentStatus::Active @ ErrorCode::AgentPaused,
    )]
    pub agent_state: Account<'info, AgentState>,

    #[account(
        mut,
        seeds = [VaultState::SEED, &agent_id.to_le_bytes()],
        bump = vault_state.bump,
    )]
    pub vault_state: Account<'info, VaultState>,

    /// User's token account for the deposit asset.
    #[account(mut)]
    pub user_token_account: Account<'info, TokenAccount>,

    /// Vault's token account for the deposit asset.
    #[account(mut)]
    pub vault_token_account: Account<'info, TokenAccount>,

    /// Share mint PDA for this agent.
    #[account(mut)]
    pub share_mint: Account<'info, Mint>,

    /// User's share token account (created if needed).
    #[account(mut)]
    pub user_share_account: Account<'info, TokenAccount>,

    /// Creator's share token account.
    #[account(mut)]
    pub creator_share_account: Account<'info, TokenAccount>,

    /// Vault PDA authority.
    /// CHECK: PDA seeds validated.
    pub vault_authority: AccountInfo<'info>,

    /// IncentiveConfig for bonus shares (optional).
    pub incentive_config: Option<Account<'info, IncentiveConfig>>,

    /// Deposit asset mint.
    pub deposit_mint: Account<'info, Mint>,

    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
}

pub fn deposit(ctx: Context<Deposit>, agent_id: u64, amount: u64) -> Result<()> {
    let vault = &mut ctx.accounts.vault_state;
    let agent = &ctx.accounts.agent_state;

    // Verify asset is accepted by this agent
    require!(
        agent.accepted_assets.contains(&ctx.accounts.deposit_mint.key()),
        ErrorCode::AssetNotAccepted
    );

    // Calculate shares to mint
    let base_shares = if vault.total_shares == 0 {
        amount // 1:1 bootstrap
    } else {
        (amount as u128)
            .checked_mul(vault.total_shares as u128).unwrap()
            .checked_div(vault.total_nav as u128).unwrap() as u64
    };

    // Creator gets ownership %
    let creator_shares = (base_shares as u128)
        .checked_mul(agent.owner_pct_bps as u128).unwrap()
        .checked_div(10_000).unwrap() as u64;
    let user_base_shares = base_shares.checked_sub(creator_shares).unwrap();

    // Apply bonus multiplier if active
    let user_shares = if let Some(ref incentive) = ctx.accounts.incentive_config {
        let clock = Clock::get()?;
        if clock.unix_timestamp < incentive.bonus_deadline {
            (user_base_shares as u128)
                .checked_mul(incentive.bonus_multiplier_bps as u128).unwrap()
                .checked_div(10_000).unwrap() as u64
        } else {
            user_base_shares
        }
    } else {
        user_base_shares
    };

    let total_minted = creator_shares.checked_add(user_shares).unwrap();

    // Transfer deposit asset from user to vault
    let transfer_ctx = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        Transfer {
            from: ctx.accounts.user_token_account.to_account_info(),
            to: ctx.accounts.vault_token_account.to_account_info(),
            authority: ctx.accounts.user.to_account_info(),
        },
    );
    token::transfer(transfer_ctx, amount)?;

    // Mint shares to creator and user using vault PDA authority
    let seeds = &[VaultState::SEED, &agent_id.to_le_bytes(), &[vault.bump]];
    let signer = &[&seeds[..]];

    let mint_to_creator = CpiContext::new_with_signer(
        ctx.accounts.token_program.to_account_info(),
        MintTo {
            mint: ctx.accounts.share_mint.to_account_info(),
            to: ctx.accounts.creator_share_account.to_account_info(),
            authority: ctx.accounts.vault_authority.to_account_info(),
        },
        signer,
    );
    token::mint_to(mint_to_creator, creator_shares)?;

    let mint_to_user = CpiContext::new_with_signer(
        ctx.accounts.token_program.to_account_info(),
        MintTo {
            mint: ctx.accounts.share_mint.to_account_info(),
            to: ctx.accounts.user_share_account.to_account_info(),
            authority: ctx.accounts.vault_authority.to_account_info(),
        },
        signer,
    );
    token::mint_to(mint_to_user, user_shares)?;

    // Update state
    vault.total_shares = vault.total_shares.checked_add(total_minted).unwrap();
    vault.total_nav = vault.total_nav.checked_add(amount).unwrap();

    emit!(DepositEvent {
        agent_id,
        user: ctx.accounts.user.key(),
        amount,
        creator_shares,
        user_shares,
        total_shares: vault.total_shares,
        nav: vault.total_nav,
    });

    Ok(())
}
```

### Step 3: Implement request_burn and execute_burn

```rust
pub fn request_burn(ctx: Context<RequestBurn>, agent_id: u64, share_amount: u64) -> Result<()> {
    let vault = &ctx.accounts.vault_state;
    let agent = &ctx.accounts.agent_state;

    // Transfer shares from user to burn_request escrow
    // ... SPL transfer ...

    let burn = &mut ctx.accounts.burn_request;
    burn.user = ctx.accounts.user.key();
    burn.agent_id = agent_id;
    burn.share_amount = share_amount;
    burn.nav_at_request = vault.total_nav;
    burn.requested_at = Clock::get()?.unix_timestamp;
    burn.executable_after = burn.requested_at + agent.withdrawal_delay_secs;
    burn.executed = false;
    burn.bump = ctx.bumps.burn_request;

    Ok(())
}

pub fn execute_burn(ctx: Context<ExecuteBurn>, agent_id: u64) -> Result<()> {
    let burn = &ctx.accounts.burn_request;
    let vault = &mut ctx.accounts.vault_state;
    let clock = Clock::get()?;

    require!(clock.unix_timestamp >= burn.executable_after, ErrorCode::WithdrawalDelayActive);
    require!(!burn.executed, ErrorCode::AlreadyExecuted);

    // Calculate proportional share
    let share_pct_bps = (burn.share_amount as u128)
        .checked_mul(10_000).unwrap()
        .checked_div(vault.total_shares as u128).unwrap();

    // Transfer proportional assets from vault to user
    // Using remaining_accounts for [vault_ata, user_ata] pairs
    for pair in ctx.remaining_accounts.chunks(2) {
        let vault_ata = &pair[0];
        let user_ata = &pair[1];
        let balance = TokenAccount::try_deserialize(&mut &**vault_ata.try_borrow_data()?)?.amount;
        let transfer_amount = (balance as u128)
            .checked_mul(share_pct_bps).unwrap()
            .checked_div(10_000).unwrap() as u64;

        if transfer_amount > 0 {
            // Transfer via PDA signer
            // ...
        }
    }

    // Burn the shares
    // ... token::burn ...

    vault.total_shares = vault.total_shares.checked_sub(burn.share_amount).unwrap();

    emit!(BurnExecutedEvent {
        agent_id,
        user: burn.user,
        shares: burn.share_amount,
        nav: vault.total_nav,
    });

    Ok(())
}
```

### Step 4: Implement execute_trade

```rust
pub fn execute_trade(ctx: Context<ExecuteTrade>, agent_id: u64, trade_value: u64) -> Result<()> {
    let agent = &mut ctx.accounts.agent_state;
    let vault = &mut ctx.accounts.vault_state;
    let platform = &ctx.accounts.platform_config;

    // Only the registered agent signer can call this
    require!(ctx.accounts.signer.key() == agent.agent_signer, ErrorCode::Unauthorized);
    require!(agent.status == AgentStatus::Active, ErrorCode::AgentPaused);
    require!(!platform.paused, ErrorCode::PlatformPaused);

    // Verify router is whitelisted
    let adapter = ctx.accounts.adapter_program.key();
    require!(platform.approved_routers.contains(&adapter), ErrorCode::RouterNotApproved);

    // CPI to obey_fees: collect_trade_fee
    // This deducts 0.8% and stores in fee accumulator
    let fee = collect_fee_cpi(ctx, agent_id, trade_value)?;
    let net_value = trade_value.checked_sub(fee).unwrap();

    // CPI to whitelisted adapter/router
    // ... execute the actual swap/order ...

    // Post-trade: concentration check via CPI to obey_nav
    // ... check_concentration(...) ...

    // Drawdown circuit breaker
    let drawdown_limit = (agent.high_water_mark as u128)
        .checked_mul((10_000 - agent.max_drawdown_bps as u128) as u128).unwrap()
        .checked_div(10_000).unwrap() as u64;
    if vault.total_nav < drawdown_limit {
        agent.status = AgentStatus::Paused;
        emit!(AgentPausedEvent { agent_id, reason: "max_drawdown".to_string() });
    }

    // Update stats
    agent.trade_count = agent.trade_count.checked_add(1).unwrap();
    agent.last_trade_at = Clock::get()?.unix_timestamp;
    vault.total_fees_collected = vault.total_fees_collected.checked_add(fee).unwrap();
    if vault.total_nav > vault.all_time_high_nav {
        vault.all_time_high_nav = vault.total_nav;
    }

    emit!(TradeExecutedEvent { agent_id, value: net_value, fee, nav: vault.total_nav });
    Ok(())
}
```

### Step 5: Write tests

In `tests/test_vault.rs`:

1. `test_deposit_first_user` — first deposit gets 1:1 shares, creator gets owner_pct
2. `test_deposit_second_user` — second deposit gets proportional shares based on NAV
3. `test_deposit_paused_agent_rejected` — paused agent rejects deposits
4. `test_request_burn` — shares locked in escrow, BurnRequest created
5. `test_execute_burn_after_delay` — wait for delay, execute, verify proportional asset transfer
6. `test_execute_burn_before_delay` — rejected if delay not elapsed
7. `test_execute_trade_unauthorized` — non-agent-signer rejected
8. `test_execute_trade_unapproved_router` — router not in whitelist rejected
9. `test_drawdown_circuit_breaker` — NAV drops below threshold, agent auto-paused
10. `test_full_lifecycle` — deposit -> trade -> NAV update -> burn (end-to-end)

## Done When

- [ ] All requirements met
- [ ] Deposits mint shares proportionally with creator ownership cut
- [ ] Burns transfer proportional underlying assets after withdrawal delay
- [ ] Trades deduct fees, execute via whitelisted routers, check concentration
- [ ] Drawdown circuit breaker auto-pauses agent at configured threshold
- [ ] Share mint is PDA-controlled, unique per agent
- [ ] All instructions emit events
- [ ] `anchor test` passes with all vault program tests green
