---
fest_type: task
fest_id: 01_justfile.md
fest_name: justfile
fest_parent: 01_project_scaffold
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:43:28.922183-07:00
fest_tracking: true
---

# Task: justfile

## Objective

Create a justfile with build, simulate, test, and deploy recipes for the CRE Risk Router project.

## Requirements

- [ ] Root justfile created at `projects/cre-risk-router/justfile` (Req P0.1)
- [ ] `just simulate` runs `cre workflow simulate .`
- [ ] `just broadcast` runs `cre workflow simulate . --broadcast`
- [ ] `just test` runs Go tests and Foundry tests
- [ ] `just deploy` deploys the contract via Foundry

## Implementation

1. **Create `justfile`** at `projects/cre-risk-router/justfile`:

   ```just
   # CRE Risk Router - Build, Simulate, Test, Deploy

   default:
       @just --list

   simulate:
       cre workflow simulate .

   broadcast:
       cre workflow simulate . --broadcast

   test: test-go test-sol

   test-go:
       go test ./... -v

   test-sol:
       forge test -vvv

   build:
       go build -o bin/cre-risk-router .

   deploy:
       forge create contracts/evm/src/RiskDecisionReceipt.sol:RiskDecisionReceipt \
           --rpc-url $TESTNET_RPC \
           --private-key $DEPLOYER_PRIVATE_KEY

   bindings:
       cre generate-bindings evm

   lint:
       go vet ./...

   fmt:
       gofmt -w .

   demo:
       bash demo/e2e.sh

   clean:
       rm -rf bin/ contracts/evm/out/
   ```

2. **Verify recipes** work on the scaffolded project:

   ```bash
   just
   just build
   ```

## Done When

- [ ] All requirements met
- [ ] `just` shows available recipes
- [ ] `just build` compiles the Go project
- [ ] All recipe names are documented and functional
