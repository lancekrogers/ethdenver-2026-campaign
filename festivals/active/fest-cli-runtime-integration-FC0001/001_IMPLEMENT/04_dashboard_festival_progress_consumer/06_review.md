---
fest_type: gate
fest_id: 06_review.md
fest_name: Code Review
fest_parent: 04_dashboard_festival_progress_consumer
fest_order: 6
fest_status: completed
fest_autonomy: low
fest_gate_type: review
fest_created: 2026-03-06T13:39:01.57045-07:00
fest_updated: 2026-03-06T15:49:49.56677-07:00
fest_tracking: true
---


# Task: Code Review

**Task Number:** 06 | **Dependencies:** 05_testing | **Autonomy:** low

## Objective
Review dashboard changes for correctness, UI clarity, and backward compatibility.

## Review Scope

- `src/lib/data/types.ts`
- `src/hooks/useMirrorNode.ts`
- `src/components/panels/FestivalView.tsx`
- `src/components/panels/__tests__/FestivalView.test.tsx`

## Review Checklist

- [ ] Event/payload types are coherent and minimal.
- [ ] Parser branches are deterministic and safe.
- [ ] Source badge is clear but unobtrusive.
- [ ] Legacy payload path is preserved.

## Done When

- [ ] No unresolved high-severity findings
- [ ] Findings (if any) routed to 07_iterate