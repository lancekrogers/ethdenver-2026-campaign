---
fest_type: task
fest_id: 01_update_justfiles_for_rebuild_on_code_changes.md
fest_name: update justfiles for rebuild on code changes
fest_parent: 05_docker_integration
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_tracking: true
---

# Task: Update Justfiles for Rebuild on Code Changes

## Objective

Update the demo justfile so `just demo up` rebuilds Docker images when source code has changed, instead of reusing stale cached images.

## Requirements

- [ ] `just demo up` passes `--build` to docker compose so images are rebuilt
- [ ] Rebuild is fast when no code changes (Docker layer caching)
- [ ] `just demo build` available as explicit rebuild command

## Implementation

1. In `.justfiles/demo.just`, change the `up` recipe to include `--build` flag in the docker compose up call
2. Add a `build` recipe that explicitly rebuilds all demo profile images
3. Ensure the docker-compose `up -d --build` pattern is used so containers restart with new code

## Done When

- [ ] All requirements met
- [ ] Code changes in agent-defi are reflected after `just demo up` without manual rebuild
- [ ] `just demo build` rebuilds all images explicitly
