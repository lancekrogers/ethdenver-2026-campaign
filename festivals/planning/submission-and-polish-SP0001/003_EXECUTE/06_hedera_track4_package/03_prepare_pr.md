---
fest_type: task
fest_id: 03_prepare_pr.md
fest_name: prepare_pr
fest_parent: 06_hedera_track4_package
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Finalize PR to Hiero CLI Repo

**Task Number:** 03 | **Sequence:** 06_hedera_track4_package | **Autonomy:** medium

## Objective

Finalize the pull request to the Hiero CLI repository (or prepare a standalone submission if contributing to the upstream repo is not possible). The PR must have a clear description, include screenshots, and reference the Hedera Track 4 bounty requirements.

## Requirements

- [ ] PR description is clear and follows the target repo's contribution guidelines
- [ ] Screenshots of the plugin in action are included
- [ ] Bounty requirements are referenced in the PR description
- [ ] All CI checks pass (if the target repo has CI)
- [ ] PR is ready for review (or standalone submission is packaged)

## Implementation

### Step 1: Check PR status

Determine the current state of the PR:

```bash
cd $(fgo)
# Check if a PR branch exists
git branch -a | grep pr
# Check if there's an existing draft PR
gh pr list --state all
```

If a PR already exists, review its current state. If not, prepare to create one.

### Step 2: Review target repo contribution guidelines

Check the Hiero CLI repo for:

- CONTRIBUTING.md or similar guide
- PR template (if any)
- Required CI checks
- Code style requirements

Follow these guidelines exactly.

### Step 3: Write or update the PR description

The PR description should include:

```markdown
## Summary

Brief description of what the plugin adds to the Hiero CLI.

## What's Included

- [ ] Plugin manifest and registration
- [ ] Commands: [list each command]
- [ ] Templates: [list each template]
- [ ] Tests: [unit and integration tests]
- [ ] Documentation: README with installation, usage, and examples

## Screenshots

[Include screenshots showing:]
- Plugin installation verification
- Each command being run with output
- Template generation with output

## Bounty Alignment

This plugin is submitted for the Hedera Track 4 developer tooling bounty.
It meets the requirements by:
- Extending the Hiero CLI with practical development commands
- Providing project templates for common Hedera development patterns
- Following the Hiero plugin API conventions

## Testing

Describe how to test the plugin:
1. Install the plugin following README instructions
2. Run each command with the provided examples
3. Verify template generation produces working projects
```

### Step 4: Capture screenshots

Take screenshots of:

1. Plugin listed in `hiero plugin list` (or equivalent)
2. Each command being run with output visible
3. Template generation showing the created files
4. Any other visual evidence of the plugin working

Save screenshots and add them to the PR description.

### Step 5: Verify CI passes

If the target repo has CI:

```bash
# Push the branch and check CI status
git push origin <branch-name>
gh pr checks <pr-number>
```

Fix any CI failures before marking the PR as ready.

### Step 6: Handle standalone submission

If contributing upstream is not possible:

- Package the plugin as a standalone repository
- Ensure the repository is public and accessible
- Include the same PR-quality description in the README
- Note in the submission that this is a standalone plugin ready for upstream integration

## Done When

- [ ] PR description is complete with summary, screenshots, and bounty alignment
- [ ] Screenshots captured and included
- [ ] All CI checks pass (if applicable)
- [ ] PR is in "ready for review" state (or standalone repo is public)
- [ ] PR URL or repo URL is recorded for the submission form
