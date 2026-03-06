root := justfile_directory()

[private]
@default:
    just --list --justfile {{source_file()}}

# Show runtime fest health and selected festival diagnostics
status:
    @if ! command -v fest >/dev/null 2>&1; then \
      echo "fest status: FAILED (fest binary not found in PATH)"; \
      exit 1; \
    fi; \
    echo "Fest Runtime Status"; \
    fest version; \
    echo ""; \
    all_json="$(fest show all --json)"; \
    echo "$all_json" | jq '{counts: {active: .active.count, ready: .ready.count, planning: .planning.count, dungeon_someday: .["dungeon/someday"].count, dungeon_completed: .["dungeon/completed"].count}}'; \
    selector="$(echo "$all_json" | jq -r '(.active.festivals[0].name // .ready.festivals[0].name // .planning.festivals[0].name // .["dungeon/someday"].festivals[0].name // empty)')"; \
    if [ -n "$selector" ]; then \
      echo ""; \
      echo "Selected festival candidate: $selector"; \
      fest show --festival "$selector" --json --summary | jq '{name: .name, status: .status, progress: .stats.progress}'; \
    else \
      echo ""; \
      echo "No selectable festival candidate found in active/ready/planning/dungeon-someday."; \
    fi

# Validate fest runtime prerequisites for live mode
doctor:
    @if ! command -v fest >/dev/null 2>&1; then \
      echo "fest doctor: FAILED (fest binary not found in PATH)"; \
      exit 1; \
    fi; \
    all_json="$(fest show all --json)"; \
    selector="${FEST_SELECTOR:-$(echo "$all_json" | jq -r '(.active.festivals[0].name // .ready.festivals[0].name // .planning.festivals[0].name // .["dungeon/someday"].festivals[0].name // empty)')}"; \
    if [ -z "$selector" ]; then \
      echo "fest doctor: FAILED (no festival selector available; set FEST_SELECTOR or create an active/ready/planning festival)"; \
      exit 1; \
    fi; \
    fest show --festival "$selector" --json --roadmap >/dev/null; \
    echo "fest doctor: PASS (selector=$selector)"
