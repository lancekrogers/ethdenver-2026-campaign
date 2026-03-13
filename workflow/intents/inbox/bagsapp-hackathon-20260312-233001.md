---
id: bagsapp-hackathon-20260312-233001
title: Bags Hackathon - AI Agent Integration
type: idea
concept:
status: inbox
created_at: 2026-03-12
author: lancekrogers

priority: high
horizon: now

blocked_by: []
depends_on: []

promotion_criteria: >
  Exploration doc completed, integration path validated, Bags API key obtained,
  and mainnet deployment strategy approved.
---

# Bags Hackathon - AI Agent Integration

## Description

https://bags.fm/hackathon

## Hackathon Criteria

### Overview
- **Funding Pool:** $4M total — $1M in grants to 100 teams, $3M to The Bags Fund
- **Grant Size:** $10,000 - $100,000 per winner
- **Bonus:** 100 Mac Minis distributed to all winners
- **Applications:** Rolling throughout Q1 2026 (no hard deadline)
- **Category:** AI Agents (one of the listed tracks)

### Eligibility Requirements
1. Project must **have a Bags token**, **use the Bags API**, or **release a fee sharing app**
2. All winning projects must be **verified onchain**
3. Must deploy a **working product with real users and real transactions**
4. Team and contract ownership must be **publicly verifiable**
5. Prototypes accepted at application, but grants only for **shipped products**

### Judging Criteria (Two Dimensions)
1. **Product Traction:** MRR, DAU, GitHub Stars
2. **Onchain Performance:** Market cap, volume, active traders, revenue

Deeper Bags integrations rank higher.

### Platform Details
- **Chain:** Solana
- **API Base:** `https://public-api-v2.bags.fm/api/v1/`
- **Auth:** API key via `x-api-key` header (get keys at dev.bags.fm)
- **Rate Limit:** 1,000 requests/hour per user/IP
- **Key Features:** Token launch, fee sharing, agent authentication, swap/trade, fee claiming
- **Partners:** DFlow, Privy, Helius, Meteora

### Contact
- Email: apps@bags.fm
- Discord: discord.gg/bagsapp

## Context

Our Obey Agent Economy is an AI agent coordination system currently deployed on Base Sepolia (EVM).
Bags is a Solana-based creator token platform with native agent authentication and fee sharing.
The AI Agents track aligns directly with our agent economy work. Extending to Solana with a
Bags-native agent opens a path to mainnet traction, real revenue, and hackathon grant funding.

## Notes

- Bags has dedicated agent auth endpoints (Moltbook-based JWT, 365-day tokens)
- Fee sharing supports up to 100 claimers with basis point allocation
- Agent can autonomously launch tokens, trade, and claim fees
- See workflow/explore/bagsapphackathon/ for full integration analysis
