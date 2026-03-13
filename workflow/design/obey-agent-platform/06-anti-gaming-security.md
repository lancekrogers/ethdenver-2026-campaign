# 06 — Anti-Gaming & Security Design

## Threat Model

### Attacker Profiles

| Attacker | Goal | Capability |
|----------|------|-----------|
| **Malicious Creator** | Inflate NAV, burn shares, extract real assets | Controls agent signer, can execute trades |
| **Colluding Creator+Agent** | Wash trade to generate fees, manipulate positions | Full trade execution control |
| **External Attacker** | Exploit contract vulnerabilities | Smart contract interaction |
| **MEV Bot** | Sandwich deposits/withdrawals | Mempool monitoring, fast execution |
| **Whale Depositor** | Manipulate share pricing | Large capital |

## Defense Layer 1: Oracle-Only NAV

**Rule: If a token has no Pyth price feed, it is worth $0 in the NAV.**

This is the primary defense. It makes NAV manipulation self-defeating:

```
Attacker buys junk token with pool funds:
  → Pool USDC balance decreases (real value lost)
  → Junk token balance increases BUT valued at $0 (no Pyth feed)
  → NAV DROPS instead of inflating
  → Attacker's shares are now worth LESS
  → Attack is self-defeating
```

Pyth feeds only exist for tokens with:
- Real markets across multiple exchanges
- Decentralized oracle aggregation from multiple sources
- Deep liquidity making sustained manipulation prohibitively expensive

Nobody is manipulating the SOL/USD or ETH/USD Pyth feed economically.

### Pyth Confidence Interval Check

Even with a Pyth feed, reject prices with wide confidence intervals:

```rust
let price_data = price_update.get_price_no_older_than(&clock, MAX_AGE, &feed_id)?;

// Confidence as % of price — reject if too wide
let confidence_pct = price_data.conf * 100 / price_data.price.unsigned_abs();
require!(confidence_pct <= MAX_CONFIDENCE_PCT, ErrorCode::PriceUnreliable);
```

Wide confidence = oracle isn't sure about the price = don't trust it for NAV.

### Staleness Check

```rust
// Reject prices older than 60 seconds
let MAX_AGE: u64 = 60;
let price = price_update.get_price_no_older_than(&clock, MAX_AGE, &feed_id)?;
```

## Defense Layer 2: Approved Token List

Agents can only trade tokens on the platform-approved list:

```rust
pub fn execute_trade(ctx: Context<ExecuteTrade>, ...) -> Result<()> {
    let platform = &ctx.accounts.platform_config;

    // Output token must be platform-approved
    require!(
        platform.approved_tokens.contains(&ctx.accounts.output_mint.key()),
        ErrorCode::TokenNotApproved
    );

    // Router must be whitelisted
    require!(
        platform.approved_routers.contains(&ctx.accounts.router_program.key()),
        ErrorCode::RouterNotApproved
    );

    // ... execute trade
}
```

**Approved token criteria:**
- Has an active Pyth price feed
- Minimum $1M DEX liquidity across venues
- Listed on at least 2 major DEXes
- Token has been live for at least 30 days

Tokens are added/removed by platform admin. Future: governance via OBEY token.

## Defense Layer 3: Concentration Limits

No single non-base token can exceed the max concentration:

```rust
pub fn check_concentration(vault: &VaultState, nav: u64, max_pct_bps: u16) -> bool {
    for (mint, balance) in vault.token_balances.iter() {
        if *mint == vault.base_asset { continue; } // USDC exempt

        let token_value = get_pyth_value(mint, *balance);
        let concentration = token_value * 10_000 / nav;

        if concentration > max_pct_bps as u64 {
            return false;
        }
    }
    true
}
```

Default: 40% max. Creators can set tighter limits (never looser).

## Defense Layer 4: Proportional Withdrawal

Burns pay **actual underlying assets**, not a USD-equivalent swap:

```rust
pub fn execute_burn(ctx: Context<ExecuteBurn>, ...) -> Result<()> {
    let share_pct = burn_amount * 10_000 / vault.total_shares;

    // Transfer proportional slice of each asset
    for (mint, vault_ata, user_ata) in vault.token_accounts.iter() {
        let vault_balance = get_balance(vault_ata);
        let transfer_amount = vault_balance * share_pct / 10_000;
        if transfer_amount > 0 {
            token::transfer(vault_ata, user_ata, transfer_amount)?;
        }
    }

    token::burn(shares, burn_amount)?;
}
```

**Why this matters:** If the pool holds 60% USDC and 40% SOL, you get 60% USDC and 40% SOL of your share. You can't inflate "SOL value" to extract more USDC — you just get SOL back. Combined with oracle-only NAV, there's no conversion exploit.

## Defense Layer 5: Drawdown Circuit Breaker

```rust
// After every trade, check if NAV has dropped below threshold
let drawdown = (vault.all_time_high_nav - current_nav) * 10_000 / vault.all_time_high_nav;

if drawdown > agent.max_drawdown_bps as u64 {
    agent.status = AgentStatus::Paused;
    emit!(CircuitBreakerEvent {
        agent_id,
        trigger: "max_drawdown",
        drawdown_bps: drawdown,
        nav: current_nav,
    });
}
```

Only the creator can unpause after a circuit breaker. Depositors can still burn shares while paused.

## Defense Layer 6: Agent Update Timelock

Changing the agent signer (who can execute trades) requires a 48-hour timelock:

```
Creator calls proposeAgentUpdate(newSigner)
  → AgentStatus set to PendingUpdate
  → Event emitted with new signer address
  → Depositors see the pending change on the agent profile
  → 48-hour countdown begins
  → During this window, depositors can burn shares and exit
  → After 48 hours: creator calls executeAgentUpdate()
  → New signer takes over
```

This prevents a creator from swapping in a malicious agent signer without giving depositors time to exit.

## Defense Layer 7: Transfer Restrictions

The vault contract enforces at the instruction level:

```rust
// These are the ONLY ways funds can leave the vault:
// 1. execute_trade → CPI to whitelisted router (swap, not transfer)
// 2. execute_burn → proportional withdrawal to share holder
// 3. platform_fee → to platform treasury

// Explicitly blocked:
// - token::transfer to arbitrary addresses
// - token::approve to non-whitelisted programs
// - system_program::transfer (SOL) to arbitrary addresses
// - Any CPI to non-whitelisted programs
```

The agent signer has NO ability to call `transfer` directly. They can only call `execute_trade` which routes through whitelisted programs.

## Prediction Market-Specific Security

### Position Valuation for Burns

Prediction market positions across chains need special handling:

```go
// Off-chain positions (Polymarket on Polygon, Limitless on Base)
// are valued by the agent runtime and reported to the vault
// via the update_nav instruction.

// Risk: agent could report inflated off-chain position values.
// Mitigation: NAV updates are verified against platform APIs.

type NAVVerifier struct {
    adapters map[string]MarketAdapter
}

func (v *NAVVerifier) VerifyReportedNAV(
    ctx context.Context,
    agentID string,
    reported NAVReport,
) (bool, error) {
    // For each reported off-chain position, verify against source:
    for _, pos := range reported.OffChainPositions {
        adapter := v.adapters[pos.Platform]
        actual, err := adapter.GetPositionValue(ctx, pos)
        if err != nil { return false, err }

        // Allow small deviation (slippage, timing)
        deviation := reported.Value.Sub(actual).Abs().Div(actual)
        if deviation.GreaterThan(MAX_NAV_DEVIATION) {
            return false, fmt.Errorf("NAV deviation too high: %.2f%%", deviation)
        }
    }
    return true, nil
}
```

### Cross-Chain Bridge Risk

Funds bridged to other chains (Polygon for Polymarket, Base for Limitless) are outside Solana contract custody. Mitigations:

| Risk | Mitigation |
|------|-----------|
| Bridge hack | Limit max bridged amount per agent (e.g., 50% of NAV) |
| Stuck funds | Track bridge status, count in-transit as NAV |
| Agent misreports | Independent NAV verification against platform APIs |
| Bridge delay affects burns | In-transit funds counted at face value; burns wait for bridge settlement |

## Attack Scenario Matrix

| # | Attack | Vector | Defense | Outcome |
|---|--------|--------|---------|---------|
| 1 | Create junk token, pump, burn shares | Trade into unpriced token | Oracle-only NAV: $0 value | NAV drops, attack fails |
| 2 | Buy approved low-cap token to pump | Trade into approved token | Pyth aggregated price, concentration limits | Can't move Pyth feed economically |
| 3 | Swap all USDC for single token, burn | Concentration attack | 40% concentration limit, proportional withdrawal | Gets the token back, not USDC |
| 4 | Change agent key to malicious signer | Agent update | 48-hour timelock, depositors exit | Users leave before new signer activates |
| 5 | Report fake off-chain positions | NAV inflation | Independent API verification | Flagged, agent paused |
| 6 | Sandwich a large deposit | MEV | Share pricing uses pre-deposit NAV | No profit from frontrunning |
| 7 | Whale deposit, dilute, withdraw | Share dilution | Proportional math: deposit and withdrawal at same NAV ratio | No profit |
| 8 | Creator raises ownership % | Economic extraction | Can only decrease, never increase | Impossible by contract |
| 9 | Agent calls transfer() on vault funds | Direct theft | Only execute_trade via whitelisted routers | Reverts: unauthorized instruction |
| 10 | Wash trading for fee generation | Creator collusion | 1-2% fee comes from pool, hurting pool NAV → hurting creator shares | Self-defeating: creator shares lose value |

## Monitoring & Alerting

```go
type SecurityMonitor struct {
    alerts AlertService
}

// Continuous monitoring checks
func (m *SecurityMonitor) Monitor(ctx context.Context) {
    // 1. NAV deviation alert
    // If reported NAV deviates from independently calculated NAV
    m.checkNAVDeviation(ctx)

    // 2. Unusual trade patterns
    // High frequency, large size, single direction
    m.checkTradePatterns(ctx)

    // 3. Concentration spikes
    // Token concentration approaching limit
    m.checkConcentration(ctx)

    // 4. Drawdown approach
    // NAV approaching circuit breaker threshold
    m.checkDrawdown(ctx)

    // 5. Agent update proposals
    // Alert depositors when agent key change is proposed
    m.checkPendingUpdates(ctx)

    // 6. Bridge monitoring
    // Track all bridge transactions, alert on stuck funds
    m.checkBridgeStatus(ctx)
}
```
