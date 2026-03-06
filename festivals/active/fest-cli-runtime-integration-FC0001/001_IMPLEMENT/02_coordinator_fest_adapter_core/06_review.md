---
fest_type: gate
fest_id: 06_review.md
fest_name: Code Review
fest_parent: 02_coordinator_fest_adapter_core
fest_order: 6
fest_status: completed
fest_autonomy: low
fest_gate_type: review
fest_created: 2026-03-06T13:39:01.568827-07:00
fest_updated: 2026-03-06T15:36:18.310115-07:00
fest_tracking: true
---


# Task: Code Review

**Task Number:** 06 | **Dependencies:** 05_testing | **Autonomy:** low

## Objective
Review coordinator adapter implementation for parser safety, deterministic behavior, and clean failure handling.

## Review Scope

- `internal/festival/reader.go`
- `internal/festival/messages.go`
- `internal/festival/protocol.go`
- `internal/festival/*_test.go`
- `testdata/fest/*`

## Review Checklist

- [ ] No unchecked JSON type assertions.
- [ ] All external command errors include actionable context.
- [ ] Selector resolution order matches spec.
- [ ] Tests cover malformed/empty outputs.
- [ ] No secrets or sensitive env values logged.

## Done When

- [ ] No unresolved high-severity findings
- [ ] Findings (if any) are routed to 07_iterate