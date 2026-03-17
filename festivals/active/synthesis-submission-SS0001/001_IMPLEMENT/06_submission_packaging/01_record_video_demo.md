---
fest_type: task
fest_id: 01_record_video_demo.md
fest_name: record video demo
fest_parent: 06_submission_packaging
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-16T21:39:51.88066-06:00
fest_tracking: true
---

# Task: Record Video Demo

## Objective

Record a ~3 minute video demo covering 6 checkpoints that showcases the full OBEY system for hackathon judges.

## Requirements

- [ ] Video covers all 6 checkpoints from the demo script
- [ ] Video is approximately 3 minutes long
- [ ] All on-chain evidence shown uses real TxIDs (Basescan links)
- [ ] Dashboard is used as the visual anchor

## Implementation

**Full demo script is in:** `workflow/explore/synthesis/00-project-design.md` — Section 8 "Demo Script"

### Pre-stage (before recording)

1. Open Basescan tabs for ALL mainnet transactions from sequence 03:
   - Vault deployment tx
   - setApprovedToken tx
   - USDC deposit tx
   - Each SwapExecuted tx (2-3 trades)
   - ERC-8004 registration tx (`0x9b31bd...` on Base Sepolia, or mainnet equivalent)
2. Start dashboard locally: `just demo` or `cd projects/dashboard && npm run dev`
3. Open terminal at campaign root, run `fest status` to verify festival hierarchy is visible
4. Open `agent.json` and `agent_log.json` in editor (from sequence 02 output)

### Record (6 checkpoints, ~30 seconds each)

- **Checkpoint 1 — Human Sets Boundaries:** Show Basescan for vault deposit + setApprovedToken + setMaxSwapSize txns. Narrate: "Human deposits USDC, sets spending rules. Agent can never break these."
- **Checkpoint 2 — Agent Identity:** Show ERC-8004 AgentRegistered event on Basescan. Show agent.json manifest. Narrate: "Agent has an on-chain identity."
- **Checkpoint 3 — Festival Plan:** Show `fest status` output in terminal. Show the ritual structure (INGEST → RESEARCH → DECIDE). Narrate: "Every decision follows a structured framework."
- **Checkpoint 4 — Trading Loop:** Show a complete ritual execution — market data ingested, CRE gates evaluated (show per-gate pass/fail), vault enforces boundaries, real Uniswap swap TxID on Basescan. Narrate: "Discover, plan, execute — with 8 safety gates."
- **Checkpoint 5 — Verification:** Show agent_log.json entry for the trade — expected vs actual fill, slippage. Narrate: "Every decision is auditable."
- **Checkpoint 6 — Dashboard:** Show all 6 panels. Narrate: "Full audit trail in one view."

### Post-record

1. Review — if any checkpoint is unclear or longer than 40 seconds, re-record that section
2. Export as MP4
3. Upload to YouTube (unlisted) or Loom
4. Record the URL for submission tasks

## Done When

- [ ] All requirements met
- [ ] Video recorded covering all 6 checkpoints
- [ ] Video is under 4 minutes
- [ ] Video URL or file path recorded for submission use
