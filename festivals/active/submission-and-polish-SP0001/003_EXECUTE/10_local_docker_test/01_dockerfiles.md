---
fest_type: task
fest_id: 01_dockerfiles.md
fest_name: dockerfiles
fest_parent: 10_local_docker_test
fest_order: 1
fest_status: pending
fest_autonomy: high
fest_created: 2026-02-21T13:00:00-07:00
fest_tracking: true
---

# Task: Create Dockerfiles

**Task Number:** 01 | **Sequence:** 10_local_docker_test | **Autonomy:** high

## Objective

Create multi-stage Dockerfiles for all 4 services: agent-coordinator, agent-defi, agent-inference (Go agents), and dashboard (Next.js). Each Dockerfile should produce a minimal runtime image.

## Requirements

- [ ] Dockerfile created at `projects/agent-coordinator/Dockerfile`
- [ ] Dockerfile created at `projects/agent-defi/Dockerfile`
- [ ] Dockerfile created at `projects/agent-inference/Dockerfile`
- [ ] Dockerfile created at `projects/dashboard/Dockerfile`
- [ ] All Go Dockerfiles use multi-stage build (Go builder -> scratch/distroless/alpine runtime)
- [ ] Dashboard Dockerfile uses multi-stage build (node builder -> node runtime with standalone output)
- [ ] Each Dockerfile builds successfully with `docker build`

## Implementation

### Step 1: Create Go agent Dockerfiles

All 3 Go agents follow the same structure. Create a multi-stage Dockerfile for each:

**Pattern for Go agents:**

```dockerfile
# Build stage
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/agent ./cmd/<agent-name>

# Runtime stage
FROM alpine:3.19
RUN apk add --no-cache ca-certificates
COPY --from=builder /bin/agent /usr/local/bin/agent
ENTRYPOINT ["agent"]
```

Entry points:
- agent-coordinator: `./cmd/coordinator`
- agent-defi: `./cmd/agent-defi`
- agent-inference: `./cmd/agent-inference`

Check each project's `go.mod` for the Go version and use the matching base image.

### Step 2: Create dashboard Dockerfile

The dashboard is a Next.js app. Use standalone output mode:

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
EXPOSE 3000
CMD ["node", "server.js"]
```

Check `next.config.ts` to verify standalone output is configured. If not, add `output: 'standalone'` to the Next.js config.

### Step 3: Verify each Dockerfile builds

```bash
cd projects/agent-coordinator && docker build -t agent-coordinator .
cd projects/agent-defi && docker build -t agent-defi .
cd projects/agent-inference && docker build -t agent-inference .
cd projects/dashboard && docker build -t dashboard .
```

Fix any build failures before proceeding.

## Done When

- [ ] All 4 Dockerfiles exist and follow multi-stage build pattern
- [ ] `docker build` succeeds for each service
- [ ] No Go toolchain or node_modules in final runtime images
- [ ] Images are reasonably sized (Go agents < 50MB, dashboard < 200MB)
