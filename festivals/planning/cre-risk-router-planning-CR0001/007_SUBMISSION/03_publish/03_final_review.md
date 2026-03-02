---
fest_type: task
fest_id: 01_final_review.md
fest_name: final review
fest_parent: 03_publish
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:45:34.441182-07:00
fest_tracking: true
---

# Task: final review

## Objective

Perform a comprehensive final review of the entire submission -- Moltbook post, GitHub repo, README, scenarios, simulation evidence, and contract deployment -- to ensure everything is complete, accurate, and judge-ready before publishing.

## Requirements

- [ ] Moltbook post has all 10 sections with no placeholder text (Req P0.23)
- [ ] GitHub repo README enables clone-to-simulate in under 5 commands
- [ ] All 5 scenario JSON files exist and have documented expected outcomes
- [ ] Simulation logs and block explorer evidence are present and referenced
- [ ] Contract address in README matches the deployed contract
- [ ] `demo/e2e.sh` is executable and self-documenting
- [ ] No secrets, API keys, or private keys in the codebase

## Implementation

1. **Review the Moltbook post** (`submission/moltbook-draft.md`):
   - [ ] Section 1 (Title) is present and descriptive
   - [ ] Section 2 (Summary) is 2-3 clear sentences
   - [ ] Section 3 (Problem Statement) explains the need
   - [ ] Section 4 (Architecture) has data flow description
   - [ ] Section 5 (Risk Gates) lists all 8 gates with thresholds
   - [ ] Section 6 (Smart Contract) has address and interface
   - [ ] Section 7 (Simulation) has log output or screenshots
   - [ ] Section 8 (Evidence) has block explorer link
   - [ ] Section 9 (Scenarios) summarizes all 5 scenarios
   - [ ] Section 10 (Integration) describes coordinator bridge path
   - [ ] No `[TODO]`, `[PLACEHOLDER]`, or `[REPLACE:]` markers anywhere

2. **Review the GitHub repo**:
   ```bash
   cd projects/cre-risk-router
   # Check README exists and is complete
   cat README.md | head -100

   # Check no secrets in codebase
   grep -r "PRIVATE_KEY\|API_KEY\|SECRET" --include="*.go" --include="*.sol" --include="*.json" --include="*.env" .

   # Check .env.example exists (not .env with real values)
   ls -la .env*

   # Check scenarios exist
   ls scenarios/

   # Check demo script exists and is executable
   ls -la demo/e2e.sh

   # Check evidence directory
   ls evidence/
   ```

3. **Test the clone-to-simulate flow**:
   - Follow the README instructions from a clean perspective
   - Verify each step works as documented
   - Confirm the output matches what the README describes
   - Ensure `just simulate` and `just broadcast` commands work

4. **Verify contract deployment**:
   - Confirm the contract address in README matches `config.receipt_contract_address`
   - Verify the contract is still accessible on the block explorer
   - Check that the testnet and chain ID are correctly documented

5. **Cross-reference evidence**:
   - Tx hash in simulation logs matches the block explorer evidence
   - DecisionRecorded event is visible and parameters are readable
   - All links in the Moltbook post are valid and accessible

6. **Security audit**:
   ```bash
   # No .env files committed
   git ls-files | grep -i "\.env$"

   # No private keys
   grep -rn "0x[a-fA-F0-9]{64}" --include="*.go" --include="*.json" .

   # No hardcoded secrets
   grep -rn "password\|secret\|apikey" --include="*.go" -i .
   ```

7. **Final formatting check**:
   - All markdown renders correctly
   - Code blocks have language tags
   - Tables are properly formatted
   - Links work (not broken)

## Done When

- [ ] All requirements met
- [ ] Every section of the Moltbook post reviewed and verified
- [ ] Clone-to-simulate flow tested and working
- [ ] No secrets or placeholder text in the codebase
- [ ] All evidence is present, accurate, and cross-referenced
