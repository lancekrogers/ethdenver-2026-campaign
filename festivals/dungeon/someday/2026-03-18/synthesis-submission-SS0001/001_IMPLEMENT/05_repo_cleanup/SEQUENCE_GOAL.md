---
fest_type: sequence
fest_id: 05_repo_cleanup
fest_name: 05_repo_cleanup
fest_parent: 001_IMPLEMENT
fest_order: 5
fest_status: completed
fest_created: 2026-03-16T21:34:06.781108-06:00
fest_updated: 2026-03-17T00:21:00.608227-06:00
fest_tracking: true
fest_working_dir: .
---


# Sequence Goal: 05_repo_cleanup

**Sequence:** 05_repo_cleanup | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-16T21:34:06-06:00

## Sequence Objective

**Primary Goal:** Make the obey-agent-economy repository public on GitHub without exposing any secrets, private keys, or API keys.

**Contribution to Phase Goal:** The Uniswap bounty requires an "open-source public GitHub with README." All submissions benefit from a clean, public repo that judges can inspect. This is a multi-project workspace with submodules across 4 chains -- secret cleanup is non-trivial.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Secret audit**: All files audited for API keys, private keys, and .env contents across all submodules
- [ ] **Git history audit**: Git history checked for previously committed secrets
- [ ] **Updated .gitignore**: Comprehensive .gitignore covering all sensitive file patterns
- [ ] **Submodule verification**: All submodule references point to public repos or are removed
- [ ] **Public repo**: Repository set to public on GitHub
- [ ] **Submission-ready README**: README reflects project purpose and hackathon context

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] No secrets found in any tracked files or git history
- [ ] Repo is publicly accessible at the expected URL
- [ ] README is accurate and informative for judges

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_audit_secrets | Scan all files and git history for exposed secrets | Identifies what must be cleaned |
| 02_clean_gitignore | Update .gitignore and remove sensitive tracked files | Prevents future exposure |
| 03_verify_submodules | Ensure submodule refs are public or removed | Prevents broken/private links |
| 04_make_public | Set repo to public on GitHub and verify README | Final publication step |

## Dependencies

### Prerequisites (from other sequences)

- None -- can run in parallel with other sequences

### Provides (to other sequences)

- Public repo URL: Used by 06_submission_packaging (all track submissions require public repo link)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Secrets found in git history | Medium | High -- requires history rewrite or key rotation | Check history early; rotate any exposed keys immediately |
| Private submodule blocks public access | Medium | Medium -- judges can't clone | Remove or replace private submodule refs before publishing |
| .env files committed in submodules | Medium | High -- exposes API keys | Recursive search across all submodule directories |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Secret audit complete (files + git history)
- [ ] **Milestone 2**: .gitignore updated and sensitive files removed from tracking
- [ ] **Milestone 3**: All submodules verified as public or removed
- [ ] **Milestone 4**: Repo set to public on GitHub