root := justfile_directory()

[private]
@default:
    just live run

# Start live testnet stack after preflight validation
up:
    @env_file="$(just mode env live-testnet)"; \
    echo "MODE=live-testnet ENV_FILE=$env_file"; \
    MODE=live-testnet ENV_FILE="$env_file" bash {{root}}/scripts/preflight-live.sh && \
    MODE=live-testnet ENV_FILE="$env_file" NEXT_PUBLIC_USE_MOCK=false DEFI_MOCK_MODE=false just chainlink up

# Run live stack + smoke scenarios
run:
    @env_file="$(just mode env live-testnet)"; \
    MODE=live-testnet ENV_FILE="$env_file" just live up && \
    MODE=live-testnet ENV_FILE="$env_file" NEXT_PUBLIC_USE_MOCK=false DEFI_MOCK_MODE=false just chainlink demo

# Stop live stack
down:
    @env_file="$(just mode env live-testnet)"; \
    MODE=live-testnet ENV_FILE="$env_file" just chainlink down

# Show service status for live mode
status:
    @env_file="$(just mode env live-testnet)"; \
    MODE=live-testnet ENV_FILE="$env_file" just chainlink status

# Follow logs for live services
logs *ARGS:
    @env_file="$(just mode env live-testnet)"; \
    MODE=live-testnet ENV_FILE="$env_file" just chainlink logs {{ARGS}}
