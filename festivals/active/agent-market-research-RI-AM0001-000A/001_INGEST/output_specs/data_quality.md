# Data Quality

- Run: agent-market-research-RI-AM0001-000A
- Collected at: 2026-03-19T09:21:52.630Z
- Primary source: Base Sepolia RPC via on-chain `cast` calls against the Uniswap V3 pool and vault contracts.
- Secondary quote API: unavailable during this run; on-chain pool state was used as the authoritative live source.
- Historical samples: 30 points spaced 150 blocks apart.
- Oldest sample age: 145 minutes.
- Most recent sample age: 0 minutes.
- 24h volume is unavailable in this run and is flagged as non-fatal.
- NAV fallback used: yes (Command failed: cast call 0xbAbDd92397Cd812593e79A5b4c2a32bB4aDb06b1 totalAssets()(uint256) --rpc-url https://sepolia.base.org).
- NAV fallback confidence impact: conservative lower bound only (nav_is_lower_bound=true).
