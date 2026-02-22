---
fest_type: task
fest_id: 02_verify_mock_mode.md
fest_name: verify mock mode
fest_parent: 06_docker_verify
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:54.724341-07:00
fest_tracking: true
---

# Task: Verify Mock Mode Dashboard Renders

## Objective

Run `just demo` to start the full Docker stack in mock mode and verify that all five dashboard panels (agent status, economy cycle, Hedera transactions, P&L, network graph) render correctly with mock data in the browser.

## Requirements

- [ ] `just demo` starts the stack without errors
- [ ] All containers reach a running state within 60 seconds
- [ ] The dashboard is accessible at `http://localhost:3000` (or the configured port)
- [ ] All 5 panels render with populated mock data — no blank panels, no loading spinners that never resolve, no console errors
- [ ] `just demo` can be stopped cleanly with Ctrl+C or `docker compose down`

## Implementation

### Step 1: Start the demo stack

```bash
just demo
```

Watch the docker compose output for any immediate failures (container exit codes, port conflicts).

### Step 2: Wait for services to be healthy

```bash
docker compose ps
```

All services should show `running` or `healthy` status. If a service is `exiting`, check its logs:

```bash
docker compose logs <service-name>
```

### Step 3: Open the dashboard in a browser

Navigate to `http://localhost:3000` (or whatever port is mapped by docker-compose.demo.yml).

Verify each of the 5 panels:

1. **Agent Status panel** — shows coordinator, inference, and defi agent status indicators (should show "running" or mock status)
2. **Economy Cycle panel** — shows the three-agent economy cycle visualization with mock transaction flow
3. **Hedera Transactions panel** — shows a list of mock Hedera testnet transactions with timestamps and amounts
4. **P&L panel** — shows a mock profit/loss chart or summary for the agent-defi component
5. **Network Graph panel** — shows a visual graph of agent-to-agent connections or network topology

### Step 4: Check browser console for errors

Open browser developer tools (F12) and check the Console tab. Fix any errors that prevent panel data from loading.

Common mock mode issues:
- The dashboard expects a WebSocket or REST endpoint from the coordinator that is not running in demo mode
- Environment variable `MOCK_MODE=true` is missing from docker-compose.demo.yml
- A panel component crashes with a JavaScript error when mock data has an unexpected shape

### Step 5: Fix any non-rendering panels

If a panel is blank or stuck loading:
- Read the panel's component source to find what data it expects
- Read docker-compose.demo.yml to verify the mock data environment variables are set
- Add or correct the relevant `MOCK_*` env var in docker-compose.demo.yml

### Step 6: Teardown

```bash
docker compose down
```

Confirm the stack stops cleanly with no orphaned containers.

## Done When

- [ ] All requirements met
- [ ] All 5 dashboard panels render with mock data and no browser console errors
