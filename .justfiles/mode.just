root := justfile_directory()

[private]
@default:
    just --list --justfile {{source_file()}}

# Resolve env file path for a mode (demo | live-testnet)
env mode:
    @if [ "{{mode}}" = "live-testnet" ]; then \
      if [ -f "{{root}}/.env.live" ]; then echo "{{root}}/.env.live"; \
      elif [ -f "{{root}}/.env.docker" ]; then echo "{{root}}/.env.docker"; \
      else echo "{{root}}/.env.live.example"; fi; \
    else \
      if [ -f "{{root}}/.env.demo" ]; then echo "{{root}}/.env.demo"; \
      elif [ -f "{{root}}/.env.docker" ]; then echo "{{root}}/.env.docker"; \
      else echo "{{root}}/.env.demo.example"; fi; \
    fi

# Show current mode env resolution and command matrix
status:
    @demo_env="$(just mode env demo)"; \
    live_env="$(just mode env live-testnet)"; \
    echo "Mode Environment Resolution"; \
    echo "  demo         -> $demo_env"; \
    echo "  live-testnet -> $live_env"; \
    echo ""; \
    echo "Primary Commands"; \
    echo "  just demo up|run|down|status|logs"; \
    echo "  just live up|run|down|status|logs"; \
    echo "  just mode doctor"; \
    echo "  just fest status"; \
    echo "  just fest doctor";

# Run live preflight checks and write a machine-readable report
doctor:
    @live_env="$(just mode env live-testnet)"; \
    MODE=live-testnet ENV_FILE="$live_env" bash {{root}}/scripts/preflight-live.sh
