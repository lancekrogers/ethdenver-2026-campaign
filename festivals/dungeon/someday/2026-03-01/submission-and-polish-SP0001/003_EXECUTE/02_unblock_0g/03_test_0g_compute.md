---
fest_type: task
fest_id: 03_test_0g_compute.md
fest_name: test_0g_compute
fest_parent: 02_unblock_0g
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Test 0G Compute Integration

**Task Number:** 03 | **Sequence:** 02_unblock_0g | **Autonomy:** medium

## Objective

Run the inference agent against the live Galileo testnet with the corrected ABI and verify that provider discovery works and inference requests can be submitted. Document the exact outcome — success or specific failure — so blockers are clearly identified.

## Requirements

- [ ] Agent connects to Galileo testnet RPC (`https://evmrpc-testnet.0g.ai`) without error
- [ ] `listFromChain()` returns at least one provider (or documents why none exist)
- [ ] At least one test inference request is submitted to a discovered provider
- [ ] Outcome is documented: success logs or specific error message
- [ ] If inference fails, the root cause is identified and documented

## Prerequisites

- Task 01 complete: `ZG_SERVING_CONTRACT` set in `.env`
- Task 02 complete: ABI fixed in `broker.go`
- `just build` passes

## Implementation

### Step 1: Verify testnet connectivity

```bash
# Confirm the RPC endpoint is reachable
curl -s -X POST https://evmrpc-testnet.0g.ai \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
# Expected: {"result":"0x40da"} (0x40da = 16602 decimal)
```

### Step 2: Verify provider discovery via the contract

Use `cast` or a small Go test to call `getAllServices` directly:

```bash
cast call --rpc-url https://evmrpc-testnet.0g.ai \
  0xa79F4c8311FF93C06b8CfB403690cc987c93F91E \
  "getAllServices(uint256,uint256)" 0 100
```

Record the raw output. If the response is empty (no providers registered), document that and proceed to Step 3 using the HTTP fallback endpoint.

### Step 3: Run the inference agent

```bash
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
just run
```

Or if a specific test binary or integration test exists:

```bash
go test ./internal/zerog/compute/... -v -run Integration -count=1
```

Watch the logs for:
- `listFromChain` result (number of providers found)
- Provider URL selected for the test request
- HTTP response from the provider

### Step 4: Submit a test inference request

If the agent has a CLI or HTTP interface for triggering inference:

```bash
# Example — adjust to the actual agent CLI flags
./bin/agent-inference --test-inference \
  --model "llama-3-8b" \
  --prompt "Summarize the role of AI agents in DeFi in one sentence."
```

If no CLI flag exists, write a small integration test or use the existing test harness.

### Step 5: Document results

Create `results/compute_test_results.md` in this sequence directory:

```markdown
# 0G Compute Test Results

**Date:** 2026-02-21
**Contract:** 0xa79F4c8311FF93C06b8CfB403690cc987c93F91E
**Chain:** Galileo testnet (chain ID 16602)
**RPC:** https://evmrpc-testnet.0g.ai

## Provider Discovery

getAllServices(0, 100) returned:
- Count: [N]
- Providers: [list addresses and URLs]

## Inference Test

- Model requested: [model ID]
- Provider URL used: [URL]
- Request status: [Success / Failed]
- Response excerpt: [first 200 chars of response or error message]

## Issues Encountered

[Any errors, retries, or unexpected behavior]

## Conclusion

[Pass / Fail / Partial — and what remains blocked]
```

## Done When

- [ ] Galileo testnet RPC connectivity confirmed
- [ ] `getAllServices` call documented (with result count)
- [ ] At least one inference request submitted (success or specific error documented)
- [ ] `results/compute_test_results.md` written with findings
- [ ] If inference fails, root cause identified and documented for the iterate gate
