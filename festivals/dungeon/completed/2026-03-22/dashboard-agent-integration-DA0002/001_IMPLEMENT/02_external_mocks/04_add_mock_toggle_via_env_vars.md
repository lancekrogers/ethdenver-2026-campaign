---
fest_type: task
fest_id: 01_add_mock_toggle_via_env_vars.md
fest_name: add mock toggle via env vars
fest_parent: 02_external_mocks
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.12355-06:00
fest_updated: 2026-03-22T16:22:28.26393-06:00
fest_tracking: true
---


# Task: Add Mock Toggle via Env Vars

## Objective

Ensure all agent binaries have a consistent mock toggle pattern — env var checked at startup, determines whether real or mock external clients are injected.

## Requirements

- [ ] Each agent binary checks its mock env var at startup and injects the appropriate client implementation
- [ ] Env vars already defined in docker-compose.yml are reused (DEFI_MOCK_MODE, etc.)
- [ ] Add any missing mock env vars for coordinator (MOCK_HCS) and inference (ZG_MOCK_MODE)
- [ ] Document the full set of mock env vars in .env.demo.example

## Implementation

1. In each agent's main.go, add a conditional at client creation time:
   ```go
   var hcsClient hcs.Client
   if os.Getenv("MOCK_HCS") == "true" {
       hcsClient = hcs.NewMockClient()
   } else {
       hcsClient = hcs.NewClient(config)
   }
   ```
2. Update .env.demo.example with all mock flags set to true
3. Update .env.live.example with all mock flags set to false
4. Ensure docker-compose.yml passes these env vars to the appropriate services

## Done When

- [ ] All requirements met
- [ ] All agent binaries start cleanly with mock flags enabled
- [ ] .env.demo.example and .env.live.example document all mock env vars