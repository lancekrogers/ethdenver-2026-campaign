---
fest_type: task
fest_id: 03_add_healthchecks.md
fest_name: add healthchecks
fest_parent: 06_docker_verify
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:54.72466-07:00
fest_tracking: true
---

# Task: Add Healthchecks to docker-compose.yml

## Objective

Add a `healthcheck` block to each of the four services (coordinator, inference, defi, dashboard) in docker-compose.yml so Docker can track service health, enabling `docker compose ps` to report meaningful status and making the demo stack reliably observable.

## Requirements

- [ ] `docker-compose.yml` has a `healthcheck:` block for the `coordinator` service
- [ ] `docker-compose.yml` has a `healthcheck:` block for the `agent-inference` service
- [ ] `docker-compose.yml` has a `healthcheck:` block for the `agent-defi` service
- [ ] `docker-compose.yml` has a `healthcheck:` block for the `dashboard` service
- [ ] After `just demo`, `docker compose ps` shows all 4 services as `healthy` within 2 minutes
- [ ] Healthcheck intervals are set to 10s with a 5s timeout and 3 retries

## Implementation

### Step 1: Determine health endpoints for each service

Read each service's source code to find its health endpoint:

- **coordinator**: look for `/health`, `/healthz`, or `/ready` HTTP handler in `projects/agent-coordinator/`
- **agent-inference**: look for the same in `projects/agent-inference/`
- **agent-defi**: look for the same in `projects/agent-defi/`
- **dashboard**: look for Next.js API route `/api/health` or nginx `location /health` in `projects/dashboard/`

If a service does not expose a health endpoint, add one — a minimal HTTP handler returning `{"status":"ok"}` with HTTP 200 is sufficient.

### Step 2: Read the current docker-compose.yml

```
projects/docker-compose.yml
```

Note the service names and which ports are exposed so the healthcheck `test` commands use the correct ports.

### Step 3: Add healthcheck blocks

For each Go agent service (coordinator, inference, defi):

```yaml
healthcheck:
  test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080/health"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 15s
```

Replace `8080` with the actual port each service listens on. Use `wget` rather than `curl` since Alpine-based images typically have `wget` but not `curl`.

For the dashboard service:

```yaml
healthcheck:
  test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/api/health"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 20s
```

### Step 4: Complete docker-compose.yml healthcheck example

After reading the actual service names and ports, the diff should look roughly like this:

```yaml
services:
  coordinator:
    image: agent-coordinator
    ports:
      - "8081:8081"
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8081/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 15s

  agent-inference:
    image: agent-inference
    ports:
      - "8082:8082"
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8082/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 15s

  agent-defi:
    image: agent-defi
    ports:
      - "8083:8083"
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8083/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 15s

  dashboard:
    image: dashboard
    ports:
      - "3000:3000"
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 20s
```

Adapt port numbers and service names to the actual configuration.

### Step 5: Implement missing health endpoints

If any service lacks a `/health` endpoint, add a minimal one.

For a Go service, add to the main HTTP mux setup:

```go
mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(`{"status":"ok"}`))
})
```

For the Next.js dashboard, create `projects/dashboard/src/app/api/health/route.ts`:

```typescript
import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({ status: 'ok' });
}
```

### Step 6: Verify healthchecks work

```bash
just demo
sleep 60
docker compose ps
```

All 4 services must show `(healthy)` in the STATUS column. If any show `(unhealthy)`, run:

```bash
docker inspect <container-name> | grep -A 20 '"Health"'
```

to see the healthcheck failure output and fix accordingly.

## Done When

- [ ] All requirements met
- [ ] `docker compose ps` shows all 4 services as `(healthy)` after `just demo`
