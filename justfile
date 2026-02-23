mod docker 'justfiles/docker.just'
mod test 'justfiles/test.just'
mod build 'justfiles/build.just'
mod lint 'justfiles/lint.just'
mod status 'justfiles/status.just'

root := justfile_directory()

[private]
@default:
    just --list --list-submodules

# Install all project dependencies
install:
    cd {{root}}/projects/agent-coordinator && go mod download
    cd {{root}}/projects/agent-inference && go mod download
    cd {{root}}/projects/agent-defi && go mod download
    cd {{root}}/projects/dashboard && npm install
    cd {{root}}/projects/hiero-plugin && npm install

# Build + run dashboard in mock mode (zero config)
demo:
    just docker build
    just docker up

# Build + run full system with agents (requires .env.docker)
live:
    just docker build-all
    just docker up-all

# Stop all services
down:
    just docker down
