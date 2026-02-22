---
fest_type: task
fest_id: 01_verify_tests.md
fest_name: verify tests
fest_parent: 05_hiero_plugin_polish
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:54.706127-07:00
fest_tracking: true
---

# Task: Verify All Hiero Plugin Tests Pass

## Objective

Run the full hiero-plugin test suite (37 existing tests plus any new tests added for the 0G templates) and fix every failing test so that `just test` exits 0 with no skipped or erroring cases.

## Requirements

- [ ] `just test` exits 0 in `projects/hiero-plugin/`
- [ ] No tests are skipped with `t.Skip()` to paper over failures
- [ ] New tests covering `0g-agent` and `0g-inft-build` template registration are added if they do not already exist
- [ ] All 37 pre-existing tests still pass after the 0G template changes

## Implementation

### Step 1: Run the test suite baseline

```bash
cd projects/hiero-plugin && just test 2>&1 | tee /tmp/plugin-test-baseline.txt
```

Read the output carefully. Note any FAIL lines, panic output, or tests with unexpected skip calls.

### Step 2: Fix compilation errors first

If there are compilation errors, no tests will run. Fix any import errors, undefined symbols, or type mismatches introduced by the Seq 04 template registration changes before proceeding.

```bash
go build ./... 2>&1
```

### Step 3: Investigate and fix each failing test

For each failing test identified in Step 1:

1. Read the test file to understand what it asserts.
2. Read the production code it exercises.
3. Apply the minimal fix that makes the test pass without altering test semantics.

Common failure patterns after adding new templates:
- A test asserting `len(templates) == N` — update N to include the 2 new templates.
- A test iterating all templates to verify they compile — ensure both new template directories have valid Go source.
- A test checking `manifest.json` structure — ensure the new entries match the required schema.

### Step 4: Add tests for the new 0G templates

If there are no tests that verify the 0G templates are registered and produce valid scaffolds, add them. Create or update the relevant test file (e.g., `internal/template/template_test.go`):

```go
func TestTemplateRegistry_Contains0GTemplates(t *testing.T) {
    registry := LoadRegistry()

    names := make(map[string]bool)
    for _, tmpl := range registry.Templates() {
        names[tmpl.Name] = true
    }

    require.True(t, names["0g-agent"], "expected 0g-agent in template registry")
    require.True(t, names["0g-inft-build"], "expected 0g-inft-build in template registry")
}

func TestTemplateScaffold_0gAgent(t *testing.T) {
    dir := t.TempDir()
    err := ScaffoldTemplate("0g-agent", dir)
    require.NoError(t, err)

    // Verify key files are present
    assert.FileExists(t, filepath.Join(dir, "go.mod"))
    assert.FileExists(t, filepath.Join(dir, "Justfile"))
    assert.FileExists(t, filepath.Join(dir, "cmd", "agent", "main.go"))
    assert.FileExists(t, filepath.Join(dir, "internal", "zerog", "chain.go"))
}

func TestTemplateScaffold_0gInftBuild(t *testing.T) {
    dir := t.TempDir()
    err := ScaffoldTemplate("0g-inft-build", dir)
    require.NoError(t, err)

    assert.FileExists(t, filepath.Join(dir, "go.mod"))
    assert.FileExists(t, filepath.Join(dir, "Justfile"))
    assert.FileExists(t, filepath.Join(dir, "cmd", "mint", "main.go"))
    assert.FileExists(t, filepath.Join(dir, "internal", "crypto", "encrypt.go"))
}
```

Adapt function names to the actual API in the hiero-plugin codebase.

### Step 5: Re-run and confirm

```bash
cd projects/hiero-plugin && just test
```

Confirm output ends with `ok` for every package and the total pass count is at least 37 + the new tests.

## Done When

- [ ] All requirements met
- [ ] `just test` exits 0 and all packages show `ok` in the output
