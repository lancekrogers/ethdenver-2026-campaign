---
# Template metadata (for fest CLI discovery)
id: QUALITY_GATE_REVIEW
aliases:
  - code-review
  - qg-review
description: Standard quality gate task for code review

# Fest document metadata (becomes document frontmatter)
fest_type: gate
fest_id: {{ .GateID }}
fest_name: Code Review
fest_parent: {{ .SequenceID }}
fest_order: {{ .TaskNumber }}
fest_gate_type: review
fest_status: pending
fest_tracking: true
fest_created: {{ .created_date }}
---

# Task: Code Review

**Task Number:** <no value> | **Parallel Group:** None | **Dependencies:** Testing and Verification | **Autonomy:** low

## Objective

Review all changes in this sequence for quality, correctness, and adherence to the runtime design and campaign standards.

## Review Checklist

### Code Quality

- [ ] Code is readable and well-organized
- [ ] Functions and methods stay focused
- [ ] No unnecessary complexity was introduced
- [ ] Naming is clear and consistent
- [ ] Comments explain why, not what

### Architecture & Design

- [ ] Changes align with `workflow/design/2026-03-18-synthesis-fest-ritual-runtime/README.md`
- [ ] No duplicate fest engine logic was introduced into `agent-defi`
- [ ] Dependencies are appropriate and explicit
- [ ] Interfaces are clean and focused
- [ ] No unnecessary duplication remains

### Standards Compliance

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
gofmt -l .
go vet ./...
```

- [ ] Formatting is consistent
- [ ] Vet or equivalent static checks pass
- [ ] Project conventions are followed

### Error Handling

- [ ] Errors are handled appropriately
- [ ] Error messages are useful
- [ ] No obvious panic or crash paths remain
- [ ] Resources and subprocess results are cleaned up correctly

### Security Considerations

- [ ] No secrets are introduced into tracked files
- [ ] Input validation is present where runtime config is parsed
- [ ] Command execution uses explicit arguments and trusted paths
- [ ] Daemon/session handling does not weaken auth boundaries

### Performance

- [ ] No obvious runtime stalls or unbounded waits remain
- [ ] Polling and timeout behavior are reasonable
- [ ] Large file scans or subprocess calls are justified
- [ ] Logging remains useful without becoming noisy

### Testing

- [ ] Tests are meaningful
- [ ] Edge cases are covered
- [ ] Manual checks map to the sequence goal
- [ ] Runtime claims are backed by evidence, not assumptions

## Review Process

1. Read the sequence goal and design spec.
2. Review each modified file.
3. Re-run the relevant checks.
4. Document findings and follow-up actions.

## Findings

### Critical Issues (Must Fix)

1. [ ] [Issue description and recommendation]

### Suggestions (Should Consider)

1. [ ] [Suggestion and rationale]

### Positive Observations

- [Note strong patterns or clean integrations observed]

## Definition of Done

- [ ] All files reviewed
- [ ] Formatting and vet checks pass
- [ ] No critical issues remain
- [ ] Suggestions documented
- [ ] Knowledge shared with the team if needed

## Review Summary

**Reviewer:** [Name/Agent]
**Date:** [Date]
**Verdict:** [ ] Approved / [ ] Needs Changes

**Notes:**
[Summary of the review and any outstanding concerns]
