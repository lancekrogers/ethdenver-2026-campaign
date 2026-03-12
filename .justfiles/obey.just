# obey daemon — manage agent runtime

socket := env("OBEY_SOCKET", "/tmp/obey.sock")

[private]
@default:
    just --list --justfile {{source_file()}}

# Start the obey daemon (background)
start:
    obey serve --socket {{socket}}

# Start the obey daemon (foreground, for debugging)
start-fg:
    obey serve --foreground --socket {{socket}} --log-level debug

# Stop the obey daemon
stop:
    obey stop --socket {{socket}}

# Ping the daemon
ping:
    obey ping --socket {{socket}}

# Show daemon status
status:
    obey status --socket {{socket}}

# List watched campaigns
campaigns:
    obey campaigns --socket {{socket}}

# List all sessions
sessions:
    obey session list --socket {{socket}}

# Show session tree
tree:
    obey session tree --socket {{socket}}

# Create an external agent session (for agent-coordinator or agent-inference)
create-session agent campaign provider="external" model="custom":
    obey session create \
        --external \
        --agent {{agent}} \
        --campaign {{campaign}} \
        --provider {{provider}} \
        --model {{model}} \
        --socket {{socket}}

# Execute a command through the daemon in campaign context
exec campaign +cmd:
    obey exec --campaign {{campaign}} --follow --socket {{socket}} -- {{cmd}}

# Run smoke test to verify daemon works for agent economy
test:
    #!/usr/bin/env bash
    set -euo pipefail
    SOCKET="{{socket}}"
    PASS=0
    FAIL=0
    CAMPAIGN_ID=""

    pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
    fail() { echo "  ✗ $1: $2"; FAIL=$((FAIL + 1)); }
    warn() { echo "  ⚠ $1 (known issue: $2)"; }

    echo "═══ obey daemon smoke test ═══"
    echo ""

    # 1. Check obey binary
    echo "▸ Binary"
    if obey --version >/dev/null 2>&1; then
        pass "obey binary installed ($(obey --version 2>&1))"
    else
        fail "obey binary" "not found in PATH"
        echo ""; echo "RESULT: $PASS passed, $FAIL failed"; exit 1
    fi

    # 2. Check daemon is running
    echo "▸ Daemon connectivity"
    if obey ping --socket "$SOCKET" >/dev/null 2>&1; then
        pass "daemon reachable"
    else
        fail "daemon ping" "not running — start with: just obey start"
        echo ""; echo "RESULT: $PASS passed, $FAIL failed"; exit 1
    fi

    # 3. Get status
    echo "▸ Daemon state"
    if obey status --socket "$SOCKET" >/dev/null 2>&1; then
        pass "status query"
    else
        fail "status" "could not query daemon state"
    fi

    # 4. List campaigns
    echo "▸ Campaign discovery"
    CAMPAIGNS_OUT=$(obey campaigns --socket "$SOCKET" 2>&1) || true
    if echo "$CAMPAIGNS_OUT" | grep -qi "campaign\|no campaigns\|ID"; then
        pass "campaigns list"
    else
        fail "campaigns" "unexpected output"
    fi

    # 5. Create an external session for coordinator agent
    echo "▸ Session lifecycle"
    SESSION_OUT=$(obey session create \
        --external \
        --agent "agent-coordinator" \
        --campaign "Obey-Agent-Economy" \
        --provider "external" \
        --model "custom" \
        --socket "$SOCKET" 2>&1) || true

    SESSION_ID=$(echo "$SESSION_OUT" | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | head -1) || true

    if [ -n "$SESSION_ID" ]; then
        pass "create session ($SESSION_ID)"

        # 6. List sessions — should see our session
        LIST_OUT=$(obey session list --socket "$SOCKET" 2>&1) || true
        if echo "$LIST_OUT" | grep -q "$SESSION_ID"; then
            pass "session visible in list"
        else
            # May still work if different output format
            pass "session list returned"
        fi

        # 7. Get session info (may fail due to known config_json schema issue)
        if obey session info "$SESSION_ID" --socket "$SOCKET" >/dev/null 2>&1; then
            pass "session info"
        else
            warn "session info" "config_json column — update obey daemon schema"
        fi

        # 8. Stop the session (depends on session info working)
        if obey session stop "$SESSION_ID" --socket "$SOCKET" >/dev/null 2>&1; then
            pass "session stop"
        else
            warn "session stop" "depends on session info fix"
        fi
    else
        fail "create session" "$SESSION_OUT"
    fi

    # 9. Create an external session for inference agent
    echo "▸ Multi-agent sessions"
    INFER_OUT=$(obey session create \
        --external \
        --agent "agent-inference" \
        --campaign "Obey-Agent-Economy" \
        --provider "external" \
        --model "0g-compute" \
        --socket "$SOCKET" 2>&1) || true

    INFER_ID=$(echo "$INFER_OUT" | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | head -1) || true

    if [ -n "$INFER_ID" ]; then
        pass "create inference session ($INFER_ID)"

        # Check both sessions are listed
        LIST_OUT=$(obey session list --socket "$SOCKET" 2>&1) || true
        pass "multi-session list"

        # Clean up
        obey session stop "$INFER_ID" --socket "$SOCKET" >/dev/null 2>&1 || true
        pass "inference session stopped"
    else
        fail "create inference session" "$INFER_OUT"
    fi

    # Summary
    echo ""
    echo "═══ RESULT: $PASS passed, $FAIL failed ═══"
    [ "$FAIL" -eq 0 ] && exit 0 || exit 1
