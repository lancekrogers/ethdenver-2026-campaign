---
fest_type: task
fest_id: 01_add_mock_daemon_to_docker_compose.md
fest_name: add mock daemon to docker compose
fest_parent: 03_daemon_mock
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.12355-06:00
fest_updated: 2026-03-22T16:23:44.638692-06:00
fest_tracking: true
---


# Task: Add Mock Daemon to Docker Compose

## Objective

Add the mock obey daemon as a Docker Compose service that runs in the demo profile and makes the socket available to agent containers.

## Requirements

- [ ] New service `mock-daemon` in docker-compose.yml under the `agents` or `demo` profile
- [ ] Shares the Unix socket via a Docker volume so agent containers can connect
- [ ] Only starts in demo mode — live mode uses the real obey daemon on the host
- [ ] Health check confirms the mock daemon is ready before agents start

## Implementation

1. Add service to docker-compose.yml:
   ```yaml
   mock-daemon:
     build:
       context: ./cmd/mock-daemon  # or wherever the binary lives
     volumes:
       - daemon-sock:/tmp
     profiles: [agents]
     healthcheck:
       test: ["CMD", "test", "-S", "/tmp/obey-mock.sock"]
       interval: 2s
       timeout: 2s
       retries: 5
   ```
2. Add `daemon-sock` volume shared between mock-daemon and agent services
3. Update agent services to mount the same volume and set OBEY_SOCKET=/tmp/obey-mock.sock
4. In live mode, agents connect to host.docker.internal:50051 (existing config) — mock-daemon doesn't start

## Done When

- [ ] All requirements met
- [ ] `docker compose --profile agents up mock-daemon` starts and passes healthcheck
- [ ] Agent containers can connect to the mock daemon socket