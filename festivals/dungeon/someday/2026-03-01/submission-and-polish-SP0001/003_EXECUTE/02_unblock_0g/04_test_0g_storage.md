---
fest_type: task
fest_id: 04_test_0g_storage.md
fest_name: test_0g_storage
fest_parent: 02_unblock_0g
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Test 0G Storage Integration

**Task Number:** 04 | **Sequence:** 02_unblock_0g | **Autonomy:** medium

## Objective

Verify that 0G Storage upload and download work correctly using the Flow contract at `0x22E03a6A89B950F1c82ec5e74F8eCa321a105296` on Galileo testnet. Test storing and retrieving an inference result as a concrete end-to-end storage proof.

## Requirements

- [ ] 0G Storage client connects to Galileo testnet
- [ ] A test payload (simulated inference result) can be uploaded to 0G Storage
- [ ] The uploaded payload can be retrieved by its content hash or storage ID
- [ ] The retrieved content matches the uploaded content byte-for-byte
- [ ] Outcome documented in `results/storage_test_results.md`

## Context

- Flow contract address: `0x22E03a6A89B950F1c82ec5e74F8eCa321a105296`
- Chain: Galileo testnet (chain ID 16602)
- The storage layer is used by the inference agent to persist results on-chain so the coordinator and auditors can verify outputs

## Implementation

### Step 1: Locate the storage package

```bash
find /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference \
  -type f -name "*.go" | xargs grep -l "storage\|Storage\|flow\|Flow" | head -20
```

Identify the existing storage client code (likely under `internal/zerog/storage/`).

### Step 2: Verify Flow contract connectivity

```bash
cast call --rpc-url https://evmrpc-testnet.0g.ai \
  0x22E03a6A89B950F1c82ec5e74F8eCa321a105296 \
  "name()(string)"
```

This confirms the contract is live and accessible.

### Step 3: Run the storage upload test

Use the existing storage integration test or run the agent with a storage test flag:

```bash
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
go test ./internal/zerog/storage/... -v -run Integration -count=1
```

If no integration test exists, write a minimal one or use the `just run` path with a flag that exercises the storage path.

The test payload should be a small JSON object representing an inference result:

```json
{
  "job_id": "test-storage-001",
  "model": "llama-3-8b",
  "output": "AI agents in DeFi automate trading decisions using real-time on-chain data.",
  "tokens_used": 22,
  "timestamp": "2026-02-21T09:45:00Z"
}
```

### Step 4: Verify download

After upload completes, retrieve the content using the returned storage ID or content hash:

```bash
# Use the storage client's retrieve method
go test ./internal/zerog/storage/... -v -run IntegrationRetrieve -count=1
```

Verify the retrieved bytes match the original payload.

### Step 5: Document results

Create `results/storage_test_results.md`:

```markdown
# 0G Storage Test Results

**Date:** 2026-02-21
**Flow Contract:** 0x22E03a6A89B950F1c82ec5e74F8eCa321a105296
**Chain:** Galileo testnet (chain ID 16602)

## Upload Test

- Payload size: [N bytes]
- Upload transaction hash: [txhash]
- Storage ID / content hash: [ID]
- Upload duration: [N ms]

## Download Test

- Retrieved by: [content hash / storage ID]
- Content matches original: [Yes / No]
- Download duration: [N ms]

## Issues Encountered

[Any errors or unexpected behavior]

## Conclusion

[Pass / Fail / Partial]
```

## Done When

- [ ] Flow contract connectivity confirmed
- [ ] Test payload successfully uploaded to 0G Storage
- [ ] Uploaded content successfully retrieved and verified to match
- [ ] `results/storage_test_results.md` written with transaction hash and findings
- [ ] If storage fails, root cause documented for iterate gate
