root := justfile_directory()

[private]
@default:
    just --list --justfile {{source_file()}}

# Build all projects
all: _coordinator _inference _defi _hiero-plugin

[private]
_coordinator:
    cd {{root}}/projects/agent-coordinator && go build -o bin/coordinator ./cmd/coordinator

[private]
_inference:
    cd {{root}}/projects/agent-inference && go build -o bin/agent-inference ./cmd/agent-inference

[private]
_defi:
    cd {{root}}/projects/agent-defi && go build -o bin/agent-defi ./cmd/agent-defi

[private]
_hiero-plugin:
    cd {{root}}/projects/hiero-plugin && npm run build
