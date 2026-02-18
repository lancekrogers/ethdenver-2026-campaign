---
fest_type: task
fest_id: 04_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 03_templates
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 04 | **Sequence:** 03_templates | **Autonomy:** medium | **Dependencies:** All implementation tasks

## Objective

Verify that all three Hedera scaffold templates generate valid projects and that the template integration with the init command works correctly end-to-end.

## Requirements

- [ ] All unit tests pass
- [ ] Each template generates a project with correct file structure
- [ ] Variable substitution works correctly in all template files
- [ ] Generated projects can install dependencies and compile
- [ ] Manual testing confirms the full init-with-template flow works

## Test Categories

### Unit Tests

Run the test suite:

```bash
cd $(fgo) && npx jest
```

**Tests to write:**

1. **`src/templates.test.ts`** - Template module tests:
   - `listTemplates()` returns all three templates
   - `listTemplates()` returns correct metadata for each template
   - `getTemplate()` returns correct template by ID
   - `getTemplate()` returns null for unknown template ID
   - `buildVariables()` creates correct PascalCase from kebab-case
   - `buildVariables()` uses current year
   - `buildVariables()` applies overrides
   - `substituteVariables()` replaces all `{{variable}}` patterns
   - `substituteVariables()` handles multiple occurrences
   - `substituteVariables()` leaves non-matching patterns unchanged
   - `copyTemplate()` creates target directory
   - `copyTemplate()` copies all files except template.json
   - `copyTemplate()` substitutes variables in file contents
   - `copyTemplate()` substitutes variables in file names
   - `copyTemplate()` throws for unknown template ID

2. **Template content validation tests:**
   - hedera-smart-contract template.json is valid
   - hedera-dapp template.json is valid
   - hedera-agent template.json is valid
   - Each template directory contains expected files
   - No template file contains unintended `{{` markers after substitution

**Verify:**

- [ ] All tests pass with meaningful assertions
- [ ] Template copying tests use a temporary directory (cleaned up after)
- [ ] Test names describe what they verify

### Integration Tests

Test that generated projects are functional:

```bash
cd $(fgo) && npx jest --testPathPattern='integration'
```

**Integration tests to write:**

1. **hedera-smart-contract generation**: Generate the template to a temp directory, run `npm install`, run `npx hardhat compile`, verify no errors
2. **hedera-dapp generation**: Generate the template to a temp directory, run `npm install`, run `npx tsc --noEmit`, verify no errors
3. **hedera-agent generation**: Generate the template to a temp directory, verify `go.mod` is valid, run `go build ./...` (if Go is available)

**Verify:**

- [ ] Generated hedera-smart-contract project installs and compiles
- [ ] Generated hedera-dapp project installs and type-checks
- [ ] Generated hedera-agent project builds (if Go is available)

### Manual Verification

Walk through the full user flow:

1. [ ] **Template list**: Call `listTemplates()` and verify all three templates appear with correct metadata
2. [ ] **Init with template**: Run `handleInit(["my-test", "--template", "hedera-smart-contract"])` and verify the generated project
3. [ ] **Init with dApp template**: Run `handleInit(["my-dapp", "--template", "hedera-dapp"])` and verify HashConnect setup is present
4. [ ] **Init with agent template**: Run `handleInit(["my-agent", "--template", "hedera-agent"])` and verify Go files are present
5. [ ] **Variable substitution**: Check that `{{projectName}}` is replaced everywhere in the generated project
6. [ ] **No leftover markers**: Grep the generated project for `{{` to confirm all variables are substituted
7. [ ] **README accuracy**: Read each generated README and verify the instructions make sense

## Coverage Requirements

- Minimum coverage: 80% for new code

```bash
cd $(fgo) && npx jest --coverage
```

## Error Handling Verification

- [ ] Invalid template ID produces clear error message
- [ ] Missing templates directory is handled gracefully
- [ ] File system errors during copying produce actionable messages
- [ ] Template.json parse errors are handled (malformed JSON)

## Definition of Done

- [ ] All automated tests pass
- [ ] Manual verification complete for all three templates
- [ ] Generated projects install dependencies without errors
- [ ] Variable substitution verified with no leftover `{{` markers
- [ ] Coverage meets 80% requirement for new code
- [ ] Error handling verified
- [ ] No regressions to previous sequences

## Notes

Integration tests that require `npm install` or `go build` may be slow and should be marked as integration tests that can be skipped in CI. Mark these with a `@slow` or `integration` tag.

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Integration tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
