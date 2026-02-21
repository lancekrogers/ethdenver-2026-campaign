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

**Primary Goal:** Unblock all three chains (Hedera, 0G, Base), verify the dashboard, run the full economy cycle end-to-end, package bounty evidence, and validate the system is deployment-ready via Docker.

**Context:** The ingest phase cataloged all artifacts from festivals 1-4 and the planning phase identified three blockers: dashboard needs build verification, 0G inference has an ABI mismatch in broker.go, and Base DeFi has stub trade execution. The first three sequences unblock these in parallel, then E2E testing validates the full system, bounty packaging documents everything, and Docker local testing validates containerized deployment readiness. Deployment and demo video are handled in 004_SUBMIT.

## Sequences

| Sequence | Project | Objective |
|----------|---------|-----------|
| 01_dashboard_verify | dashboard | Verify build, mock mode, configure live Hedera data sources |
| 02_unblock_0g | agent-inference | Fix serving contract ABI, test compute/storage/iNFT on Galileo |
| 03_unblock_base | agent-defi | Fix Uniswap V3 executor, identity registration, test real trades |
| 04_e2e_testing | agent-coordinator | Run full economy cycle on testnet, test failure recovery, validate profitability |
| 05_hedera_track3_package | agent-coordinator | Polish README, write architecture docs, prepare demo notes for Hedera Track 3 |
| 06_zerog_track2_package | agent-inference | Polish README, gather compute metrics for 0G Track 2 |
| 07_zerog_track3_package | agent-inference | Create iNFT showcase documentation and demo notes for 0G Track 3 |
| 08_base_package | agent-defi | Polish README, create P&L proof document for Base bounty |
| 09_hedera_track4_package | hiero-plugin | Polish README, finalize PR for Hedera Track 4 |
| 10_local_docker_test | all projects | Containerize all services, verify Docker Compose stack works locally |

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
- [ ] All services containerized with Dockerfiles and docker-compose.yml
- [ ] Docker Compose stack verified locally (all services build, start, and communicate)

## Dependencies

- 001_INGEST must be complete (artifact inventory established)
- 002_PLAN must be complete (submission strategy and checklists defined)
- Festivals 1-4 (chain-agents, dashboard, hedera-foundation, hiero-plugin) must be complete

## Notes

- Sequences are ordered by dependency: unblock chains first, then E2E testing, then per-track packaging, then Docker local verification.
- Each sequence targets one project at a time using `fest link` / `fest unlink`.
- Quality gates (testing, code review, iterate) are appended to every sequence.
- No new features. If something is broken, fix it. If something is missing, document it as a known limitation.

---

*Implementation phases use sequences with numbered tasks. Each sequence targets a single project.*
