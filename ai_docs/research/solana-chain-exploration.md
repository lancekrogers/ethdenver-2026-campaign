# Solana Chain Exploration: AI Agent Trading/Fundraising Platform

> Research date: 2026-03-13
> Purpose: Evaluate Solana as a deployment chain for the Obey Agent Economy platform

---

## Table of Contents

1. [Solana DeFi Landscape](#1-solana-defi-landscape)
2. [Smart Contract Development](#2-smart-contract-development)
3. [Agent Infrastructure on Solana](#3-agent-infrastructure-on-solana)
4. [Oracle Infrastructure](#4-oracle-infrastructure)
5. [Solana vs Base/EVM Tradeoffs](#5-solana-vs-baseevm-tradeoffs)
6. [Bags.fm Integration](#6-bagsfm-integration)
7. [Key Programs and SDKs](#7-key-programs-and-sdks)
8. [Conclusions and Recommendations](#8-conclusions-and-recommendations)

---

## 1. Solana DeFi Landscape

### Overall Metrics (Q3 2025 - Q1 2026)

| Metric | Value |
|--------|-------|
| Total DeFi TVL | ~$11.5B (Q3 2025) |
| Daily DEX Volume | $3B+ average |
| Monthly DEX Volume | $100B+ (March 2025) |
| DEX Market Share (high-perf chains) | ~63% |
| Transaction Cost | ~$0.00025 per tx |
| Block Time | 400ms |

### Major DEXes

#### Jupiter (Aggregator + DEX)

- **Role**: Primary swap aggregator, routes ~90% of aggregator volume on Solana
- **TVL**: $2.6B (Q3 2025, 22.1% market share on Solana)
- **Daily Volume**: $700M+
- **Architecture**: Aggregates pricing from all Solana DEXes and AMMs using "smart routing" that splits trades across multiple venues for optimal execution
- **API Variants**:
  - **Ultra Swap API**: Streamlined RPC-less, gasless swaps with automatic slippage optimization, sub-second landing, and sub-2s API latency. Returns pre-built transaction payloads ready for signing.
  - **Swap API**: Allows custom instructions and Cross-Program Invocation (CPI) calls. Required for on-chain program integration.
- **Key Features**: Juno liquidity engine (multi-source aggregation with self-learning), Real-Time Slippage Estimator (RTSE), Jupiter Beam for sub-second landing
- **Jupiter Lend**: Launched August 2025, hit $500M TVL in 24 hours, reached $1.65B TVL by October 2025. Isolated vaults with rehypothecation.
- **Integration Pattern**: Quote-then-swap -- request quote with input/output tokens and amount, receive optimal route, construct and sign transaction, submit.

#### Raydium

- **TVL**: $2.3B (Q3 2025, 20% market share)
- **Types**: Standard AMM (CPMM) and Concentrated Liquidity (CLMM)
- **CLMM**: Open-source concentrated liquidity market maker allowing LPs to select specific price ranges. Revenue $2.8M in Q3 2025 (+16% QoQ).
- **CPI Integration**: Available for on-chain program invocation. Requires careful account ordering, correct signer requirements, and appropriate remaining accounts for tick arrays during swaps.
- **Program**: `raydium-clmm` on GitHub, open-source

#### Orca (Whirlpools)

- **30-day Volume**: $22.8B (May 2025)
- **Architecture**: Concentrated liquidity AMM using discrete price bins (Whirlpools program)
- **SDKs**: TypeScript (`@orca-so/whirlpools`) and Rust (`orca_whirlpools`)
- **High-Level SDK** abstracts tick array management and other complexities
- **Program**: Open-source, runs on both Solana and Eclipse networks
- **SOL/USDC Pool TVL**: $31.3M

#### Meteora

- **TVL**: $750M-$1B+
- **Monthly Volume**: $39.9B peak (January 2025), $14B (May 2025)
- **Daily Volume**: $300M+
- **Products**:
  - **DLMM (Dynamic Liquidity Market Maker)**: Inspired by Trader Joe's Liquidity Book. Uses discrete price bins for zero-slippage within bins. Dynamically adjusts fees based on market volatility.
  - **Dynamic Bonding Curve (DBC)**: Permissionless launch pool protocol. Universal Curve with up to 16-point customizable curve system using constant product between points. Used by launchpads like Bags.fm.
  - **DAMM v1/v2**: Dynamic AMM pools that DBC liquidity migrates to after reaching threshold.
- **DBC Fee Structure**: 20% of trading fee to DBC protocol, 80% to launch partner.
- **DBC Migration**: When virtual pool reaches minimum quote threshold, auto-migrator creates new DAMM pool and distributes liquidity to partner and creator.
- **DBC SDK**: Available in TypeScript and Rust. Open-source program on GitHub (`MeteoraAg/dynamic-bonding-curve`).

### How Swaps Work on Solana (Technical)

1. **Account Model**: Every account touched in a swap is explicit in the transaction. Wallets can simulate side effects and show accurate previews before signing.
2. **Token Accounts**: Swaps move tokens between Associated Token Accounts (ATAs). Each ATA is deterministically derived from wallet address + token program ID + mint address.
3. **CPI Pattern**: Programs invoke the SPL Token program via Cross-Program Invocation for transfers, mints, and burns.
4. **Aggregation**: Jupiter splits trades across multiple DEXes atomically within a single transaction using Solana's composability.

---

## 2. Smart Contract Development

### Anchor Framework

Anchor is the de facto framework for Solana program development. It provides:

- **Macro-based structure**: `#[program]`, `#[derive(Accounts)]`, `#[account]` macros reduce boilerplate
- **IDL Generation**: Automatically generates Interface Description Language files for client integration
- **Account Validation**: Declarative account constraints (`has_one`, `constraint`, `seeds`)
- **CPI Helpers**: Simplified cross-program invocation patterns
- **Error Handling**: Custom error codes with descriptive messages

**Alternatives emerging in 2025**: Pinocchio (lightweight), Kinobi (code generation), Surfpool (testing), Umi (client-side abstraction)

### Program Derived Addresses (PDAs)

PDAs are the foundation of Solana's trustless program architecture:

- **Deterministic**: Generated from seeds + program ID using `find_program_address()`
- **No Private Key**: Cannot be signed by a keypair -- only the owning program can authorize
- **Bump Seed**: Stored on-chain to prevent alternative derivations
- **Use Cases**: Vaults, escrows, configuration accounts, authority delegation

```
PDA = hash(seeds, program_id, bump)
// Only the program at program_id can sign for this address
```

### Vault/Escrow Architecture on Solana

#### How Vaults Work (ERC-4626 Equivalent)

Solana's vault pattern differs fundamentally from EVM:

**Account Structure Required**:
| Account | Purpose |
|---------|---------|
| Underlying Mint | The asset being deposited (e.g., USDC) |
| Share Mint | PDA-controlled mint tracking ownership shares |
| Vault ATA | Token account holding deposited assets |
| Vault State PDA | Configuration: share_mint, pda_bump, total assets |

**Deposit Flow**:
1. User signs transaction providing their token account, vault account, share mint, state PDA
2. Program executes `token::transfer` moving assets into vault
3. Program computes proportional shares: `shares = (assets * totalShareSupply) / totalAssets()`
4. Program invokes `token::mint_to` using PDA signer to mint share tokens
5. Vault state updates; event emitted for indexing

**Withdrawal Flow**:
1. Program verifies ownership or allowance
2. Computes asset amount: `assets = (shares * totalAssets()) / totalShareSupply`
3. Burns shares via `token::burn`
4. Transfers underlying assets back using `token::transfer` with PDA signing
5. Emits withdrawal event

**First depositor** gets 1:1 exchange rate. Subsequent depositors use the weighted formula.

#### Escrow Pattern

Reference implementation uses three instructions:
- `make`: Create escrow, transfer Token A to PDA vault
- `take`: Taker pays Token B, vault releases Token A
- `refund`: Reclaim Token A after timeout

The vault token account has both a PDA key and PDA authority, eliminating private key exposure.

### SPL Token Program

The standard token program on Solana:

- **Mints**: Define token supply, decimals, mint authority, freeze authority
- **Token Accounts**: Hold balances for a specific mint. Each wallet needs one per token.
- **Associated Token Accounts (ATAs)**: Deterministically derived from `wallet_address + token_program_id + mint_address`. Canonical location for token balances.
- **Rent**: ATAs require ~0.00203928 SOL deposit (rent-exempt). Reclaimable on account closure.
- **Authority Model**: Wallet owner must sign to transfer from their ATA. Programs can transfer via PDA authority.

### Token-2022 (Token Extensions)

Enhanced token program with built-in extensions:

| Extension | Purpose | Relevance |
|-----------|---------|-----------|
| **Transfer Hooks** | Custom logic on every transfer (KYC, royalties, taxes) | Could enforce vault rules, fee collection |
| **Confidential Transfers** | Privacy-preserving transfers (encrypted amounts) | Privacy for agent trades |
| **Transfer Fees** | Built-in fee on transfers | Automated fee collection for platform |
| **Permanent Delegate** | Irrevocable delegation authority | Platform could manage agent tokens |
| **Non-Transferable** | Soulbound tokens | Agent identity/reputation tokens |
| **Interest-Bearing** | Display tokens with interest accrual | NAV-tracking share tokens |
| **Metadata** | On-chain token metadata | Rich token descriptions |

**Limitation**: Transfer hooks and confidential transfers cannot be combined (hooks need to read amounts, confidential transfers encrypt them).

**Key Consideration for Our Platform**: The `Interest-Bearing` extension could display share token values that reflect NAV changes. The `Transfer Fees` extension could automate platform fee collection on share token transfers. `Transfer Hooks` could enforce compliance rules on vault share tokens.

---

## 3. Agent Infrastructure on Solana

### Solana Agent Kit v2 (SendAI)

The primary framework for building AI agents on Solana.

**Architecture**:
- Modular plugin system with 5 specialized packages:
  1. **Token Plugin**: Asset transfers, swaps, bridge operations, rug checks
  2. **NFT Plugin**: Metaplex minting, listing, metadata
  3. **DeFi Plugin**: Staking, lending, borrowing, spot + perp trading
  4. **Misc Plugin**: Airdrops, price feeds, domain registration
  5. **Blinks Plugin**: Protocol interactions
- 60+ pre-built actions
- Adapters for MCP and N8N integration

**Wallet Security (v2)**:
- Private keys never directly input (major v1 improvement)
- Embedded wallet support: **Turnkey** (fine-grained rules for autonomous agents) and **Privy** (human-in-the-loop confirmation)
- Plugin isolation: agents only see relevant tools, reducing hallucinations

**Adoption**: 100,000+ downloads, 1,400+ GitHub stars, 800+ forks

**Compatibility**: Works with ElizaOS, LangChain, Perplexity, Vercel AI SDK

### Other Agent Frameworks

| Framework | Language | Strength | Use Case |
|-----------|----------|----------|----------|
| **ElizaOS** | TypeScript | Persistent personality, multi-platform (Twitter, Discord, Telegram) | Social agents |
| **GOAT Toolkit (Crossmint)** | TypeScript | 200+ protocol plugins, 30+ chains | Multi-chain agents |
| **Rig Framework** | Rust | Sub-millisecond latency, native performance | HFT, performance-critical |
| **LangChain** | Python/TS | Mature orchestration, memory, retrieval | Complex reasoning agents |

### Agent Wallet Architecture (Production)

Recommended dual-key architecture for production agents:

```
Smart Contract Wallet
├── Owner Key (user-held, ultimate control, override)
└── Agent Key (TEE-deployed, limited permissions)
    ├── Transaction limits
    ├── Daily spending caps
    ├── Authorized transaction types only
    └── Dedicated wallet with minimal funds
```

Solutions: Crossmint custodial wallets, Turnkey policy-controlled access

### Why Solana for Agents

- **400ms block times**: Tight feedback loops for reactive agents
- **$0.00025 transactions**: Agents can operate indefinitely on minimal capital
- **Atomic composability**: Bundle multiple DeFi operations in a single transaction
- **Parallel execution**: Sealevel runtime processes non-conflicting transactions simultaneously
- **Ecosystem momentum**: Jupiter processes 90% of aggregator volume, mature SDK ecosystem

---

## 4. Oracle Infrastructure

### Pyth Network (Solana-Native)

The dominant oracle on Solana, purpose-built for the ecosystem.

**Architecture**: Pull-based model
- Price updates created on Pythnet (dedicated appchain)
- Streamed off-chain via Wormhole Network
- Only written on-chain when a consumer requests it (gas-efficient)
- 400ms update frequency on Solana/Pythnet

**Feed Coverage**: 500+ price feeds available for Solana protocols

**Data Sources**: Aggregates directly from primary sources (exchanges, trading firms, market makers). Each data point traceable to individual publisher public keys.

**Integration (Anchor)**:
```rust
use pyth_solana_receiver_sdk::price_update::PriceUpdateV2;

// In your instruction context:
pub price_update: Account<'info, PriceUpdateV2>,

// Read price:
let price = price_update.get_price_no_older_than(
    &Clock::get()?,
    maximum_age,   // staleness threshold in seconds
    &feed_id       // specific price feed identifier
)?;
// Returns: price, confidence interval, exponent
```

**Account Types**:
- **Price Feed Accounts**: Fixed address, continuously updated by Pyth Data Association. Best for always-latest price.
- **Price Update Accounts**: Ephemeral, anyone can create/overwrite/close. Best for timestamp-specific prices.

**TypeScript SDK**: `@pythnetwork/price-service-client` (fetch prices) + `@pythnetwork/pyth-solana-receiver` (submit to chain)

### Switchboard

**Architecture**: Permissionless, multi-source oracle

**Key Differentiator**: Anyone can create a data feed without partnerships or DAO approval (unlike Pyth's permissioned model)

**Switchboard Surge** (2025):
- Sub-100ms latency (8x faster than competitors)
- 8-25ms with co-located Surge nodes
- ~1/100th the cost of existing providers

**Flexibility**: Can aggregate from Pyth, Chainlink, Web2 APIs, and custom sources in a single feed

**2025 Developments**: Integration with Movement and alt-VMs, feed composability improvements, validator restaking

### Chainlink on Solana

**Architecture**: Offchain Reporting (OCR) -- no dependencies on external blockchains, operates at Solana-native speed and cost

**SDK**: Chainlink Solana Crate v2 -- improved performance with lower compute unit usage via direct account reads instead of CPI

**Available Clusters**: Devnet and Mainnet (NOT available on Testnet)

**Feed Availability**: SOL/USD, LINK/USD, and others. More limited selection compared to EVM chains. Check [data.chain.link](https://data.chain.link/) for current list.

### Oracle Comparison for Our Platform

| Factor | Pyth | Switchboard | Chainlink |
|--------|------|-------------|-----------|
| Latency | 400ms | 8-100ms | ~1-2s |
| Feed Count (Solana) | 500+ | Permissionless | Limited |
| Model | Pull | Pull | Push (OCR) |
| Cost | Consumer-paid | Very low | Network-subsidized |
| Custom Feeds | Permissioned | Permissionless | Permissioned |
| Best For | DeFi standard | Custom/exotic feeds | EVM parity |

**Recommendation**: Pyth as primary (widest Solana adoption, most feeds), Switchboard as fallback or for custom/exotic feeds.

---

## 5. Solana vs Base/EVM Tradeoffs

### Architecture Comparison

| Aspect | Solana (SVM) | Base/EVM |
|--------|-------------|----------|
| **Execution** | Parallel (Sealevel) | Sequential |
| **State Model** | Stateless programs + external accounts | Stateful contracts with internal storage |
| **Storage Cost** | One-time rent deposit (~0.002 SOL per account) | Gas per SSTORE operation |
| **Transaction Cost** | ~$0.00025 | ~$0.01-0.10 (Base) |
| **Block Time** | 400ms | 2s (Base) |
| **Finality** | Sub-second | ~2 minutes (L2 finality) |
| **Smart Contract Language** | Rust (Anchor) | Solidity |
| **Account Creation** | Explicit, costs rent | Implicit via storage slots |
| **Composability** | Atomic CPI within single tx | Atomic within single tx |

### Vault-Based Agent Platform: What's Easier/Harder

#### Easier on Solana

1. **Transaction costs for agents**: At $0.00025/tx, agents can execute hundreds of trades daily for pennies. On Base, even at $0.01-0.10, high-frequency agent operations add up.

2. **Feedback loop speed**: 400ms blocks enable near-real-time agent decision cycles. Base's 2s blocks slow reactive strategies.

3. **DEX liquidity access**: Jupiter aggregation across all Solana DEXes in a single atomic transaction. No equivalent aggregator depth on Base.

4. **Oracle freshness**: Pyth's 400ms updates are native to Solana. On Base, you rely on Chainlink push feeds with slower update cadence.

5. **Agent SDK maturity**: Solana Agent Kit v2 provides 60+ pre-built DeFi actions. No equivalent on Base.

6. **Bags.fm integration**: Native Solana platform with established API/SDK and Meteora DBC integration.

#### Easier on Base/EVM

1. **Vault standards**: ERC-4626 is a battle-tested, audited vault standard with extensive tooling. Solana has no equivalent standard -- you build from scratch with Anchor.

2. **Share tokens**: On EVM, vault share tokens are standard ERC-20s compatible with all wallets, DEXes, and DeFi. On Solana, share tokens require custom mint management via PDAs.

3. **NAV calculation**: ERC-4626 `convertToShares`/`convertToAssets` are standardized. On Solana, you implement the math yourself in your program.

4. **Developer tooling**: Solidity has Foundry, Hardhat, OpenZeppelin. Solana's Anchor is powerful but the ecosystem is smaller. Debugging is harder.

5. **Audit ecosystem**: More Solidity auditors exist. Solana/Rust audit firms are fewer and more expensive.

6. **Existing Go infrastructure**: Our platform uses `go-ethereum`. The `solana-go` SDK by gagliardetto is less mature than go-ethereum.

7. **Chainlink CRE integration**: Our existing CRE risk pipeline targets Ethereum Sepolia. Chainlink's Solana presence is smaller.

8. **Account management complexity**: Every new user vault position requires creating multiple accounts (ATAs, state PDAs) with rent deposits. On EVM, a mapping entry suffices.

#### Key Consideration: Account Rent

On Solana, creating a vault for each agent requires:
- Vault state PDA (~0.002 SOL)
- Vault token ATA (~0.002 SOL)
- Share mint (~0.0015 SOL)
- Per-user: share token ATA (~0.002 SOL each)

For 100 investors in an agent vault: ~0.206 SOL in rent deposits. All reclaimable on closure, but adds UX friction and upfront capital.

On EVM: A single contract handles everything via mappings. No per-user account creation cost beyond gas.

---

## 6. Bags.fm Integration

### Platform Overview

Bags.fm is a Solana-native token launchpad where creators and AI agents earn 1% of all trading volume on their tokens -- permanently. Tokens are launched on Meteora's Dynamic Bonding Curve (DBC) infrastructure.

### How Bags Tokens Work

1. **Launch**: Creator/agent creates token via Bags API. Token starts on Meteora DBC virtual bonding curve.
2. **Trading Phase**: Tokens trade on the bonding curve. 1% trading fee goes to creator, split further via fee share config.
3. **Migration**: When bonding curve reaches minimum quote threshold, liquidity auto-migrates to Meteora DAMM v2 pool.
4. **Post-Migration**: Token continues trading on full AMM with ongoing 1% creator fee.
5. **Dividends**: Top 100 holders receive proportional payouts every 24 hours (minimum 10 SOL threshold).

### API Integration

**Base URL**: `https://public-api-v2.bags.fm/api/v1/`
**Auth**: API key via `x-api-key` header (create at dev.bags.fm)
**Rate Limit**: 1,000 requests/hour/user
**SDK**: `npm install @bagsfm/bags-sdk @solana/web3.js`

#### Key API Endpoints

| Endpoint | Purpose |
|----------|---------|
| **Agent Auth** | Generate verification challenge, complete login, get 365-day JWT |
| **Create Token Info** | Upload image, set name/ticker, generate mint |
| **Create Fee Share Config** | Set up to 100 fee claimers with basis point allocations |
| **Create Token Launch Tx** | Get signed token launch transaction |
| **Get Trade Quote** | Swap quote with output amount, price impact, slippage |
| **Create Swap Tx** | Ready-to-sign swap transaction from quote |
| **Send Transaction** | Submit signed tx to network |
| **Get Claimable Positions** | Retrieve claimable fees (virtual pool + DAMM v2) |
| **Get Claim Transactions v3** | Auto-generate fee claim transactions |
| **Get Token Lifetime Fees** | Total lifetime fees for token |
| **Get Bags Pools** | All pools with Meteora DBC and DAMM v2 keys |
| **List Agent Wallets** | All Solana wallets for authenticated agent |
| **Export Agent Wallet** | Export private key for agent wallet |

### Integration with Our Platform

**Potential Architecture**:
```
Agent launches token on Bags.fm via API
    → Token trades on Meteora DBC bonding curve
    → Agent earns 1% trading fees
    → Fee sharing configured to split between:
        - Agent operator (platform)
        - Vault investors (proportional to shares)
    → Agent claims fees periodically
    → Claimed fees deposited into vault
    → NAV updates reflect fee income
    → Share token value increases
```

**Key Integration Points**:
1. Agent authentication via Bags API (JWT-based, 365-day tokens)
2. Token launch with custom fee share configuration
3. Automated trade execution using quote + swap endpoints
4. Periodic fee claiming using v3 claim transactions
5. Pool monitoring via Bags Pools endpoint for NAV data
6. Wallet management via agent wallet endpoints

### Fee Economics

- **Creator Fee**: 1% of all trading volume, forever
- **DBC Trading Fee Split**: 80% to launch partner, 20% to Meteora protocol
- **Fee Share**: Configurable up to 100 claimers with basis point allocations
- **Dividends**: Top 100 holders, 24-hour cycles, minimum 10 SOL threshold

---

## 7. Key Programs and SDKs

### Go SDK: solana-go (gagliardetto)

**Repository**: [github.com/gagliardetto/solana-go](https://github.com/gagliardetto/solana-go)
**Version**: v1.12.0 (alpha)
**Requires**: Go 1.19+

**Features**:
- JSON RPC client
- WebSocket client
- Transaction building and signing
- Instruction encoding/decoding
- `sendAndConfirmTransaction` helper

**Transaction Building Example**:
```go
tx, err := solana.NewTransaction(
    []solana.Instruction{
        system.NewTransferInstruction(
            amount,
            accountFrom.PublicKey(),
            accountTo,
        ).Build(),
    },
    recent.Value.Blockhash,
    solana.TransactionPayer(accountFrom.PublicKey()),
)
```

**Status**: Active development but labeled alpha. Less mature than go-ethereum. No built-in DeFi protocol wrappers (Jupiter, Raydium, etc.).

**Gap Analysis for Our Platform**: We would need to build or find Go wrappers for:
- Jupiter swap API interaction (HTTP-based, manageable)
- SPL Token program instructions
- Anchor program interaction (IDL parsing)
- PDA derivation
- Pyth oracle reading

### Rust SDK

- **solana-sdk**: Official Solana SDK for program development
- **anchor-lang**: Anchor framework crate
- **spl-token**: SPL Token program client
- **pyth-solana-receiver-sdk**: Pyth oracle integration
- **orca_whirlpools**: Orca swap integration

### TypeScript SDKs

| Package | Purpose |
|---------|---------|
| `@solana/web3.js` | Core Solana interaction |
| `@coral-xyz/anchor` | Anchor program client |
| `@jup-ag/api` | Jupiter swap integration |
| `@orca-so/whirlpools` | Orca swap integration |
| `@pythnetwork/pyth-solana-receiver` | Pyth oracle |
| `@bagsfm/bags-sdk` | Bags.fm token launch/trade |
| `@sendaifun/solana-agent-kit` | AI agent toolkit |

### Relevant Solana Programs

| Program | Address | Purpose |
|---------|---------|---------|
| SPL Token | `TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA` | Standard token operations |
| Token-2022 | `TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb` | Extended token operations |
| Associated Token | `ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL` | ATA derivation/creation |
| Jupiter v6 | Program-specific | Swap aggregation |
| Raydium CLMM | Program-specific | Concentrated liquidity |
| Orca Whirlpool | `whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc` | Concentrated liquidity |
| Meteora DBC | Program-specific | Dynamic bonding curves |
| Pyth Oracle | `pythWSnswVUd12oZpeFP8e9CVaEqJg25g1Vtc2biRsT` | Price feeds (pull) |
| Switchboard | Program-specific | Oracle feeds |

---

## 8. Conclusions and Recommendations

### Solana's Strengths for Our Platform

1. **Cost advantage is massive**: At $0.00025/tx, agents can execute thousands of daily operations for under $1. This is 40-400x cheaper than Base.
2. **Speed enables reactive agents**: 400ms blocks with sub-second finality allow agents to respond to market conditions in near real-time.
3. **Bags.fm is a natural fit**: Direct API integration for token launches, fee sharing, and trading. Agent-first platform design.
4. **DeFi depth**: Jupiter, Raydium, Orca, Meteora provide deep liquidity with mature APIs.
5. **Agent SDK ecosystem**: Solana Agent Kit v2 with embedded wallet support and plugin architecture.
6. **Oracle quality**: Pyth's 400ms pull oracle is purpose-built for Solana DeFi.

### Solana's Challenges for Our Platform

1. **No ERC-4626 equivalent**: Vault/share token logic must be built from scratch in Anchor/Rust. Significant development effort.
2. **Go SDK immaturity**: `solana-go` is alpha-quality. DeFi protocol wrappers don't exist for Go. Our Go-based agent runtime would need substantial new infrastructure.
3. **Account model complexity**: Rent deposits, ATA creation, PDA management add friction compared to EVM's mapping-based approach.
4. **Audit ecosystem**: Fewer Solana auditors, higher costs.
5. **Chainlink CRE gap**: Our existing CRE risk pipeline targets EVM. Chainlink's Solana presence is more limited.
6. **Developer ramp**: Team would need to learn Rust/Anchor program development alongside Solana's account model.

### Strategic Options

**Option A: Solana-Native**
Build the entire vault/agent platform on Solana using Anchor programs. Maximum integration with Bags.fm and Solana DeFi.
- Effort: High (new program development in Rust, new Go infrastructure)
- Reward: Best performance, lowest costs, deepest Bags integration

**Option B: Hybrid**
Keep agent runtime in Go (existing codebase). Interact with Solana via HTTP APIs (Jupiter, Bags.fm) and RPC (solana-go). Deploy vault programs on Solana in Rust/Anchor.
- Effort: Medium (HTTP integration manageable, vault program is the big lift)
- Reward: Leverages existing Go infrastructure while accessing Solana DeFi

**Option C: EVM-First with Solana Bridge**
Deploy vaults and core logic on Base (ERC-4626). Add Solana integration for Bags.fm token launches and Meteora trading via cross-chain messaging.
- Effort: Lower for vault logic (ERC-4626 standards), higher for cross-chain
- Reward: Leverages existing EVM expertise, still accesses Bags ecosystem

**Option D: Bags API-Only**
Use Bags.fm and Jupiter purely via their HTTP APIs from our existing Go runtime. No on-chain program deployment on Solana. Vaults remain on EVM.
- Effort: Lowest
- Reward: Quick Bags integration, but limited on-chain composability

---

## Sources

### DeFi Landscape
- [Top DeFi Apps on Solana 2026 - Eco Support](https://eco.com/support/en/articles/13225733-top-10-defi-apps-on-solana-in-2026-complete-guide)
- [Top Solana DEXs - Coin Bureau](https://coinbureau.com/analysis/top-solana-dex-platforms)
- [Solana DeFi TVL - DefiLlama](https://defillama.com/chain/Solana)
- [Meteora DLMM Review - DexRank](https://dexrank.com/reviews/meteora-dex)
- [State of Solana Q3 2025 - Messari](https://messari.io/report/state-of-solana-q3-2025)
- [Jupiter DEX Data - Hive](https://hive.blog/jupiter/@dalz/a-look-at-the-number-one-dex-on-solana-jupiter-or-data-on-trading-volume-tvl-users-top-pairs-and-more-or-apr-2025)
- [Ultra Swap API - Jupiter Developers](https://dev.jup.ag/docs/ultra)
- [Jupiter Swap API](https://hub.jup.ag/docs/swap-api/)

### Smart Contract Development
- [EVM to SVM: ERC-4626 - Solana](https://solana.com/developers/evm-to-svm/erc4626)
- [EVM to SVM: Smart Contracts - Solana](https://solana.com/developers/evm-to-svm/smart-contracts)
- [Anchor Escrow Program - HackMD](https://hackmd.io/@ironaddicteddog/solana-anchor-escrow)
- [Anchor Framework - GitHub](https://github.com/solana-foundation/anchor)
- [Solana Developer Toolbox 2025 - Medium](https://medium.com/@smilewithkhushi/inside-solanas-developer-toolbox-a-2025-deep-dive-7f7e6c4df389)
- [PDAs in Anchor - QuickNode](https://www.quicknode.com/guides/solana-development/anchor/how-to-use-program-derived-addresses)

### Token Programs
- [Token Extensions - Solana](https://solana.com/solutions/token-extensions)
- [Token-2022 Specification - RareSkills](https://rareskills.io/post/token-2022)
- [Transfer Hooks - QuickNode](https://www.quicknode.com/guides/solana-development/spl-tokens/token-2022/transfer-hooks)
- [SPL Token Program Architecture - Chainstack](https://chainstack.com/spl-token-program-architecture/)
- [Associated Token Account - Solana SPL](https://spl.solana.com/associated-token-account)

### Agent Infrastructure
- [How to Build Solana AI Agents 2026 - Alchemy](https://www.alchemy.com/blog/how-to-build-solana-ai-agents-in-2026)
- [Solana Agent Kit v2 Introduction - SendAI](https://docs.sendai.fun/docs/v2/introduction)
- [Solana Agent Kit - GitHub](https://github.com/sendaifun/solana-agent-kit)
- [AI on Solana - Solana.com](https://solana.com/ai)
- [Top AI Agent Tokens on Solana - BingX](https://bingx.com/en/learn/article/top-ai-agent-crypto-projects-in-solana-ecosystem)

### Oracle Infrastructure
- [Pyth Pull Oracle on Solana - Pyth Blog](https://www.pyth.network/blog/pyth-network-pull-oracle-on-solana)
- [Pyth Solana Integration - Developer Hub](https://docs.pyth.network/price-feeds/core/use-real-time-data/pull-integration/solana)
- [Oracle Comparison 2025 - RedStone](https://blog.redstone.finance/2025/01/16/blockchain-oracles-comparison-chainlink-vs-pyth-vs-redstone-2025/)
- [Switchboard Surge - Medium](https://switchboardxyz.medium.com/introducing-switchboard-surge-the-fastest-oracle-on-solana-is-here-36ff615bfdf9)
- [Chainlink Data Feeds on Solana](https://docs.chain.link/data-feeds/solana)
- [Switchboard Documentation](https://docs.switchboard.xyz/)

### Solana vs EVM
- [EVM to SVM Guide - Solana](https://solana.com/news/evm-to-svm)
- [Solana vs EVM - Allbridge](https://allbridge.io/blog/core/discoversolana/)
- [EVM to SVM Security - Sigma Prime](https://blog.sigmaprime.io/transitioning-from-evm-to-svm-key-concepts-for-solana-security-assessment.html)
- [Solana Rent - RareSkills](https://rareskills.io/post/solana-account-rent)
- [Solana Development for EVM Devs - QuickNode](https://www.quicknode.com/guides/solana-development/getting-started/solana-development-for-evm-developers)

### Bags.fm
- [Bags.fm Platform](https://bags.fm/)
- [Bags API Documentation](https://docs.bags.fm)
- [Bags SDK - GitHub](https://github.com/bagsfm/bags-sdk)
- [Bags FM API - Bitquery](https://docs.bitquery.io/docs/blockchain/Solana/bags-fm-api/)
- [Bags.fm Creator Monetization - DEV Community](https://dev.to/sivarampg/bagsfm-the-solana-launchpad-thats-changing-creator-monetization-4g7n)

### SDKs
- [solana-go - GitHub](https://github.com/gagliardetto/solana-go)
- [solana-go - Go Packages](https://pkg.go.dev/github.com/gagliardetto/solana-go)
- [Raydium CLMM - GitHub](https://github.com/raydium-io/raydium-clmm)
- [Orca Whirlpools - GitHub](https://github.com/orca-so/whirlpools)
- [Meteora DBC - GitHub](https://github.com/MeteoraAg/dynamic-bonding-curve)
- [Meteora Documentation](https://docs.meteora.ag)
