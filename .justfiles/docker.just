root := justfile_directory()
compose := "docker compose -f " + root / "docker-compose.yml"
compose_env := compose + " --env-file " + root / ".env.docker"

[private]
@default:
    just --list --justfile {{source_file()}}

# Build dashboard image (mock mode)
build:
    {{compose}} build dashboard

# Build all images (dashboard + agents)
build-all:
    just chainlink build

# Start dashboard in mock mode (zero config)
up:
    {{compose}} up -d

# Start full system with agents (requires .env.docker)
up-all:
    just chainlink up

# Stop all services
down:
    {{compose}} --profile agents --profile chainlink down

# Follow logs for all running services
logs *ARGS:
    {{compose}} --profile agents --profile chainlink logs -f {{ARGS}}

# Show running containers
ps:
    {{compose}} --profile agents --profile chainlink ps

# Rebuild and restart a specific service
restart service:
    {{compose}} --profile agents --profile chainlink up -d --build {{service}}

# Remove all containers, images, and volumes
clean:
    {{compose}} --profile agents --profile chainlink down --rmi local --volumes --remove-orphans
