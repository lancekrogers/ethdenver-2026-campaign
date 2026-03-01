---
fest_type: task
fest_id: 02_docker_compose.md
fest_name: docker_compose
fest_parent: 10_local_docker_test
fest_order: 2
fest_status: pending
fest_autonomy: high
fest_created: 2026-02-21T13:00:00-07:00
fest_tracking: true
---

# Task: Create Docker Compose

**Task Number:** 02 | **Sequence:** 10_local_docker_test | **Autonomy:** high

## Objective

Create a `docker-compose.yml` at the project root that orchestrates all 4 services with environment variables, networking, health checks, and proper dependency ordering.

## Requirements

- [ ] `docker-compose.yml` created at the campaign root
- [ ] All 4 services defined: coordinator, defi, inference, dashboard
- [ ] Environment variables configurable via `.env` file
- [ ] Health checks defined for each service
- [ ] Service dependencies ensure correct startup order
- [ ] Shared network for inter-service communication

## Implementation

### Step 1: Determine required environment variables

Read each agent's configuration to identify required env vars. At minimum:

- **All agents**: `HEDERA_OPERATOR_ID`, `HEDERA_OPERATOR_KEY`, `HEDERA_NETWORK` (testnet)
- **Coordinator**: Port for WebSocket, HCS topic IDs
- **Dashboard**: `NEXT_PUBLIC_COORDINATOR_WS_URL` (points to coordinator container)

Check each project's README, `.env.example`, or config code for the full list.

### Step 2: Create `.env.example`

Create a `.env.example` at the campaign root with all required variables (no real credentials):

```env
# Hedera Testnet Credentials
HEDERA_OPERATOR_ID=0.0.XXXXX
HEDERA_OPERATOR_KEY=302e...
HEDERA_NETWORK=testnet

# Service Ports
COORDINATOR_PORT=8080
DASHBOARD_PORT=3000

# Agent Configuration
# Add project-specific vars as discovered in Step 1
```

### Step 3: Create docker-compose.yml

```yaml
services:
  coordinator:
    build:
      context: ./projects/agent-coordinator
    env_file: .env
    ports:
      - "${COORDINATOR_PORT:-8080}:8080"
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:8080/health"]
      interval: 10s
      timeout: 5s
      retries: 3
    networks:
      - agent-network

  defi:
    build:
      context: ./projects/agent-defi
    env_file: .env
    depends_on:
      coordinator:
        condition: service_healthy
    networks:
      - agent-network

  inference:
    build:
      context: ./projects/agent-inference
    env_file: .env
    depends_on:
      coordinator:
        condition: service_healthy
    networks:
      - agent-network

  dashboard:
    build:
      context: ./projects/dashboard
    env_file: .env
    ports:
      - "${DASHBOARD_PORT:-3000}:3000"
    depends_on:
      coordinator:
        condition: service_healthy
    environment:
      - NEXT_PUBLIC_COORDINATOR_WS_URL=ws://coordinator:8080/ws
    networks:
      - agent-network

networks:
  agent-network:
    driver: bridge
```

Adjust ports, health check endpoints, and env vars based on actual project configuration discovered in Step 1.

### Step 4: Create .dockerignore files

Add `.dockerignore` to each project to exclude unnecessary files from the build context:

**Go agents:**
```
bin/
*.md
docs/
.git/
```

**Dashboard:**
```
node_modules/
.next/
coverage/
*.md
.git/
```

## Done When

- [ ] `docker-compose.yml` exists at campaign root with all 4 services
- [ ] `.env.example` documents all required environment variables
- [ ] Health checks are configured for services that expose HTTP endpoints
- [ ] `.dockerignore` files minimize build context size
- [ ] `docker compose config` validates without errors
