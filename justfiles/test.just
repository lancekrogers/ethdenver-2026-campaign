root := justfile_directory()

[private]
@default:
    just --list --justfile {{source_file()}}

# Run all tests across all projects
all: _go-tests _dashboard-tests _hiero-plugin-tests

[private]
_go-tests:
    cd {{root}}/projects/agent-coordinator && go test -race ./...
    cd {{root}}/projects/agent-inference && go test -race ./...
    cd {{root}}/projects/agent-defi && go test -race ./...

[private]
_dashboard-tests:
    cd {{root}}/projects/dashboard && npm test

[private]
_hiero-plugin-tests:
    cd {{root}}/projects/hiero-plugin && npm test

# Run Go tests with coverage
go-coverage:
    cd {{root}}/projects/agent-coordinator && go test -race -coverprofile=coverage.out ./...
    cd {{root}}/projects/agent-inference && go test -race -coverprofile=coverage.out ./...
    cd {{root}}/projects/agent-defi && go test -race -coverprofile=coverage.out ./...
