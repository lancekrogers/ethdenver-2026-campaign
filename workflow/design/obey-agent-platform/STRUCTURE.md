# OBEY Agent Platform — Implementation Festival Structure

## Festival Goal

Build and launch the OBEY Agent Platform: AI agents trading prediction markets with on-chain custody, real deposits, and real revenue. Follows the step-based approach from design docs 00-11.

---

## Phase Breakdown

### 001_DRIFT_BET_AGENT (implementation)

**Goal:** Live prediction market agent trading on Drift BET (Solana mainnet) with platform seed capital.

This is the critical first step — everything else depends on having a working agent.

#### 01_drift_client

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_drift_api_research.md | Research Drift BET API endpoints, auth, market data format, order format | No |
| 02_drift_http_client.md | Go HTTP client implementing MarketAdapter interface for Drift BET: ListMarkets, PlaceOrder, Positions, Settle | No |
| 03_drift_client_tests.md | Unit tests with mock HTTP responses, integration test against devnet | No |

#### 02_analysis_pipeline

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_claude_client.md | Go client for Claude API: structured market analysis prompts, response parsing | Yes |
| 01_market_normalization.md | NormalizedMarket struct population from Drift BET market data | Yes |
| 02_resolution_analysis.md | LLM prompt chain: parse resolution rules, assess probability, identify mispricing | No |
| 03_signal_generation.md | Convert LLM analysis into Signal structs with edge, confidence, sizing | No |

#### 03_agent_loop

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_config.md | Agent config from env vars (PRED_ prefix), Solana wallet loading, interval settings | No |
| 02_execution_loop.md | Goroutine-based loop: trading (15min), P&L reporting (5min), health (30s) — follows agent-defi patterns | No |
| 03_risk_manager.md | Position sizing, max position limits, stop-loss at configurable drawdown %, concentration limits | No |
| 04_portfolio_tracker.md | Track open positions, calculate NAV from Drift position values, P&L reporting via HCS | No |
| 05_mock_mode.md | Full mock adapters for dry-run testing without real funds | No |

#### 04_mainnet_deployment

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_solana_wallet_setup.md | Generate agent Solana wallet, fund with SOL for gas, transfer USDC seed capital | No |
| 02_deploy_and_verify.md | Deploy agent binary, verify trading on mainnet with small positions, monitor for 24h | No |
| 03_hcs_integration.md | Connect to coordinator HCS topics, broadcast trade events and P&L reports | No |

---

### 002_MVP_VAULT (implementation)

**Goal:** On-chain deposit/withdraw system so users can fund the agent. Revenue begins here.

#### 01_anchor_vault

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_anchor_setup.md | Initialize Anchor project in obey-platform, configure for Solana devnet, set up test framework | No |
| 02_vault_state.md | VaultState account: authority, agent_wallet, share_mint, usdc_vault, total_nav, total_shares, withdrawal_delay | No |
| 03_initialize.md | Initialize instruction: create vault PDA, share token mint, USDC vault account | No |
| 04_deposit.md | Deposit instruction: transfer USDC to vault PDA, mint shares proportional to deposit/NAV | No |
| 05_withdrawal.md | Request + execute withdrawal: escrow shares, enforce delay, burn shares, transfer proportional USDC | No |
| 06_nav_update.md | Admin-only NAV update instruction (verified off-chain against Drift positions) | No |

#### 02_vault_tests

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_lifecycle_test.md | Full lifecycle: initialize → deposit → NAV update → withdraw. Multi-depositor proportional math | No |
| 02_attack_tests.md | Unauthorized NAV update, unauthorized withdrawal, zero-amount edge cases | No |
| 03_devnet_deploy.md | Deploy to devnet, run through full flow with test wallets | No |

#### 03_agent_vault_client

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_vault_client.md | Go client for vault program: read vault state, update NAV from agent portfolio tracker | No |
| 02_nav_reporting.md | Agent periodically updates on-chain NAV from Drift position values | No |

---

### 003_LANDING_PAGE (implementation)

**Goal:** Public page showing agent performance + deposit flow. Users can see and invest.

#### 01_agent_profile

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_data_api.md | REST API endpoints: agent stats (NAV, return, win rate, Sharpe), trade history, NAV chart data | No |
| 02_profile_page.md | Next.js page: NAV chart (Recharts), trade history table, strategy description, live status | No |
| 03_performance_metrics.md | Calculate and display: return %, win rate, Sharpe ratio, max drawdown, trade count | No |

#### 02_deposit_flow

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_wallet_connect.md | Solana wallet adapter: Phantom, Solflare, Backpack connection | No |
| 02_deposit_ui.md | Deposit form: amount input, share preview calculation, USDC approval, transaction confirmation | No |
| 03_withdrawal_ui.md | Withdrawal form: share balance display, burn amount, delay display, request + execute flow | No |

#### 03_landing_design

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_landing_page.md | Hero section, how it works, agent card, CTA — single page that converts visitors to depositors | No |
| 02_responsive.md | Mobile-friendly layout, wallet connect on mobile browsers | No |

---

### 004_BAGS_INTEGRATION (implementation)

**Goal:** OBEY token live on Bags/Meteora with automated fee claiming. Second revenue stream.

#### 01_bags_client

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_auth_client.md | Bags API auth: agent registration, Moltbook JWT acquisition, token refresh | No |
| 02_token_client.md | Token operations: create token, set metadata, configure fee sharing (40/30/20/10 split) | No |
| 03_trading_client.md | Quote and swap operations for OBEY token | No |
| 04_fee_client.md | Fee claiming: list claimable fees, execute claim, verify receipt | No |

#### 02_token_launch

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_create_token.md | Create OBEY token via Bags API with metadata (name, symbol, image, description) | No |
| 02_configure_fees.md | Set fee sharing: 40% treasury, 30% performance pool, 20% holders, 10% creator | No |
| 03_launch_meteora.md | Launch on Meteora DBC, verify on-chain, confirm trading is live | No |

#### 03_automated_claiming

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_claim_loop.md | Periodic fee claiming service (every 6 hours), distribute to treasury wallet | No |
| 02_metrics_reporting.md | Track token volume, fee revenue, holder count — report via HCS | No |

---

### 005_GROWTH_ENGINE (implementation)

**Goal:** Referral system and early depositor incentives to drive organic growth.

#### 01_referral_system

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_referral_state.md | On-chain ReferralState PDA: referrer, referrer_l2, referred_count, total_earned | No |
| 02_referral_registration.md | Vault instruction: register referral code on first deposit, link L1/L2 referrers | No |
| 03_fee_distribution.md | On fee collection: distribute 10% L1 + 3% L2 to referrer wallets | No |
| 04_referral_ui.md | Dashboard: referral code display, copy link, referred users table, earnings tracker | No |

#### 02_incentives

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_bonus_shares.md | First-14-day depositors get 15% bonus shares (configurable deadline in vault state) | No |
| 02_fee_waiver.md | First-30-day fee waiver flag in vault state, skip fee deduction during waiver period | No |
| 03_shareable_cards.md | Generate performance card images: portfolio return, best agent, P&L, referral link — shareable to Twitter | No |

---

### 006_PHASE_2_FOUNDATION (implementation)

**Goal:** Multi-platform support and full vault contracts for scale.

#### 01_polymarket_adapter

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_clob_client.md | Polymarket CLOB API client: REST + WebSocket, EIP-712 auth, HMAC-SHA256 API key auth | No |
| 02_gamma_client.md | Gamma API client for market metadata, resolution rules, category data | No |
| 03_order_placement.md | Order placement (GTC, FOK), CTF token position tracking, redemption flow | No |
| 04_polymarket_tests.md | Integration tests against Polymarket testnet/paper trading | No |

#### 02_cross_platform

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_event_matcher.md | LLM-assisted cross-platform event matching: same event on Drift + Polymarket, confidence scoring | No |
| 02_arbitrage_strategy.md | ArbitrageScanner strategy: detect price discrepancies, calculate edge net of fees/bridge costs, execute | No |
| 03_bridge_manager.md | Solana ↔ Polygon bridge via Wormhole: working capital management, status tracking | No |

#### 03_full_vault

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_registry_program.md | obey-registry: PlatformConfig, create_agent, creator management, update timelock, risk params | No |
| 02_nav_program.md | obey-nav: Pyth feed reading with validation, tiered valuation, concentration limits | No |
| 03_fees_program.md | obey-fees: fee accumulation, treasury claims, creator tier revenue sharing | No |
| 04_full_vault_program.md | obey-vault: multi-asset deposit, trade routing via CPI, anti-gaming NAV, circuit breakers | No |
| 05_migration.md | Migrate MVP vault depositors to full vault program (share token transfer, NAV continuity) | No |

---

## Dependencies

```
001_DRIFT_BET_AGENT → 002_MVP_VAULT → 003_LANDING_PAGE → 005_GROWTH_ENGINE
                    ↘                                   ↗
                      004_BAGS_INTEGRATION (parallel with 002+003)

005_GROWTH_ENGINE → 006_PHASE_2_FOUNDATION
```

Phase 001 is the hard gate — nothing proceeds without a working agent.
Phase 004 (Bags) can run in parallel with 002 and 003.
Phase 006 begins after MVP is generating revenue (phases 001-005 complete).
