# 02 — Smart Contract Design (Solana/Anchor)

## Program Overview

Four Anchor programs compose the on-chain layer:

| Program | Responsibility | Size Estimate |
|---------|---------------|---------------|
| `obey_registry` | Agent registration, metadata, creator management | ~800 LOC |
| `obey_vault` | Deposits, shares, trade execution, withdrawals | ~1200 LOC |
| `obey_nav` | Oracle reads, tiered valuation, concentration checks | ~500 LOC |
| `obey_fees` | Platform fee collection, treasury management | ~300 LOC |

## Program 1: obey_registry

### State Accounts

```rust
#[account]
pub struct PlatformConfig {
    pub admin: Pubkey,              // platform admin
    pub fee_rate_bps: u16,          // 100-200 (1-2%)
    pub treasury: Pubkey,           // fee collection address
    pub total_agents: u64,          // counter
    pub approved_tokens: Vec<Pubkey>, // platform-wide approved trading tokens
    pub approved_routers: Vec<Pubkey>, // whitelisted DEX programs
    pub paused: bool,               // emergency pause
    pub bump: u8,
}

#[account]
pub struct AgentState {
    pub agent_id: u64,              // sequential ID
    pub creator: Pubkey,            // creator wallet (management authority)
    pub agent_signer: Pubkey,       // agent's signing key (trade authority)
    pub agent_type: AgentType,      // PredictionMarket | DeFiTrading | Hybrid
    pub owner_pct_bps: u16,         // creator ownership (basis points, can only decrease)
    pub status: AgentStatus,        // Active | Paused | PendingUpdate

    // Configuration
    pub accepted_assets: Vec<Pubkey>,  // mints users can deposit
    pub trading_tokens: Vec<Pubkey>,   // subset of platform approved tokens
    pub metadata_uri: String,          // off-chain metadata (name, strategy, socials)

    // Risk Parameters
    pub max_drawdown_bps: u16,      // max drawdown before auto-pause (e.g., 2000 = 20%)
    pub max_concentration_bps: u16, // max single-token concentration (e.g., 4000 = 40%)
    pub withdrawal_delay_secs: i64, // delay between burn request and execution (0 = instant)

    // Stats
    pub total_deposited: u64,       // lifetime deposits
    pub total_withdrawn: u64,       // lifetime withdrawals
    pub created_at: i64,            // unix timestamp
    pub last_trade_at: i64,         // last trade timestamp
    pub trade_count: u64,           // total trades executed
    pub high_water_mark: u64,       // highest NAV (for performance fees)

    pub bump: u8,
}

#[account]
pub struct AgentUpdateProposal {
    pub agent_id: u64,
    pub new_agent_signer: Pubkey,
    pub proposed_at: i64,
    pub execute_after: i64,         // proposed_at + 48 hours
    pub executed: bool,
    pub bump: u8,
}

#[derive(AnchorSerialize, AnchorDeserialize, Clone, PartialEq)]
pub enum AgentType {
    PredictionMarket,
    DeFiTrading,
    Hybrid,
}

#[derive(AnchorSerialize, AnchorDeserialize, Clone, PartialEq)]
pub enum AgentStatus {
    Active,
    Paused,
    PendingUpdate,
}
```

### Instructions

```rust
#[program]
pub mod obey_registry {
    // Platform admin
    pub fn initialize_platform(ctx: Context<InitPlatform>, fee_rate_bps: u16) -> Result<()>
    pub fn update_fee_rate(ctx: Context<AdminOnly>, new_rate_bps: u16) -> Result<()>
    pub fn approve_token(ctx: Context<AdminOnly>, mint: Pubkey) -> Result<()>
    pub fn remove_token(ctx: Context<AdminOnly>, mint: Pubkey) -> Result<()>
    pub fn approve_router(ctx: Context<AdminOnly>, program_id: Pubkey) -> Result<()>
    pub fn emergency_pause(ctx: Context<AdminOnly>) -> Result<()>

    // Agent creation
    pub fn create_agent(
        ctx: Context<CreateAgent>,
        agent_type: AgentType,
        owner_pct_bps: u16,          // max 5000 (50%)
        accepted_assets: Vec<Pubkey>,
        trading_tokens: Vec<Pubkey>,
        metadata_uri: String,
        risk_params: RiskParams,
    ) -> Result<()>

    // Creator management
    pub fn update_metadata(ctx: Context<CreatorOnly>, new_uri: String) -> Result<()>
    pub fn lower_owner_pct(ctx: Context<CreatorOnly>, new_pct_bps: u16) -> Result<()>
    pub fn add_accepted_asset(ctx: Context<CreatorOnly>, mint: Pubkey) -> Result<()>
    pub fn remove_accepted_asset(ctx: Context<CreatorOnly>, mint: Pubkey) -> Result<()>
    pub fn tighten_risk_params(ctx: Context<CreatorOnly>, params: RiskParams) -> Result<()>
    pub fn pause_agent(ctx: Context<CreatorOnly>) -> Result<()>
    pub fn unpause_agent(ctx: Context<CreatorOnly>) -> Result<()>

    // Agent update (timelock)
    pub fn propose_agent_update(ctx: Context<CreatorOnly>, new_signer: Pubkey) -> Result<()>
    pub fn execute_agent_update(ctx: Context<ExecuteUpdate>) -> Result<()>
    pub fn cancel_agent_update(ctx: Context<CreatorOnly>) -> Result<()>
}
```

### Key Constraints

```rust
// create_agent constraints
require!(owner_pct_bps <= 5000, ErrorCode::OwnerPctTooHigh);  // max 50%
for asset in &accepted_assets {
    require!(platform.approved_tokens.contains(asset), ErrorCode::TokenNotApproved);
}
for token in &trading_tokens {
    require!(platform.approved_tokens.contains(token), ErrorCode::TokenNotApproved);
}

// lower_owner_pct constraints
require!(new_pct_bps < agent.owner_pct_bps, ErrorCode::MustDecrease);

// tighten_risk_params constraints
require!(params.max_drawdown_bps <= agent.max_drawdown_bps, ErrorCode::CanOnlyTighten);
require!(params.max_concentration_bps <= agent.max_concentration_bps, ErrorCode::CanOnlyTighten);

// propose_agent_update constraints
agent.status = AgentStatus::PendingUpdate;
proposal.execute_after = Clock::get()?.unix_timestamp + 172_800; // 48 hours

// execute_agent_update constraints
require!(Clock::get()?.unix_timestamp >= proposal.execute_after, ErrorCode::TimelockActive);
```

## Program 2: obey_vault

### State Accounts

```rust
#[account]
pub struct VaultState {
    pub agent_id: u64,
    pub share_mint: Pubkey,           // PDA-controlled mint for this agent's shares
    pub total_shares: u64,            // total outstanding shares
    pub total_nav: u64,               // last calculated NAV (in base units)
    pub base_asset: Pubkey,           // primary denomination (USDC mint)
    pub nav_last_updated: i64,        // timestamp
    pub all_time_high_nav: u64,       // for high-water mark
    pub total_fees_collected: u64,    // platform fees taken
    pub bump: u8,
    pub share_mint_bump: u8,
}

#[account]
pub struct BurnRequest {
    pub user: Pubkey,
    pub agent_id: u64,
    pub share_amount: u64,
    pub nav_at_request: u64,
    pub requested_at: i64,
    pub executable_after: i64,        // requested_at + withdrawal_delay
    pub executed: bool,
    pub bump: u8,
}

// No dedicated position tracking account on-chain.
// Positions on other chains (Polygon, Base) are tracked off-chain
// by the agent runtime and reported to the vault via NAV updates.
// Only Solana-native positions (Drift BET) could be tracked on-chain.
```

### Instructions

```rust
#[program]
pub mod obey_vault {
    /// Deposit accepted asset, mint share tokens
    pub fn deposit(
        ctx: Context<Deposit>,
        agent_id: u64,
        amount: u64,
    ) -> Result<()> {
        let vault = &mut ctx.accounts.vault_state;
        let agent = &ctx.accounts.agent_state;

        // Verify asset is accepted
        require!(
            agent.accepted_assets.contains(&ctx.accounts.deposit_mint.key()),
            ErrorCode::AssetNotAccepted
        );
        require!(agent.status == AgentStatus::Active, ErrorCode::AgentPaused);

        // Calculate shares to mint
        let deposit_value = get_asset_value(&ctx.accounts.pyth_feed, amount)?;
        let total_shares_to_mint = if vault.total_shares == 0 {
            deposit_value // 1:1 bootstrap
        } else {
            (deposit_value as u128 * vault.total_shares as u128
                / vault.total_nav as u128) as u64
        };

        // Split between creator and depositor
        let creator_shares = total_shares_to_mint * agent.owner_pct_bps as u64 / 10_000;
        let user_shares = total_shares_to_mint - creator_shares;

        // Transfer asset to vault
        token::transfer(/* user ATA → vault ATA */)?;

        // Mint shares
        token::mint_to(/* share_mint → creator ATA */, creator_shares)?;
        token::mint_to(/* share_mint → user ATA */, user_shares)?;

        // Update state
        vault.total_shares += total_shares_to_mint;
        vault.total_nav += deposit_value;

        emit!(DepositEvent { agent_id, user: ctx.accounts.user.key(), amount, shares: user_shares });
        Ok(())
    }

    /// Request burn (starts withdrawal delay if configured)
    pub fn request_burn(
        ctx: Context<RequestBurn>,
        agent_id: u64,
        share_amount: u64,
    ) -> Result<()> {
        let agent = &ctx.accounts.agent_state;
        let vault = &ctx.accounts.vault_state;

        // Lock shares in escrow (transfer to burn_request PDA)
        token::transfer(/* user ATA → burn_request ATA */)?;

        let burn_request = &mut ctx.accounts.burn_request;
        burn_request.user = ctx.accounts.user.key();
        burn_request.share_amount = share_amount;
        burn_request.nav_at_request = vault.total_nav;
        burn_request.requested_at = Clock::get()?.unix_timestamp;
        burn_request.executable_after =
            burn_request.requested_at + agent.withdrawal_delay_secs;

        emit!(BurnRequestEvent { agent_id, user: ctx.accounts.user.key(), shares: share_amount });
        Ok(())
    }

    /// Execute burn — pay proportional underlying assets
    pub fn execute_burn(
        ctx: Context<ExecuteBurn>,
        agent_id: u64,
    ) -> Result<()> {
        let burn = &ctx.accounts.burn_request;
        let vault = &mut ctx.accounts.vault_state;

        require!(
            Clock::get()?.unix_timestamp >= burn.executable_after,
            ErrorCode::WithdrawalDelayActive
        );
        require!(!burn.executed, ErrorCode::AlreadyExecuted);

        // Calculate user's share percentage
        let share_pct_bps = burn.share_amount as u128 * 10_000 / vault.total_shares as u128;

        // Transfer proportional assets from vault to user
        // (remaining_accounts contains pairs of [vault_ata, user_ata] for each asset)
        for asset_pair in ctx.remaining_accounts.chunks(2) {
            let vault_ata = &asset_pair[0];
            let user_ata = &asset_pair[1];
            let vault_balance = token::get_balance(vault_ata)?;
            let transfer_amount = vault_balance * share_pct_bps as u64 / 10_000;
            if transfer_amount > 0 {
                token::transfer(/* vault_ata → user_ata */, transfer_amount)?;
            }
        }

        // Burn the shares
        token::burn(/* burn_request ATA */, burn.share_amount)?;
        vault.total_shares -= burn.share_amount;

        // Recalculate NAV
        vault.total_nav = calculate_nav(/* ... */)?;

        emit!(BurnExecutedEvent { agent_id, user: burn.user, shares: burn.share_amount });
        Ok(())
    }

    /// Agent executes a trade through the vault
    pub fn execute_trade(
        ctx: Context<ExecuteTrade>,
        agent_id: u64,
        trade_value: u64,
    ) -> Result<()> {
        let agent = &ctx.accounts.agent_state;
        let platform = &ctx.accounts.platform_config;

        // Only the registered agent signer can call this
        require!(
            ctx.accounts.signer.key() == agent.agent_signer,
            ErrorCode::Unauthorized
        );
        require!(agent.status == AgentStatus::Active, ErrorCode::AgentPaused);

        // Deduct platform fee
        let fee = trade_value * platform.fee_rate_bps as u64 / 10_000;
        let net_value = trade_value - fee;
        token::transfer(/* vault → treasury */, fee)?;

        // CPI to whitelisted adapter/router
        let adapter = ctx.accounts.adapter_program.key();
        require!(
            platform.approved_routers.contains(&adapter),
            ErrorCode::RouterNotApproved
        );

        // Execute trade via CPI (details depend on adapter)
        // The adapter program handles the actual swap/order placement

        // Post-trade: check concentration limits
        let nav = calculate_nav(/* ... */)?;
        require!(
            check_concentration(&ctx.accounts.vault_state, nav, agent.max_concentration_bps),
            ErrorCode::ConcentrationExceeded
        );

        // Check drawdown circuit breaker
        if nav < agent_state.high_water_mark * (10_000 - agent.max_drawdown_bps) as u64 / 10_000 {
            agent_state.status = AgentStatus::Paused;
            emit!(AgentPausedEvent { agent_id, reason: "max_drawdown" });
        }

        // Update stats
        agent.trade_count += 1;
        agent.last_trade_at = Clock::get()?.unix_timestamp;
        vault.total_fees_collected += fee;
        if nav > vault.all_time_high_nav {
            vault.all_time_high_nav = nav;
        }

        emit!(TradeExecutedEvent { agent_id, value: net_value, fee, nav });
        Ok(())
    }

    /// Update NAV from oracle reads (called periodically by agent or keeper)
    pub fn update_nav(
        ctx: Context<UpdateNAV>,
        agent_id: u64,
    ) -> Result<()> {
        let vault = &mut ctx.accounts.vault_state;

        // Read Pyth feeds for all held tokens
        // remaining_accounts: pairs of [token_ata, pyth_feed_account]
        let mut nav: u64 = 0;
        for pair in ctx.remaining_accounts.chunks(2) {
            let token_ata = &pair[0];
            let pyth_feed = &pair[1];

            let balance = token::get_balance(token_ata)?;
            if balance == 0 { continue; }

            // Try to read Pyth price
            match read_pyth_price(pyth_feed) {
                Ok(price) => {
                    nav += balance * price.price as u64 / 10u64.pow(price.expo.unsigned_abs());
                }
                Err(_) => {
                    // No valid feed = $0 value (anti-gaming)
                    nav += 0;
                }
            }
        }

        vault.total_nav = nav;
        vault.nav_last_updated = Clock::get()?.unix_timestamp;

        emit!(NAVUpdateEvent { agent_id, nav, timestamp: vault.nav_last_updated });
        Ok(())
    }
}
```

## Program 3: obey_nav

Separated for modularity. Handles oracle integration and valuation logic.

```rust
#[program]
pub mod obey_nav {
    /// Read Pyth price with staleness and confidence checks
    pub fn get_validated_price(
        ctx: Context<GetPrice>,
        max_age_secs: u64,
        max_confidence_pct: u64, // max confidence interval as % of price
    ) -> Result<ValidatedPrice> {
        let price_update = &ctx.accounts.pyth_price_update;
        let clock = Clock::get()?;

        let price_data = price_update.get_price_no_older_than(
            &clock,
            max_age_secs,
            &ctx.accounts.feed_id.key(),
        )?;

        // Confidence check — reject if confidence interval is too wide
        // (indicates unreliable/manipulated price)
        let confidence_pct = price_data.conf as u128 * 100 / price_data.price.unsigned_abs() as u128;
        require!(
            confidence_pct <= max_confidence_pct as u128,
            ErrorCode::PriceConfidenceTooLow
        );

        Ok(ValidatedPrice {
            price: price_data.price,
            confidence: price_data.conf,
            exponent: price_data.exponent,
            publish_time: price_data.publish_time,
        })
    }
}

pub struct ValidatedPrice {
    pub price: i64,
    pub confidence: u64,
    pub exponent: i32,
    pub publish_time: i64,
}
```

## Program 4: obey_fees

```rust
#[program]
pub mod obey_fees {
    /// Claim accumulated platform fees to treasury
    pub fn claim_fees(ctx: Context<ClaimFees>) -> Result<()> {
        // Transfer from fee accumulator to treasury
        // Only callable by platform admin
    }

    /// Distribute fees to stakers/governance (future)
    pub fn distribute_fees(ctx: Context<DistributeFees>, distribution: Vec<FeeShare>) -> Result<()> {
        // Future: split fees among platform token holders
    }
}
```

## Account Sizing & Rent

| Account | Size (bytes) | Rent (SOL) | Count |
|---------|-------------|-----------|-------|
| PlatformConfig | ~1000 | ~0.007 | 1 |
| AgentState | ~800 | ~0.006 | Per agent |
| VaultState | ~500 | ~0.004 | Per agent |
| ShareMint | ~82 | ~0.002 | Per agent |
| UserShareATA | ~165 | ~0.002 | Per user per agent |
| BurnRequest | ~200 | ~0.002 | Per withdrawal |
| AgentUpdateProposal | ~150 | ~0.002 | Per pending update |

**Per agent total:** ~0.012 SOL
**Per user funding an agent:** ~0.002 SOL (ATA rent, reclaimable)
**100 agents, 1000 users average:** ~1.2 SOL + ~2 SOL = ~3.2 SOL total rent

## Security Considerations

### Access Control Matrix

| Action | Who Can Call | Constraint |
|--------|------------|-----------|
| create_agent | Anyone | — |
| update_metadata | Creator | creator == signer |
| lower_owner_pct | Creator | new < current |
| execute_trade | Agent signer | agent_signer == signer |
| deposit | Anyone | asset must be accepted |
| request_burn | Share holder | balance >= amount |
| execute_burn | Anyone (permissionless) | after delay expires |
| pause_agent | Creator OR circuit breaker | — |
| approve_token | Platform admin | admin == signer |
| emergency_pause | Platform admin | admin == signer |

### Attack Vectors & Mitigations

| Attack | Mitigation |
|--------|-----------|
| Agent rugs depositors | Funds in PDA vault, agent can only trade via whitelisted routers |
| Creator inflates ownership | owner_pct can only decrease, enforced in contract |
| NAV manipulation via junk tokens | Oracle-only valuation: no Pyth feed = $0 |
| Flash loan NAV inflation | Pyth prices are aggregated, not spot; confidence interval check |
| Concentration attack | max_concentration_bps enforced post-trade |
| Agent address swap rug | 48-hour timelock on signer updates, depositors can exit |
| Re-entrancy | Anchor checks-effects-interactions pattern + reentrancy guard |
| Integer overflow | Rust overflow checks in release mode via Anchor config |

## Testing Strategy

```
tests/
├── unit/
│   ├── test_create_agent.rs        — registration, constraints
│   ├── test_deposit.rs             — share calculation, creator shares
│   ├── test_burn.rs                — proportional withdrawal, delay
│   ├── test_trade.rs               — fee deduction, concentration check
│   ├── test_nav.rs                 — oracle reads, zero-value fallback
│   └── test_access_control.rs      — unauthorized callers rejected
├── integration/
│   ├── test_full_lifecycle.rs      — create → deposit → trade → burn
│   ├── test_multi_depositor.rs     — multiple users, proportional burns
│   ├── test_drawdown_pause.rs      — circuit breaker triggers
│   └── test_agent_update.rs        — timelock proposal → execution
└── attack/
    ├── test_concentration_attack.rs — verify concentration limits hold
    ├── test_unauthorized_trade.rs   — non-signer can't trade
    └── test_nav_manipulation.rs     — junk tokens valued at $0
```
