# Show build commands
@default:
    just --list --justfile {{source_file()}}

# Build all Go binaries
all: coordinator inference defi

# Build coordinator agent
coordinator:
    cd projects/agent-coordinator && go build -o bin/coordinator ./cmd/coordinator

# Build inference agent
inference:
    cd projects/agent-inference && go build -o bin/agent-inference ./cmd/agent-inference

# Build defi agent
defi:
    cd projects/agent-defi && go build -o bin/agent-defi ./cmd/agent-defi
