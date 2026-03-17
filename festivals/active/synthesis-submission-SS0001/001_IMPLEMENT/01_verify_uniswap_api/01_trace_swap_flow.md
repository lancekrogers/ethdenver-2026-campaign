---
fest_type: task
fest_id: 01_trace_swap_flow.md
fest_name: trace swap flow
fest_parent: 01_verify_uniswap_api
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-16T21:39:45.051722-06:00
fest_tracking: true
---

# Task: Trace Swap Flow in agent-defi

## Objective

Trace the agent-defi swap execution path to identify exactly how quotes are obtained and whether the Uniswap Developer Platform API (trade-api.gateway.uniswap.org) is used for quoting/routing.

## Requirements

- [ ] Identify the entry point for swap execution in agent-defi Go code
- [ ] Trace the quote/routing path: does the agent call the Uniswap Developer Platform API or construct SwapRouter02 calls directly?
- [ ] Document each step in the swap flow from signal to on-chain execution

## Implementation

1. Open `projects/agent-defi/` and locate the swap execution entry point (likely in a trading or executor package)
2. Follow the call chain from trade decision to on-chain execution
3. Look for HTTP client calls to `trade-api.gateway.uniswap.org` -- this is the Developer Platform API
4. Look for direct ABI-encoded calls to SwapRouter02 (`0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45` on Base)
5. Document the flow: signal -> quote source -> route construction -> transaction submission
6. Note: The Uniswap bounty requires "Uniswap API with a real API key" -- direct SwapRouter02 calls without the API do not qualify

## Done When

- [ ] All requirements met
- [ ] Swap flow documented from signal to execution with each intermediate step identified
- [ ] Quote source clearly identified as either Developer Platform API or direct contract calls
