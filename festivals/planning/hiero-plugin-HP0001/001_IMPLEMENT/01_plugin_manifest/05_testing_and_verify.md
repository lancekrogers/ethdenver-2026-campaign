---
fest_type: task
fest_id: 05_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 01_plugin_manifest
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 05 | **Sequence:** 01_plugin_manifest | **Autonomy:** medium | **Dependencies:** All implementation tasks

## Objective

Verify all functionality implemented in this sequence works correctly through comprehensive testing. This covers the plugin manifest, entry point, and camp binary discovery module.

## Requirements

- [ ] All unit tests pass
- [ ] Integration tests verify plugin loading and camp invocation workflows
- [ ] Manual testing confirms the plugin loads and camp discovery works as expected
- [ ] Error cases are handled correctly (missing camp, invalid arguments, timeouts)
- [ ] Edge cases are addressed

## Test Categories

### Unit Tests

Set up the test framework and write unit tests:

```bash
cd $(fgo) && npm install --save-dev jest ts-jest @types/jest
```

Configure Jest in package.json or jest.config.ts:

```json
{
  "jest": {
    "preset": "ts-jest",
    "testEnvironment": "node",
    "testMatch": ["**/*.test.ts"]
  }
}
```

Run tests:

```bash
cd $(fgo) && npx jest
```

**Tests to write:**

1. **`src/camp.test.ts`** - Camp discovery module tests:
   - `findCampBinary()` returns a path when camp is installed
   - `findCampBinary()` returns null when camp is not on PATH
   - `CampNotFoundError` message includes installation instructions
   - `execCamp()` throws `CampNotFoundError` when camp is not available
   - `execCamp()` returns correct stdout/stderr/exitCode on success
   - `execCamp()` handles non-zero exit codes correctly
   - `execCamp()` handles timeout correctly
   - `getCampVersion()` returns version string when camp is available
   - `getCampVersion()` returns null when camp is not available

2. **`src/index.test.ts`** - Plugin entry point tests:
   - Plugin exports have correct name and version
   - Plugin exports include all three command definitions (init, status, navigate)
   - Command handlers are callable functions

**Verify:**

- [ ] All new/modified code has test coverage
- [ ] Tests are meaningful (not just coverage padding)
- [ ] Test names describe what they verify

### Integration Tests

Test that the pieces work together:

```bash
cd $(fgo) && npx jest --testPathPattern='integration'
```

**Integration tests to write:**

1. **Camp discovery integration**: If camp is available on the test machine, verify `execCamp(["--version"])` returns a valid result
2. **Plugin loading**: Verify the plugin can be imported and its command list matches expectations

**Verify:**

- [ ] Components work together correctly
- [ ] Camp binary invocation functions properly (when camp is available)
- [ ] Plugin entry point exports all expected members

### Manual Verification

Walk through each requirement from the sequence:

1. [ ] **Plugin manifest validates**: Load the manifest file and verify all required fields are present
2. [ ] **Plugin entry point works**: Import `src/index.ts` and verify the plugin object has correct shape
3. [ ] **Camp discovery detects binary**: Run `findCampBinary()` and verify it returns the correct path (or null)
4. [ ] **Error message is helpful**: Trigger `CampNotFoundError` and verify the message includes installation steps
5. [ ] **execCamp works end-to-end**: Run `execCamp(["--version"])` and verify it returns camp's version output

## Coverage Requirements

- Minimum coverage: 80% for new code

```bash
cd $(fgo) && npx jest --coverage
```

## Error Handling Verification

- [ ] Missing camp binary is rejected with clear, actionable error message
- [ ] Invalid camp arguments produce understandable error output
- [ ] Camp process timeouts are handled gracefully with timeout message
- [ ] Errors do not expose sensitive information (paths, credentials, etc.)
- [ ] Recovery paths work correctly (retry after installing camp)

## Definition of Done

- [ ] All automated tests pass
- [ ] Manual verification complete
- [ ] Coverage meets 80% requirement for new code
- [ ] Error handling verified
- [ ] No regressions introduced

## Notes

Document any test gaps, flaky tests, or areas needing future attention here.

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Integration tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
