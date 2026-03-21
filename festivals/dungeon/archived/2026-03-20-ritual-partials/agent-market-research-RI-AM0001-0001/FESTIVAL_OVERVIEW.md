# Festival Overview: agent-market-research

## Problem Statement

**Current State:** The ObeyVault trading agent makes decisions based on LLM reasoning, but the "discovery" phase — scanning the market, evaluating conditions, assessing risk — produces no structured artifact. The agent checks prices and decides, but there's no auditable record of what it found, what it considered, and how it scored the opportunity.

**Desired State:** Every market research cycle produces a dated, structured research artifact documenting: data ingested, analysis performed, risk gates evaluated, opportunity score, and a clear go/no-go decision with rationale. This artifact feeds into the agent's planning phase and into `agent_log.json` for Protocol Labs submission.

**Why This Matters:** Protocol Labs' "Let the Agent Cook" bounty requires a full autonomous loop: discover → plan → execute → verify → submit. The "discover" step needs structured evidence, not just a log line. Festival Methodology's ritual type is purpose-built for this — a repeatable process that produces consistent, auditable outputs on every execution.

## Scope

### In Scope

- Market data ingestion (Uniswap V3 pool state, price feeds)
- Price deviation analysis (vs moving average)
- CRE Risk Router 8-gate evaluation
- Opportunity scoring with confidence level
- Go/no-go decision with structured rationale
- Machine-readable output (JSON artifact)
- Execution log entry for agent_log.json

### Out of Scope

- Trade execution (that's the planning + implementation phases of the trading loop)
- Vault interaction (downstream of this ritual)
- Strategy modification (this ritual evaluates, it doesn't change the strategy)
- Historical backtesting

## Planned Phases

### 001_INGEST (type: ingest)
Collect raw market data from on-chain sources and APIs. Price data, pool state, volume metrics, volatility indicators.

### 002_RESEARCH (type: research)
Analyze ingested data. Calculate price deviation from moving average. Run CRE Risk Router 8-gate evaluation. Score the opportunity.

### 003_DECIDE (type: non_coding_action)
Produce a structured go/no-go trading decision with full rationale. Output as JSON artifact consumable by the trading agent's planning phase.

## Notes

- This ritual is designed to run on every trading cycle (default: 5-minute intervals)
- Each execution produces a new dated artifact — the history of artifacts IS the agent's research trail
- The ritual's output maps to Protocol Labs' "discover" step in the autonomous loop
- Quality gates are lightweight for a ritual — focus on data validity and rationale completeness
