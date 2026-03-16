---
fest_type: sequence
fest_id: 05_submission
fest_name: submission
fest_parent: 001_IMPLEMENT
fest_order: 5
fest_status: completed
fest_created: 2026-03-13T19:19:52.055474-06:00
fest_updated: 2026-03-15T19:52:21.940339-06:00
fest_tracking: true
---


# Sequence Goal: 05_submission

**Sequence:** 05_submission | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-13T19:19:52-06:00

## Sequence Objective

**Primary Goal:** Build an observer CLI for vault monitoring and prepare all submission artifacts (demo recording, conversation logs, metadata) for the Synthesis hackathon.

**Contribution to Phase Goal:** This sequence produces the deliverables that judges will evaluate. The observer CLI demonstrates transparency (real-time vault state), and the submission package proves the agent works end-to-end with on-chain evidence.

## Working Directory

**Primary:** `projects/agent-defi/` (relative to campaign root)
**Absolute:** `/Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi/`

> **IMPORTANT:** Before executing ANY command in this sequence, navigate to the working directory first:
> ```bash
> cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi/
> ```
> Observer CLI and submission artifacts operate from this directory. Run `cd projects/agent-defi` before any `go` command.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Observer CLI**: Go CLI tool (`cmd/observer/main.go`) showing vault state, USDC balance, NAV, share price, held tokens, and trade history
- [ ] **Submission Package**: Demo recording showing agent registration, deposit, autonomous trading, boundary enforcement, and exit at NAV; conversation logs; submission metadata with on-chain artifact references

### Quality Standards

- [ ] **Observer Output**: CLI displays accurate real-time vault data from on-chain state
- [ ] **Demo Completeness**: Recording covers all 6 demo checkpoints (register, deposit, trade, on-chain rationale, boundary rejection, exit)

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_observer_cli | CLI tool showing vault state, NAV, trade history | Provides transparency tool for demo and ongoing monitoring |
| 02_submission_prep | Demo recording, conversation logs, metadata | Produces the final hackathon submission package |

## Dependencies

### Prerequisites (from other sequences)

- 02_agent_runtime: VaultClient interface for observer to read vault state
- 04_deploy_integrate: Deployed vault addresses and on-chain trade history for demo

### Provides (to other sequences)

- Final hackathon submission: Terminal deliverable

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Observer can't read on-chain state reliably | Low | Med | VaultClient already tested, observer is a thin wrapper |
| Demo recording fails to capture key moments | Med | Med | Script the demo flow, practice before recording |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Observer CLI compiles and displays vault state from testnet (Task 1)
- [ ] **Milestone 2**: Complete submission package with demo, logs, and metadata (Task 2)

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] Performance benchmarks met

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed
- [ ] Standards compliance verified

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A