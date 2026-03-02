---
fest_type: task
fest_id: 01_hello_world_workflow.md
fest_name: hello world workflow
fest_parent: 01_cli_setup
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:42:44.241177-07:00
fest_tracking: true
---

# Task: hello world workflow

## Objective

Create a minimal Go CRE workflow with a cron trigger that logs a string, serving as a validation target for dry-run simulation.

## Requirements

- [ ] Minimal Go CRE workflow compiles without errors (Req 0.3)
- [ ] Workflow uses a cron trigger (e.g., `*/5 * * * *`)
- [ ] Handler logs a string to prove execution
- [ ] Project has `go.mod`, `workflow.go`, and `config.json`

## Implementation

1. **Create a temporary validation directory**:

   ```bash
   mkdir -p /tmp/cre-hello-world && cd /tmp/cre-hello-world
   ```

2. **Initialize Go module**:

   ```bash
   go mod init github.com/lancekrogers/cre-hello-world
   ```

3. **Create `workflow.go`**:

   ```go
   package main

   import "github.com/smartcontractkit/chainlink-cre/pkg/cre"

   func main() {
       cre.Run(InitWorkflow)
   }

   func InitWorkflow(runtime cre.Runtime) []cre.Handler {
       return []cre.Handler{
           cre.NewHandler(
               cre.CronTrigger("*/5 * * * *"),
               func(runtime cre.Runtime, trigger cre.TriggerEvent) (any, error) {
                   runtime.Logger().Info("Hello from CRE Risk Router validation!")
                   return map[string]string{"status": "ok"}, nil
               },
           ),
       }
   }
   ```

   **Note:** The exact CRE SDK import paths and function signatures may differ from the above. Consult the CRE SDK source at `github.com/smartcontractkit/chainlink-agent-skills/cre-skills` and the hackathon skills repo for correct patterns. Update the code accordingly.

4. **Create `config.json`**:

   ```json
   {
     "name": "cre-hello-world",
     "version": "0.1.0"
   }
   ```

   Add any required CRE config fields discovered during auth setup.

5. **Resolve dependencies**:

   ```bash
   go mod tidy
   ```

6. **Build and verify compilation**:

   ```bash
   go build -o /dev/null .
   ```

7. **Document findings**:
   - Exact CRE SDK import path (may be different from above placeholder)
   - Correct function signatures for `InitWorkflow`, handler functions
   - Required fields in `config.json`
   - Any `cre init` or scaffolding command that generates boilerplate

## Done When

- [ ] All requirements met
- [ ] `go build` succeeds without errors
- [ ] Workflow has a cron trigger and a handler that logs a string
- [ ] CRE SDK import paths and function signatures are validated against actual SDK
