---
fest_type: gate
fest_id: 10_fest_commit.md
fest_name: Fest Commit Changes
fest_parent: 02_submit_all_tracks
fest_order: 10
fest_status: pending
fest_gate_type: commit
fest_created: 2026-02-18T14:21:01.394044-07:00
fest_tracking: true
---

# Task: Fest Commit Sequence Changes

**Task Number:** <no value> | **Parallel Group:** None | **Dependencies:** Testing, Code Review, Iteration | **Autonomy:** medium

## Objective

Create a clean, descriptive commit that captures all changes made in this sequence.

## Pre-Commit Checklist

Before committing, verify:

- [ ] All tests pass
- [ ] Linting is clean
- [ ] Code is formatted
- [ ] No debug code or temporary files included
- [ ] No secrets or credentials in staged changes

## Commit Message Requirements

The commit message MUST:

### Describe WHAT Changed

- List the concrete changes made (files, functions, features)
- Be specific about what was added, modified, or removed
- Reference the sequence goal when relevant

### Describe WHY It Changed

- Explain the purpose and motivation for the changes
- Connect changes to requirements or user needs
- Provide context for future readers

### Format Guidelines

```text
<type>: <concise summary of changes>

<detailed description of what changed>

<explanation of why these changes were made>

<reference to sequence/phase if applicable>
```

**Types:** feat, fix, refactor, test, docs, chore

## Ethical Requirements

**CRITICAL**: The following practices are explicitly prohibited:

- [ ] **NO** "Co-authored-by" tags for AI assistants
- [ ] **NO** advertisements or promotional content
- [ ] **NO** AI tool attribution in commit messages
- [ ] **NO** links to AI services or products

Commit messages are for describing code changes, not for marketing or self-promotion. Adding such content is considered unethical and unprofessional.

## Commit Process

1. **Review staged changes**

   ```bash
   git status
   git diff --staged
   ```

2. **Write commit message** following the format above

3. **Create commit with fest (adds task reference ID)**

   ```bash
   fest commit -m "<type>: <summary>"
   # If you need to attach a specific task reference:
   fest commit --task FEST-XXXX -m "<type>: <summary>"
   ```

   Use `fest commit` so task references are preserved. Avoid raw `git commit`
   unless you intentionally omit tags (`fest commit --no-tag`).

4. **Commit at the project level via camp**

   ```bash
   camp p commit -m "<type>: <summary>"
   ```

   This records the change at the campaign project level so submodule
   references stay in sync.

5. **Push the project repo**

   ```bash
   git push
   ```

6. **Push the campaign**

   ```bash
   camp push
   ```

   This pushes the campaign repo with updated submodule references so
   all changes are tracked end-to-end: festival → project → campaign.

7. **Verify commit chain**

   ```bash
   git log -1 --stat
   camp project list
   ```

## Definition of Done

- [ ] Pre-commit checklist verified
- [ ] Commit message describes WHAT changed
- [ ] Commit message describes WHY it changed
- [ ] No prohibited content in commit message
- [ ] Fest commit successfully created
- [ ] Camp project commit created
- [ ] Project repo pushed to GitHub
- [ ] Campaign pushed with updated submodule refs

## Example Commit Message

```text
feat: add streaming support for message display

Implemented real-time streaming for LLM responses in the chat interface.
Messages now render incrementally as tokens arrive from the provider.

This change improves user experience by showing immediate feedback
during long responses, rather than waiting for complete generation.

Part of: 003_CHAT_CORE/03_streaming_integration
```

---

**Commit Status:**

- Pre-commit checks: [ ] Pass / [ ] Fail
- Commit created: [ ] Yes / [ ] No
- Commit hash: ________________