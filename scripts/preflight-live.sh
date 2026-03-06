#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${MODE:-live-testnet}"
ENV_FILE="${ENV_FILE:-$ROOT_DIR/.env.live}"

if [[ ! -f "$ENV_FILE" ]]; then
  if [[ -f "$ROOT_DIR/.env.docker" ]]; then
    ENV_FILE="$ROOT_DIR/.env.docker"
  elif [[ -f "$ROOT_DIR/.env.live.example" ]]; then
    ENV_FILE="$ROOT_DIR/.env.live.example"
  else
    echo "preflight-live: no env file found (.env.live, .env.docker, .env.live.example)" >&2
    exit 1
  fi
fi

set -a
# shellcheck source=/dev/null
source "$ENV_FILE"
set +a

timestamp="$(date -u +%Y%m%d-%H%M%S)"
out_dir="$ROOT_DIR/workflow/explore/cre-demo/runs/$timestamp"
report_file="$out_dir/preflight-live.json"
summary_file="$out_dir/preflight-live.txt"
mkdir -p "$out_dir"

failures=()
warnings=()

fail() {
  failures+=("$1")
}

warn() {
  warnings+=("$1")
}

require_var() {
  local var_name="$1"
  if [[ -z "${!var_name:-}" ]]; then
    fail "missing_required_var:$var_name"
  fi
}

jsonrpc_post() {
  local rpc_url="$1"
  local method="$2"
  local params_json="$3"
  local payload
  payload="$(jq -nc --arg m "$method" --argjson p "$params_json" '{jsonrpc:"2.0",method:$m,params:$p,id:1}')"
  curl -fsS --max-time 12 -H 'Content-Type: application/json' --data "$payload" "$rpc_url"
}

# Gate A: config completeness and mode contracts.
required_vars=(
  HCS_TASK_TOPIC_ID
  HCS_STATUS_TOPIC_ID
  HEDERA_COORDINATOR_ACCOUNT_ID
  HEDERA_COORDINATOR_PRIVATE_KEY
  INFERENCE_HEDERA_ACCOUNT_ID
  INFERENCE_HEDERA_PRIVATE_KEY
  DEFI_HEDERA_ACCOUNT_ID
  DEFI_HEDERA_PRIVATE_KEY
  ZG_CHAIN_RPC
  DEFI_BASE_RPC_URL
  DEFI_PRIVATE_KEY
  DEFI_WALLET_ADDRESS
  DEFI_ERC8004_CONTRACT
  DEFI_DEX_ROUTER
)

for var in "${required_vars[@]}"; do
  require_var "$var"
done

if [[ "${NEXT_PUBLIC_USE_MOCK:-}" != "false" ]]; then
  fail "live_mode_requires_NEXT_PUBLIC_USE_MOCK=false"
fi

if [[ "${DEFI_MOCK_MODE:-}" != "false" ]]; then
  fail "live_mode_requires_DEFI_MOCK_MODE=false"
fi

if [[ "${LIVE_ALLOW_SIMULATED_CRE:-false}" != "true" ]]; then
  fail "live_mode_blocked_simulated_cre:set LIVE_ALLOW_SIMULATED_CRE=true to acknowledge current simulation-backed CRE oracle path"
fi

# Gate B: basic network reachability.
if [[ -n "${DEFI_BASE_RPC_URL:-}" ]]; then
  if ! base_chain_resp="$(jsonrpc_post "$DEFI_BASE_RPC_URL" "eth_chainId" '[]' 2>/dev/null)"; then
    fail "unreachable:base_rpc:$DEFI_BASE_RPC_URL"
  elif [[ "$(jq -r '.result // empty' <<<"$base_chain_resp")" != "0x14a34" ]]; then
    fail "unexpected_chain_id:base_rpc:expected=0x14a34"
  fi
fi

if [[ -n "${ZG_CHAIN_RPC:-}" ]]; then
  if ! zg_chain_resp="$(jsonrpc_post "$ZG_CHAIN_RPC" "eth_chainId" '[]' 2>/dev/null)"; then
    fail "unreachable:zg_rpc:$ZG_CHAIN_RPC"
  else
    zg_chain_id="$(jq -r '.result // empty' <<<"$zg_chain_resp")"
    if [[ -z "$zg_chain_id" ]]; then
      fail "invalid_response:zg_rpc:missing_chain_id"
    fi
  fi
fi

mirror_url="${NEXT_PUBLIC_HEDERA_MIRROR_NODE_URL:-https://testnet.mirrornode.hedera.com}"
if ! curl -fsS --max-time 12 "$mirror_url/api/v1/network/supply" >/dev/null 2>&1; then
  fail "unreachable:hedera_mirror:$mirror_url"
fi

# Gate C: funding and chain readiness.
if [[ -n "${DEFI_WALLET_ADDRESS:-}" && -n "${DEFI_BASE_RPC_URL:-}" ]]; then
  if ! balance_resp="$(jsonrpc_post "$DEFI_BASE_RPC_URL" "eth_getBalance" "[\"$DEFI_WALLET_ADDRESS\",\"latest\"]" 2>/dev/null)"; then
    fail "funding_check_failed:eth_getBalance_request"
  else
    balance_hex="$(jq -r '.result // empty' <<<"$balance_resp")"
    if [[ -z "$balance_hex" || "$balance_hex" == "null" ]]; then
      fail "funding_check_failed:missing_balance_result"
    else
      balance_wei="$(perl -e 'use bigint; my $v=shift; $v =~ s/^0x//; print hex($v);' "$balance_hex")"
      min_balance_wei="${LIVE_MIN_BASE_WEI:-100000000000000}"
      if (( balance_wei < min_balance_wei )); then
        fail "insufficient_base_balance:wallet=$DEFI_WALLET_ADDRESS:balance_wei=$balance_wei:min_wei=$min_balance_wei"
      fi
    fi
  fi
else
  fail "funding_check_failed:missing_wallet_or_rpc"
fi

# Optional warnings for currently known not-live-safe paths.
warn "phase1_skeleton_only:cre_bridge_http_path_uses_mock_oracle_until_live_feed_integration"
warn "phase1_skeleton_only:coordinator_static_plan_uses_test-model_and_may_fail_without_provider_mapping"

fail_json='[]'
if (( ${#failures[@]} > 0 )); then
  fail_json="$(printf '%s\n' "${failures[@]}" | jq -R . | jq -s .)"
fi

warn_json='[]'
if (( ${#warnings[@]} > 0 )); then
  warn_json="$(printf '%s\n' "${warnings[@]}" | jq -R . | jq -s .)"
fi

valid=true
if (( ${#failures[@]} > 0 )); then
  valid=false
fi

jq -n \
  --arg mode "$MODE" \
  --arg env_file "$ENV_FILE" \
  --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson valid "$valid" \
  --argjson failures "$fail_json" \
  --argjson warnings "$warn_json" \
  '{mode:$mode,env_file:$env_file,generated_at:$generated_at,valid:$valid,gates:{config_completeness:(($failures | map(select(startswith("missing_required_var:"))) | length)==0),network_reachability:(($failures | map(select(startswith("unreachable:"))) | length)==0),funding_readiness:(($failures | map(select(startswith("insufficient_base_balance:") or startswith("funding_check_failed:"))) | length)==0)},failures:$failures,warnings:$warnings}' > "$report_file"

{
  echo "Live Preflight Summary"
  echo "  mode: $MODE"
  echo "  env_file: $ENV_FILE"
  echo "  report: $report_file"
  if (( ${#failures[@]} == 0 )); then
    echo "  status: PASS"
  else
    echo "  status: FAIL"
    echo ""
    echo "Failures:"
    printf '  - %s\n' "${failures[@]}"
  fi
  echo ""
  echo "Warnings:"
  printf '  - %s\n' "${warnings[@]}"
} | tee "$summary_file"

if (( ${#failures[@]} > 0 )); then
  exit 1
fi
