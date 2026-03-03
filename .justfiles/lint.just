root := justfile_directory()

[private]
@default:
    just --list --justfile {{source_file()}}

# Lint all projects
all: _go-lint _dashboard-lint _hiero-plugin-lint

[private]
_go-lint:
    cd {{root}}/projects/agent-coordinator && golangci-lint run ./...
    cd {{root}}/projects/agent-inference && golangci-lint run ./...
    cd {{root}}/projects/agent-defi && golangci-lint run ./...

[private]
_dashboard-lint:
    cd {{root}}/projects/dashboard && npm run lint

[private]
_hiero-plugin-lint:
    cd {{root}}/projects/hiero-plugin && npm run lint
