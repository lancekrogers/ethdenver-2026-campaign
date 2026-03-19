# Data Quality Report — agent-market-research-RI-AM0001-0009

**Generated:** 2026-03-19T09:03:30Z
**Block:** 39071361 (Base Sepolia)

---

## Data Sources Responded

| Source | Status | Notes |
|--------|--------|-------|
| Uniswap V3 pool `slot0()` | ✅ SUCCESS | price, tick, liquidity — fresh |
| Uniswap V3 pool `liquidity()` | ✅ SUCCESS | 12771768749653 |
| Uniswap V3 TWAP observations (0–21) | ✅ SUCCESS | 22 observations available |
| ObeyVault `totalAssets()` | ✅ SUCCESS | returned 0 USDC |
| ObeyVault `maxSwapSize()` | ✅ SUCCESS | 1000 USDC |
| ObeyVault `maxDailyVolume()` | ✅ SUCCESS | 10000 USDC |
| ObeyVault `dailyVolumeUsed()` | ✅ SUCCESS | 0 USDC |
| ObeyVault `maxSlippageBps()` | ✅ SUCCESS | 100 bps |
| ObeyVault `paused()` | ✅ SUCCESS | false |
| ObeyVault `asset()` | ✅ SUCCESS | USDC |
| ObeyVault `approvedTokens(WETH)` | ✅ SUCCESS | true |
| ObeyVault `approvedTokens(USDC)` | ✅ SUCCESS | true |
| ObeyVault `heldTokenCount()` | ✅ SUCCESS | 0 |
| USDC `balanceOf(vault)` | ✅ SUCCESS | 0 (confirmed totalAssets=0) |
| `eth_gasPrice` | ✅ SUCCESS | 6000000 wei (0.006 Gwei) |
| Uniswap V3 subgraph (volume) | ❌ FAILED | 301 redirect; no Base Sepolia subgraph available at the configured URL |
| Uniswap Developer Platform API (volume) | ❌ FAILED | 403 Forbidden for pool data endpoint |

---

## Freshness Assessment

| Data Point | Age at Ingest | Threshold | Status |
|------------|---------------|-----------|--------|
| Pool slot0 (price, tick) | < 30 seconds | < 1 minute | ✅ FRESH |
| TWAP observations | Most recent: ~19 min ago (obs 21 at 1773904396) | < interval × 2 | ✅ ACCEPTABLE |
| Gas price | < 30 seconds | < 5 minutes | ✅ FRESH |
| Vault state | < 30 seconds | < 1 minute | ✅ FRESH |

---

## Flags

### ⚠️ Price History Below 30-Point Threshold
- **Expected:** ≥ 30 price data points for reliable moving average
- **Available:** 22 TWAP observations (indices 0–21, spanning ~28 hours)
- **Impact:** Moving average computed over 22 points instead of 30; labeled in research output
- **Action:** Research phase uses available 22 points and notes reduced confidence

### ⚠️ 24h Volume Unavailable
- **Source attempted:** Uniswap V3 subgraph (Base Sepolia) — 301 redirect
- **Source attempted:** Uniswap Developer Platform API — 403 Forbidden
- **Impact:** Volume-based risk gate (low volume flag < $100K) cannot be evaluated
- **Action:** Volume gate marked as `"status": "unknown"` in CRE evaluation; no penalty to confidence

### 🔴 Vault NAV = $0.00 USDC
- **`totalAssets()` returned:** 0 (zero, no revert)
- **`ERC20(USDC).balanceOf(vault)` returned:** 0 (confirmed)
- **`heldTokenCount()` returned:** 0
- **NAV source:** `totalAssets` (not a fallback)
- **NAV is lower bound:** false (exact value; vault is simply unfunded)
- **Impact:** CRITICAL — NAV < $10 threshold triggers NO_GO per ritual rules
- **This changes the confidence of the research result:** YES — the vault has no tradeable capital regardless of market conditions

---

## NAV Provenance

- `totalAssets()` succeeded and returned 0.
- This is not a fallback scenario; the vault is genuinely unfunded at this block.
- `nav_source = "totalAssets"`, `nav_is_lower_bound = false`, `nav_fallback_reason = ""`.

---

## Overall Data Confidence

| Dimension | Rating |
|-----------|--------|
| Price data | MEDIUM (22/30 points, sufficient for trending analysis) |
| Vault state | HIGH (all core calls succeeded) |
| Volume data | LOW (source unavailable) |
| Gas data | HIGH (fresh on-chain) |

**Summary:** Sufficient data to make a valid decision. Volume gap is a known limitation. Vault NAV = 0 is authoritative and blocks trading regardless of market analysis quality.
