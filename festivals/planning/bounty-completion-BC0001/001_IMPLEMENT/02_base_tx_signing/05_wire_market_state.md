---
fest_type: task
fest_id: 05_wire_market_state.md
fest_name: wire market state
fest_parent: 02_base_tx_signing
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.79607-07:00
fest_tracking: true
---

# Task: Wire Live Uniswap V3 Market Data in GetMarketState

## Objective

Implement the three on-chain query steps documented in `executor.go` lines 269–279 so that `GetMarketState` returns real sqrtPriceX96 spot price and TWAP from on-chain Uniswap V3 pools instead of returning stub/zero values.

## Requirements

- [ ] Step 1: Call `factory.getPool(tokenIn, tokenOut, 3000)` with selector `0x1698ee82` to resolve the pool address
- [ ] Step 2: Call `pool.slot0()` with selector `0x3850c7bd` and decode `sqrtPriceX96` → price
- [ ] Step 3: Call `pool.observe([1800,0])` for 30-minute TWAP
- [ ] All calls use existing `callRPC` infrastructure already in the file
- [ ] `GetMarketState` returns `MarketState` with real `Price` and `TWAP` fields populated

## Implementation

First, read the current file to understand `callRPC` signature and the stub location:

```
projects/agent-defi/internal/base/trading/executor.go  (lines 269–279 and the callRPC function)
```

The existing code already has a `callRPC(ctx, client, to, calldata)` helper or similar. Use it for all three calls below — do not add a new RPC layer.

**Step 1 — Resolve pool address from factory:**

```go
// factory.getPool(address tokenA, address tokenB, uint24 fee) returns (address pool)
// selector: keccak256("getPool(address,address,uint24)")[:4] = 0x1698ee82
factoryAddr := common.HexToAddress(e.cfg.UniswapV3Factory)

getPoolSel := []byte{0x16, 0x98, 0xee, 0x82}
abiArgs, _ := abi.Arguments{
    {Type: mustType("address")},
    {Type: mustType("address")},
    {Type: mustType("uint24")},
}.Pack(tokenIn, tokenOut, uint32(3000))
calldata := append(getPoolSel, abiArgs...)

result, err := callRPC(ctx, e.client, factoryAddr, calldata)
if err != nil {
    return nil, fmt.Errorf("getPool call: %w", err)
}
var poolAddr common.Address
copy(poolAddr[12:], result[12:32]) // ABI-encoded address is right-padded in 32 bytes
```

**Step 2 — Fetch sqrtPriceX96 from pool.slot0():**

```go
// pool.slot0() returns (uint160 sqrtPriceX96, int24 tick, ...)
// selector: keccak256("slot0()")[:4] = 0x3850c7bd
slot0Sel := []byte{0x38, 0x50, 0xc7, 0xbd}
slot0Result, err := callRPC(ctx, e.client, poolAddr, slot0Sel)
if err != nil {
    return nil, fmt.Errorf("slot0 call: %w", err)
}

// sqrtPriceX96 is the first 32 bytes of the result (uint160 ABI-encoded as uint256)
sqrtPriceX96 := new(big.Int).SetBytes(slot0Result[:32])

// price = (sqrtPriceX96 / 2^96)^2
q96 := new(big.Int).Lsh(big.NewInt(1), 96)
price := new(big.Float).SetInt(sqrtPriceX96)
price.Quo(price, new(big.Float).SetInt(q96))
priceF, _ := price.Float64()
spotPrice := priceF * priceF
```

**Step 3 — Fetch TWAP via pool.observe([1800, 0]):**

```go
// pool.observe(uint32[] secondsAgos) returns (int56[] tickCumulatives, uint160[] secondsPerLiquidityCumulativeX128s)
// selector: keccak256("observe(uint32[])")[:4] = 0x883bdbfd
observeSel := []byte{0x88, 0x3b, 0xdb, 0xfd}
// ABI-encode uint32[] [1800, 0]
obsArgs, _ := abi.Arguments{{Type: mustType("uint32[]")}}.Pack([]uint32{1800, 0})
obsCalldata := append(observeSel, obsArgs...)
obsResult, err := callRPC(ctx, e.client, poolAddr, obsCalldata)
if err != nil {
    return nil, fmt.Errorf("observe call: %w", err)
}

// Decode tickCumulatives[0] and tickCumulatives[1] from result
// Each int56 is encoded as int256 (32 bytes)
tick0 := new(big.Int).SetBytes(obsResult[32:64])    // offset past dynamic header
tick1 := new(big.Int).SetBytes(obsResult[64:96])
tickDiff := new(big.Int).Sub(tick1, tick0)
twapTick := new(big.Int).Div(tickDiff, big.NewInt(1800))
// 1.0001^tick gives price — use float approximation for simplicity
twapPrice := math.Pow(1.0001, float64(twapTick.Int64()))
```

Assemble and return:

```go
return &MarketState{
    Price: spotPrice,
    TWAP:  twapPrice,
}, nil
```

Adjust the decoding offsets if the ABI encoding differs — always print `obsResult` hex during testing to verify the layout before assuming offsets.

Add `"math"` to imports if not already present.

Run build:

```bash
cd projects/agent-defi && just build
```

## Done When

- [ ] All requirements met
- [ ] `just build` passes in projects/agent-defi
- [ ] `GetMarketState` returns non-zero `Price` and `TWAP` values when called against a live Base Sepolia RPC
