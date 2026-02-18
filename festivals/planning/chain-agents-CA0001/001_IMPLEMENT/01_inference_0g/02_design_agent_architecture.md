---
fest_type: task
fest_id: 02_design_agent_architecture.md
fest_name: design_agent_architecture
fest_parent: 01_inference_0g
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design Agent Architecture

## Objective

Design the complete architecture for the inference agent in the `agent-inference` project. Define the package layout, interfaces, agent lifecycle, and data flow. This design document and initial package scaffolding become the blueprint that all subsequent implementation tasks follow.

**Project:** `agent-inference` at `projects/agent-inference/`

## Requirements

- [ ] Define the package layout under `internal/`
- [ ] Design the agent lifecycle: start -> register with daemon -> subscribe HCS -> wait for tasks -> execute -> report
- [ ] Define core interfaces for each package
- [ ] Create the directory structure and placeholder files
- [ ] Document the data flow from task receipt to result reporting

## Implementation

### Step 1: Define the package layout

Navigate to the agent-inference project:

```bash
fgo
```

Create the following package structure under `internal/`:

```
internal/
  agent/          # Agent lifecycle, main loop, configuration
    agent.go      # Core Agent struct and lifecycle methods
    config.go     # Agent configuration (environment, keys, endpoints)
  zerog/
    compute/      # 0G Compute broker integration
      broker.go   # ComputeBroker interface and implementation
      models.go   # Job, Result, Model type definitions
    storage/      # 0G Storage integration
      client.go   # StorageClient interface and implementation
      models.go   # Upload, Download, Metadata type definitions
    inft/         # 0G Chain ERC-7857 iNFT minting
      minter.go   # INFTMinter interface and implementation
      models.go   # NFT metadata, mint request/response types
    da/           # 0G Data Availability audit trail
      publisher.go # AuditPublisher interface and implementation
      models.go   # AuditEvent, Submission type definitions
  hcs/            # Hedera Consensus Service integration
    handler.go    # HCS message handler (subscribe + publish)
    messages.go   # Task assignment and result message types
cmd/
  agent-inference/
    main.go       # Entry point, wires dependencies, starts agent
```

### Step 2: Create the directory structure

Create all directories and initial placeholder files. Each file should contain the package declaration and a brief comment describing its purpose:

```bash
mkdir -p internal/agent
mkdir -p internal/zerog/compute
mkdir -p internal/zerog/storage
mkdir -p internal/zerog/inft
mkdir -p internal/zerog/da
mkdir -p internal/hcs
mkdir -p cmd/agent-inference
```

### Step 3: Define core interfaces

Create interface definitions in each package. These interfaces are the contracts that implementation tasks will fulfill.

**internal/zerog/compute/broker.go** -- ComputeBroker interface:

```go
package compute

import "context"

// ComputeBroker submits inference jobs to 0G decentralized GPU compute
// and retrieves results.
type ComputeBroker interface {
    // SubmitJob sends an inference job to the 0G compute network.
    // Returns a job ID that can be used to poll for results.
    SubmitJob(ctx context.Context, req JobRequest) (string, error)

    // GetResult polls for the result of a previously submitted job.
    // Returns ErrJobPending if the job is still running.
    GetResult(ctx context.Context, jobID string) (*JobResult, error)

    // ListModels returns the available AI models on the 0G compute network.
    ListModels(ctx context.Context) ([]Model, error)
}
```

**internal/zerog/storage/client.go** -- StorageClient interface:

```go
package storage

import "context"

// StorageClient persists and retrieves data from 0G decentralized storage.
type StorageClient interface {
    // Upload stores data on 0G Storage. Returns a content identifier.
    Upload(ctx context.Context, data []byte, meta Metadata) (string, error)

    // Download retrieves data from 0G Storage by content identifier.
    Download(ctx context.Context, contentID string) ([]byte, error)

    // List returns metadata for stored items matching the given prefix.
    List(ctx context.Context, prefix string) ([]Metadata, error)
}
```

**internal/zerog/inft/minter.go** -- INFTMinter interface:

```go
package inft

import "context"

// INFTMinter creates ERC-7857 iNFTs with encrypted metadata on 0G Chain.
type INFTMinter interface {
    // Mint creates a new iNFT with the given encrypted metadata.
    // Returns the token ID of the minted NFT.
    Mint(ctx context.Context, req MintRequest) (string, error)

    // UpdateMetadata updates the encrypted metadata of an existing iNFT.
    UpdateMetadata(ctx context.Context, tokenID string, meta EncryptedMeta) error

    // GetStatus returns the current status of a minted iNFT.
    GetStatus(ctx context.Context, tokenID string) (*INFTStatus, error)
}
```

**internal/zerog/da/publisher.go** -- AuditPublisher interface:

```go
package da

import "context"

// AuditPublisher posts inference audit events to 0G Data Availability.
type AuditPublisher interface {
    // Publish submits an audit event to the 0G DA layer.
    // Returns a submission ID for verification.
    Publish(ctx context.Context, event AuditEvent) (string, error)

    // Verify confirms that a previously published audit event is available.
    Verify(ctx context.Context, submissionID string) (bool, error)
}
```

**internal/hcs/handler.go** -- HCS handler interfaces:

```go
package hcs

import "context"

// TaskHandler processes incoming task assignments from the coordinator.
type TaskHandler interface {
    // HandleTask is called when a new task assignment arrives via HCS.
    HandleTask(ctx context.Context, task TaskAssignment) error
}

// ResultPublisher sends task results back to the coordinator via HCS.
type ResultPublisher interface {
    // PublishResult sends a completed task result to the coordinator.
    PublishResult(ctx context.Context, result TaskResult) error

    // PublishHealth sends a periodic health/status update.
    PublishHealth(ctx context.Context, status HealthStatus) error
}
```

### Step 4: Design the agent lifecycle

Document the agent lifecycle in `internal/agent/agent.go`:

```go
package agent

// Agent orchestrates the inference agent lifecycle.
//
// Lifecycle:
//   1. Initialize: Load config, create 0G clients, create HCS handler
//   2. Register: Connect to daemon client, register as inference agent
//   3. Subscribe: Start HCS subscription for task assignments
//   4. Run: Enter main loop -- wait for tasks, execute, report
//   5. Shutdown: Graceful shutdown on context cancellation or signal
//
// The main loop processes tasks sequentially:
//   - Receive TaskAssignment from HCS
//   - Submit inference job to 0G Compute
//   - Poll for result
//   - Store result on 0G Storage
//   - Mint iNFT with result metadata
//   - Publish audit event to 0G DA
//   - Report TaskResult back via HCS
type Agent struct {
    cfg     Config
    compute compute.ComputeBroker
    storage storage.StorageClient
    minter  inft.INFTMinter
    audit   da.AuditPublisher
    hcs     *hcs.Handler
}
```

### Step 5: Verify the scaffold compiles

After creating all files with their package declarations and interfaces:

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go build ./...
```

Fix any compilation errors. At this stage the files contain only type definitions and interfaces, so compilation should succeed cleanly.

## Done When

- [ ] All directories under `internal/` created as specified
- [ ] Each package has its interface file with documented Go interfaces
- [ ] Each package has a models file with type definitions for request/response structs
- [ ] `cmd/agent-inference/main.go` exists with a minimal main function
- [ ] `internal/agent/agent.go` documents the full agent lifecycle in comments
- [ ] `go build ./...` succeeds with no errors
- [ ] Package layout is clean: no file exceeds 500 lines, all interfaces have 3-5 methods max
