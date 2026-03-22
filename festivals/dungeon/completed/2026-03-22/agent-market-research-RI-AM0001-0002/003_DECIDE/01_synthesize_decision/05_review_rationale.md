---
fest_type: task
fest_id: 05_review_rationale
fest_parent: 01_synthesize_decision
fest_order: 5
fest_status: completed
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-19T01:29:11.870957-06:00
---


# Review Rationale Quality

Evaluate whether the decision rationale is genuinely auditable — would a judge, a depositor, or another agent reading this rationale understand exactly why this decision was made?

## Review Criteria

### Specificity (the rationale must answer these questions)

- [ ] **What did the agent see?** — Specific price, deviation %, moving average value
- [ ] **What risks did it evaluate?** — Per-gate CRE results with pass/fail and specific thresholds
- [ ] **What would it cost?** — Uniswap fee, gas, estimated slippage in dollar terms
- [ ] **What would it earn?** — Expected reversion profit in dollar terms
- [ ] **Why this size?** — How the position size was calculated (confidence × max, adjusted for volatility)

### Anti-Patterns (any of these = FAIL)

- [ ] No vague language: "market looks good", "conditions are favorable", "risk is acceptable"
- [ ] No missing numbers: "confidence is high" without stating 0.72
- [ ] No cherry-picking: only mentioning passed gates while hiding failed ones
- [ ] No circular reasoning: "decided to buy because the signal says buy"
- [ ] No post-hoc rationalization: rationale must trace to pre-decision research, not be invented after

### Auditability Test

Could someone who has NEVER seen this system:
- [ ] Understand what data the agent looked at?
- [ ] Verify the decision logic by checking the numbers themselves?
- [ ] Identify which specific conditions would have changed the decision?
- [ ] Determine whether the agent followed its own rules?

If any answer is "no", the rationale needs improvement.

This is a self-review step for the executing agent. Do not wait for an external reviewer before writing `results/rationale_review.md`.

## If Review Fails

- Document specific deficiencies in `results/rationale_review.md`
- Cite the exact phrases that are vague, missing, or circular
- Suggest specific improvements (e.g., "replace 'risk is low' with 'risk score 42 below 75 threshold'")
- Do NOT rewrite the rationale — flag for iteration in task 06

## Done When

- [ ] All specificity criteria met
- [ ] No anti-patterns present
- [ ] Auditability test passes
- [ ] `results/rationale_review.md` written with PASS or FAIL + details