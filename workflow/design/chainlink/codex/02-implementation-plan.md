# 02 - Implementation Plan (March 1 to March 8, 2026)

## Deadline Context

- Current date for this plan: **Sunday, March 1, 2026**
- Submission cutoff from requirement doc: **Sunday, March 8, 2026 at 11:59 PM ET**

This is a 7-day delivery plan focused on shipping a high-confidence `#cre-ai` entry.

## Delivery Strategy

Ship in this order:

1. CRE simulation + decision path in coordinator
2. DeFi execution gate from CRE decision
3. On-chain receipt write
4. Dashboard evidence view
5. Submission packaging

## Day-by-Day Plan

| Date | Priority | Output |
|---|---|---|
| Mar 1 (Sun) | P0 | Finalize feature contracts + message schema (`cre_simulation`, `cre_decision`, `cre_execution_receipt`) |
| Mar 2 (Mon) | P0 | Coordinator CRE adapter + simulation command wrapper + decision publish path |
| Mar 3 (Tue) | P0 | Inference structured signal fields + DeFi decision gate + parameter enforcement |
| Mar 4 (Wed) | P0 | Workflow receipt contract + deploy script + first successful on-chain write |
| Mar 5 (Thu) | P1 | Dashboard CRE panel and timeline events |
| Mar 6 (Fri) | P1 | Scenario bank (`cre simulate`) + reproducibility artifacts |
| Mar 7 (Sat) | P0 | Full end-to-end dry run + evidence capture + post draft |
| Mar 8 (Sun) | P0 | Final verification, publish Moltbook post before 11:59 PM ET |

## Workstream Breakdown

## WS1 - Coordinator CRE Integration

**Target repo:** `projects/agent-coordinator`

Tasks:

- Add `internal/chainlink/cre/client.go`
- Add `internal/chainlink/cre/models.go` for simulation/decision payloads
- Wire adapter in `cmd/coordinator/main.go`
- Call simulation before assignment in `internal/coordinator/assign.go`
- Emit simulation/decision events via HCS envelope

Done criteria:

- One command invocation path runs `cre simulate ...` per task intent
- Coordinator can block execution when simulation fails

## WS2 - Agent Payload Upgrades

**Target repos:** `projects/agent-inference`, `projects/agent-defi`

Tasks:

- Inference adds structured signal fields to result payload
- DeFi validates CRE decision envelope before trade execution
- Add timeout/TTL validation for stale decisions

Done criteria:

- DeFi refuses trade when CRE decision is absent/expired
- Logs clearly show "decision approved/rejected" reason

## WS3 - On-Chain Proof Write

**Target repo:** `projects/contracts` (+ coordinator writer hook)

Tasks:

- Implement `ChainlinkWorkflowReceipt.sol`
- Add deploy script and integration call
- Record at least one successful `recordRun(...)` write on CRE-supported testnet

Done criteria:

- Transaction hash captured
- Event log includes run ID + decision hash

## WS4 - Dashboard Evidence

**Target repo:** `projects/dashboard`

Tasks:

- Extend event types with CRE-specific states
- Add CRE panel showing:
  - simulation ID/status
  - decision status
  - linked receipt tx hash

Done criteria:

- Judges can see full flow without reading terminal logs

## WS5 - Submission Packaging

Tasks:

- Archive command output for one-shot simulation
- Save tx hash and explorer link for on-chain write
- Produce short video/demo pass
- Prepare Moltbook post in exact required format

Done criteria:

- All required evidence exists in one review checklist

## Required Artifacts Checklist

1. `cre simulate ...` command and output artifact
2. One successful execution trace showing:
   - input signal
   - CRE decision
   - gated DeFi action
3. On-chain write tx hash for run receipt
4. Screenshot/video of dashboard CRE timeline
5. Final post text matching title/body hashtag constraints

## Suggested Simulation Scenarios

1. `bullish_high_confidence`: expected trade approved
2. `bearish_high_risk`: expected trade denied
3. `stale_signal`: expected denial due TTL/data freshness
4. `low_liquidity`: expected constrained position size

## Risk Register

| Risk | Impact | Mitigation |
|---|---|---|
| CRE tooling friction | blocks simulation requirement | keep CLI wrapper thin; validate with smallest workflow first |
| Testnet instability | blocks on-chain proof | produce write early (Mar 4) and keep fallback window |
| Scope creep into extra hashtags | delays shipping | lock P0 to `#cre-ai`; treat others as stretch only |
| Dashboard lag | weak demo clarity | keep simple CRE timeline card, no complex chart dependency |

## Exit Criteria (March 8)

Submission-ready when all are true:

1. CRE simulation is reproducible from command line.
2. At least one on-chain receipt is written and verifiable.
3. End-to-end flow is demonstrated with current agent economy components.
4. Moltbook post is compliant and published before cutoff.
