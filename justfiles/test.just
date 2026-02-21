# Show test commands
@default:
    just --list --justfile {{source_file()}}

# Run all tests across all projects
all: go-tests dashboard-tests

# Run all Go agent tests
go-tests:
    cd projects/agent-coordinator && go test -race ./...
    cd projects/agent-inference && go test -race ./...
    cd projects/agent-defi && go test -race ./...

# Run dashboard tests
dashboard-tests:
    cd projects/dashboard && npm test

# Run Go tests with coverage
go-coverage:
    cd projects/agent-coordinator && go test -race -coverprofile=coverage.out ./...
    cd projects/agent-inference && go test -race -coverprofile=coverage.out ./...
    cd projects/agent-defi && go test -race -coverprofile=coverage.out ./...
