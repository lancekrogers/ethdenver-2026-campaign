---
fest_type: task
fest_id: 04_record_demo_video.md
fest_name: record demo video
fest_parent: 04_hiero_submission_prep
fest_order: 4
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.79534-07:00
fest_updated: 2026-02-23T13:53:36.60163-07:00
fest_tracking: true
---


# Task: Record Demo Video

## Objective

Record a short demo video showing the camp plugin commands in action — required for the Hedera Track 4 submission.

## Requirements

- [ ] Demo video (2-3 minutes) showing `hcli camp init`, `hcli camp status`, and `hcli camp navigate` with at least one template
- [ ] Video uploaded and link added to `projects/hiero-plugin/docs/submission.md`

## Implementation

### Step 1: Prepare demo script

Write a script of commands to run in sequence:

```bash
# 1. Show available templates
hcli camp init --help

# 2. Create a new Hedera agent project
hcli camp init my-hedera-agent --template hedera-agent

# 3. Show workspace status
hcli camp status --verbose

# 4. Create a 0G project in the same workspace
hcli camp init my-0g-agent --template 0g-agent

# 5. Navigate to the project
hcli camp navigate my-0g-agent

# 6. Show final workspace status
hcli camp status
```

### Step 2: Record

Use a screen recording tool (OBS, QuickTime, or asciinema for terminal). Keep it concise:

- Start with a brief intro of what the plugin does
- Run through the demo script
- Show the generated project structure briefly

### Step 3: Upload and link

Upload to YouTube (unlisted) or similar. Add the link to `projects/hiero-plugin/docs/submission.md`.

**NOTE:** This task requires Lance to record the video. The agent should prepare the demo script and instructions, then flag it for Lance.

## Done When

- [ ] All requirements met
- [ ] Video link is present in `docs/submission.md` and the video shows all 3 plugin commands working