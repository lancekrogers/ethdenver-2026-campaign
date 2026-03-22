---
fest_type: task
fest_id: 01_implement_ping_and_session_create_responses.md
fest_name: implement ping and session create responses
fest_parent: 03_daemon_mock
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.12355-06:00
fest_updated: 2026-03-22T16:23:44.595649-06:00
fest_tracking: true
---


# Task: Implement Ping and Session Create Responses

## Objective

Implement the RPC handlers for Ping and SessionCreate that return realistic responses without creating real agent sessions.

## Requirements

- [ ] Ping handler returns version info and "healthy" status
- [ ] SessionCreate handler returns a generated UUID session ID without starting any real process
- [ ] SessionSend handler (if called) returns success without executing anything
- [ ] Responses match the proto message format the real daemon uses

## Implementation

1. Ping response: `{version: "mock-0.1.0", status: "healthy"}`
2. SessionCreate response: generate a UUID, store it in a map, return `{session_id: uuid}`
3. SessionSend response: return `{ok: true}` — the mock doesn't execute prompts
4. Log all RPC calls with slog for debugging

## Done When

- [ ] All requirements met
- [ ] Agent vault-agent can call `obey session create` against the mock and get a session ID back
- [ ] Agent vault-agent can call `obey session send` against the mock without error