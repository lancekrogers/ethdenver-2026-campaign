---
fest_type: workflow
fest_id: 001_INGEST-WF
fest_parent: 001_INGEST
---

# Market Data Ingest Workflow

This workflow runs on each trading cycle. It collects real-time market data from on-chain sources and APIs, validates freshness, and produces structured snapshots for the research phase.

All paths below are relative to the active ritual run directory created by `fest ritual run`.

---

## Step 1: QUERY POOL STATE

**Goal:** Get current Uniswap V3 pool state for the trading pair.

**Actions:**
1. Query Uniswap V3 USDC/WETH pool (3000 BPS fee tier) on Base
   - Current price (sqrtPriceX96 → human-readable)
   - Current tick
   - Liquidity at current tick
   - Fee growth
2. Query via: pool contract `slot0()` + `liquidity()` calls, or Uniswap Subgraph
3. Record the block number this data came from

**Data sources:**
- Uniswap V3 pool contract on Base: SwapRouter02 (`0x2626664c2603336E57B271c5C0b26F421741e481`)
- Uniswap Subgraph (backup): `https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3`
- Uniswap Developer Platform API: `trade-api.gateway.uniswap.org/v1/`

**Output:** Pool state object with price, tick, liquidity, block number, timestamp. This data is later written into `001_INGEST/output_specs/market_snapshot.json`.

**Checkpoint:** Verify price is non-zero and within reasonable range (ETH $500-$50,000)

---

## Step 2: COLLECT PRICE HISTORY

**Goal:** Get 30+ historical price data points for moving average calculation.

**Actions:**
1. Fetch last 30 data points at the ritual's interval (default: 5-minute candles)
2. Source: Uniswap V3 TWAP oracle (`observe()` on pool contract) or API historical data
3. If fewer than 30 points available (e.g., first runs), use what's available and flag in data quality

**Heuristics:**
- Prefer on-chain TWAP over API prices (manipulation-resistant)
- If TWAP oracle has insufficient cardinality, fall back to API candle data
- Each price point needs: timestamp, price, volume (if available)

**Output:** Array of `{timestamp, price, volume}` objects in `001_INGEST/output_specs/price_history.json`

**Checkpoint:** Verify ≥ 30 data points, chronologically ordered, no gaps > 2× interval

---

## Step 3: GET VOLUME AND VOLATILITY

**Goal:** Understand current market activity and risk conditions.

**Actions:**
1. Query 24h trading volume for USDC/WETH pair
2. Calculate recent volatility (standard deviation of last 30 prices)
3. Get current gas price on Base (`eth_gasPrice` or `eth_maxPriorityFeePerGas`)

**Heuristics:**
- Low volume (< $100K 24h) = thinner liquidity = higher slippage risk → flag for research phase
- High volatility (> 5% daily) = wider price swings = both opportunity and risk → flag for research phase
- Gas price affects minimum profitable trade size → pass to research phase for cost analysis

**Output:** Volume, volatility, and gas metrics written into `001_INGEST/output_specs/market_snapshot.json`

**Checkpoint:** None — missing volume/volatility data is acceptable (flagged, not fatal)

---

## Step 4: QUERY VAULT STATE

**Goal:** Understand current vault position and remaining capacity.

**Actions:**
1. Query ObeyVault contract on Base:
   - `totalAssets()` — current NAV in USDC
   - `maxSwapSize()` — per-trade limit
   - `maxDailyVolume()` — daily cap
   - `dailyVolumeUsed()` — how much of daily cap is consumed
   - `maxSlippageBps()` — slippage tolerance
   - `approvedTokens` — which tokens agent can trade
   - `paused()` — is vault paused?
2. Calculate remaining daily capacity: `maxDailyVolume - dailyVolumeUsed`

**Heuristics:**
- If `paused() == true` → short-circuit the entire ritual, output NO_GO immediately
- If remaining daily capacity < minimum profitable trade size → NO_GO (not enough room)
- If NAV < $10 → NO_GO (insufficient assets to trade meaningfully)

**Output:** Vault state object with all parameters + remaining capacity written into `001_INGEST/output_specs/market_snapshot.json`

**Checkpoint:** Verify vault is not paused and has capacity

---

## Step 5: VALIDATE AND PACKAGE

**Goal:** Assemble all data into structured output, validate freshness.

**Actions:**
1. Combine all data into `market_snapshot.json`:
   ```json
   {
     "timestamp": "2026-03-16T21:15:00Z",
     "block_number": 12345678,
     "pool": { "price": 3245.67, "tick": -201234, "liquidity": "..." },
     "price_history": [...],
     "volume_24h": 1250000,
     "volatility_pct": 2.1,
     "gas_gwei": 0.01,
     "vault": { "nav": 100.00, "remaining_daily_capacity": 80.00, "paused": false }
   }
   ```
2. Write `data_quality.md`:
   - All sources responded? (list any failures)
   - Data freshness: oldest data point age
   - Any flags raised (low volume, high volatility, low capacity)

**Freshness rules:**
- Pool state must be < 1 minute old
- Price history most recent point must be < interval × 2
- Gas price must be < 5 minutes old
- Vault state must be < 1 minute old

**Output:** `001_INGEST/output_specs/market_snapshot.json` + `001_INGEST/output_specs/price_history.json` + `001_INGEST/output_specs/data_quality.md`

**Checkpoint:** All data passes freshness check. If not, flag stale sources but continue.

---

## Workflow State Tracking

| Step | Status | Notes |
|------|--------|-------|
| 1. QUERY POOL STATE | [ ] pending | |
| 2. COLLECT PRICE HISTORY | [ ] pending | |
| 3. GET VOLUME AND VOLATILITY | [ ] pending | |
| 4. QUERY VAULT STATE | [ ] pending | Short-circuits if paused |
| 5. VALIDATE AND PACKAGE | [ ] pending | |
