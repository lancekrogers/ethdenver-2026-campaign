---
fest_type: phase
fest_id: 003_EXECUTE
fest_name: EXECUTE
fest_parent: submission-and-polish-SP0001
fest_order: 3
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 003_EXECUTE

**Phase:** 003_EXECUTE | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Execute end-to-end system testing, build submission packages for all five bounty tracks, deploy agents and dashboard to testnet, and record the demo video.

**Context:** The ingest phase cataloged all artifacts from festivals 1-4 and the planning phase defined the submission strategy, checklists, and deployment plan. This execute phase is where the actual work happens: running the full economy cycle, polishing documentation, gathering evidence for each bounty track, deploying for judges, and recording the demo. No new features are built here -- only verification, documentation, and submission packaging.

## Sequences

| Sequence | Project | Objective |
|----------|---------|-----------|
| 01_e2e_testing | agent-coordinator | Run full economy cycle on testnet, test failure recovery, validate profitability |
| 02_hedera_track3_package | agent-coordinator | Polish README, write architecture docs, prepare demo notes for Hedera Track 3 |
| 03_zerog_track2_package | agent-inference | Polish README, gather compute metrics for 0G Track 2 |
| 04_zerog_track3_package | agent-inference | Create iNFT showcase documentation and demo notes for 0G Track 3 |
| 05_base_package | agent-defi | Polish README, create P&L proof document for Base bounty |
| 06_hedera_track4_package | hiero-plugin | Polish README, finalize PR for Hedera Track 4 |
| 07_deploy | agent-coordinator | Deploy all agents to testnet, deploy dashboard to hosting |
| 08_demo_video | dashboard | Write demo script, rehearse, and record 2-minute demo video |

## Success Criteria

This execute phase is complete when:

- [ ] Full economy cycle tested end-to-end on testnet with documented logs
- [ ] Failure recovery tested and documented for all critical scenarios
- [ ] DeFi agent profitability validated with transaction-level P&L proof
- [ ] All six project READMEs polished with setup instructions, architecture, and bounty alignment
- [ ] Architecture documentation written for agent-coordinator
- [ ] Compute metrics gathered and documented for agent-inference
- [ ] iNFT showcase documentation created with on-chain evidence
- [ ] P&L proof document created with transaction hashes and revenue breakdown
- [ ] Hiero plugin PR finalized and ready for submission
- [ ] All three agents deployed and running on testnet
- [ ] Dashboard deployed and accessible via public URL
- [ ] Demo video recorded, under 2 minutes, uploaded with public URL

## Dependencies

- 001_INGEST must be complete (artifact inventory established)
- 002_PLAN must be complete (submission strategy and checklists defined)
- Festivals 1-4 (chain-agents, dashboard, hedera-foundation, hiero-plugin) must be complete

## Notes

- Sequences are ordered by dependency: E2E testing first (validates everything works), then per-track packaging, then deployment, then demo.
- Each sequence targets one project at a time using `fest link` / `fest unlink`.
- Quality gates (testing, code review, iterate) are appended to every sequence.
- No new features. If something is broken, fix it. If something is missing, document it as a known limitation.

---

*Implementation phases use sequences with numbered tasks. Each sequence targets a single project.*
