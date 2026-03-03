root := justfile_directory()
compose := "docker compose -f " + root / "docker-compose.yml"
compose_env := compose + " --env-file " + root / ".env.docker"
cre_endpoint := "http://cre-bridge:8080/evaluate-risk"
bridge_port := env_var_or_default("CRE_BRIDGE_PORT", "8080")

[private]
@default:
    just --list --justfile {{source_file()}}

# Build images for Chainlink demo profile (dashboard + agents + cre-bridge)
build:
    {{compose_env}} --profile agents --profile chainlink build

# Bring up Chainlink demo stack with CRE endpoint wiring
up:
    CRE_ENDPOINT="${CRE_ENDPOINT:-{{cre_endpoint}}}" {{compose_env}} --profile chainlink up -d cre-bridge
    until {{compose_env}} --profile chainlink ps --services --status running | grep -q '^cre-bridge$'; do sleep 1; done
    until curl -fsS http://localhost:{{bridge_port}}/health >/dev/null 2>&1; do sleep 1; done
    CRE_ENDPOINT="${CRE_ENDPOINT:-{{cre_endpoint}}}" NEXT_PUBLIC_USE_MOCK=false {{compose_env}} --profile agents --profile chainlink up -d dashboard coordinator inference defi

# Show running Chainlink stack services
status:
    {{compose_env}} --profile agents --profile chainlink ps
    @echo ""
    @echo "CRE bridge health:"
    @if {{compose_env}} --profile chainlink ps --services --status running | grep -q '^cre-bridge$'; then curl -fsS http://localhost:{{bridge_port}}/health; else echo "cre-bridge not running"; fi

# Follow logs for all Chainlink demo services
logs *ARGS:
    {{compose_env}} --profile agents --profile chainlink logs -f {{ARGS}}

# Run an integrated demo scenario set against the local CRE bridge
demo:
    just chainlink up
    now_ts=$(date +%s); \
    approved_payload="{\"agent_id\":\"defi-001\",\"task_id\":\"demo-approved-001\",\"signal\":\"buy\",\"signal_confidence\":0.85,\"risk_score\":10,\"market_pair\":\"ETH/USD\",\"requested_position\":1000000000,\"timestamp\":${now_ts}}"; \
    denied_payload="{\"agent_id\":\"defi-001\",\"task_id\":\"demo-denied-001\",\"signal\":\"buy\",\"signal_confidence\":0.45,\"risk_score\":20,\"market_pair\":\"ETH/USD\",\"requested_position\":1000000000,\"timestamp\":${now_ts}}"; \
    echo "=== Approved Scenario ==="; \
    curl -fsS -X POST http://localhost:{{bridge_port}}/evaluate-risk -H 'Content-Type: application/json' -d "$approved_payload" | jq .; \
    echo "=== Denied Scenario ==="; \
    curl -fsS -X POST http://localhost:{{bridge_port}}/evaluate-risk -H 'Content-Type: application/json' -d "$denied_payload" | jq .

# Optional on-chain receipt broadcast via CRE workflow
broadcast:
    cd {{root}}/projects/cre-risk-router && just broadcast

# Stop Chainlink demo stack
down:
    {{compose_env}} --profile agents --profile chainlink down
