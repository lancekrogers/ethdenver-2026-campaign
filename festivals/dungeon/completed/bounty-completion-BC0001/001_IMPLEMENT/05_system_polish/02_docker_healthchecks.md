---
fest_type: task
fest_id: 02_docker_healthchecks.md
fest_name: docker healthchecks
fest_parent: 05_system_polish
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.811548-07:00
fest_updated: 2026-02-23T13:57:06.922241-07:00
fest_tracking: true
---


# Task: Add Docker Healthchecks

## Objective

Add healthcheck blocks to all 4 services in `docker-compose.yml` so `docker compose ps` shows health status and judges can verify the system is running correctly.

## Requirements

- [ ] All 4 services (`dashboard`, `coordinator`, `inference`, `defi`) in `docker-compose.yml` have a `healthcheck` block
- [ ] `docker compose up -d && docker compose ps` shows health status for each service

## Implementation

### Step 1: Add healthchecks to docker-compose.yml

In the root `docker-compose.yml`, add healthcheck blocks to each service:

**dashboard** (Next.js on port 3000):

```yaml
healthcheck:
  test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 15s
```

**coordinator** (Go binary — add a simple /healthz endpoint or use process check):

```yaml
healthcheck:
  test: ["CMD", "pgrep", "-x", "coordinator"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 10s
```

**inference** (Go binary):

```yaml
healthcheck:
  test: ["CMD", "pgrep", "-x", "agent-inference"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 10s
```

**defi** (Go binary):

```yaml
healthcheck:
  test: ["CMD", "pgrep", "-x", "agent-defi"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 10s
```

### Step 2: Verify

```bash
just docker build-all
just docker up-all
docker compose ps
```

All services should show `healthy` or `starting` in the status column.

### Step 3: Validate compose config

```bash
docker compose config --quiet && echo "docker-compose.yml is valid"
```

## Done When

- [ ] All requirements met
- [ ] `docker compose ps` shows health status for all 4 services after `just docker up-all`