---
fest_type: task
fest_id: 01_audit_secrets.md
fest_name: audit secrets
fest_parent: 05_repo_cleanup
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-16T21:39:50.183794-06:00
fest_tracking: true
---

# Task: Audit All Files for Secrets

## Objective

Scan all files in the repository and git history for exposed secrets including API keys, private keys, and sensitive credentials.

## Requirements

- [ ] Scan all tracked files for secrets (API keys, private keys, passwords, tokens)
- [ ] Scan git history for previously committed secrets
- [ ] Scan all submodule directories recursively
- [ ] Document all findings with file paths and secret types

## Implementation

1. Scan current files for common secret patterns:
   ```bash
   # Search for private keys
   grep -r "PRIVATE_KEY\|0x[a-fA-F0-9]{64}" --include="*.env*" --include="*.json" --include="*.yaml" --include="*.toml" .
   # Search for API keys
   grep -r "API_KEY\|api_key\|apiKey\|sk-\|xai-" --include="*.env*" --include="*.go" --include="*.ts" --include="*.js" .
   # Search for .env files
   find . -name ".env*" -not -path "*/node_modules/*"
   ```
2. Scan git history for secrets:
   ```bash
   git log --all --full-history -p -- "*.env" "*.env.*"
   git log --all --full-history -p -S "PRIVATE_KEY"
   ```
3. Check each submodule directory:
   - `projects/agent-defi/`
   - `projects/contracts/`
   - `projects/cre-risk-router/`
   - `projects/agent-coordinator/`
   - `projects/agent-inference/`
   - `projects/dashboard/`
4. Document findings in a checklist:
   - File path, secret type, current status (committed/gitignored), action needed
5. For any secrets found in git history: note that key rotation is required even after removal

## Done When

- [ ] All requirements met
- [ ] All tracked files scanned for secret patterns
- [ ] Git history scanned for previously committed secrets
- [ ] All submodule directories checked
- [ ] Findings documented with action items
