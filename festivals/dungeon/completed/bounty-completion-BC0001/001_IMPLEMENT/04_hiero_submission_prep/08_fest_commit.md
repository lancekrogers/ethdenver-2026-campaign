---
fest_type: gate
fest_id: 08_fest_commit.md
fest_name: Fest Commit Changes
fest_parent: 04_hiero_submission_prep
fest_order: 8
fest_status: completed
fest_gate_type: commit
fest_created: 2026-02-23T11:06:55.279926-07:00
fest_updated: 2026-02-23T13:54:44.146791-07:00
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

4. **Verify commit**

   ```bash
   git log -1 --stat
   ```

## Definition of Done

- [ ] Pre-commit checklist verified
- [ ] Commit message describes WHAT changed
- [ ] Commit message describes WHY it changed
- [ ] No prohibited content in commit message
- [ ] Commit successfully created
- [ ] Changes are properly attributed to the sequence

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