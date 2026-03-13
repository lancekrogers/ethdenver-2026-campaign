# Solana — Chain Exploration for Agent Platform

## Why Solana

| Factor | Solana | Base (EVM) |
|--------|--------|-----------|
| Tx cost | $0.00025 | $0.01-0.10 |
| Block time | 400ms | 2s |
| DEX volume | $3B+/day | Lower |
| Agent SDK | Solana Agent Kit v2 (60+ actions) | None equivalent |
| Oracle freshness | Pyth 400ms | Chainlink ~1-2s |
| Bags.fm | Native | Cross-chain |

**Bottom line:** 40-400x cheaper transactions, 5x faster blocks, deeper DEX liquidity, and Bags.fm is native. The cost advantage alone makes Solana compelling for agents that execute hundreds of trades daily.

## DeFi Landscape

### DEXes

| DEX | Type | Volume | TVL | Integration |
|-----|------|--------|-----|-------------|
| **Jupiter** | Aggregator | $700M+/day, 90% share | $2.6B | Ultra Swap API (RPC-less) + Swap API (CPI) |
| **Raydium** | CPMM + CLMM | Major | $2.3B | Open-source, CPI available |
| **Orca** | CLMM (Whirlpools) | $22.8B/30d | Significant | TypeScript + Rust SDKs |
| **Meteora** | DLMM + DBC | $300M+/day | $750M-1B | DBC SDK, Bags.fm backbone |

**Jupiter is the integration point** — aggregates all DEXes, provides HTTP APIs that work from any language. Agent doesn't need to integrate each DEX individually.

### Swap Pattern

```
1. GET /quote → optimal route across all DEXes
2. POST /swap → pre-built transaction
3. Sign locally → submit to RPC
```

Jupiter's Ultra Swap API is gasless and RPC-less — ideal for agents.

## Smart Contract Architecture on Solana

### Key Differences from EVM

| Concept | EVM | Solana |
|---------|-----|--------|
| State | Inside contract (mappings) | External accounts |
| Vault shares | ERC-20 (standard) | SPL Token via PDA mint |
| Vault standard | ERC-4626 (battle-tested) | **None — build from scratch** |
| User state | Mapping entry (free) | ATA creation (~0.002 SOL rent) |
| Authority | msg.sender | PDA signing |
| Framework | Solidity + Foundry/Hardhat | Rust + Anchor |

### Vault Pattern (No ERC-4626 Equivalent)

Must be built in Anchor. Required accounts per agent vault:
- Vault state PDA (~0.002 SOL)
- Vault token ATAs (one per accepted asset, ~0.002 SOL each)
- Share mint PDA (~0.0015 SOL)
- Per user: share token ATA (~0.002 SOL)

100 investors in one agent vault ≈ 0.206 SOL in rent deposits (reclaimable on closure).

### Token-2022 Extensions (Relevant)

| Extension | Use Case |
|-----------|----------|
| **Transfer Fees** | Automate platform fee on share transfers |
| **Interest-Bearing** | Display NAV-adjusted share values |
| **Transfer Hooks** | Enforce vault rules on share transfers |
| **Non-Transferable** | Agent identity/reputation tokens |
| **Metadata** | On-chain agent metadata |

## Oracle Infrastructure

### Pyth (Primary — Solana Native)

- 500+ price feeds
- 400ms update frequency
- Pull-based (gas-efficient — only pay when you read)
- Aggregates from primary sources (exchanges, trading firms)
- Anchor integration:

```rust
let price = price_update.get_price_no_older_than(
    &Clock::get()?,
    maximum_age,
    &feed_id
)?;
```

### Switchboard (Fallback)

- Permissionless feed creation (no DAO approval needed)
- Sub-100ms latency (Surge)
- Can aggregate from Pyth, Chainlink, Web2 APIs

### Chainlink on Solana

- Present but limited feed selection vs EVM
- OCR-based, Solana-native speed
- Check data.chain.link for available feeds

**For NAV calculation:** Pyth is the clear choice on Solana — widest coverage, fastest updates, native integration. Same Chainlink-only NAV principle applies, just swap "Chainlink feed" for "Pyth feed" — if no oracle feed exists, token is worth $0 in NAV.

## Agent Infrastructure

### Solana Agent Kit v2 (SendAI)

- 60+ pre-built DeFi actions
- Plugin architecture: Token, NFT, DeFi, Misc, Blinks
- Embedded wallet support (Turnkey for autonomous agents, Privy for human-in-loop)
- 100K+ downloads, 1,400+ GitHub stars
- Works with ElizaOS, LangChain, Vercel AI SDK

### Production Wallet Architecture

```
Smart Contract Wallet
├── Owner Key (user-held, ultimate control)
└── Agent Key (TEE-deployed, limited permissions)
    ├── Transaction limits
    ├── Daily spending caps
    └── Authorized tx types only
```

## Bags.fm Integration

Native Solana platform. Tokens launch on Meteora DBC:

1. Create token via API → starts on bonding curve
2. Trading generates 1% creator fee
3. Fee sharing configurable (up to 100 claimers, basis points)
4. Auto-migration to DAMM v2 at liquidity threshold
5. Top 100 holders get dividends (24hr cycles, 10 SOL min)

**Platform integration path:**
```
Agent launches Bags token → trades generate fees → agent claims fees →
fees deposited to vault → NAV increases → share value grows
```

## Go SDK Gap

`solana-go` (gagliardetto) is alpha. Missing:
- DeFi protocol wrappers (Jupiter, Raydium, etc.)
- Anchor IDL parsing
- PDA derivation helpers
- Pyth oracle reading

**Mitigation:** Jupiter, Bags, and Pyth all have HTTP APIs accessible from Go. On-chain programs (vault) would be Rust/Anchor. The Go agent runtime talks to Solana via HTTP APIs + RPC, not CPI.

## Solana Challenges

1. **No vault standard** — ERC-4626 doesn't exist, build from scratch in Anchor
2. **Go SDK immaturity** — alpha quality, no DeFi wrappers
3. **Account complexity** — rent deposits, ATA creation, PDA management
4. **Fewer auditors** — Solana/Rust audit firms are scarcer and more expensive
5. **Chainlink CRE gap** — existing risk pipeline targets EVM
6. **Learning curve** — Rust/Anchor + Solana account model

## Strategic Recommendation

**Option B: Hybrid** is the pragmatic choice:

- **Agent runtime stays in Go** (existing codebase)
- **Vault programs in Rust/Anchor** on Solana (no Go alternative for on-chain)
- **DeFi interaction via HTTP APIs** (Jupiter, Bags, Pyth — all accessible from Go)
- **Solana RPC via solana-go** for transaction submission and monitoring

This keeps our Go investment while accessing Solana's cost/speed advantages. The vault program is the one piece that must be native Rust.

## Next Steps

1. Prototype Anchor vault program (deposit → mint shares, burn → withdraw)
2. Build Go wrapper for Jupiter Ultra Swap API
3. Integrate Pyth price feeds for NAV calculation
4. Test Bags.fm agent auth + token launch flow from Go
5. Evaluate Token-2022 extensions for share tokens (transfer fees, interest-bearing)

## Full Research

See `ai_docs/research/solana-chain-exploration.md` for complete technical details including SDK examples, program addresses, CPI patterns, and all source links.
