---
fest_type: task
fest_id: 04_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 02_camp_commands
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 04 | **Sequence:** 02_camp_commands | **Autonomy:** medium | **Dependencies:** All implementation tasks

## Objective

Verify all three camp commands (init, status, navigate) work correctly through comprehensive testing. Confirm argument parsing, camp binary invocation, output formatting, and error handling for each command.

## Requirements

- [ ] All unit tests pass
- [ ] Integration tests verify each command end-to-end
- [ ] Manual testing confirms all three commands produce expected output
- [ ] Error cases are handled correctly (missing camp, invalid arguments, uninitialized workspace)
- [ ] Edge cases are addressed (empty workspace, single project, many projects)

## Test Categories

### Unit Tests

Run the test suite:

```bash
cd $(fgo) && npx jest
```

**Tests to write:**

1. **`src/commands/init.test.ts`** - Init command tests:
   - `parseInitArgs` extracts project name from positional argument
   - `parseInitArgs` extracts project name from `--name` flag
   - `parseInitArgs` extracts template from `--template` flag
   - `parseInitArgs` throws when no project name is provided
   - `handleInit` calls execCamp with correct arguments
   - `handleInit` includes template flag when template is specified
   - `handleInit` calls configureHederaDefaults after successful init
   - `handleInit` reports error when camp init fails (non-zero exit)

2. **`src/commands/status.test.ts`** - Status command tests:
   - `parseStatusArgs` defaults to non-verbose mode
   - `parseStatusArgs` sets verbose with `--verbose` flag
   - `parseStatusArgs` extracts project filter from `--project` flag
   - `handleStatus` calls both `camp project list` and `camp status`
   - `handleStatus` formats output with project list and status info
   - `handleStatus` handles uninitialized workspace gracefully
   - `handleStatus` handles empty project list gracefully
   - `handleStatus` filters to specific project when `--project` is used

3. **`src/commands/navigate.test.ts`** - Navigate command tests:
   - `parseNavigateArgs` extracts query from positional argument
   - `parseNavigateArgs` sets list mode with `--list` flag
   - `fuzzyMatch` returns true for matching queries
   - `fuzzyMatch` returns false for non-matching queries
   - `fuzzyMatch` is case-insensitive
   - `highlightMatch` highlights matching characters
   - `handleNavigate` tries native camp navigate first
   - `handleNavigate` falls back to built-in finder when native is unavailable
   - `handleNavigate` outputs single match directly to stdout
   - `handleNavigate` shows numbered list for multiple matches
   - `handleNavigate` handles empty workspace gracefully

**Verify:**

- [ ] All new/modified code has test coverage
- [ ] Tests mock `execCamp` to avoid requiring a real camp binary
- [ ] Test names describe what they verify

### Integration Tests

If camp is available on the test machine, run integration tests:

```bash
cd $(fgo) && npx jest --testPathPattern='integration'
```

**Integration tests:**

1. **Init integration**: If camp is available, verify `handleInit` creates a workspace
2. **Status integration**: After init, verify `handleStatus` shows the new project
3. **Navigate integration**: After init, verify `handleNavigate` finds the new project

**Verify:**

- [ ] Commands work end-to-end with a real camp binary (if available)
- [ ] Output formatting looks correct in a real terminal
- [ ] Color output works with chalk

### Manual Verification

Walk through each command manually:

1. [ ] **Init command**: Run `handleInit(["test-project"])` and verify a workspace is created
2. [ ] **Init with template**: Run `handleInit(["test-project", "--template", "hedera-dapp"])` and verify template is passed
3. [ ] **Status command**: Run `handleStatus([])` in an initialized workspace and verify formatted output
4. [ ] **Status verbose**: Run `handleStatus(["--verbose"])` and verify additional detail is shown
5. [ ] **Navigate command**: Run `handleNavigate(["test"])` and verify fuzzy matching works
6. [ ] **Navigate list**: Run `handleNavigate(["--list"])` and verify all projects are listed
7. [ ] **Error: no workspace**: Run `handleStatus([])` outside a workspace and verify helpful error

## Coverage Requirements

- Minimum coverage: 80% for new code

```bash
cd $(fgo) && npx jest --coverage
```

## Error Handling Verification

- [ ] Missing camp binary shows CampNotFoundError with install instructions
- [ ] Invalid init arguments show usage message
- [ ] Camp command failures (non-zero exit) show stderr with context
- [ ] Uninitialized workspace provides "run hiero camp init" guidance
- [ ] Navigate with no matches shows available projects

## Definition of Done

- [ ] All automated tests pass
- [ ] Manual verification complete for all three commands
- [ ] Coverage meets 80% requirement for new code
- [ ] Error handling verified for all failure modes
- [ ] No regressions to sequence 01 functionality

## Notes

Document any test gaps, flaky tests, or areas needing future attention here.

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Integration tests: [ ] Pass / [ ] Fail (or N/A if camp not available)
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
