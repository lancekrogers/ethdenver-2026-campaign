# 09 — Existing System Reuse Map

## What We Keep (Existing OBEY Agent Economy)

Every existing component has a role in the platform. Nothing is thrown away.

### agent-coordinator → Platform Coordinator

| Existing | Reuse | Changes |
|----------|-------|---------|
| HCS topic management | Agent event logging | Add platform event types (deposit, burn, trade, NAV) |
| Task assignment via HCS | Agent task coordination | Extend for multi-agent prediction market tasks |
| Agent reputation tracking | Leaderboard data source | Feed performance metrics from vault NAV |
| Inter-agent messaging | Agent-to-agent signals | Agents can share market intelligence |
| Festival engine | Strategy orchestration | Structure complex multi-step strategies as festivals |

### agent-defi → Reference Trading Agent

| Existing | Reuse | Changes |
|----------|-------|---------|
| Mean reversion strategy | Strategy framework reference | Generalize into Strategy interface |
| Uniswap V3 integration | DeFi adapter template | Adapt for Jupiter swaps on Solana |
| P&L calculation | Portfolio math reference | Extend for prediction market positions |
| x402 payment handling | Agent-to-service payments | Agents pay for LLM API, data feeds |
| ERC-8004 identity | Agent identity layer | Register platform agents with ERC-8004 |
| ERC-8021 attribution | Trade attribution | Attribute platform trades |

### agent-inference → Inference Integration (Future)

| Existing | Reuse | Changes |
|----------|-------|---------|
| 0G Compute routing | LLM inference routing | Agents could route analysis to decentralized compute |
| 0G Storage | Agent memory/knowledge persistence | Store strategy models, training data |
| ERC-7857 iNFT | Agent identity NFT | Tokenized agent identities (future) |
| Provider discovery | GPU provider marketplace | Decentralized inference for agent analysis |

### dashboard → Platform UI

| Existing | Reuse | Changes |
|----------|-------|---------|
| Next.js app shell | Platform frontend | Extend with marketplace, profiles, deposit flows |
| HCS feed component | Real-time event feed | Show agent trades, deposits, burns |
| Payment flow visualization | Fee flow display | Show platform fee collection |
| P&L display | Agent/portfolio P&L | Extend for multi-agent portfolio view |
| Metrics components | Leaderboard, agent stats | Add Sharpe, win rate, drawdown charts |

### contracts → Contract Reference

| Existing | Reuse | Changes |
|----------|-------|---------|
| Foundry setup | Testing reference | New contracts are Anchor (Solana) not Solidity |
| ERC-8004 deployment | Agent identity (Base) | Keep for cross-chain agent identity |
| OpenZeppelin patterns | Security patterns reference | Apply same principles in Anchor |

### hiero-plugin → Platform CLI Integration

| Existing | Reuse | Changes |
|----------|-------|---------|
| Hiero CLI integration | Platform CLI commands | Add `hiero platform` commands for agent management |
| Camp wrapping | Workflow integration | Platform operations via camp commands |

### cre-risk-router → Risk Pipeline

| Existing | Reuse | Changes |
|----------|-------|---------|
| Chainlink CRE workflows | Risk assessment pipeline | Use CRE for agent risk scoring |
| Risk metrics calculation | Risk parameter validation | Feed into agent risk profiles |

## Code Reuse Estimate

| Component | Existing LOC (est.) | Reusable | New LOC (est.) | Reuse % |
|-----------|-------------------|----------|---------------|---------|
| Coordinator | ~3,000 | ~2,000 | ~1,500 | 57% |
| Trading Agent | ~4,000 | ~1,500 | ~6,000 | 20% |
| Inference Agent | ~3,500 | ~500 (future) | — | — |
| Dashboard | ~5,000 | ~3,000 | ~8,000 | 27% |
| Contracts | ~2,000 | ~200 (patterns) | ~3,000 | 6% |
| Hiero Plugin | ~1,000 | ~500 | ~300 | 63% |
| **Total** | **~18,500** | **~7,700** | **~18,800** | **29%** |

~30% of the new platform is built on existing code. The remaining 70% is genuinely new: vault contracts, market adapters, prediction market strategies, marketplace UI, and Bags integration.

## Migration Path

The existing system continues to work as-is. The platform is built alongside it:

```
Phase 1 (Now): Existing OBEY economy runs on Base/Hedera/0G
                ↓
Phase 2: Platform contracts deployed on Solana
         Existing agents continue running
                ↓
Phase 3: New prediction market agents deployed on platform
         Existing agents optionally migrate to platform custody
                ↓
Phase 4: Existing agent-defi becomes a platform agent
         (trades via vault contract instead of direct wallet)
                ↓
Phase 5: Full platform — all agents on platform,
         marketplace live, OBEY token active
```

No existing functionality is broken at any point. The platform is additive.
