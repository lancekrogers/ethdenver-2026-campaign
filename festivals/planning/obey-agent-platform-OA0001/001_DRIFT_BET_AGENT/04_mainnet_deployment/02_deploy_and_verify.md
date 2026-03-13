---
fest_type: task
fest_id: 02_deploy_and_verify.md
fest_name: deploy_and_verify
fest_parent: 04_mainnet_deployment
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.336556-06:00
fest_tracking: true
---

# Task: Mainnet Deployment and Verification

## Objective

Deploy the prediction market agent to a VPS/server as a Docker container, configure it for Solana mainnet with real Drift BET trading, verify it executes at least one full trading cycle successfully, and set up basic monitoring and alerting.

## Requirements

- [ ] Dockerfile that builds the agent binary
- [ ] Docker Compose with environment variable configuration
- [ ] Deployment script for initial launch on a VPS
- [ ] Pre-flight checks: wallet balance, Drift API reachability, Claude API key valid
- [ ] First-cycle verification: agent starts, fetches markets, analyzes, and logs signals
- [ ] Structured JSON logging to stdout (Docker-friendly)
- [ ] Graceful shutdown on SIGINT/SIGTERM
- [ ] Basic health monitoring via log output

## Implementation

### Step 1: Create Dockerfile

Create file `projects/agent-prediction/Dockerfile`:

```dockerfile
# Build stage
FROM golang:1.26-alpine AS builder

RUN apk add --no-cache git ca-certificates

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /agent-prediction ./cmd/agent/

# Runtime stage
FROM alpine:3.19

RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /agent-prediction /usr/local/bin/agent-prediction

# Non-root user
RUN adduser -D -u 1000 agent
USER agent

ENTRYPOINT ["/usr/local/bin/agent-prediction"]
```

### Step 2: Create Docker Compose

Create file `projects/agent-prediction/docker-compose.yml`:

```yaml
version: "3.9"

services:
  agent-prediction:
    build: .
    container_name: obey-predictor
    restart: unless-stopped
    env_file:
      - .env
    environment:
      - PRED_LOG_LEVEL=info
    logging:
      driver: json-file
      options:
        max-size: "50m"
        max-file: "5"
    healthcheck:
      test: ["CMD", "true"]  # Agent logs health; external monitoring via logs
      interval: 5m
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: "0.5"
```

### Step 3: Create Deployment Script

Create file `projects/agent-prediction/scripts/deploy.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# OBEY Prediction Agent - Deployment Script
# Usage: ./scripts/deploy.sh [--mock]

MOCK_MODE="${1:-}"
ENV_FILE=".env"

echo "=== OBEY Prediction Agent Deployment ==="

# Step 1: Verify environment file exists
if [[ ! -f "$ENV_FILE" ]]; then
    echo "ERROR: .env file not found. Copy .env.example to .env and configure it."
    exit 1
fi

# Step 2: Source environment for pre-flight checks
set -a
source "$ENV_FILE"
set +a

# Step 3: Pre-flight checks
echo ""
echo "--- Pre-flight Checks ---"

# Check required vars
if [[ "$MOCK_MODE" == "--mock" ]]; then
    echo "[OK] Running in MOCK mode"
    export PRED_MOCK_MODE=true
else
    if [[ -z "${PRED_SOLANA_PRIVATE_KEY:-}" ]]; then
        echo "[FAIL] PRED_SOLANA_PRIVATE_KEY not set"
        exit 1
    fi
    echo "[OK] Solana private key configured"

    if [[ -z "${PRED_CLAUDE_API_KEY:-}" ]]; then
        echo "[FAIL] PRED_CLAUDE_API_KEY not set"
        exit 1
    fi
    echo "[OK] Claude API key configured"

    # Test Solana RPC
    RPC_URL="${PRED_SOLANA_RPC_URL:-https://api.mainnet-beta.solana.com}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "$RPC_URL" \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","id":1,"method":"getHealth"}' 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" == "200" ]]; then
        echo "[OK] Solana RPC reachable ($RPC_URL)"
    else
        echo "[WARN] Solana RPC may be unreachable (HTTP $HTTP_CODE)"
    fi

    # Test Claude API
    CLAUDE_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "https://api.anthropic.com/v1/messages" \
        -H "x-api-key: $PRED_CLAUDE_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -H "Content-Type: application/json" \
        -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"ping"}]}' 2>/dev/null || echo "000")

    if [[ "$CLAUDE_CODE" == "200" ]]; then
        echo "[OK] Claude API reachable and key valid"
    else
        echo "[WARN] Claude API check returned HTTP $CLAUDE_CODE"
    fi

    # Test Drift API
    DRIFT_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        "${PRED_DRIFT_BASE_URL:-https://mainnet-beta.api.drift.trade}/health" 2>/dev/null || echo "000")
    echo "[INFO] Drift API check: HTTP $DRIFT_CODE"
fi

echo ""
echo "--- Building and Deploying ---"

# Step 4: Build and run
docker compose build
docker compose up -d

echo ""
echo "--- Deployment Complete ---"
echo "Container: obey-predictor"
echo "Logs: docker compose logs -f"
echo ""

# Step 5: Tail logs for first cycle
echo "Waiting for first trading cycle (30 seconds)..."
sleep 5
docker compose logs --tail=50
```

### Step 4: Create Pre-flight Check in Agent

Add to `projects/agent-prediction/internal/agent/agent.go`, a `Preflight` method:

```go
// Preflight runs pre-start checks to verify all dependencies are reachable.
func (a *Agent) Preflight(ctx context.Context) error {
	a.log.Info("running pre-flight checks")

	// Check 1: Can we list markets?
	markets, err := a.adapter.ListMarkets(ctx)
	if err != nil {
		return fmt.Errorf("preflight: market adapter unreachable: %w", err)
	}
	a.log.Info("preflight: market adapter OK", "markets_available", len(markets))

	// Check 2: Strategy can handle the available markets?
	if len(markets) == 0 {
		a.log.Warn("preflight: no markets available — agent will idle until markets appear")
	}

	// Check 3: Portfolio initialized?
	nav := a.portfolio.NAV()
	if nav <= 0 {
		return fmt.Errorf("preflight: portfolio NAV is zero — configure PRED_SEED_CAPITAL")
	}
	a.log.Info("preflight: portfolio initialized", "nav", nav)

	a.log.Info("pre-flight checks passed")
	return nil
}
```

Call `Preflight` at the start of `Run()`, before entering the main loops:

```go
func (a *Agent) Run(ctx context.Context) error {
	a.startTime = time.Now()
	// ... existing logging ...

	// Run pre-flight checks
	if err := a.Preflight(ctx); err != nil {
		return fmt.Errorf("agent: pre-flight failed: %w", err)
	}

	// ... rest of Run() ...
}
```

### Step 5: Create Verification Checklist

Create file `projects/agent-prediction/docs/deployment-checklist.md`:

```markdown
# Deployment Verification Checklist

## Pre-Deployment
- [ ] .env file configured with all required variables
- [ ] Solana wallet funded with >= 0.05 SOL (fees) and >= $100 USDC (trading)
- [ ] Claude API key tested and active
- [ ] Drift BET API accessible from deployment server
- [ ] Docker and Docker Compose installed on target server

## First-Cycle Verification
- [ ] Agent starts without errors: `docker compose logs | head -20`
- [ ] Pre-flight checks pass: look for "pre-flight checks passed" in logs
- [ ] Markets fetched: look for "fetched markets" with count > 0
- [ ] Strategy analysis runs: look for "resolution_hunter: analyzed market" entries
- [ ] Risk filter runs: look for "risk-approved signals" entry
- [ ] P&L report published: look for "P&L report published" (after PnLReportInterval)
- [ ] Health heartbeat published: look for "trading" status in health messages

## Ongoing Monitoring
- [ ] Check logs daily for errors: `docker compose logs --since 24h | grep -i error`
- [ ] Monitor NAV: look for "P&L report published" with nav field
- [ ] Monitor drawdown: look for "max drawdown reached" errors (trading halted)
- [ ] Monitor wallet SOL balance: agent needs SOL for transaction fees
```

### Step 6: Add Deployment Recipes to Justfile

Add to `projects/agent-prediction/justfile`:

```just
# Deploy to production
deploy:
    ./scripts/deploy.sh

# Deploy in mock mode
deploy-mock:
    ./scripts/deploy.sh --mock

# View logs
logs:
    docker compose logs -f --tail=100

# Stop the agent
stop:
    docker compose down

# Restart the agent
restart:
    docker compose restart

# Check agent status
status:
    docker compose ps
    @echo "---"
    docker compose logs --tail=5
```

## Done When

- [ ] All requirements met
- [ ] `Dockerfile` builds the agent binary in a multi-stage build
- [ ] `docker-compose.yml` configures the agent with env file and resource limits
- [ ] `scripts/deploy.sh` performs pre-flight checks and deploys
- [ ] Agent runs `Preflight()` on startup to verify dependencies
- [ ] Agent successfully starts, fetches Drift BET markets, and completes one cycle
- [ ] Structured JSON logging outputs to stdout
- [ ] Graceful shutdown works on SIGINT/SIGTERM
- [ ] `docs/deployment-checklist.md` documents verification steps
- [ ] `just deploy` and `just deploy-mock` work
