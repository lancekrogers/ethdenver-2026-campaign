# 07 — Market Evidence Snapshot (2026-03-09)

## Purpose

Reusable, source-backed market snapshot so monetization decisions are based on data, not memory.

## Snapshot Date

- Collected on **2026-03-09** (UTC evening).
- Values from public APIs are time-variant and should be refreshed before major decisions.

## Key Question

Do real buyers exist for "agent reliability + risk controls" in crypto, outside speculation?

## Evidence Summary

### 1) There is large capital at risk onchain

- DeFiLlama chains API total TVL: **~$170.27B**
- DeFiLlama protocols with non-null TVL: **6,543**
- Protocol counts by size:
  - `> $10M TVL`: **733**
  - `> $50M TVL`: **382**
  - `> $100M TVL`: **263**
  - `> $500M TVL`: **101**

Inference: enough protocols have meaningful TVL to justify paid risk/reliability spend.

### 2) There is ongoing execution activity (not just parked TVL)

- DeFiLlama DEX overview:
  - 24h DEX volume: **$5.90B**
  - 7d DEX volume: **$54.56B**

Inference: high activity supports demand for guardrails on automated execution paths.

### 3) "AI agents" are active but speculative

- CoinGecko `ai-agents` category:
  - Market cap: **~$3.12B**
  - 24h volume: **~$495M**

Inference: token interest exists, but this does not directly prove B2B willingness to pay for infra.

### 4) Paid risk-provider budgets exist in DAO markets

- Aave governance (Chaos renewal thread) references renewal at flat **$2M** commercial terms.
- Aave governance (LlamaRisk renewal) proposes **$1M for one year**.

Inference: large protocols already pay for externalized risk expertise/services.

## Customer Segments That Likely Exist

### A) Protocols/DAOs with treasury and risk committees

- Trigger: increasing TVL, more assets, governance pressure.
- Buyer: risk lead, core contributor set, governance delegates.
- Budget type: service-provider stream, retainer, milestone contract.

### B) Agent/trading teams with automated execution

- Trigger: need to reduce bad fills, stale-signal trades, and incident rates.
- Buyer: founder/CTO, quant lead, ops lead.
- Budget type: integration sprint + monthly reliability support.

### C) Chains/ecosystems funding adoption

- Trigger: need credible demos and production-like patterns for builders.
- Buyer: DevRel/ecosystem teams.
- Budget type: grants, bounties, pilot sponsorship.

## Economics Model (Service-First)

Suggested packaging based on current assets:

- Integration sprint: `$10k-$25k`
- Reliability audit/hardening: `$3k-$12k`
- Monthly support retainer: `$3k-$8k`

Targeting `$30k/mo`:

- 2 integration sprints at `$15k` each, or
- 1 sprint at `$15k` + 3 retainers at `$5k` each.

Inference: feasible with sales execution; unlikely on autopilot initially.

## What This Does NOT Prove

- It does not prove immediate PMF for a standalone SaaS product.
- It does not prove small teams will pay recurring fees without pilot results.
- It does not prove "agent token narratives" convert into enterprise spend.

## Decision Impact

Current evidence supports:

1. **Service-led monetization now**
2. **Productization later** only after repeated paid engagements
3. **Portfolio-only fallback** if paid demand is not validated within a fixed window

## Refresh Procedure

Run and append updated numbers monthly:

```bash
# TVL and protocol breadth
curl -s https://api.llama.fi/chains | jq '(map(.tvl)|add)'
curl -s https://api.llama.fi/protocols | jq '[.[] | select(.tvl != null)] | {protocol_count: length, total_tvl: (map(.tvl) | add)}'
curl -s https://api.llama.fi/protocols | jq '{gt_10m: map(select(.tvl!=null and .tvl>10000000))|length, gt_50m: map(select(.tvl!=null and .tvl>50000000))|length, gt_100m: map(select(.tvl!=null and .tvl>100000000))|length, gt_500m: map(select(.tvl!=null and .tvl>500000000))|length}'

# DEX activity
curl -s 'https://api.llama.fi/overview/dexs?excludeTotalDataChart=true&excludeTotalDataChartBreakdown=true' | jq '{total24h,total48hto24h,total7d}'

# AI-agent category context
curl -s 'https://api.coingecko.com/api/v3/coins/categories' | jq 'map(select(.id=="ai-agents"))[0] | {id,name,market_cap,market_cap_change_24h,volume_24h,top_3_coins_id}'
```

## Sources

- DeFiLlama chains API: https://api.llama.fi/chains
- DeFiLlama protocols API: https://api.llama.fi/protocols
- DeFiLlama DEX overview API: https://api.llama.fi/overview/dexs?excludeTotalDataChart=true&excludeTotalDataChartBreakdown=true
- CoinGecko categories API: https://api.coingecko.com/api/v3/coins/categories
- Aave governance (Chaos Labs renewal): https://governance.aave.com/t/chaos-labs-x-aave-dao-early-renewal-proposal/22346
- Aave governance (LlamaRisk renewal): https://governance.aave.com/t/arfc-renew-llamarisk-as-risk-service-provider-epoch-3/21666
