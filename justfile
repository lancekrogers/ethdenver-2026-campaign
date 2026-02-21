mod docker 'justfiles/docker.just'
mod test 'justfiles/test.just'
mod build 'justfiles/build.just'
mod status 'justfiles/status.just'

# Show all available commands
@default:
    just --list --list-submodules

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
