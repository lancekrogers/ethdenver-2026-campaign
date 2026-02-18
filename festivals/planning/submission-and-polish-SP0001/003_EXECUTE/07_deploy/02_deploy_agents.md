---
fest_type: task
fest_id: 02_deploy_agents.md
fest_name: deploy_agents
fest_parent: 07_deploy
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Deploy All Agents to Testnet

**Task Number:** 02 | **Sequence:** 07_deploy | **Autonomy:** medium

## Objective

Deploy all three agents (coordinator, inference, defi) to run persistently on testnet. Verify heartbeats, HCS messaging, and active trading. These agents must stay running for judges to observe live behavior.

## Requirements

- [ ] Coordinator agent deployed and running persistently
- [ ] Inference agent deployed and running persistently
- [ ] DeFi agent deployed and running persistently
- [ ] All agents producing HCS heartbeat messages
- [ ] HCS messaging between agents verified (task assignment, status updates)
- [ ] DeFi agent executing trades (or ready to trade on signal)
- [ ] Agents survive for at least 1 hour without manual intervention

## Implementation

### Step 1: Prepare deployment environment

Decide on the deployment approach:

- **Option A**: Deploy to a cloud server (e.g., a small VPS) with process supervision (systemd, supervisord, or Docker)
- **Option B**: Deploy as Docker containers with restart policies
- **Option C**: Run locally with a process manager (for hackathon, this may be sufficient if the machine stays on)

Ensure the deployment environment has:

- Go runtime (if running binaries) or Docker
- Network access to Hedera testnet and Base testnet
- Sufficient testnet HBAR and tokens for ongoing operation
- Environment variables configured for all three agents

### Step 2: Deploy the coordinator agent

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator

# Build the binary
go build -o bin/coordinator cmd/coordinator/main.go

# Deploy with process supervision (example with nohup for simplicity)
nohup ./bin/coordinator --config config/testnet.yaml > logs/coordinator.log 2>&1 &
echo $! > coordinator.pid

# Verify it started
tail -f logs/coordinator.log
# Look for: "Coordinator started", heartbeat messages
```

### Step 3: Deploy the inference agent

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference

go build -o bin/inference cmd/agent/main.go

nohup ./bin/inference --config config/testnet.yaml > logs/inference.log 2>&1 &
echo $! > inference.pid

tail -f logs/inference.log
# Look for: "Agent registered with coordinator", heartbeat messages
```

### Step 4: Deploy the DeFi agent

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi

go build -o bin/defi cmd/agent/main.go

nohup ./bin/defi --config config/testnet.yaml > logs/defi.log 2>&1 &
echo $! > defi.pid

tail -f logs/defi.log
# Look for: "Agent registered with coordinator", heartbeat messages, trade activity
```

### Step 5: Verify inter-agent communication

After all three agents are running, verify:

1. **Heartbeats**: All three agents producing heartbeat messages on HCS (visible in coordinator logs or dashboard)
2. **Task Assignment**: Trigger a task and verify the coordinator assigns it via HCS
3. **Status Updates**: Verify the assigned agent sends status updates back via HCS
4. **Payment**: Verify HTS payment settles after task completion

### Step 6: Verify persistence

Wait at least 15 minutes and verify:

- All agent processes are still running (`ps aux | grep coordinator`, etc.)
- Heartbeat messages continue flowing
- No crash logs or error spikes
- Memory and CPU usage are stable

### Step 7: Document deployment details

Record:

- Where each agent is running (host, port, process ID)
- Configuration used (config file path, key environment variables -- not secrets)
- How to restart if needed (commands)
- How to check logs
- Agent account IDs on testnet

## Done When

- [ ] All three agents deployed and running
- [ ] Heartbeats verified for all agents
- [ ] Inter-agent HCS messaging verified
- [ ] Agents running for at least 15 minutes without issues
- [ ] Deployment details documented
- [ ] Restart procedures documented
