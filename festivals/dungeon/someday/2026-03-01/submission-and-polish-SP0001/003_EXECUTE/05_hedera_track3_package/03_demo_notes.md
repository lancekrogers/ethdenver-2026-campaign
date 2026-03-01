---
fest_type: task
fest_id: 03_demo_notes.md
fest_name: demo_notes
fest_parent: 05_hedera_track3_package
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_updated: 2026-02-21T12:06:45.45805-07:00
fest_tracking: true
---


# Task: Write Demo Notes for Hedera Track 3

**Task Number:** 03 | **Sequence:** 02_hedera_track3_package | **Autonomy:** medium

## Objective

Write demo notes at `docs/demo-notes.md` in the agent-coordinator project. These notes provide the Hedera Track 3 demo script: what to show judges, in what order, and the key talking points that highlight native Hedera service usage.

## Requirements

- [ ] Demo structure defined with timed sections
- [ ] Key talking points for each section emphasizing Hedera Track 3 alignment
- [ ] Visual cues noted (what should be on screen during each talking point)
- [ ] Hedera-specific highlights called out (HCS messages, HTS transfers, topic IDs, transaction hashes)
- [ ] Document saved at `projects/agent-coordinator/docs/demo-notes.md`

## Implementation

### Step 1: Define the demo structure

The demo notes should follow this structure (times are for the Hedera Track 3 portion of the overall demo):

1. **Opening (10s)**: Introduce the agent-coordinator and its role in the multi-agent economy
2. **HCS Messaging (20s)**: Show live HCS messages flowing between agents on the dashboard
3. **Task Lifecycle (20s)**: Walk through a single task from assignment to completion, highlighting HCS state transitions
4. **HTS Payment (15s)**: Show a payment settling via HTS, reference the transaction on HashScan
5. **Key Differentiator (10s)**: Emphasize that all coordination uses native Hedera services (no Solidity, no EVM)

### Step 2: Write talking points for each section

For each section, write 2-3 bullet points of what to say. Keep language concise and jargon-free. Judges may not be Hedera experts.

Example talking points:

- "The coordinator assigns tasks to agents using Hedera Consensus Service messages -- every task assignment is an immutable, timestamped record on Hedera's public ledger"
- "Payments between agents use Hedera Token Service -- native, fast, and verifiable on HashScan"

### Step 3: Note visual cues

For each section, note what should be visible on screen:

- Dashboard panel showing HCS message feed
- Dashboard panel showing agent status (heartbeats)
- HashScan transaction page for an HTS transfer
- Terminal showing agent logs (optional, if time permits)

### Step 4: Highlight Hedera-specific features

Call out what makes this a "native Hedera" project:

- HCS (not a custom P2P layer)
- HTS (not ERC-20 on EVM)
- Hedera Go SDK (not web3.js or ethers)
- Topic IDs and transaction IDs verifiable on HashScan
- No Solidity contracts required for coordination or payment

## Done When

- [ ] Demo structure defined with timing for each section
- [ ] Talking points written for every section
- [ ] Visual cues documented
- [ ] Hedera-specific highlights explicitly called out
- [ ] Document saved at `projects/agent-coordinator/docs/demo-notes.md`