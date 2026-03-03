root := justfile_directory()
compose := "docker compose -f " + root / "docker-compose.yml"
compose_env := compose + " --env-file " + root / ".env.docker"
out_dir := root / "workflow/explore/cre-demo/evidence/latest"
bridge_port := env_var_or_default("CRE_BRIDGE_PORT", "8080")

[private]
@default:
    just --list --justfile {{source_file()}}

# Collect a submission-ready Chainlink evidence pack from local services
collect:
    mkdir -p {{out_dir}}
    just chainlink up
    now_ts=$(date +%s); \
    approved_payload="{\"agent_id\":\"defi-001\",\"task_id\":\"evidence-approved-001\",\"signal\":\"buy\",\"signal_confidence\":0.85,\"risk_score\":10,\"market_pair\":\"ETH/USD\",\"requested_position\":1000000000,\"timestamp\":${now_ts}}"; \
    denied_payload="{\"agent_id\":\"defi-001\",\"task_id\":\"evidence-denied-001\",\"signal\":\"buy\",\"signal_confidence\":0.45,\"risk_score\":20,\"market_pair\":\"ETH/USD\",\"requested_position\":1000000000,\"timestamp\":${now_ts}}"; \
    approved_resp=$(curl -fsS -X POST http://localhost:{{bridge_port}}/evaluate-risk -H 'Content-Type: application/json' -d "$approved_payload"); \
    denied_resp=$(curl -fsS -X POST http://localhost:{{bridge_port}}/evaluate-risk -H 'Content-Type: application/json' -d "$denied_payload"); \
    printf '%s\n' "$approved_resp" > {{out_dir}}/approved.json; \
    printf '%s\n' "$denied_resp" > {{out_dir}}/denied.json; \
    approved_flag=$(echo "$approved_resp" | jq -r '.approved'); \
    denied_flag=$(echo "$denied_resp" | jq -r '.approved'); \
    denied_reason=$(echo "$denied_resp" | jq -r '.reason'); \
    generated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ); \
    jq -n \
      --arg generated_at "$generated_at" \
      --argjson approved "$approved_flag" \
      --argjson denied "$denied_flag" \
      --arg denied_reason "$denied_reason" \
      '{generated_at:$generated_at,scenarios:[{name:"approved_trade",approved:$approved,response_file:"approved.json"},{name:"denied_low_confidence",approved:$denied,reason:$denied_reason,response_file:"denied.json"}]}' > {{out_dir}}/scenario-results.json; \
    jq -n \
      --arg generated_at "$generated_at" \
      '{generated_at:$generated_at,checks:[{name:"hcs_feed_shows_risk_events",status:"pending_manual"},{name:"cre_panel_counts_render",status:"pending_manual"},{name:"approved_and_denied_visible",status:"pending_manual"}]}' > {{out_dir}}/dashboard-checklist.json; \
    printf '# Chainlink Evidence Pack\n\nGenerated: %s\n\n## Artifacts\n- run.log\n- approved.json\n- denied.json\n- scenario-results.json\n- dashboard-checklist.json\n\n## Summary\n- Approved scenario result: %s\n- Denied scenario result: %s\n- Denied scenario reason: %s\n\n## Optional Broadcast\nRun `just chainlink broadcast` to capture on-chain receipt tx hash for final submission evidence.\n' "$generated_at" "$approved_flag" "$denied_flag" "$denied_reason" > {{out_dir}}/submission-ready.md
    {{compose_env}} --profile agents --profile chainlink logs --since=15m coordinator cre-bridge > {{out_dir}}/run.log || true
    @echo "Evidence pack written to: {{out_dir}}"

# Validate required evidence files exist and contain expected fields
validate:
    test -f {{out_dir}}/scenario-results.json
    test -f {{out_dir}}/run.log
    test -f {{out_dir}}/submission-ready.md
    jq -e '.scenarios | length >= 2' {{out_dir}}/scenario-results.json >/dev/null
    jq -e '.scenarios[0].approved' {{out_dir}}/scenario-results.json >/dev/null
    @echo "Evidence validation passed: {{out_dir}}"

# Create a compressed evidence bundle for sharing
bundle:
    just evidence validate
    bundle="{{root}}/workflow/explore/cre-demo/evidence/chainlink-evidence-$(date +%Y%m%d-%H%M%S).tar.gz"; \
    tar -czf "$bundle" -C {{root}} workflow/explore/cre-demo/evidence/latest; \
    echo "Created $bundle"
