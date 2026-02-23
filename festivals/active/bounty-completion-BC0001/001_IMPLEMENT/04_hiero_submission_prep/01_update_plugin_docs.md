---
fest_type: task
fest_id: 01_update_plugin_docs.md
fest_name: update plugin docs
fest_parent: 04_hiero_submission_prep
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.794206-07:00
fest_tracking: true
---

# Task: Verify and Patch Hiero Plugin Documentation

## Objective

Verify that the existing hiero-plugin docs (submission.md, architecture.md, usage-guide.md, README.md) accurately describe all 5 templates including the 0G additions, and patch any gaps found. The docs already exist and are substantive — this is an accuracy audit, not a rewrite.

## Requirements

- [ ] `projects/hiero-plugin/README.md` templates table lists all 5 templates: `hedera-smart-contract`, `hedera-dapp`, `hedera-agent`, `0g-agent`, `0g-inft-build`
- [ ] `projects/hiero-plugin/docs/usage-guide.md` includes usage examples for the 0G templates
- [ ] `projects/hiero-plugin/docs/submission.md` accurately describes 0G Track 4 requirements mapping
- [ ] `projects/hiero-plugin/docs/architecture.md` template system section covers 0G templates
- [ ] All commands shown in docs actually work when copy-pasted

## Implementation

### Step 1: Audit existing docs

Read all four docs and cross-reference against the actual template directories in `src/templates/`. Note any inaccuracies, missing templates, or stale references.

### Step 2: Patch gaps

Fix only what is inaccurate or missing. Do not rewrite sections that are already correct. Focus on:
- Template table completeness in README
- 0G template usage examples in usage-guide.md
- Any stale command syntax or file paths

## Done When

- [ ] All requirements met
- [ ] All 5 templates accurately described across all 4 docs
- [ ] No unnecessary rewrites — only targeted patches applied
