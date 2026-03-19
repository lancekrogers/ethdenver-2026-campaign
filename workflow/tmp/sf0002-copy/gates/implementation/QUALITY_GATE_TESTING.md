---
# Template metadata (for fest CLI discovery)
id: QUALITY_GATE_TESTING
aliases:
  - testing-verify
  - qg-test
description: Standard quality gate task for testing and verification

# Fest document metadata (becomes document frontmatter)
fest_type: gate
fest_id: {{ .GateID }}
fest_name: Testing and Verification
fest_parent: {{ .SequenceID }}
fest_order: {{ .TaskNumber }}
fest_gate_type: testing
fest_status: pending
fest_tracking: true
fest_created: {{ .created_date }}
---

# Task: Testing and Verification

**Task Number:** <no value> | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify the work in this sequence through automated checks plus a real runtime-oriented integration pass.

## Requirements

- [ ] All relevant Go tests pass
- [ ] Festival structure validates cleanly
- [ ] Manual testing confirms the sequence's user-visible behavior
- [ ] Error cases are handled correctly
- [ ] Edge cases are addressed or explicitly documented

## Test Categories

### Unit Tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
```

**Verify:**

- [ ] All new or modified Go code has meaningful coverage
- [ ] Test names describe the behavior they verify
- [ ] No sequence-specific regression is introduced

### Integration Tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/festivals/planning/synthesis-fest-ritual-runtime-SF0002
fest validate
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
```

**Verify:**

- [ ] Festival artifacts and runtime code agree on file paths and contracts
- [ ] Components work together correctly across campaign root and `agent-defi`
- [ ] The sequence can be exercised without hidden manual steps

### Manual Verification

Walk through the core claims from the sequence:

1. [ ] The sequence's primary deliverable exists in the expected file or runtime path.
2. [ ] The resulting behavior matches the runtime design spec.
3. [ ] Failures are visible and do not silently fall back to a synthetic path.

## Coverage Requirements

- Minimum coverage: 70% for new helper code or a documented reason if higher-value integration coverage is used instead

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./... -coverprofile=coverage.out
go tool cover -func=coverage.out
```

## Error Handling Verification

- [ ] Invalid inputs are rejected gracefully
- [ ] Error messages are clear and actionable
- [ ] Errors do not expose sensitive information
- [ ] Recovery or fail-closed paths work correctly

## Definition of Done

- [ ] All automated tests pass
- [ ] Manual verification complete
- [ ] Coverage meets the target or is explicitly justified
- [ ] Error handling verified
- [ ] No regressions introduced

## Notes

Document any test gaps, flaky checks, or areas needing follow-up here.

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Integration tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
