---
fest_type: task
fest_id: 02_clean_gitignore.md
fest_name: clean gitignore
fest_parent: 05_repo_cleanup
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-16T21:39:50.184183-06:00
fest_tracking: true
---

# Task: Update .gitignore and Remove Sensitive Tracked Files

## Objective

Update .gitignore to cover all sensitive file patterns and remove any currently-tracked sensitive files from the index.

## Requirements

- [ ] Update root .gitignore with comprehensive secret patterns
- [ ] Remove any currently-tracked sensitive files from git index
- [ ] Ensure submodule .gitignore files also cover sensitive patterns

## Implementation

1. Review and update root `.gitignore` to include:
   ```
   # Secrets and credentials
   .env
   .env.*
   .env.local
   *.pem
   *.key
   credentials.json
   keystore/

   # Build artifacts
   out/
   cache/
   broadcast/

   # IDE
   .idea/
   .vscode/

   # OS
   .DS_Store
   Thumbs.db
   ```
2. For any sensitive files currently tracked (found in task 01), remove from index:
   ```bash
   git rm --cached <file>
   ```
3. Check each submodule for its own .gitignore adequacy
4. If secrets were found in git history (task 01), evaluate options:
   - Option A: Rotate all exposed keys (preferred -- simpler than history rewrite)
   - Option B: Use `git filter-repo` to remove from history (more complex)
5. Commit the .gitignore updates

## Done When

- [ ] All requirements met
- [ ] .gitignore updated with comprehensive patterns
- [ ] No sensitive files remain in the git index
- [ ] Any exposed keys have been rotated
