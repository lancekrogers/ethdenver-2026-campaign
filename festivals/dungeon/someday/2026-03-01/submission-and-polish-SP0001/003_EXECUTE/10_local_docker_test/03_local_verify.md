---
fest_type: task
fest_id: 03_local_verify.md
fest_name: local_verify
fest_parent: 10_local_docker_test
fest_order: 3
fest_status: pending
fest_autonomy: high
fest_created: 2026-02-21T13:00:00-07:00
fest_tracking: true
---

# Task: Local Verification

**Task Number:** 03 | **Sequence:** 10_local_docker_test | **Autonomy:** high

## Objective

Build all Docker images, bring up the Compose stack, and verify that all services start successfully, agents connect to Hedera testnet, and the dashboard connects to the coordinator WebSocket.

## Requirements

- [ ] All 4 Docker images build without errors
- [ ] `docker compose up` starts all services
- [ ] Health checks pass for all services
- [ ] Agents connect to Hedera testnet (visible in logs)
- [ ] Dashboard is accessible at `http://localhost:3000`
- [ ] Dashboard connects to coordinator WebSocket (visible in browser console or network tab)

## Implementation

### Step 1: Ensure .env is configured

Copy `.env.example` to `.env` and fill in real testnet credentials:

```bash
cp .env.example .env
# Edit .env with actual Hedera testnet credentials
```

### Step 2: Build all images

```bash
docker compose build
```

Document any build failures and fix them in the Dockerfiles (return to task 01 if needed).

### Step 3: Start the stack

```bash
docker compose up -d
```

### Step 4: Check service health

```bash
# Wait for services to start
sleep 15

# Check all containers are running
docker compose ps

# Check health status
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}"
```

All services should show `Up` status. Services with health checks should show `healthy`.

### Step 5: Verify agent logs

```bash
# Check coordinator logs for startup and HCS connection
docker compose logs coordinator | tail -30

# Check defi agent logs
docker compose logs defi | tail -30

# Check inference agent logs
docker compose logs inference | tail -30
```

Look for:
- Successful startup messages
- Hedera client initialization
- HCS topic subscription (coordinator)
- No fatal errors or panics

### Step 6: Verify dashboard

```bash
# Check dashboard is responding
curl -s http://localhost:3000 | head -5

# Check dashboard logs for WebSocket connection
docker compose logs dashboard | tail -20
```

Open `http://localhost:3000` in a browser and verify:
- Page loads without errors
- WebSocket connection to coordinator is established (check browser dev tools Network tab)

### Step 7: Tear down

```bash
docker compose down
```

### Step 8: Document results

Record the verification results:
- Which services started successfully
- Any issues encountered and how they were resolved
- Screenshot or log excerpt showing healthy stack

## Done When

- [ ] `docker compose build` succeeds for all 4 services
- [ ] `docker compose up` starts all containers without crashes
- [ ] Health checks pass (where configured)
- [ ] Agent logs show testnet connectivity
- [ ] Dashboard loads and connects to coordinator
- [ ] Stack tears down cleanly with `docker compose down`
