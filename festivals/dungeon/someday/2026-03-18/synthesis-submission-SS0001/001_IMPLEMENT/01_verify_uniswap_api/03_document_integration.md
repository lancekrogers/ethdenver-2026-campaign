---
fest_type: task
fest_id: 03_document_integration.md
fest_name: document integration
fest_parent: 01_verify_uniswap_api
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-16T21:39:45.052235-06:00
fest_updated: 2026-03-16T22:27:12.76403-06:00
fest_tracking: true
---


# Task: Document Uniswap Integration Path

## Objective

Write a clear summary of how OBEY integrates with the Uniswap Developer Platform, suitable for inclusion in the hackathon submission narrative.

## Requirements

- [ ] Write integration path document showing API flow from agent decision to on-chain swap
- [ ] Include API endpoints, key configuration, and code references
- [ ] Document how ObeyVault's executeSwap() consumes API-provided route data

## Implementation

1. Using findings from tasks 01 (trace) and 02 (verify), write `workflow/explore/synthesis/uniswap-integration.md`
2. Include these sections:
   - **API Endpoint**: trade-api.gateway.uniswap.org and which routes are used
   - **Key Configuration**: How the API key is stored and passed
   - **Quote Flow**: Agent decision -> API quote request -> response parsing
   - **Route Execution**: How the API-provided calldata is passed to vault.executeSwap()
   - **TWAP Oracle**: How Uniswap V3 TWAP complements API quotes for vault NAV pricing
   - **Code References**: Specific files and functions in agent-defi that handle each step
3. Keep it under 500 words -- judges need to verify the integration quickly

## Done When

- [ ] All requirements met
- [ ] Integration document saved to `workflow/explore/synthesis/uniswap-integration.md`
- [ ] A reviewer can verify the full Uniswap Developer Platform integration in under 2 minutes of reading