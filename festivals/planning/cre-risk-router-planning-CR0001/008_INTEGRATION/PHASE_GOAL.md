---
fest_type: phase
fest_id: 008_INTEGRATION
fest_name: INTEGRATION
fest_parent: cre-risk-router-planning-CR0001
fest_order: 8
fest_status: pending
fest_created: 2026-03-01T17:42:33.45878-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 006_INTEGRATION

**Phase:** 006_INTEGRATION | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Bridge the CRE Risk Router to the existing Obey Agent Economy for competitive edge, adding a coordinator CRE client, structured inference signal fields, DeFi execution guard, and HCS message types.

**Context:** This is a P1 phase that only starts if P0 (Phases 001-005) is stable and submitted. It backs up the "real agent economy" claim by integrating the CRE workflow with agent-coordinator, agent-inference, and agent-defi. This gives a structural advantage over other submissions by demonstrating the workflow operates inside a production-like multi-agent system spanning Hedera, 0G, and Base chains.

## Required Outcomes

Deliverables this phase must produce:

- [ ] `client.go` + `models.go` in `agent-coordinator/internal/chainlink/cre/` implementing HTTP client to CRE Risk Router
- [ ] `assign.go` wired to check CRE risk before task assignment; denied decisions produce `quality_gate` event
- [ ] Inference agent task results include `signal`, `signal_confidence`, `risk_score`, `explanation_hash` fields
- [ ] DeFi agent trading strategy enforces CRE constraints (position/slippage caps) when present, falls back to local strategy when absent (backwards compatible)
- [ ] HCS message types added: `cre_simulation`, `cre_decision`, `cre_execution_receipt`

## Quality Standards

Quality criteria for all work in this phase:

- [ ] CRE client is a thin HTTP bridge with proper error handling and timeout
- [ ] All integration changes are backwards compatible -- agents work without CRE configured
- [ ] Signal fields match the exact types the CRE workflow expects as input
- [ ] HCS message types follow existing message type patterns in the codebase

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_coordinator_bridge | Add CRE client to agent-coordinator for pre-assignment risk checks | `client.go`, `models.go`, wired `assign.go` |
| 02_agent_signals | Add structured signal fields to inference and DeFi agents, plus HCS message types | Updated agent payloads + new HCS message types |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_coordinator_bridge
- [ ] 02_agent_signals

## Notes

This phase modifies existing repos (agent-coordinator, agent-inference, agent-defi) rather than the cre-risk-router project. All changes must be backwards compatible. Only proceed if P0 submission is stable and published. Requirements traced: P1.1-P1.4.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
