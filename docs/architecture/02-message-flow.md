# Message Flow

The full task lifecycle as agents coordinate over Hedera Consensus Service, from task assignment through inference, risk evaluation, DeFi execution, and payment settlement.

## Task Lifecycle Sequence

```mermaid
sequenceDiagram
    participant COORD as Coordinator
    participant HCS_T as HCS Task Topic
    participant INF as Inference Agent
    participant HCS_S as HCS Status Topic
    participant CRE as CRE Bridge
    participant DEFI as DeFi Agent
    participant HTS as HTS (AGNT)

    Note over COORD: Reads festival plan<br/>phases → sequences → tasks

    COORD->>HCS_T: task_assignment (inference task)
    HCS_T->>INF: subscribe → receives task

    Note over INF: 0G Pipeline:<br/>discover → infer → store → mint → audit

    INF->>HCS_S: task_result {signal_confidence, risk_score}
    HCS_S->>COORD: subscribe → receives result

    Note over COORD: Quality gate validation

    COORD->>CRE: POST /evaluate-risk {signal, confidence, risk_score}

    alt CRE Approved
        CRE-->>COORD: {Approved: true, MaxPositionUSD, MaxSlippageBps, TTL}
        COORD->>HCS_T: task_assignment (execute_trade) + cre_decision
        HCS_T->>DEFI: subscribe → receives trade task

        Note over DEFI: CREGuard enforces constraints<br/>Uniswap V3 exactInputSingle

        DEFI->>HCS_S: task_result {tx_hash, status}
        HCS_S->>COORD: subscribe → receives trade result

        COORD->>HTS: TransferTransaction (AGNT → INF)
        COORD->>HTS: TransferTransaction (AGNT → DEFI)
        COORD->>HCS_T: payment_settled {tx_hash}
    else CRE Denied
        CRE-->>COORD: {Approved: false, Reason: "..."}
        Note over COORD: Logs denial, no DeFi task issued
    end
```

## Envelope Wire Format

All agents serialize JSON `Envelope` structs to HCS topics:

```mermaid
classDiagram
    class Envelope {
        +string type
        +string sender
        +string recipient
        +string task_id
        +uint64 sequence_num
        +time timestamp
        +json payload
    }
    note for Envelope "Recipient filtering: agents skip\nenvelopes where recipient != ''\nand recipient != myAgentID"
```

### Message Types

| Type | Publisher | Subscriber | Topic |
|------|-----------|------------|-------|
| `task_assignment` | Coordinator | Inference, DeFi | Task |
| `task_result` | Inference, DeFi | Coordinator | Status |
| `status_update` | Inference, DeFi | Coordinator | Status |
| `heartbeat` | Inference, DeFi | Coordinator | Status |
| `pnl_report` | DeFi | Coordinator | Status |
| `quality_gate` | Coordinator | — | Task |
| `payment_settled` | Coordinator | — | Task |
| `risk_check_requested` | Coordinator | CRE | Task |
| `risk_check_approved` | CRE | Coordinator | Task |
| `risk_check_denied` | CRE | Coordinator | Task |

## Task State Machine

```mermaid
stateDiagram-v2
    [*] --> pending
    pending --> assigned: coordinator publishes task_assignment
    assigned --> in_progress: agent picks up task
    in_progress --> review: agent publishes task_result
    review --> complete: quality gate passes
    complete --> paid: HTS transfer settled

    in_progress --> failed: execution error
    failed --> pending: retry (coordinator re-assigns)
```

## See Also

- [System Overview](./01-system-overview.md) — full system topology
- [CRE Risk Pipeline](./04-cre-risk-pipeline.md) — detailed 8-gate evaluation
- [Chain Integration](./03-chain-integration.md) — which components touch which chains
