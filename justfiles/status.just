root := justfile_directory()

[private]
@default:
    just --list --justfile {{source_file()}}

# Health check across all projects
check:
    @echo "=== Submodule Status ==="
    @cd {{root}} && git submodule status
    @echo ""
    @echo "=== Go Build Check ==="
    @cd {{root}}/projects/agent-coordinator && go build ./... 2>/dev/null && echo "  coordinator   OK" || echo "  coordinator   FAILED"
    @cd {{root}}/projects/agent-inference && go build ./... 2>/dev/null && echo "  inference     OK" || echo "  inference     FAILED"
    @cd {{root}}/projects/agent-defi && go build ./... 2>/dev/null && echo "  defi          OK" || echo "  defi          FAILED"
    @echo ""
    @echo "=== Dashboard Check ==="
    @cd {{root}}/projects/dashboard && npm run build > /dev/null 2>&1 && echo "  dashboard     OK" || echo "  dashboard     FAILED"

# Check environment variable files
env:
    @echo "=== Environment Files ==="
    @test -f {{root}}/.env.docker && echo "  .env.docker               OK" || echo "  .env.docker               MISSING (cp .env.docker.example .env.docker)"
    @test -f {{root}}/projects/agent-coordinator/.env && echo "  agent-coordinator/.env    OK" || echo "  agent-coordinator/.env    MISSING"
    @test -f {{root}}/projects/agent-inference/.env && echo "  agent-inference/.env      OK" || echo "  agent-inference/.env      MISSING"
    @test -f {{root}}/projects/agent-defi/.env && echo "  agent-defi/.env           OK" || echo "  agent-defi/.env           MISSING"
    @test -f {{root}}/projects/dashboard/.env.local && echo "  dashboard/.env.local      OK" || echo "  dashboard/.env.local      MISSING"

# Show submodule status
submodules:
    cd {{root}} && git submodule status --recursive

# List open PRs across all project submodules
prs:
    @for proj in agent-coordinator agent-inference agent-defi contracts hiero-plugin dashboard; do \
        echo "=== $proj ==="; \
        cd {{root}}/projects/$proj && gh pr list 2>/dev/null || echo "  (no remote or gh not configured)"; \
        echo ""; \
    done

# List all PRs (open + closed + merged) across all project submodules
prs-all:
    @for proj in agent-coordinator agent-inference agent-defi contracts hiero-plugin dashboard; do \
        echo "=== $proj ==="; \
        cd {{root}}/projects/$proj && gh pr list --state all 2>/dev/null || echo "  (no remote or gh not configured)"; \
        echo ""; \
    done

# Merge all open develop→main PRs across all project submodules
prs-merge:
    @for proj in agent-coordinator agent-inference agent-defi contracts hiero-plugin dashboard; do \
        echo "=== $proj ==="; \
        cd {{root}}/projects/$proj && gh pr list --base main --head develop --json number --jq '.[0].number' 2>/dev/null | xargs -I{} gh pr merge {} --merge 2>/dev/null || echo "  (no open PR or already merged)"; \
    done
