---
fest_type: task
fest_id: 04_profitability_validation.md
fest_name: profitability_validation
fest_parent: 01_e2e_testing
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Profitability Validation

**Task Number:** 04 | **Sequence:** 01_e2e_testing | **Autonomy:** medium

## Objective

Validate that the DeFi agent generates positive profit over multiple trading cycles. Run N trading cycles on testnet, document total revenue, total costs (gas fees, service fees), and net profit. This data is required evidence for the Base bounty ("self-sustaining agent").

## Requirements

- [ ] N trading cycles executed (minimum 5, ideally 10+)
- [ ] Each cycle's revenue and costs documented with transaction hashes
- [ ] Total revenue calculated across all cycles
- [ ] Total costs calculated across all cycles (gas, service fees, HTS transfer fees)
- [ ] Net profit calculated (revenue minus costs)
- [ ] Net profit is positive (required for Base bounty claim)
- [ ] Results saved to `results/profitability_report.md` within this sequence directory

## Implementation

### Step 1: Prepare the test environment

Ensure all agents are running from the full cycle test (task 02). The DeFi agent should be connected and ready to trade.

Verify the DeFi agent's wallet balances before starting:

```bash
# Check the agent's token balances on testnet
# Use the project's balance check command or Hedera Mirror Node API
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
just balance
# Or query directly: curl https://testnet.mirrornode.hedera.com/api/v1/accounts/<account-id>/tokens
```

Record the starting balances.

### Step 2: Run N trading cycles

Allow the DeFi agent to execute multiple trading cycles. For each cycle, record:

- **Cycle number**: Sequential identifier
- **Trade type**: Buy/sell, token pair
- **Entry transaction hash**: The transaction that opened the position
- **Exit transaction hash**: The transaction that closed the position
- **Revenue**: The gross revenue from the trade (in token units and USD equivalent)
- **Gas cost**: The gas fee for the trade transactions
- **Service fees**: Any platform fees, HTS transfer fees, or x402 payment fees
- **Net result**: Revenue minus all costs for this cycle

### Step 3: Calculate totals

After all cycles complete, calculate:

```
Total Revenue = sum of all cycle revenues
Total Gas Costs = sum of all gas fees
Total Service Fees = sum of all service fees (HTS, x402, platform)
Total Costs = Total Gas Costs + Total Service Fees
Net Profit = Total Revenue - Total Costs
Profit Margin = Net Profit / Total Revenue * 100
```

### Step 4: Write the profitability report

Create `results/profitability_report.md` with:

```markdown
# Profitability Validation Report

## Test Environment
- Date: [date]
- Network: Hedera Testnet / Base Testnet
- DeFi agent version: [commit hash]
- Number of cycles: [N]
- Duration: [total time]

## Starting Balances
| Token | Balance |
|-------|---------|
| HBAR | [amount] |
| [token] | [amount] |

## Cycle-by-Cycle Results

| Cycle | Trade | Entry TX | Exit TX | Revenue | Gas | Fees | Net |
|-------|-------|----------|---------|---------|-----|------|-----|
| 1 | | | | | | | |
| 2 | | | | | | | |
...

## Summary

| Metric | Value |
|--------|-------|
| Total Revenue | |
| Total Gas Costs | |
| Total Service Fees | |
| Total Costs | |
| **Net Profit** | |
| **Profit Margin** | |

## Ending Balances
| Token | Balance | Change |
|-------|---------|--------|
| HBAR | [amount] | [+/-] |
| [token] | [amount] | [+/-] |

## Verification
All transaction hashes above can be verified on:
- Hedera: https://hashscan.io/testnet/transaction/[hash]
- Base: https://sepolia.basescan.org/tx/[hash]

## Analysis
[Brief analysis of trading strategy performance, any patterns observed,
and confidence level in sustained profitability]
```

### Step 5: Handle negative profit

If net profit is negative after N cycles:

1. Analyze which cycles lost money and why
2. Check if trading parameters can be adjusted (slippage tolerance, minimum spread, etc.)
3. Run additional cycles with adjusted parameters
4. If profitability cannot be achieved, document the path to profitability (what would need to change) and flag this as a risk for the Base bounty

## Done When

- [ ] Minimum 5 trading cycles executed with full documentation
- [ ] Every transaction hash recorded and verifiable on block explorer
- [ ] Net profit calculated and positive
- [ ] Report saved to `results/profitability_report.md`
- [ ] Data is ready to feed into the P&L proof document in sequence 05_base_package
