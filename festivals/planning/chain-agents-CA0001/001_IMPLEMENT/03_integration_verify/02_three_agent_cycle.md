---
fest_type: task
fest_id: 02_three_agent_cycle.md
fest_name: three_agent_cycle
fest_parent: 03_integration_verify
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Three-Agent Cycle Verification

## Objective

Run the complete three-agent autonomous economy cycle on testnets and verify the full flow: coordinator assigns task via HCS, inference agent executes on 0G, DeFi agent trades on Base, both report results back via HCS, and coordinator triggers HTS payment. This is the primary integration test that proves the entire system works as designed.

**Project:** `agent-coordinator` at `projects/agent-coordinator/` (orchestration)
**Also Running:** `agent-inference` and `agent-defi` as separate processes

## Requirements

- [ ] All three agents start successfully and connect to testnets
- [ ] Coordinator assigns a task to the inference agent via HCS
- [ ] Inference agent receives the task, executes on 0G, and reports results via HCS
- [ ] DeFi agent trades autonomously on Base and reports P&L via HCS
- [ ] Coordinator receives results from both agents via HCS
- [ ] Coordinator triggers HTS token payment upon receiving inference results
- [ ] Full cycle captured in logs with timestamps

## Implementation

### Step 1: Prepare environment variables

Create environment files for each agent. These contain testnet credentials and configuration.

**Coordinator environment (`/tmp/env-coordinator`):**

```bash
# Hedera Testnet
HEDERA_OPERATOR_ID=<testnet_operator_id>
HEDERA_OPERATOR_KEY=<testnet_operator_key>
HEDERA_NETWORK=testnet

# HCS Topics (create these first if they don't exist)
HEDERA_TASK_TOPIC=<task_topic_id>
HEDERA_RESULT_TOPIC=<result_topic_id>
HEDERA_HEALTH_TOPIC=<health_topic_id>

# HTS Token
HEDERA_TOKEN_ID=<payment_token_id>

# Coordinator
COORDINATOR_ID=coordinator-001
```

**Inference agent environment (`/tmp/env-inference`):**

```bash
# Hedera Testnet (same topics as coordinator)
HEDERA_OPERATOR_ID=<inference_operator_id>
HEDERA_OPERATOR_KEY=<inference_operator_key>
HEDERA_NETWORK=testnet
HEDERA_TASK_TOPIC=<task_topic_id>
HEDERA_RESULT_TOPIC=<result_topic_id>
HEDERA_HEALTH_TOPIC=<health_topic_id>

# 0G Services
ZG_COMPUTE_ENDPOINT=<0g_compute_testnet_endpoint>
ZG_COMPUTE_API_KEY=<0g_api_key>
ZG_STORAGE_ENDPOINT=<0g_storage_testnet_endpoint>
ZG_STORAGE_API_KEY=<0g_storage_key>
ZG_CHAIN_RPC=<0g_chain_testnet_rpc>
ZG_INFT_CONTRACT=<inft_contract_address>
ZG_CHAIN_PRIVATE_KEY=<0g_chain_private_key>
ZG_DA_ENDPOINT=<0g_da_testnet_endpoint>
ZG_DA_NAMESPACE=inference-agent-audit

# Agent
INFERENCE_AGENT_ID=inference-001
INFERENCE_DAEMON_ADDR=localhost:9090
INFERENCE_HEALTH_INTERVAL=30s
```

**DeFi agent environment (`/tmp/env-defi`):**

```bash
# Hedera Testnet (same topics)
HEDERA_OPERATOR_ID=<defi_operator_id>
HEDERA_OPERATOR_KEY=<defi_operator_key>
HEDERA_NETWORK=testnet
HEDERA_TASK_TOPIC=<task_topic_id>
HEDERA_RESULT_TOPIC=<result_topic_id>
HEDERA_HEALTH_TOPIC=<health_topic_id>

# Base Sepolia
BASE_RPC_ENDPOINT=https://sepolia.base.org
BASE_PRIVATE_KEY=<base_private_key>
BASE_IDENTITY_CONTRACT=<erc8004_contract_address>
BASE_DEX_ROUTER=<uniswap_v3_router_on_base_sepolia>
BASE_BUILDER_CODE=<erc8021_builder_code>
BASE_ATTRIBUTION_ENABLED=true

# Agent
DEFI_AGENT_ID=defi-001
DEFI_DAEMON_ADDR=localhost:9090
DEFI_TRADING_INTERVAL=60s
DEFI_PNL_REPORT_INTERVAL=120s
DEFI_HEALTH_INTERVAL=30s
```

Replace all `<placeholder>` values with actual testnet credentials. Use Hedera testnet faucet, 0G testnet faucet, and Base Sepolia faucet to fund the agent wallets.

### Step 2: Create HCS topics (if needed)

If the HCS topics do not already exist, create them using the coordinator:

```bash
# This may be a coordinator CLI command or a separate setup script
# The coordinator should have topic creation capability from HF0001
```

Record the topic IDs in all three environment files.

### Step 3: Start the three agents

Open three terminal sessions (or use a process manager). Start each agent with its environment:

**Terminal 1 -- Coordinator:**

```bash
source /tmp/env-coordinator
/tmp/agent-coordinator 2>&1 | tee /tmp/log-coordinator.txt
```

**Terminal 2 -- Inference Agent:**

Wait for coordinator to show "ready" in logs, then:

```bash
source /tmp/env-inference
/tmp/agent-inference 2>&1 | tee /tmp/log-inference.txt
```

**Terminal 3 -- DeFi Agent:**

```bash
source /tmp/env-defi
/tmp/agent-defi 2>&1 | tee /tmp/log-defi.txt
```

Alternatively, create a shell script that starts all three:

```bash
#!/bin/bash
# integration-test.sh

# Start coordinator in background
source /tmp/env-coordinator
/tmp/agent-coordinator 2>&1 | tee /tmp/log-coordinator.txt &
COORD_PID=$!
sleep 10  # Wait for coordinator to initialize

# Start inference agent
source /tmp/env-inference
/tmp/agent-inference 2>&1 | tee /tmp/log-inference.txt &
INFER_PID=$!
sleep 5

# Start DeFi agent
source /tmp/env-defi
/tmp/agent-defi 2>&1 | tee /tmp/log-defi.txt &
DEFI_PID=$!

echo "All agents started: coordinator=$COORD_PID inference=$INFER_PID defi=$DEFI_PID"
echo "Press Ctrl+C to stop all agents"

# Wait for interrupt
trap "kill $COORD_PID $INFER_PID $DEFI_PID; wait" SIGINT SIGTERM
wait
```

### Step 4: Verify the inference cycle

Watch the logs for the following sequence:

1. **Coordinator log**: "assigning task to inference agent" with task ID and HCS topic message
2. **Inference log**: "received task assignment" with the matching task ID
3. **Inference log**: "submitting inference job to 0G Compute" with model ID
4. **Inference log**: "inference job completed" with result
5. **Inference log**: "storing result on 0G Storage" with content ID
6. **Inference log**: "minting iNFT" with token ID
7. **Inference log**: "publishing audit event to 0G DA" with submission ID
8. **Inference log**: "publishing result to coordinator" via HCS
9. **Coordinator log**: "received inference result" with task ID, content ID, iNFT token ID
10. **Coordinator log**: "triggering HTS payment" for completed inference task

Record the timestamps and transaction hashes for each step.

### Step 5: Verify the DeFi cycle

Watch the DeFi agent logs for:

1. **DeFi log**: "registered identity on Base" with ERC-8004 transaction hash
2. **DeFi log**: "evaluating market state" with price data
3. **DeFi log**: "strategy signal: buy/sell" with reasoning
4. **DeFi log**: "executing trade on Base" with swap details
5. **DeFi log**: "trade executed" with transaction hash and gas cost
6. **DeFi log**: "P&L report: revenue=X gas=Y net=Z self_sustaining=true/false"
7. **DeFi log**: "publishing P&L report via HCS"
8. **Coordinator log**: "received P&L report from DeFi agent"

### Step 6: Verify HCS message flow

Confirm that all HCS messages are flowing correctly:

- [ ] Coordinator publishes task_assignment, inference agent receives it
- [ ] Inference agent publishes task_result, coordinator receives it
- [ ] DeFi agent publishes pnl_report, coordinator receives it
- [ ] Both agents publish health_status, coordinator receives them
- [ ] Sequence numbers increment correctly per sender
- [ ] No message parsing errors in any agent's logs

### Step 7: Verify HTS payment

After the coordinator receives inference results:

- [ ] Coordinator triggers HTS token transfer
- [ ] Transaction hash visible in coordinator logs
- [ ] Payment amount matches the expected reward
- [ ] Payment is visible on Hedera testnet explorer (hashscan.io)

### Step 8: Capture artifacts

Save all evidence for bounty submissions:

```bash
# Copy logs
cp /tmp/log-coordinator.txt /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator/docs/integration/
cp /tmp/log-inference.txt /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator/docs/integration/
cp /tmp/log-defi.txt /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator/docs/integration/
```

Record all transaction hashes, topic IDs, token IDs, content IDs, and iNFT token IDs in a summary document.

### Step 9: Graceful shutdown test

Send SIGINT to all three agents and verify:

- [ ] Each agent logs "shutting down gracefully"
- [ ] No panics or unhandled errors
- [ ] All goroutines exit cleanly
- [ ] Agents stop within 5 seconds

## Done When

- [ ] All three agents started and connected to testnets
- [ ] Inference cycle completed: coordinator -> HCS -> inference -> 0G -> HCS -> coordinator -> HTS
- [ ] DeFi cycle running: strategy -> trade -> P&L -> HCS -> coordinator
- [ ] All HCS messages flowing correctly between all three agents
- [ ] HTS payment triggered and confirmed
- [ ] All logs captured and saved
- [ ] Transaction hashes recorded for all on-chain operations
- [ ] Graceful shutdown verified for all three agents
- [ ] Integration test can be repeated (documented steps)
