---
fest_type: task
fest_id: 02_architecture_doc.md
fest_name: architecture_doc
fest_parent: 05_hedera_track3_package
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_updated: 2026-02-21T12:06:29.470781-07:00
fest_tracking: true
---


# Task: Write Architecture Documentation

**Task Number:** 02 | **Sequence:** 02_hedera_track3_package | **Autonomy:** medium

## Objective

Write a detailed architecture document at `docs/architecture.md` in the agent-coordinator project. This document provides technical depth for Hedera Track 3 judges who want to understand the system design beyond the README overview. It must cover HCS messaging flow, HTS payment cycle, coordinator state machine, and the agent communication protocol.

## Requirements

- [ ] HCS messaging flow documented with message types and topic structure
- [ ] HTS payment cycle documented with token transfer flow and fee model
- [ ] Coordinator state machine documented with all states and transitions
- [ ] Agent communication protocol documented with message envelope format
- [ ] Diagrams included for each major subsystem
- [ ] Document saved at `projects/agent-coordinator/docs/architecture.md`

## Implementation

### Step 1: Write the HCS Messaging Flow section

Document how agents communicate through HCS:

- **Topic Structure**: What topics exist, what each topic is used for (e.g., task-assignments topic, status-updates topic, heartbeat topic)
- **Message Flow**: For each operation (task assignment, status update, result delivery), show the message path from sender to receiver through HCS topics
- **Message Format**: Reference the Envelope struct with field descriptions
- **Ordering Guarantees**: Explain what ordering HCS provides and how the system handles out-of-order messages (sequence numbers)
- **Diagram**: Sequence diagram showing a complete message exchange for a task lifecycle

### Step 2: Write the HTS Payment Cycle section

Document how payments flow between agents:

- **Token Model**: What tokens are used (HBAR, custom fungible tokens), token IDs
- **Payment Triggers**: What events trigger a payment (task completion, trade profit, service fee)
- **Transfer Flow**: Step-by-step from payment trigger to confirmed transfer
- **Fee Model**: Gas costs, network fees, and any application-level fees
- **Diagram**: Flow diagram showing payment from DeFi agent profit through coordinator to inference agent

### Step 3: Write the Coordinator State Machine section

Document the coordinator's internal state machine:

- **States**: List all coordinator states (idle, assigning, monitoring, settling, error)
- **Transitions**: What triggers each state transition
- **Error States**: How the coordinator enters error states and how it recovers
- **Diagram**: State diagram showing all states and transitions with trigger labels

### Step 4: Write the Agent Communication Protocol section

Document the higher-level protocol that agents follow:

- **Registration**: How an agent registers with the coordinator
- **Heartbeat**: How agents signal liveness, timeout thresholds
- **Task Lifecycle**: From assignment through completion and payment
- **Error Handling**: How protocol errors are communicated and resolved
- **Extensibility**: How new agent types or message types can be added

### Step 5: Review and cross-reference

- Cross-reference with the README (no contradictions)
- Cross-reference with the actual code (architecture doc must match implementation)
- Verify all diagram references are rendered correctly in Markdown

## Done When

- [ ] Document covers all four subsystems (HCS flow, HTS payments, state machine, protocol)
- [ ] Each subsystem has at least one diagram
- [ ] Document is technically accurate (matches the code)
- [ ] No contradictions with README
- [ ] Saved at `projects/agent-coordinator/docs/architecture.md`