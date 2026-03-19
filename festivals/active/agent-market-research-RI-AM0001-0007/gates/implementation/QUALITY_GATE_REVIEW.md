---
id: QUALITY_GATE_RATIONALE_REVIEW
aliases:
  - rationale-review
  - qg-rationale
description: Quality gate for evaluating decision rationale quality and auditability

fest_type: gate
fest_id: <no value>
fest_name: Rationale Quality Review
fest_parent: <no value>
fest_order: <no value>
fest_gate_type: rationale_review
fest_status: pending
fest_tracking: true
fest_created: 2026-03-16T21:06:06-06:00
---

# Gate: Rationale Quality Review

**Dependencies:** Decision Validation | **Autonomy:** medium

## Objective

Evaluate whether the decision rationale is genuinely auditable — could a depositor, a judge, or another agent understand exactly why this decision was made?

## Specificity Checks

The rationale must answer:

- [ ] **What did the agent see?** — Specific price, deviation %, moving average value
- [ ] **What risks were evaluated?** — Per-gate CRE results with pass/fail and thresholds
- [ ] **What would it cost?** — Uniswap fee, gas, slippage in dollar terms
- [ ] **What would it earn?** — Expected reversion profit in dollar terms
- [ ] **Why this size?** — Position sizing calculation with inputs

## Anti-Patterns (any = FAIL)

- [ ] No vague language ("market looks good", "conditions favorable", "risk acceptable")
- [ ] No missing numbers ("confidence is high" without stating the value)
- [ ] No cherry-picking (hiding failed gates, only showing positives)
- [ ] No circular reasoning ("decided to buy because signal says buy")
- [ ] No post-hoc rationalization (rationale must trace to pre-decision research)

## Auditability Test

Could someone who has NEVER seen this system:

- [ ] Understand what data the agent looked at?
- [ ] Verify the decision by checking the numbers?
- [ ] Identify what conditions would have changed the decision?
- [ ] Determine whether the agent followed its own rules?

## Output

Write `results/rationale_review.md`:
- PASS: all checks pass
- FAIL: cite the exact phrases that are vague, missing, or circular + suggest specific fixes

This review is performed by the executing agent as part of the ritual run. It must not pause for an external human reviewer.

## Definition of Done

- [ ] Specificity checks all pass
- [ ] No anti-patterns present
- [ ] Auditability test passes
- [ ] Review result documented
