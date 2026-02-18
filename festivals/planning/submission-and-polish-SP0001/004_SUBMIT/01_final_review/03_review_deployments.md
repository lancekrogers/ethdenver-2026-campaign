---
fest_type: task
fest_id: 03_review_deployments.md
fest_name: review_deployments
fest_parent: 01_final_review
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Review All Deployments

**Task Number:** 03 | **Sequence:** 01_final_review | **Autonomy:** medium

## Objective

Verify all deployments are live and accessible. Agents must be running on testnet, the dashboard must be accessible via its public URL, the demo video URL must work, and all links in READMEs must resolve. This is the last check before submitting to bounty tracks.

## Requirements

- [ ] All three agents verified running on testnet
- [ ] Dashboard verified accessible at its public URL
- [ ] Demo video URL verified accessible and playable
- [ ] All links across all READMEs verified valid
- [ ] Results saved to `results/deployment_review.md` in this sequence directory

## Implementation

### Step 1: Verify agent deployments

For each agent, verify it is running and producing heartbeats:

**Coordinator Agent:**

```bash
# Check process
ps aux | grep coordinator
# Check recent heartbeat on HCS (via mirror node or logs)
tail -20 /path/to/coordinator/logs/coordinator.log
# Look for heartbeat messages within the last 5 minutes
```

**Inference Agent:**

```bash
ps aux | grep inference
tail -20 /path/to/inference/logs/inference.log
```

**DeFi Agent:**

```bash
ps aux | grep defi
tail -20 /path/to/defi/logs/defi.log
```

### Step 2: Verify dashboard deployment

1. Open the dashboard public URL in a browser
2. Verify page loads within 3 seconds
3. Verify WebSocket connects (check connection indicator)
4. Verify all 5 panels show live data
5. Test from an incognito/private window (no cookies, no auth)
6. Test from a mobile device if possible

### Step 3: Verify demo video

1. Open the demo video URL in an incognito browser
2. Verify the video loads and plays
3. Verify audio and video quality are acceptable
4. Verify the video is under 2 minutes
5. Note the exact URL for submission forms

### Step 4: Link verification across all READMEs

For each README link identified in the previous task, verify it resolves:

```bash
# Test each external link
curl -o /dev/null -s -w "%{http_code}" <url>
```

Focus on:

- Demo video links (must resolve to playable video)
- Dashboard links (must load the dashboard)
- Block explorer links (must show real transaction data)
- Documentation links (must load the referenced document)

### Step 5: Write the deployment review report

Create `results/deployment_review.md`:

```markdown
# Deployment Review Report

## Agent Status
| Agent | Status | Last Heartbeat | PID | Notes |
|-------|--------|----------------|-----|-------|
| Coordinator | [Running/Down] | [timestamp] | [pid] | |
| Inference | [Running/Down] | [timestamp] | [pid] | |
| DeFi | [Running/Down] | [timestamp] | [pid] | |

## Dashboard Status
| Check | Result |
|-------|--------|
| Public URL accessible | [Yes/No] |
| Load time | [seconds] |
| WebSocket connected | [Yes/No] |
| All panels populated | [Yes/No] |
| Incognito access works | [Yes/No] |

## Demo Video Status
| Check | Result |
|-------|--------|
| URL accessible | [Yes/No] |
| Video plays | [Yes/No] |
| Duration | [X:XX] |
| Quality acceptable | [Yes/No] |

## Link Verification
| Link | Source | Status |
|------|--------|--------|
| [url] | [which README] | [200/404/timeout] |

## Issues Found
[List any issues and required fixes]
```

## Done When

- [ ] All agents verified running with recent heartbeats
- [ ] Dashboard verified accessible and showing live data
- [ ] Demo video verified accessible and playable
- [ ] All README links verified valid
- [ ] Deployment review report written
- [ ] Report saved to `results/deployment_review.md`
- [ ] Any issues found are flagged for immediate fix
