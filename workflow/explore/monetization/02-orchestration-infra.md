# 02 — Orchestration Infrastructure

## Description

Offer the Agent Coordinator as a managed service. Other agent builders submit tasks, the coordinator dispatches to registered agents, enforces quality gates, records audit trails on Hedera Consensus Service, and settles payments via HTS tokens.

## What Exists Today

The coordinator (`projects/agent-coordinator/`) is a working Go service:

- **HCS messaging** — two provisioned topics on Hedera testnet (Task: `0.0.7999404`, Status: `0.0.7999405`)
- **Task dispatch** — reads festival plans, derives task graphs, publishes `task_assignment` messages
- **Task state machine** — `pending → assigned → in_progress → review → complete → paid`
- **Quality gates** — validates task completion criteria before authorizing payment
- **CRE integration** — HTTP client calls the Risk Router bridge for `defi`/`trade`/`execute_trade` tasks (fail-closed)
- **HTS payments** — custom `AGNT` fungible token, 100 AGNT per completed task via `TransferTransaction`
- **Heartbeat** — `ScheduleCreateTransaction` for agent liveness proofs (30s interval)
- **gRPC daemon connection** — sandboxed command execution with `NoopClient` fallback

## Capital Required

Low — $10-50 in HBAR for Hedera mainnet.

| Cost | Amount | Notes |
|------|--------|-------|
| Hedera mainnet account | ~$5 | One-time |
| HCS topic creation | ~$1 each | Two topics needed |
| HCS message fees | ~$0.0001/msg | Per-message (very cheap) |
| HTS token creation | ~$1 | One-time for payment token |
| VPS hosting | $5-20/mo | Coordinator service |

Total to go live: ~$30 + $10-20/mo hosting.

## Revenue Model

Per-task orchestration fee:

| Model | Price | Mechanism |
|-------|-------|-----------|
| x402 per-task | $0.01-0.10 | Charged when task is submitted |
| HTS settlement fee | 5-10% of AGNT | Deducted from agent payment |
| Subscription | $50-200/mo | Dedicated coordinator instance |

At 1,000 tasks/day at $0.05/task = $50/day = $1,500/month.

## Moat

- **HCS audit trail** — every task assignment, status update, and payment is recorded on Hedera with consensus timestamps. This is a tamper-proof operational log.
- **Quality gates** — built-in validation before payment authorization. Prevents agents from claiming completion on garbage output.
- **CRE integration** — automatic risk evaluation for financial tasks. No other orchestrator pre-checks trades against an 8-gate risk pipeline.
- **Festival methodology** — structured task planning with phases, sequences, and dependencies. More rigorous than ad-hoc task queues.

## Blockers

### Hard Blockers

1. **No external agents to orchestrate.** The coordinator currently orchestrates three agents that we built (inference, defi, coordinator itself). There are no third-party agents registered. The service needs agents to dispatch to, and those agents need to exist and be compatible.

2. **Agent compatibility.** External agents would need to implement the HCS message protocol — listen on topics, send structured JSON envelopes with `task_result`, `heartbeat`, `pnl_report` types. This is a non-trivial integration burden for potential users.

3. **Chicken-and-egg.** Agents won't register without tasks. Task submitters won't use the platform without agents. Classic marketplace cold-start problem.

### Soft Blockers

4. **Hedera ecosystem size.** The pool of builders running autonomous agents on Hedera specifically is small. Most agent activity is on EVM chains or off-chain.

5. **Festival methodology adoption.** The task planning system is tightly coupled to festival methodology, which is custom and unfamiliar to external users.

6. **AGNT token utility.** The payment token has no external value. It's a testnet token with no market. Converting orchestration fees to real revenue requires either fiat payment rails or an established token.

## Honest Assessment

The coordinator is genuinely well-built infrastructure — HCS audit trails, quality gates, and the CRE fail-closed pattern are things agent builders should want. But "should want" and "will pay for" are different.

The hard truth: most agent builders today are running single-agent setups that don't need orchestration. Multi-agent systems are still early. The teams that do run multi-agent systems tend to build their own coordination layer because the protocol design is coupled to their specific agent behavior.

The HCS audit trail is the most compelling piece — immutable, timestamped, consensus-ordered logs of every agent action. But it's a feature, not a product. Selling "auditable agent operations" is more a consulting pitch than an API business.

**Verdict: Not viable as a standalone product today. The orchestration layer adds value as part of a consulting engagement (see 05) but the standalone service has a cold-start problem with no clear solution.**
