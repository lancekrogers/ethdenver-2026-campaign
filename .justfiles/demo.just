root := justfile_directory()
compose := "docker compose -f " + root / "docker-compose.yml"
bridge_port := env_var_or_default("CRE_BRIDGE_PORT", "8080")

[private]
@default:
    just demo run

# Start demo stack (dashboard + CRE bridge) with mock-safe defaults
up:
    @env_file="$(just mode env demo)"; \
    echo "MODE=demo ENV_FILE=$env_file"; \
    MODE=demo ENV_FILE="$env_file" just docker up; \
    MODE=demo ENV_FILE="$env_file" {{compose}} --env-file "$env_file" --profile chainlink up -d cre-bridge; \
    until curl -fsS http://localhost:{{bridge_port}}/health >/dev/null 2>&1; do sleep 1; done

# Execute deterministic demo scenarios against local CRE bridge
run:
    @env_file="$(just mode env demo)"; \
    MODE=demo ENV_FILE="$env_file" just demo up; \
    now_ts=$(date +%s); \
    approved_payload='{"agent_id":"defi-001","task_id":"demo-approved-001","signal":"buy","signal_confidence":0.85,"risk_score":10,"market_pair":"ETH/USD","requested_position":1000000000,"timestamp":'"${now_ts}"'}'; \
    denied_payload='{"agent_id":"defi-001","task_id":"demo-denied-001","signal":"buy","signal_confidence":0.45,"risk_score":20,"market_pair":"ETH/USD","requested_position":1000000000,"timestamp":'"${now_ts}"'}'; \
    echo "=== Approved Scenario ==="; \
    curl -fsS -X POST http://localhost:{{bridge_port}}/evaluate-risk -H 'Content-Type: application/json' -d "$approved_payload" | jq .; \
    echo "=== Denied Scenario ==="; \
    curl -fsS -X POST http://localhost:{{bridge_port}}/evaluate-risk -H 'Content-Type: application/json' -d "$denied_payload" | jq .

# Stop demo stack
down:
    @env_file="$(just mode env demo)"; \
    MODE=demo ENV_FILE="$env_file" just chainlink down

# Show service status for demo mode
status:
    @env_file="$(just mode env demo)"; \
    MODE=demo ENV_FILE="$env_file" just chainlink status

# Follow logs for demo services
logs *ARGS:
    @env_file="$(just mode env demo)"; \
    MODE=demo ENV_FILE="$env_file" just chainlink logs {{ARGS}}
