---
fest_type: task
fest_id: 04_record.md
fest_name: record
fest_parent: 08_demo_video
fest_order: 4
fest_status: pending
fest_autonomy: low
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Record Demo Video

**Task Number:** 04 | **Sequence:** 08_demo_video | **Autonomy:** low

## Objective

Record the final demo video. Screen capture + voiceover. Export to MP4. Upload to YouTube or similar. Get a public URL for inclusion in bounty submission forms.

## Requirements

- [ ] Video recorded with screen capture and voiceover
- [ ] Video is 2 minutes or under
- [ ] Audio is clear and professional (no background noise, consistent volume)
- [ ] Video resolution is at least 1080p
- [ ] Exported as MP4
- [ ] Uploaded to YouTube (unlisted) or similar platform
- [ ] Public URL obtained and accessible without authentication
- [ ] URL recorded for use in submission forms

## Implementation

### Step 1: Run the pre-recording warmup

Follow the warmup checklist from the rehearsal task:

1. Verify all agents running: check PIDs and heartbeats
2. Trigger a test task to ensure fresh data flows through the system
3. Refresh the dashboard in the browser
4. Verify WebSocket connection indicator shows connected
5. Check all 5 panels are populated with data
6. Wait 30 seconds for the triggered task to propagate

### Step 2: Set up recording

**Screen Recording**:

- Use OBS Studio, QuickTime (macOS), or similar
- Set resolution to 1920x1080 (1080p) minimum
- Set frame rate to 30fps
- Configure to capture the browser window (not full desktop to avoid distractions)

**Audio**:

- Use a good microphone (USB condenser, headset mic, or MacBook built-in in a quiet room)
- Do a 10-second test recording and play it back to check quality
- Close all notification sources (Slack, email, system notifications) to avoid interruption sounds

### Step 3: Record the demo

- Start the screen recording
- Start the voiceover
- Follow the demo script section by section
- Follow the transition table for screen actions
- Speak clearly and at a measured pace
- If something goes wrong (agent crash, panel empty, stumbled words), stop and restart

### Step 4: Review the recording

Play back the recording and verify:

- [ ] Audio is clear throughout (no mumbling, no background noise)
- [ ] Screen capture is sharp and readable (text on dashboard is legible)
- [ ] All dashboard panels are visible and show live data
- [ ] Total duration is 2 minutes or under
- [ ] No dead time > 5 seconds
- [ ] No embarrassing errors (wrong project name, incorrect claims)
- [ ] Transitions are smooth

If any issue is found, re-record.

### Step 5: Export to MP4

Export the recording as MP4 with:

- H.264 codec
- 1080p resolution (1920x1080)
- AAC audio
- Reasonable file size (under 100MB for a 2-minute video)

### Step 6: Upload to YouTube

1. Go to YouTube Studio
2. Upload the MP4 file
3. Set the title: "[Project Name] - ETHDenver 2026 Demo"
4. Set visibility to **Unlisted** (accessible via link, but not publicly searchable)
5. Add a description with project name and bounty tracks
6. Wait for processing to complete
7. Copy the video URL

### Step 7: Verify the upload

- Open the URL in an incognito/private browser window
- Verify the video plays without authentication
- Verify the video quality is acceptable (not blurry, audio synced)

### Step 8: Record the URL

Save the video URL in a location accessible for submission tasks:

- Update the demo notes documents with the video URL
- Update README demo sections with the video URL
- Note the URL for the submission form tasks in 004_SUBMIT

## Done When

- [ ] Demo video recorded with screen capture and voiceover
- [ ] Video is 2 minutes or under
- [ ] Audio and video quality are acceptable
- [ ] Exported as MP4
- [ ] Uploaded to YouTube (unlisted) or similar
- [ ] Public URL obtained and verified accessible
- [ ] URL recorded for submission forms
- [ ] READMEs and demo notes updated with video URL
