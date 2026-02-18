---
fest_type: task
fest_id: 03_rehearse.md
fest_name: rehearse
fest_parent: 08_demo_video
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Rehearse Demo

**Task Number:** 03 | **Sequence:** 08_demo_video | **Autonomy:** medium

## Objective

Rehearse the demo script at least once with timing. Identify and eliminate any dead time > 5 seconds. Verify all dashboard panels show activity during the recording window. Adjust the script as needed.

## Requirements

- [ ] Demo rehearsed at least once with full timing
- [ ] Each section timed individually and total time verified <= 2 minutes
- [ ] No dead time > 5 seconds anywhere in the demo
- [ ] All dashboard panels confirmed to show live data during rehearsal
- [ ] Script updated with any adjustments from rehearsal
- [ ] Rehearsal notes documented

## Implementation

### Step 1: Pre-rehearsal checks

Before rehearsing, verify the environment:

1. **Agents running**: Confirm all three agents are active and producing heartbeats
2. **Dashboard live**: Confirm the dashboard is accessible and showing live data
3. **Screen recording ready**: Have screen recording software ready (OBS, QuickTime, or similar)
4. **Audio ready**: Have microphone ready and tested
5. **Script printed/visible**: Have the demo script visible on a second screen or printed out

### Step 2: Run the full rehearsal

- Start a timer
- Follow the demo script section by section
- Navigate the dashboard as described in the transition table
- Speak the talking points aloud (or silently time them)
- Note any issues: panels not loading, transitions too slow, talking points too long/short

### Step 3: Review timing

After the rehearsal, compare actual timing to planned timing:

| Section | Planned | Actual | Notes |
|---------|---------|--------|-------|
| Intro | 15s | | |
| Architecture | 20s | | |
| Dashboard Walkthrough | 60s | | |
| Key Highlights | 20s | | |
| Closing | 5s | | |
| **Total** | **120s** | | |

### Step 4: Identify dead time

Review the rehearsal for any moments where:

- The screen showed nothing interesting (loading, blank panels)
- The speaker had nothing to say (awkward silence)
- A transition took too long (clicking, scrolling, waiting)

For each dead time moment:

- **Location**: Which section and timestamp
- **Cause**: Why the dead time occurred
- **Fix**: How to eliminate it (pre-load the page, add a talking point, skip the transition)

### Step 5: Verify panel activity

During rehearsal, confirm:

- [ ] Agent Status panel showed all agents online
- [ ] HCS Message Feed showed messages flowing (not empty or stale)
- [ ] Task Activity showed at least one recent task
- [ ] DeFi Trading showed activity
- [ ] System Overview showed current metrics

If any panel was empty or stale, determine the cause:

- Is the agent not producing data? Trigger a task before recording.
- Is the WebSocket disconnected? Refresh the page.
- Is the data too old? Check agent activity timing.

### Step 6: Update the demo script

Based on rehearsal findings:

- Adjust talking point length for sections that ran long/short
- Add filler talking points where dead time occurred
- Reorder transitions if a smoother flow was discovered
- Note any "warm-up" actions needed before recording (e.g., trigger a task 30 seconds before recording to ensure fresh data)

### Step 7: Pre-recording warmup plan

Create a warmup checklist to run 2 minutes before recording:

1. Verify all agents running
2. Trigger a test task to ensure fresh data flows
3. Refresh the dashboard
4. Verify WebSocket connection indicator
5. Check all panels populated
6. Start recording

## Done When

- [ ] At least one full rehearsal completed with timing
- [ ] All sections within their time budgets
- [ ] No dead time > 5 seconds identified (or all dead time eliminated)
- [ ] All dashboard panels confirmed to show live data
- [ ] Demo script updated with rehearsal adjustments
- [ ] Pre-recording warmup plan created
