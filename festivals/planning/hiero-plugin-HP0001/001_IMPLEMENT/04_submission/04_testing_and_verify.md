---
fest_type: task
fest_id: 04_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 04_submission
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 04 | **Sequence:** 04_submission | **Autonomy:** medium | **Dependencies:** All implementation tasks

## Objective

Verify that all documentation is accurate, the submission package is complete, and the demo flow works end-to-end. This is the final quality gate before the festival is considered complete.

## Requirements

- [ ] All documentation is accurate and code examples work
- [ ] Demo script runs successfully from start to finish
- [ ] Plugin installs from a clean environment
- [ ] All bounty requirements are verified as met
- [ ] Repository is clean and submission-ready

## Test Categories

### Documentation Accuracy Tests

Verify every code example in the documentation:

1. [ ] **README Quick Start**: Follow the Quick Start section step-by-step and verify each command works
2. [ ] **Usage Guide init examples**: Run every `hiero camp init` example and verify output matches docs
3. [ ] **Usage Guide status examples**: Run every `hiero camp status` example and verify output matches docs
4. [ ] **Usage Guide navigate examples**: Run every `hiero camp navigate` example and verify output matches docs
5. [ ] **Architecture references**: Verify file paths and component names in architecture doc match actual code

### Demo Flow Tests

Run the demo script:

```bash
cd $(fgo) && bash demo.sh
```

Verify:

- [ ] Demo script exits with code 0
- [ ] Init command creates a project successfully
- [ ] Status command shows the project in the workspace
- [ ] Navigate command finds the project
- [ ] Cleanup removes the demo project

### Installation Tests

Test a fresh install:

```bash
# Build
cd $(fgo) && npm run build

# Pack
cd $(fgo) && npm pack

# Install globally from tarball
npm install -g ./hiero-plugin-camp-*.tgz

# Verify the plugin is accessible
which hiero-plugin-camp || npm list -g hiero-plugin-camp

# Run basic commands
hiero camp init test-install --template hedera-smart-contract
hiero camp status
hiero camp navigate test
rm -rf test-install

# Uninstall
npm uninstall -g hiero-plugin-camp
```

### Repository Cleanliness Tests

```bash
cd $(fgo)

# No secrets in the repo
grep -rn "private.*key\|secret\|password\|token" src/ --include='*.ts' | grep -v "test\|example\|.env"

# No debug code
grep -rn "console.debug\|debugger" src/ --include='*.ts'

# .gitignore covers expected files
cat .gitignore

# No large binary files
find . -size +1M -not -path './node_modules/*' -not -path './.git/*'

# License file present
cat LICENSE

# All expected directories exist
ls -la src/ src/commands/ templates/ docs/
```

### Bounty Requirement Verification

Review `docs/submission.md` and verify each claimed requirement:

1. [ ] **Developer tooling**: Plugin provides developer-facing CLI commands
2. [ ] **Hedera ecosystem**: Templates target Hedera networks, uses Hedera SDK
3. [ ] **Functional**: All three commands execute without errors
4. [ ] **Documented**: README, usage guide, and architecture doc are complete
5. [ ] **Open source**: Apache-2.0 license, public repository

### Manual Verification

Walk through the complete user journey:

1. [ ] Install the plugin from npm (or globally from tarball)
2. [ ] Run `hiero camp init my-project --template hedera-dapp`
3. [ ] Verify the generated project has correct files and no `{{` markers
4. [ ] Run `cd my-project && npm install` and verify dependencies install
5. [ ] Run `hiero camp status` and verify formatted output
6. [ ] Run `hiero camp navigate my` and verify fuzzy matching
7. [ ] Clean up the test project

## Error Handling Verification

- [ ] Documentation accurately describes error messages
- [ ] Demo script handles failures gracefully
- [ ] Installation failure modes are documented

## Definition of Done

- [ ] All documentation examples verified as working
- [ ] Demo script runs successfully
- [ ] Plugin installs cleanly from tarball
- [ ] All bounty requirements verified
- [ ] Repository is clean (no secrets, debug code, or unnecessary files)
- [ ] Complete user journey tested manually

## Notes

This is the final verification gate. Any issues found here must be fixed before the festival can be considered complete.

---

**Test Results Summary:**

- Documentation accuracy: [ ] Pass / [ ] Fail
- Demo flow: [ ] Pass / [ ] Fail
- Installation: [ ] Pass / [ ] Fail
- Bounty requirements: [ ] Pass / [ ] Fail
- Repository cleanliness: [ ] Pass / [ ] Fail
