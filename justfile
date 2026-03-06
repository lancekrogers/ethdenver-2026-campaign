mod docker '.justfiles/docker.just'
mod test '.justfiles/test.just'
mod build '.justfiles/build.just'
mod lint '.justfiles/lint.just'
mod status '.justfiles/status.just'
mod chainlink '.justfiles/chainlink.just'
mod evidence '.justfiles/evidence.just'
mod mode '.justfiles/mode.just'
mod demo '.justfiles/demo.just'
mod live '.justfiles/live.just'

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

# Build + run dashboard + CRE demo scenario in demo mode
demo-run:
    just demo run

# Build + run full live testnet stack with preflight checks
live-run:
    just live run

# Stop all mode services
down:
    just live down

# Chainlink demo stack (dashboard + agents + CRE bridge)
chainlink-demo:
    just chainlink demo

# Capture Chainlink evidence pack
chainlink-evidence:
    just evidence collect

# Optional CRE broadcast helper
chainlink-broadcast:
    just chainlink broadcast
