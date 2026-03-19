# Output Specifications

Structured output from the ingest phase is written here inside each active ritual run.

## Canonical Runtime Files

| Document | Purpose |
|----------|---------|
| `market_snapshot.json` | Current pool, volume, volatility, gas, and vault state used by research and decide phases |
| `price_history.json` | Chronological price history used to calculate the moving average |
| `data_quality.md` | Source freshness, fallback use, and any warnings raised during ingest |

## Runtime Rules

- These files are produced automatically during a ritual run.
- File names and paths are part of the runtime contract and must not drift without updating downstream consumers.
- No user approval step is required before the ritual advances to research.
