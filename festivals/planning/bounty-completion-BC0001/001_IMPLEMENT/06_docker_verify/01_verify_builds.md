---
fest_type: task
fest_id: 01_verify_builds.md
fest_name: verify builds
fest_parent: 06_docker_verify
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:54.723998-07:00
fest_tracking: true
---

# Task: Verify All Docker Images Build

## Objective

Run `just docker build-all` to build all four Docker images (coordinator, inference, defi, dashboard) and fix any Dockerfile failures so that a clean build succeeds from end to end.

## Requirements

- [ ] `just docker build-all` exits 0 with no errors
- [ ] All four images are present in `docker image ls` after the build: `agent-coordinator`, `agent-inference`, `agent-defi`, `dashboard`
- [ ] No `latest` base image tags used — all Dockerfiles pin to a specific version tag
- [ ] Multi-stage builds are used for Go services to keep final images minimal

## Implementation

### Step 1: Attempt the build

```bash
just docker build-all 2>&1 | tee /tmp/docker-build.log
```

Read the log from the bottom up to find the first error. Docker errors usually appear as `ERROR [stage N/M]` lines.

### Step 2: Common failure patterns and fixes

**Go module cache miss (slow or network error)**

If `go mod download` fails because the module cache is missing:
- Ensure each Go Dockerfile has a `COPY go.mod go.sum ./` followed by `RUN go mod download` as a dedicated layer before `COPY . .`
- Example fix for coordinator Dockerfile:
  ```dockerfile
  FROM golang:1.22-alpine AS builder
  WORKDIR /app
  COPY go.mod go.sum ./
  RUN go mod download
  COPY . .
  RUN go build -o bin/coordinator ./cmd/coordinator/...
  ```

**Missing environment variable at build time**

If a Dockerfile references a `--build-arg` that is not passed by `just docker build-all`:
- Read the `justfile` recipe for `docker build-all` to see which `--build-arg` flags are passed
- Add any missing args to the recipe or provide defaults in the Dockerfile with `ARG VAR=default`

**Node/npm errors for the dashboard**

If the dashboard build fails on `npm install` or `npm run build`:
- Check the Node version in the dashboard Dockerfile matches what the package.json `engines` field requires
- If `package-lock.json` is out of sync, run `npm install` locally and commit the updated lock file

**Binary name mismatch**

If the final stage copies a binary that was built to a different path:
- Verify the `go build -o bin/ ./cmd/...` output directory matches the `COPY --from=builder /app/bin/<name>` path in the final stage

### Step 3: Rebuild after fixes

After each fix, run:

```bash
docker build --no-cache -f projects/<service>/Dockerfile -t <image-name> projects/<service>/
```

for the specific failing service to iterate quickly, then re-run `just docker build-all` for a full verification.

### Step 4: Verify images exist

```bash
docker image ls | grep -E "agent-coordinator|agent-inference|agent-defi|dashboard"
```

All four images must appear.

## Done When

- [ ] All requirements met
- [ ] `just docker build-all` exits 0 and all 4 images appear in `docker image ls`
