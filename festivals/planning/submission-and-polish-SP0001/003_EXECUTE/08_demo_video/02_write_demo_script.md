---
fest_type: task
fest_id: 02_write_demo_script.md
fest_name: write_demo_script
fest_parent: 08_demo_video
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Write Demo Script

**Task Number:** 02 | **Sequence:** 08_demo_video | **Autonomy:** medium

## Objective

Write a complete 2-minute demo script at `docs/demo-script.md` in the dashboard project. The script covers the entire multi-agent economy, structured as: intro (15s), architecture overview (20s), live dashboard walkthrough (60s), key highlights (20s), closing (5s). Include talking points and screen transitions for each section.

## Requirements

- [ ] Demo script is exactly 2 minutes or under
- [ ] Five sections with allocated timing: intro (15s), architecture (20s), dashboard walkthrough (60s), highlights (20s), closing (5s)
- [ ] Talking points for each section (word-for-word script or detailed bullet points)
- [ ] Screen transitions noted (what to show on screen during each section)
- [ ] No dead time > 5 seconds anywhere in the script
- [ ] Document saved at `projects/dashboard/docs/demo-script.md`

## Implementation

### Step 1: Write Section 1 - Intro (15 seconds)

**Screen**: Dashboard landing page with all panels visible

**Talking Points** (write 2-3 sentences that can be said in 15 seconds):

- Name the project
- State the core concept in one sentence (e.g., "a multi-agent economy where AI agents coordinate, infer, trade, and pay each other using Hedera and Base")
- Mention the bounty tracks being targeted

### Step 2: Write Section 2 - Architecture Overview (20 seconds)

**Screen**: Architecture diagram (from README or a prepared slide), then transition to dashboard

**Talking Points** (write 3-4 sentences for 20 seconds):

- Describe the three agents and their roles (coordinator, inference, DeFi)
- Explain how they communicate (HCS) and pay (HTS)
- Mention the technology stack: Hedera native services, 0G Compute, Base chain

### Step 3: Write Section 3 - Live Dashboard Walkthrough (60 seconds)

This is the main section. Walk through each dashboard panel:

**Screen**: Dashboard, switching focus to each panel

**Sub-sections** (12 seconds each for 5 panels):

1. **Agent Status Panel (12s)**: Show all three agents online, explain heartbeat mechanism
2. **HCS Message Feed (12s)**: Show live messages, explain a task assignment message
3. **Task Activity (12s)**: Show a task lifecycle from assignment to completion
4. **DeFi Trading (12s)**: Show trade activity, mention profitability
5. **System Overview (12s)**: Show aggregate metrics, total trades, uptime

For each sub-section: what to click/highlight on screen, what to say, timing

### Step 4: Write Section 4 - Key Highlights (20 seconds)

**Screen**: Dashboard or prepared highlights slide

**Talking Points** (3-4 key differentiators):

- "All coordination happens natively on Hedera -- no Solidity, no EVM for messaging or payments"
- "Inference runs on decentralized GPUs via 0G Compute"
- "The DeFi agent is self-sustaining -- revenue from trades exceeds costs"
- "Agent identity and attribution are on-chain via ERC-8004 and ERC-8021"

### Step 5: Write Section 5 - Closing (5 seconds)

**Screen**: Dashboard or project repo

**Talking Points** (1 sentence):

- Thank judges, reference the repo URL and documentation

### Step 6: Time the script

Read the entire script aloud with a timer. Each section must fit within its allocated time. If any section runs over, trim the talking points. If any section has dead time > 5 seconds, add content or adjust the pace.

### Step 7: Note screen transitions

Create a transition table:

| Time | Screen Content | Action | Talking Point |
|------|---------------|--------|---------------|
| 0:00 | Dashboard landing | None | Intro |
| 0:15 | Architecture diagram | Click/switch | Architecture |
| 0:35 | Dashboard - Agent panel | Click panel | Walkthrough start |
| ... | ... | ... | ... |

## Done When

- [ ] Demo script written with all five sections
- [ ] Talking points are detailed enough to read verbatim
- [ ] Screen transitions documented in a transition table
- [ ] Total time is 2 minutes or under
- [ ] No dead time > 5 seconds
- [ ] Script timed by reading aloud
- [ ] Document saved at `projects/dashboard/docs/demo-script.md`
