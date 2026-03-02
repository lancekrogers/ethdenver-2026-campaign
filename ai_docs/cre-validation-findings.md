# CRE Validation Findings

> Phase 003 (CRE_VALIDATION) — Validated 2026-03-02
> Festival: cre-risk-router-planning-CR0001

This document captures all findings from CRE CLI and SDK validation. It serves as the authoritative reference for all subsequent implementation phases.

---

## Supported Testnets

**Selected testnet:** `ethereum-testnet-sepolia`

CRE supports any EVM chain with a chain selector in `go-ethereum`. The chain name is used throughout config and SDK:

| Chain Name | Selector | Status |
|---|---|---|
| `ethereum-testnet-sepolia` | via `evm.ChainSelectorFromName()` | Validated |

**RPC:** `https://ethereum-sepolia-rpc.publicnode.com` (public, used in `project.yaml`)
**Block Explorer:** `https://sepolia.etherscan.io`
**Faucet:** `https://www.alchemy.com/faucets/ethereum-sepolia` or Google Cloud faucet

Experimental chains can be added via `project.yaml` under `experimental-chains` with a custom `chain-selector`, `rpc-url`, and `forwarder` address.

---

## CRE CLI Installation

**CLI version validated:** v1.2.0
**Repository:** `github.com/smartcontractkit/cre-cli`
**Install method:** Direct binary download from GitHub releases

```bash
# macOS arm64
curl -L -o cre.tar.gz \
  https://github.com/smartcontractkit/cre-cli/releases/download/v1.2.0/cre-cli_1.2.0_darwin_arm64.tar.gz
tar xzf cre.tar.gz
chmod +x cre
mv cre ~/bin/cre  # or /usr/local/bin/cre
```

**Gotcha:** The official install script (`curl -sSL https://cre.chain.link/install | sh`) returns "Unsupported platform" on macOS. Use the direct download instead.

**Gotcha:** Version check is `cre version` (subcommand), not `cre --version` (flag).

---

## Authentication Flow

```bash
# 1. Login (opens browser for OAuth)
cre login

# 2. Verify authentication
cre whoami
# Output: Email, Org ID, Deploy Access status

# 3. Link a signing key (required for broadcast)
cre account link-key

# 4. List linked keys
cre account list-key
```

**Credentials:** OAuth-based via browser. No API key needed. Auth persists across sessions (stored locally by the CLI).

**Environment variables for broadcast:**
- `CRE_ETH_PRIVATE_KEY` — Private key for signing transactions during broadcast

**Validated auth state:**
- Email: `lancekrogers@gmail.com`
- Org ID: `org_epIAEl49GPLrvGZ9`

---

## SDK Import Paths

The CRE SDK is modular — each capability is a separate Go module with independent versioning.

### Core SDK

```go
import (
    "github.com/smartcontractkit/cre-sdk-go/cre"       // Core types: Workflow, Handler, Runtime, Promise
    "github.com/smartcontractkit/cre-sdk-go/cre/wasm"   // WASM runner for main.go
)
```

### Capability Modules

```go
import (
    "github.com/smartcontractkit/cre-sdk-go/capabilities/scheduler/cron"      // Cron trigger
    "github.com/smartcontractkit/cre-sdk-go/capabilities/blockchain/evm"      // EVM client, chain selectors
)
```

### Generated Bindings

```go
import (
    "<module>/contracts/evm/src/generated/<contract>"  // Generated from ABI files
)
```

### Proto Dependencies

```go
import (
    "github.com/smartcontractkit/chainlink-protos/cre/go/values/pb"  // pb.BigInt, etc.
    "github.com/smartcontractkit/chainlink-protos/cre/go/sdk"        // pb2 types
)
```

### Validated Versions (go.mod)

| Module | Version |
|---|---|
| `cre-sdk-go` | `v1.2.0` |
| `cre-sdk-go/capabilities/blockchain/evm` | `v1.0.0-beta.5` |
| `cre-sdk-go/capabilities/scheduler/cron` | `v1.3.0` |
| `go-ethereum` | `v1.16.4` |
| `chainlink-protos/cre/go` | `v0.0.0-20260204183622-63ecea457961` |

**Go version:** 1.25.3
**Build target:** `GOOS=wasip1 GOARCH=wasm` (WASM)

---

## CRE Project Structure

```
project-root/
├── project.yaml              # Project-level settings (RPCs, chain config)
├── secrets.yaml              # Secret name declarations
├── go.mod                    # Go module (module name matches project)
├── go.sum
├── contracts/
│   └── evm/
│       └── src/
│           ├── abi/          # .abi files (ABI JSON arrays, NOT full Foundry JSON)
│           └── generated/    # Generated Go bindings (via cre generate-bindings evm)
│               └── <contract>/
│                   └── <Contract>.go
└── <workflow-name>/          # One directory per workflow
    ├── main.go               # WASM entrypoint (build tag: wasip1)
    ├── workflow.go            # Workflow logic (InitWorkflow + handlers)
    ├── workflow.yaml          # Workflow settings (staging/production targets)
    ├── config.staging.json    # Staging config
    └── config.production.json # Production config
```

---

## CRE Workflow Patterns

### main.go (WASM Entrypoint)

Every workflow needs this exact boilerplate:

```go
//go:build wasip1

package main

import (
    "github.com/smartcontractkit/cre-sdk-go/cre"
    "github.com/smartcontractkit/cre-sdk-go/cre/wasm"
)

func main() {
    wasm.NewRunner(cre.ParseJSON[Config]).Run(InitWorkflow)
}
```

- `cre.ParseJSON[Config]` deserializes the config JSON into the `Config` struct
- `wasm.NewRunner(...).Run(InitWorkflow)` wires everything up for the WASM runtime

### InitWorkflow Signature

```go
func InitWorkflow(
    config *Config,
    logger *slog.Logger,
    secretsProvider cre.SecretsProvider,
) (cre.Workflow[*Config], error) {
    trigger := cron.Trigger(&cron.Config{Schedule: "*/30 * * * * *"})
    return cre.Workflow[*Config]{
        cre.Handler(trigger, handlerFunc),
    }, nil
}
```

- Returns a `cre.Workflow[*Config]` which is a slice of handlers
- Each handler pairs a trigger with a callback function
- Multiple handlers can be registered in the same workflow

### Handler Function Signature

```go
func handlerFunc(
    config *Config,
    runtime cre.Runtime,
    trigger *cron.Payload,  // Type matches the trigger
) (*ResultType, error) {
    // ...
}
```

- `config` — Deserialized from `config.staging.json` or `config.production.json`
- `runtime` — Provides Logger(), GenerateReport(), and other runtime capabilities
- `trigger` — Payload from the trigger (e.g., `cron.Payload` has `ScheduledExecutionTime`)
- Return type is user-defined (any struct)

### Trigger Types

| Trigger | Constructor | Payload Type |
|---|---|---|
| Cron | `cron.Trigger(&cron.Config{Schedule: "..."})` | `*cron.Payload` |
| EVM Log | `evm.LogTrigger(chainSelector, &evm.FilterLogTriggerRequest{...})` | `*evm.Log` |

Cron schedule uses 6-field format (seconds included): `*/30 * * * * *` = every 30 seconds.

### Runtime Object

```go
runtime.Logger()          // *slog.Logger
runtime.GenerateReport()  // Promise[*cre.Report]
```

---

## EVM Write Pattern (Report-Based)

CRE does **NOT** do direct contract calls. All EVM writes go through a report-based consensus flow:

1. ABI-encode the data payload
2. Generate a DON-signed report via `runtime.GenerateReport()`
3. Submit the report to the consumer contract via `binding.WriteReport()`

The DON forwarder contract calls the consumer contract's `IReceiver` interface.

### Step-by-Step

```go
// 1. Create EVM client with chain selector
chainSelector, err := evm.ChainSelectorFromName(config.ChainName)
evmClient := &evm.Client{ChainSelector: chainSelector}

// 2. Create contract binding from generated code
address := common.HexToAddress(config.ContractAddress)
contract, err := trivial.NewTrivial(evmClient, address, nil)

// 3. ABI-encode the payload
uint256Type, _ := abi.NewType("uint256", "", nil)
args := abi.Arguments{{Type: uint256Type}}
encodedValue, err := args.Pack(big.NewInt(42))

// 4. Generate DON-signed report
report, err := runtime.GenerateReport(&cre.ReportRequest{
    EncodedPayload: encodedValue,
    EncoderName:    "evm",         // ALWAYS "evm" for Ethereum
}).Await()

// 5. Write report to chain via forwarder → consumer contract
resp, err := contract.WriteReport(runtime, report, nil).Await()
txHash := common.BytesToHash(resp.TxHash).Hex()
```

### Key Types

- `cre.ReportRequest` — `EncodedPayload []byte`, `EncoderName string`
- `cre.Report` — Opaque DON-signed report
- `evm.WriteReportReply` — `TxHash []byte`
- `evm.GasConfig` — Optional gas settings (pass `nil` for defaults)

### Generated Binding Methods

The `cre generate-bindings evm` command produces:

- `NewContract(client, address, options)` — Constructor
- `Contract.Value(runtime, blockNumber)` — Read methods return `cre.Promise[T]`
- `Contract.WriteReport(runtime, report, gasConfig)` — Write method returns `cre.Promise[*evm.WriteReportReply]`
- `Contract.LogTrigger<Event>(chainSelector, confidence, filters)` — Log trigger factory
- `Codec` — ABI encode/decode helpers

---

## EVM Read Pattern

```go
// Read a value at the finalized block
result, err := contract.Value(runtime, nil).Await()

// Read at a specific block
blockNum := big.NewInt(12345)
result, err := contract.Value(runtime, blockNum).Await()
```

**Gotcha:** Read methods don't work in simulation for non-CRE contracts. The simulation environment returns empty responses for view calls.

---

## Config Structure

### config.staging.json / config.production.json

User-defined JSON matching the `Config` struct:

```json
{
  "contractAddress": "0xa5378FbDCD2799C549A559C1C7c1F91D7C983A44",
  "chainName": "ethereum-testnet-sepolia"
}
```

### workflow.yaml (REQUIRED in each workflow directory)

```yaml
staging-settings:
  user-workflow:
    workflow-name: "my-workflow-staging"
  workflow-artifacts:
    workflow-path: "."
    config-path: "./config.staging.json"
    secrets-path: ""

production-settings:
  user-workflow:
    workflow-name: "my-workflow-production"
  workflow-artifacts:
    workflow-path: "."
    config-path: "./config.production.json"
    secrets-path: ""
```

### project.yaml (at project root)

```yaml
staging-settings:
  rpcs:
    - chain-name: ethereum-testnet-sepolia
      url: https://ethereum-sepolia-rpc.publicnode.com

production-settings:
  rpcs:
    - chain-name: ethereum-testnet-sepolia
      url: https://ethereum-sepolia-rpc.publicnode.com
```

Optional fields: `account.workflow-owner-address`, `experimental-chains`.

### secrets.yaml

```yaml
secretsNames:
  - MY_SECRET_KEY
```

Secrets are accessed via `secretsProvider` in `InitWorkflow`.

---

## CLI Commands Reference

```bash
# Project scaffolding
cre init --template=hello-world-go --project-name=<name> --workflow-name=<name>

# Generate EVM bindings from .abi files
cre generate-bindings evm

# Simulate (dry run, no on-chain tx)
cre workflow simulate ./<workflow-dir> \
  --non-interactive \
  --trigger-index=0 \
  --target=staging-settings

# Broadcast (actual on-chain tx)
CRE_ETH_PRIVATE_KEY=<key> cre workflow simulate ./<workflow-dir> \
  --non-interactive \
  --trigger-index=0 \
  --target=staging-settings \
  --broadcast
```

### Available Templates

| Template | Description |
|---|---|
| `hello-world-go` | Basic cron trigger workflow |
| `hello-world-ts` | TypeScript equivalent |
| `read-data-feeds-go` | Reads Chainlink price feeds |
| `custom-data-feed-go` | Custom data feed with EVM write |

---

## Binding Generation

```bash
# 1. Place .abi files (ABI JSON arrays only, NOT full Foundry JSON)
contracts/evm/src/abi/<Contract>.abi

# 2. Extract ABI array from Foundry output if needed
python3 -c "import json; print(json.dumps(json.load(open('out/Contract.sol/Contract.json'))['abi']))" > Contract.abi

# 3. Generate bindings
cre generate-bindings evm
# Outputs to: contracts/evm/src/generated/<contract>/<Contract>.go
```

**Gotcha:** The `.abi` file must contain ONLY the ABI array `[{...}]`, not the full Foundry JSON artifact `{"abi":[...], "bytecode":...}`.

---

## Gotchas and Pitfalls

### Installation
- Official install script (`cre.chain.link/install`) doesn't support macOS — download binary directly
- Version check: `cre version` not `cre --version`
- `cre init` fails without TTY — provide all flags: `--template`, `--project-name`, `--workflow-name`

### SDK Versioning
- Each capability module is versioned independently in `go.mod`
- `cre-sdk-go/capabilities/scheduler/cron` is NOT included with core `cre-sdk-go` — must be added separately
- Version mismatches between capability modules cause build failures

### workflow.yaml
- **REQUIRED** in each workflow directory — the `cre init` template sometimes doesn't create it
- Without it: `cre workflow simulate` fails with "workflow.yaml: no such file or directory"
- Must be created manually following the format above

### Simulation vs Broadcast
- Simulation uses mock environment — EVM reads against real contracts return empty data
- Broadcast requires `CRE_ETH_PRIVATE_KEY` environment variable
- Broadcast requires `--broadcast` flag added to the simulate command
- The broadcast goes through a DON, so the tx sender is the forwarder contract, not your wallet

### Report Generation
- `EncoderName: "evm"` is MANDATORY in `ReportRequest` — omitting it causes "unsupported encoder name: " error
- `GenerateReport` returns `Promise[*Report]`, not `(*Report, error)` — must call `.Await()`
- The report is opaque — you don't inspect it, you pass it directly to `WriteReport`

### ABI Bindings
- `cre generate-bindings evm` expects `.abi` files, not `.json`
- Files must be in `contracts/evm/src/abi/` directory
- Generated code goes to `contracts/evm/src/generated/<lowercase-contract>/`

### Build Target
- All workflow code compiles to WASM: `GOOS=wasip1 GOARCH=wasm`
- The `//go:build wasip1` tag is required on `main.go`
- Standard library I/O (file system, network) is not available in WASM context

---

## Validated Artifacts

| Artifact | Value |
|---|---|
| Deployed contract | `0xa5378FbDCD2799C549A559C1C7c1F91D7C983A44` (Sepolia) |
| Deploy tx | `0x08055ba76bbc651c94eabc9ff4c89cc87c75b17bb9240e015be264d0ad9f5f7e` |
| Broadcast tx | `0x46f144cf4566ab9b59330ac55adb11d39ae5bec32f597824dfaef4dc81fa82e0` |
| Broadcast block | 10367095 |
| Deployer wallet | `0xC71d8A19422C649fe9bdCbF3ffA536326c82b58b` |
| Deployer key env var | `DEFI_PRIVATE_KEY` (in `projects/agent-defi/.env`) |
| CRE CLI | v1.2.0 at `~/bin/cre` |
