---
fest_type: task
fest_id: 03_pnl_proof.md
fest_name: pnl_proof
fest_parent: 08_base_package
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_updated: 2026-02-21T12:17:50.601603-07:00
fest_tracking: true
---


# Task: Create P&L Proof Document

**Task Number:** 03 | **Sequence:** 05_base_package | **Autonomy:** medium

## Objective

Create a P&L (Profit and Loss) proof document at `docs/pnl-proof.md` in the agent-defi project. This is THE key evidence for the Base bounty. It must include transaction hashes for every trade, a revenue breakdown, a cost breakdown, and a net profit calculation that judges can independently verify on-chain.

## Requirements

- [ ] Every trade transaction hash included and verifiable on block explorer
- [ ] Revenue breakdown by trade
- [ ] Cost breakdown (gas fees per transaction, service fees, HTS transfer fees)
- [ ] Net profit calculation (total revenue minus total costs)
- [ ] Net profit is positive
- [ ] Verification instructions for judges
- [ ] Document saved at `projects/agent-defi/docs/pnl-proof.md`

## Implementation

### Step 1: Gather data from profitability validation

Pull data from the E2E testing profitability report (`003_EXECUTE/01_e2e_testing/results/profitability_report.md`). This report contains the raw cycle-by-cycle data with transaction hashes.

### Step 2: Organize trades chronologically

List every trade in chronological order with:

| # | Timestamp | Action | Token Pair | Amount | Price | TX Hash | Block |
|---|-----------|--------|------------|--------|-------|---------|-------|

### Step 3: Calculate revenue per trade

For each trade, calculate the gross revenue:

- Buy trades: Negative revenue (cost to acquire)
- Sell trades: Positive revenue (proceeds from sale)
- Net revenue per round-trip: Sell price minus buy price, multiplied by quantity

### Step 4: Calculate costs per trade

For each transaction, document:

- **Gas fee**: Actual gas paid (pull from block explorer)
- **Service fees**: Any platform fees, DEX fees, or protocol fees
- **HTS transfer fees**: Cost of HTS token transfers if applicable
- **x402 payment fees**: Cost of x402 protocol payments if applicable

### Step 5: Calculate net profit

```
Total Revenue = sum of all sell proceeds - sum of all buy costs
Total Gas Costs = sum of all gas fees across all transactions
Total Service Fees = sum of all non-gas fees
Total Costs = Total Gas Costs + Total Service Fees
Net Profit = Total Revenue - Total Costs
```

### Step 6: Write the P&L proof document

Create `docs/pnl-proof.md`:

```markdown
# P&L Proof: Self-Sustaining Agent

## Summary

| Metric | Value |
|--------|-------|
| Period | [start date] to [end date] |
| Total Trades | [N] |
| Total Revenue | [amount] |
| Total Costs | [amount] |
| **Net Profit** | **[amount]** |
| Profit Margin | [X]% |

## Trade Log

| # | Time | Action | Pair | Amount | Price | Revenue | TX Hash |
|---|------|--------|------|--------|-------|---------|---------|
| 1 | | | | | | | |
| 2 | | | | | | | |
...

## Cost Breakdown

| Category | Total | Per-Trade Avg | Notes |
|----------|-------|---------------|-------|
| Gas Fees | | | |
| DEX Fees | | | |
| HTS Transfer Fees | | | |
| x402 Payment Fees | | | |
| **Total Costs** | | | |

## Revenue Breakdown

| Trade Pair | Cycles | Gross Revenue | Net Revenue |
|------------|--------|---------------|-------------|
| [pair 1] | | | |
| [pair 2] | | | |
| **Total** | | | |

## Verification

Judges can verify each transaction independently:

1. Visit [block explorer URL]
2. Search for any TX hash from the Trade Log
3. Confirm the sender matches the agent address: [address]
4. Confirm the amounts match the Trade Log

All transactions are on [network name] testnet.

## Agent Identity

| Field | Value |
|-------|-------|
| Agent Address | [address] |
| ERC-8004 Identity | [contract/token ID] |
| Network | [network] |
```

### Step 7: Verify accuracy

Cross-check every transaction hash on the block explorer. Ensure amounts in the document match on-chain data exactly.

## Done When

- [ ] Every trade transaction hash is listed and verifiable
- [ ] Revenue calculation is correct (verified against on-chain data)
- [ ] Cost calculation is correct (gas fees pulled from block explorer)
- [ ] Net profit is positive
- [ ] Verification instructions are clear and work when followed
- [ ] Document saved at `projects/agent-defi/docs/pnl-proof.md`