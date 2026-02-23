---
fest_type: task
fest_id: 02_add_0g_test_coverage.md
fest_name: add 0g test coverage
fest_parent: 04_hiero_submission_prep
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.794567-07:00
fest_updated: 2026-02-23T13:51:54.001767-07:00
fest_tracking: true
---


# Task: Add 0G Template Test Coverage

## Objective

Add the `0g-agent` and `0g-inft-build` templates to the mock data in `handlers.test.ts` so that `init --template 0g-agent` is covered by tests.

## Requirements

- [ ] `projects/hiero-plugin/src/__tests__/handlers.test.ts` mock for `listTemplates` returns all 5 templates (currently only returns 3 Hedera ones)
- [ ] A test case verifies `initHandler` succeeds with `--template 0g-agent`

## Implementation

### Step 1: Update the mock

In `projects/hiero-plugin/src/__tests__/handlers.test.ts`, find the mock for `listTemplates` or `getTemplate`. It currently returns an array of 3 templates. Add the two 0G templates:

```typescript
{ id: '0g-agent', name: '0G Agent', description: 'Go agent with 0G Compute/Storage' },
{ id: '0g-inft-build', name: '0G iNFT Build', description: 'ERC-7857 iNFT minting with 0G DA' },
```

### Step 2: Add a test case

Add a test in the `initHandler` describe block:

```typescript
it('should succeed with 0g-agent template', async () => {
  const result = await initHandler({
    args: { name: 'test-project' },
    options: { template: '0g-agent' },
    // ... rest of mock args
  });
  expect(result.status).toBe('success');
});
```

### Step 3: Run tests

```bash
cd projects/hiero-plugin && npm test
```

## Done When

- [ ] All requirements met
- [ ] `npm test` passes with the new 0G template test cases and total test count increases