compose := "docker compose"
compose_env := "docker compose --env-file .env.docker"

# Show docker commands
@default:
    just --list --justfile {{source_file()}}

# Build dashboard image (mock mode)
build:
    {{compose}} build dashboard

# Build all images (dashboard + agents)
build-all:
    {{compose_env}} --profile agents build

# Start dashboard in mock mode (zero config)
up:
    {{compose}} up -d

# Start full system with agents (requires .env.docker)
up-all:
    NEXT_PUBLIC_USE_MOCK=false {{compose_env}} --profile agents up -d

# Stop all services
down:
    {{compose}} --profile agents down

# Follow logs for all running services
logs *ARGS:
    {{compose}} --profile agents logs -f {{ARGS}}

# Show running containers
ps:
    {{compose}} --profile agents ps

# Rebuild and restart a specific service
restart service:
    {{compose}} --profile agents up -d --build {{service}}

# Remove all containers, images, and volumes
clean:
    {{compose}} --profile agents down --rmi local --volumes --remove-orphans
