---
fest_type: task
fest_id: 03_verify_submodules.md
fest_name: verify submodules
fest_parent: 05_repo_cleanup
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-16T21:39:50.184468-06:00
fest_updated: 2026-03-17T00:20:14.143394-06:00
fest_tracking: true
---


# Task: Verify Submodule References Are Public or Removed

## Objective

Ensure all git submodule references point to public repositories so judges can clone the repo without access errors.

## Requirements

- [ ] List all submodule references in .gitmodules
- [ ] Verify each referenced repo is publicly accessible
- [ ] Remove or replace any private submodule references

## Implementation

1. List all submodules:
   ```bash
   cat .gitmodules
   git submodule status
   ```
2. For each submodule, check public accessibility:
   ```bash
   # Try to access the repo without authentication
   git ls-remote <submodule_url> 2>&1
   ```
3. For any private submodules:
   - Option A: Make the referenced repo public (if appropriate)
   - Option B: Remove the submodule reference:
     ```bash
     git submodule deinit <path>
     git rm <path>
     rm -rf .git/modules/<path>
     ```
   - Option C: Replace with a public fork or archive
4. After changes, verify a clean clone works:
   ```bash
   git clone --recurse-submodules <repo_url> /tmp/test-clone
   ```
5. Update README if any submodules were removed (explain what was removed and why)

## Done When

- [ ] All requirements met
- [ ] All submodule URLs verified as publicly accessible
- [ ] Private submodules removed or made public
- [ ] Clean clone with --recurse-submodules succeeds