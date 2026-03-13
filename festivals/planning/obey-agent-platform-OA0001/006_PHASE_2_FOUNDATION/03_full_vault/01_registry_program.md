---
fest_type: task
fest_id: 01_registry_program.md
fest_name: registry_program
fest_parent: 03_full_vault
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.608305-06:00
fest_tracking: true
---

# Task: obey_registry Anchor Program

## Objective

Implement the `obey_registry` Anchor program with PlatformConfig, AgentState, and AgentUpdateProposal accounts, plus all instructions for platform admin operations, agent creation, creator management, and timelock-protected agent updates.

## Requirements

- [ ] `PlatformConfig` PDA: admin, fee_rate_bps, treasury, total_agents, approved_tokens[], approved_routers[], paused, bump
- [ ] `AgentState` PDA: agent_id, creator, agent_signer, agent_type, owner_pct_bps, status, accepted_assets[], trading_tokens[], metadata_uri, risk params, stats, bump
- [ ] `AgentUpdateProposal` PDA: agent_id, new_agent_signer, proposed_at, execute_after (48h), executed, bump
- [ ] Admin instructions: initialize_platform, update_fee_rate, approve_token, remove_token, approve_router, emergency_pause
- [ ] Agent creation: create_agent (validates tokens against approved list, owner_pct <= 5000)
- [ ] Creator management: update_metadata, lower_owner_pct (can only decrease), tighten_risk_params (can only make stricter)
- [ ] Agent update timelock: propose_agent_update (48h delay), execute_agent_update, cancel_agent_update
- [ ] Agent status: pause_agent, unpause_agent
- [ ] All constraints from 02-smart-contracts.md enforced

## Implementation

### Step 1: Project scaffold

Initialize the Anchor project (if not already done):

```bash
cd projects/contracts  # or wherever Anchor programs live
anchor init obey_registry --no-git
```

Directory structure:
```
programs/obey_registry/
  src/
    lib.rs
    state/
      mod.rs
      platform.rs
      agent.rs
      update_proposal.rs
    instructions/
      mod.rs
      initialize_platform.rs
      create_agent.rs
      update_metadata.rs
      lower_owner_pct.rs
      tighten_risk_params.rs
      propose_agent_update.rs
      execute_agent_update.rs
      cancel_agent_update.rs
      pause_agent.rs
      admin.rs
    errors.rs
```

### Step 2: State accounts

In `programs/obey_registry/src/state/platform.rs`:

```rust
use anchor_lang::prelude::*;

#[account]
pub struct PlatformConfig {
    pub admin: Pubkey,
    pub fee_rate_bps: u16,           // 100-200 (1-2%)
    pub treasury: Pubkey,
    pub total_agents: u64,
    pub approved_tokens: Vec<Pubkey>, // max 50
    pub approved_routers: Vec<Pubkey>, // max 10
    pub paused: bool,
    pub bump: u8,
}

impl PlatformConfig {
    // 8 + 32 + 2 + 32 + 8 + (4 + 50*32) + (4 + 10*32) + 1 + 1 = 1,992
    pub const MAX_APPROVED_TOKENS: usize = 50;
    pub const MAX_APPROVED_ROUTERS: usize = 10;
    pub const SIZE: usize = 8 + 32 + 2 + 32 + 8
        + (4 + Self::MAX_APPROVED_TOKENS * 32)
        + (4 + Self::MAX_APPROVED_ROUTERS * 32)
        + 1 + 1;
    pub const SEED: &'static [u8] = b"platform_config";
}
```

In `programs/obey_registry/src/state/agent.rs`:

```rust
#[account]
pub struct AgentState {
    pub agent_id: u64,
    pub creator: Pubkey,
    pub agent_signer: Pubkey,
    pub agent_type: AgentType,
    pub owner_pct_bps: u16,
    pub status: AgentStatus,
    pub accepted_assets: Vec<Pubkey>,  // max 10
    pub trading_tokens: Vec<Pubkey>,   // max 20
    pub metadata_uri: String,          // max 200 chars
    pub max_drawdown_bps: u16,
    pub max_concentration_bps: u16,
    pub withdrawal_delay_secs: i64,
    pub total_deposited: u64,
    pub total_withdrawn: u64,
    pub created_at: i64,
    pub last_trade_at: i64,
    pub trade_count: u64,
    pub high_water_mark: u64,
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

impl AgentState {
    pub const MAX_ACCEPTED_ASSETS: usize = 10;
    pub const MAX_TRADING_TOKENS: usize = 20;
    pub const MAX_URI_LEN: usize = 200;
    pub const SIZE: usize = 8 + 8 + 32 + 32 + 1 + 2 + 1
        + (4 + Self::MAX_ACCEPTED_ASSETS * 32)
        + (4 + Self::MAX_TRADING_TOKENS * 32)
        + (4 + Self::MAX_URI_LEN)
        + 2 + 2 + 8
        + 8 + 8 + 8 + 8 + 8 + 8
        + 1;
    pub const SEED: &'static [u8] = b"agent";
}
```

### Step 3: Key instructions

`create_agent`:

```rust
pub fn create_agent(
    ctx: Context<CreateAgent>,
    agent_type: AgentType,
    owner_pct_bps: u16,
    accepted_assets: Vec<Pubkey>,
    trading_tokens: Vec<Pubkey>,
    metadata_uri: String,
    max_drawdown_bps: u16,
    max_concentration_bps: u16,
    withdrawal_delay_secs: i64,
) -> Result<()> {
    let platform = &ctx.accounts.platform_config;
    require!(!platform.paused, ErrorCode::PlatformPaused);
    require!(owner_pct_bps <= 5000, ErrorCode::OwnerPctTooHigh);
    require!(metadata_uri.len() <= AgentState::MAX_URI_LEN, ErrorCode::URITooLong);

    // Validate all assets are platform-approved
    for asset in &accepted_assets {
        require!(platform.approved_tokens.contains(asset), ErrorCode::TokenNotApproved);
    }
    for token in &trading_tokens {
        require!(platform.approved_tokens.contains(token), ErrorCode::TokenNotApproved);
    }

    let agent = &mut ctx.accounts.agent_state;
    agent.agent_id = platform.total_agents; // auto-increment
    agent.creator = ctx.accounts.creator.key();
    agent.agent_signer = ctx.accounts.agent_signer.key();
    agent.agent_type = agent_type;
    agent.owner_pct_bps = owner_pct_bps;
    agent.status = AgentStatus::Active;
    agent.accepted_assets = accepted_assets;
    agent.trading_tokens = trading_tokens;
    agent.metadata_uri = metadata_uri;
    agent.max_drawdown_bps = max_drawdown_bps;
    agent.max_concentration_bps = max_concentration_bps;
    agent.withdrawal_delay_secs = withdrawal_delay_secs;
    agent.created_at = Clock::get()?.unix_timestamp;
    agent.bump = ctx.bumps.agent_state;

    // Increment platform counter
    let platform = &mut ctx.accounts.platform_config;
    platform.total_agents += 1;

    Ok(())
}
```

`propose_agent_update` (48h timelock):

```rust
pub fn propose_agent_update(
    ctx: Context<ProposeAgentUpdate>,
    new_signer: Pubkey,
) -> Result<()> {
    let agent = &mut ctx.accounts.agent_state;
    require!(agent.status == AgentStatus::Active, ErrorCode::AgentNotActive);
    require!(ctx.accounts.creator.key() == agent.creator, ErrorCode::NotCreator);

    agent.status = AgentStatus::PendingUpdate;

    let proposal = &mut ctx.accounts.update_proposal;
    proposal.agent_id = agent.agent_id;
    proposal.new_agent_signer = new_signer;
    proposal.proposed_at = Clock::get()?.unix_timestamp;
    proposal.execute_after = proposal.proposed_at + 172_800; // 48 hours
    proposal.executed = false;
    proposal.bump = ctx.bumps.update_proposal;

    Ok(())
}
```

### Step 4: Error codes

```rust
#[error_code]
pub enum ErrorCode {
    #[msg("Platform is paused")] PlatformPaused,
    #[msg("Owner percentage too high (max 50%)")] OwnerPctTooHigh,
    #[msg("Token not approved by platform")] TokenNotApproved,
    #[msg("Router not approved by platform")] RouterNotApproved,
    #[msg("URI too long")] URITooLong,
    #[msg("Only creator can perform this action")] NotCreator,
    #[msg("Only admin can perform this action")] NotAdmin,
    #[msg("Owner percentage can only decrease")] MustDecrease,
    #[msg("Risk params can only be tightened")] CanOnlyTighten,
    #[msg("Agent is not active")] AgentNotActive,
    #[msg("Timelock period has not elapsed")] TimelockActive,
    #[msg("Cannot refer yourself")] SelfReferral,
    #[msg("Unauthorized caller")] Unauthorized,
}
```

### Step 5: Write tests

In `tests/test_registry.rs`:

1. `test_initialize_platform` — verify PlatformConfig created with correct admin and fee_rate
2. `test_create_agent` — verify AgentState created, total_agents incremented
3. `test_create_agent_owner_pct_too_high` — 51% rejected
4. `test_create_agent_unapproved_token` — rejected if token not in approved list
5. `test_lower_owner_pct` — 15% -> 10% succeeds, 15% -> 20% rejected
6. `test_tighten_risk_params` — 20% drawdown -> 15% succeeds, 20% -> 25% rejected
7. `test_propose_and_execute_update` — propose, wait 48h (warp clock), execute
8. `test_execute_update_before_timelock` — rejected if <48h elapsed
9. `test_emergency_pause` — admin pauses, verify new agent creation rejected
10. `test_non_admin_cannot_pause` — non-admin rejected

## Done When

- [ ] All requirements met
- [ ] PlatformConfig PDA initialized with admin, fee rate, treasury
- [ ] AgentState PDA created with all fields, validated against approved tokens
- [ ] Owner percentage can only decrease, risk params can only tighten
- [ ] Agent signer update requires 48-hour timelock
- [ ] Emergency pause prevents new agent creation and deposits
- [ ] `anchor test` passes with all registry tests green
- [ ] `anchor build` produces deployable .so
