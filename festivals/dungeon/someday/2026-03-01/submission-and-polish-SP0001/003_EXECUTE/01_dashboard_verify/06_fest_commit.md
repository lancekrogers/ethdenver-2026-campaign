---
fest_type: gate
fest_id: 06_fest_commit.md
fest_name: fest_commit
fest_parent: 01_dashboard_verify
fest_order: 6
fest_status: pending
fest_gate_type: fest_commit
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Gate: Fest Commit

## Objective

Commit all changes from this sequence. Update sequence and task statuses to reflect completion.

## Pre-Commit Checklist

- [ ] `next build` still passes (run one final time before committing)
- [ ] `.env.local` is NOT staged — confirm it is gitignored
- [ ] All modified source files are staged
- [ ] Festival task files updated to `fest_status: complete` where appropriate

## Commit

Use the campaign commit command which stages everything automatically:

```bash
camp commit -m "[SP0001] 01_dashboard_verify: dashboard build verified, live Hedera data configured"
```

Adjust the message to reflect what actually changed:
- If only build fixes: `dashboard next build passing, mock mode verified`
- If only live config: `dashboard configured for live Hedera testnet data`
- If both: use the message above

## Post-Commit

- [ ] Update `SEQUENCE_GOAL.md` `fest_status` to `complete`
- [ ] Confirm downstream sequences `04_e2e_testing` and `11_demo_video` are unblocked
- [ ] Note any remaining issues or caveats in the sequence goal for the next agent

## Pass Criteria

Commit created. No secrets committed. Sequence status updated to complete.
