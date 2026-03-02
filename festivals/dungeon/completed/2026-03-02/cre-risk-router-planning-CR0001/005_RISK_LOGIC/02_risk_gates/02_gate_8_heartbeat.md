---
fest_type: task
fest_id: 01_gate_8_heartbeat.md
fest_name: gate 8 heartbeat
fest_parent: 02_risk_gates
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:44:07.823814-07:00
fest_updated: 2026-03-02T00:59:56.637931-07:00
fest_tracking: true
---


# Task: gate 8 heartbeat

## Objective

Implement Gate 8 (Agent Heartbeat Circuit Breaker) in `risk.go` as a configurable gate that checks agent liveness via Hedera Mirror Node HTTP fetch.

## Requirements

- [ ] Gate is skipped if `config.enable_heartbeat_gate` is false (default: false) (Req P0.10)
- [ ] When enabled, fetch agent heartbeat timestamp from `config.heartbeat_mirror_node_url` via HTTP
- [ ] Deny if `(now - heartbeat_timestamp) > config.heartbeat_ttl_seconds` (default 600), reason: `agent_heartbeat_stale`

## Implementation

1. **Add `checkAgentHeartbeat` function** to `risk.go`:

   - Accept config, agent ID, current time, and a heartbeat timestamp (fetched by the handler)
   - If `!config.EnableHeartbeat`, return (true, "") immediately (skip gate)
   - If heartbeat timestamp is zero (fetch failed), deny with `agent_heartbeat_stale`
   - If `(now - heartbeatTimestamp) > config.HeartbeatTTLSec`, deny with `agent_heartbeat_stale`
   - Otherwise pass

2. **The actual HTTP fetch** to the Hedera Mirror Node happens in the handler (Phase 004). This gate function validates the returned timestamp.

3. **Disabled by default** so standalone simulation works from a clean clone without external dependencies. Enabled when connected to the live agent economy.

## Done When

- [ ] All requirements met
- [ ] Gate skips when disabled (default behavior)
- [ ] Gate denies with correct reason when heartbeat is stale
- [ ] Standalone simulation works without heartbeat configured