---
fest_type: task
fest_id: 08_implement_agent_lifecycle.md
fest_name: implement_agent_lifecycle
fest_parent: 01_inference_0g
fest_order: 8
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Agent Lifecycle

## Objective

Wire all packages together into the inference agent's main loop and binary entry point. The agent lifecycle manages startup, daemon registration, HCS subscription, task processing, and graceful shutdown. This task produces a runnable `agent-inference` binary that demonstrates the complete inference agent flow.

**Project:** `agent-inference` at `projects/agent-inference/`
**Packages:** `internal/agent/agent.go`, `internal/agent/config.go`, `cmd/agent-inference/main.go`

## Requirements

- [ ] Implement the Agent struct that orchestrates all 0G and HCS packages
- [ ] Implement the main processing loop: receive task -> execute inference -> store -> mint -> audit -> report
- [ ] Wire dependency injection in `cmd/agent-inference/main.go`
- [ ] Implement graceful shutdown on SIGINT/SIGTERM and context cancellation
- [ ] Load configuration from environment variables
- [ ] Connect to the daemon client for agent registration

## Implementation

### Step 1: Implement agent configuration

In `internal/agent/config.go`:

```go
package agent

import (
    "fmt"
    "os"
    "strconv"
    "time"

    "agent-inference/internal/zerog/compute"
    "agent-inference/internal/zerog/storage"
    "agent-inference/internal/zerog/inft"
    "agent-inference/internal/zerog/da"
    "agent-inference/internal/hcs"
)

// Config holds all configuration for the inference agent.
type Config struct {
    // AgentID is the unique identifier for this agent instance.
    AgentID string

    // DaemonAddr is the address of the daemon client for registration.
    DaemonAddr string

    // HealthInterval is how often to send health updates via HCS.
    HealthInterval time.Duration

    // Compute holds 0G Compute broker configuration.
    Compute compute.BrokerConfig

    // Storage holds 0G Storage client configuration.
    Storage storage.ClientConfig

    // INFT holds 0G Chain iNFT minter configuration.
    INFT inft.MinterConfig

    // DA holds 0G DA publisher configuration.
    DA da.PublisherConfig

    // HCS holds Hedera Consensus Service handler configuration.
    HCS hcs.HandlerConfig
}

// LoadConfig reads configuration from environment variables.
// Every field is loaded from an environment variable with the
// INFERENCE_ prefix (e.g., INFERENCE_AGENT_ID, INFERENCE_DAEMON_ADDR).
func LoadConfig() (*Config, error) {
    cfg := &Config{}

    cfg.AgentID = os.Getenv("INFERENCE_AGENT_ID")
    if cfg.AgentID == "" {
        return nil, fmt.Errorf("config: INFERENCE_AGENT_ID is required")
    }

    cfg.DaemonAddr = os.Getenv("INFERENCE_DAEMON_ADDR")
    if cfg.DaemonAddr == "" {
        cfg.DaemonAddr = "localhost:9090" // default
    }

    // Parse health interval with default
    healthStr := os.Getenv("INFERENCE_HEALTH_INTERVAL")
    if healthStr == "" {
        cfg.HealthInterval = 30 * time.Second
    } else {
        dur, err := time.ParseDuration(healthStr)
        if err != nil {
            return nil, fmt.Errorf("config: invalid INFERENCE_HEALTH_INTERVAL: %w", err)
        }
        cfg.HealthInterval = dur
    }

    // Load 0G Compute config
    cfg.Compute.Endpoint = os.Getenv("ZG_COMPUTE_ENDPOINT")
    cfg.Compute.APIKey = os.Getenv("ZG_COMPUTE_API_KEY")

    // Load 0G Storage config
    cfg.Storage.Endpoint = os.Getenv("ZG_STORAGE_ENDPOINT")
    cfg.Storage.APIKey = os.Getenv("ZG_STORAGE_API_KEY")

    // Load 0G Chain / iNFT config
    cfg.INFT.ChainRPC = os.Getenv("ZG_CHAIN_RPC")
    cfg.INFT.ContractAddress = os.Getenv("ZG_INFT_CONTRACT")
    cfg.INFT.PrivateKey = os.Getenv("ZG_CHAIN_PRIVATE_KEY")

    // Load 0G DA config
    cfg.DA.Endpoint = os.Getenv("ZG_DA_ENDPOINT")
    cfg.DA.Namespace = os.Getenv("ZG_DA_NAMESPACE")

    // Load Hedera HCS config (topic IDs parsed from strings)
    // HEDERA_TASK_TOPIC, HEDERA_RESULT_TOPIC, HEDERA_HEALTH_TOPIC
    // HEDERA_OPERATOR_ID, HEDERA_OPERATOR_KEY, HEDERA_NETWORK

    return cfg, nil
}
```

### Step 2: Implement the Agent struct

In `internal/agent/agent.go`:

```go
package agent

import (
    "context"
    "fmt"
    "log/slog"
    "time"

    "agent-inference/internal/zerog/compute"
    "agent-inference/internal/zerog/storage"
    "agent-inference/internal/zerog/inft"
    "agent-inference/internal/zerog/da"
    "agent-inference/internal/hcs"
)

// Agent orchestrates the inference agent lifecycle.
type Agent struct {
    cfg     Config
    log     *slog.Logger
    compute compute.ComputeBroker
    storage storage.StorageClient
    minter  inft.INFTMinter
    audit   da.AuditPublisher
    hcs     *hcs.Handler

    startTime      time.Time
    completedTasks int
}

// New creates a new Agent with all dependencies injected.
func New(cfg Config, log *slog.Logger, cb compute.ComputeBroker,
    sc storage.StorageClient, im inft.INFTMinter,
    ap da.AuditPublisher, h *hcs.Handler) *Agent {
    return &Agent{
        cfg:     cfg,
        log:     log,
        compute: cb,
        storage: sc,
        minter:  im,
        audit:   ap,
        hcs:     h,
    }
}
```

### Step 3: Implement the main loop

The Run method is the core of the agent:

```go
// Run starts the agent and blocks until the context is cancelled.
func (a *Agent) Run(ctx context.Context) error {
    a.startTime = time.Now()
    a.log.Info("starting inference agent", "agent_id", a.cfg.AgentID)

    // Step 1: Start HCS subscription
    go func() {
        if err := a.hcs.StartSubscription(ctx); err != nil {
            a.log.Error("HCS subscription failed", "error", err)
        }
    }()

    // Step 2: Start health reporter
    go a.healthLoop(ctx)

    // Step 3: Process tasks from HCS
    for {
        select {
        case <-ctx.Done():
            a.log.Info("shutting down inference agent", "completed_tasks", a.completedTasks)
            return ctx.Err()
        case task := <-a.hcs.Tasks():
            if err := a.processTask(ctx, task); err != nil {
                a.log.Error("task processing failed",
                    "task_id", task.TaskID,
                    "error", err)
                // Report failure back to coordinator
                a.reportFailure(ctx, task, err)
            }
        }
    }
}
```

### Step 4: Implement task processing pipeline

```go
// processTask executes the full inference pipeline for a single task.
func (a *Agent) processTask(ctx context.Context, task hcs.TaskAssignment) error {
    a.log.Info("processing task", "task_id", task.TaskID, "model", task.ModelID)

    // 1. Publish audit event: task received
    a.audit.Publish(ctx, da.AuditEvent{
        EventType: da.EventTaskReceived,
        JobID:     task.TaskID,
        AgentID:   a.cfg.AgentID,
        Timestamp: time.Now(),
    })

    // 2. Submit inference job to 0G Compute
    jobID, err := a.compute.SubmitJob(ctx, compute.JobRequest{
        ModelID:   task.ModelID,
        Input:     []byte(task.Input),
        MaxTokens: task.MaxTokens,
    })
    if err != nil {
        return fmt.Errorf("agent: submit job failed for task %s: %w", task.TaskID, err)
    }

    // 3. Poll for inference result
    result, err := a.compute.GetResult(ctx, jobID)
    if err != nil {
        return fmt.Errorf("agent: get result failed for job %s: %w", jobID, err)
    }

    // 4. Store result on 0G Storage
    contentID, err := a.storage.Upload(ctx, result.Output, storage.Metadata{
        Name:        fmt.Sprintf("inference-%s", task.TaskID),
        ContentType: "application/json",
        Tags:        map[string]string{"task_id": task.TaskID, "model": task.ModelID},
    })
    if err != nil {
        return fmt.Errorf("agent: storage upload failed for task %s: %w", task.TaskID, err)
    }

    // 5. Mint iNFT with encrypted metadata
    tokenID, err := a.minter.Mint(ctx, inft.MintRequest{
        Name:             fmt.Sprintf("Inference Result: %s", task.TaskID),
        InferenceJobID:   jobID,
        StorageContentID: contentID,
        PlaintextMeta: map[string]string{
            "task_id":  task.TaskID,
            "model_id": task.ModelID,
            "agent_id": a.cfg.AgentID,
        },
    })
    if err != nil {
        return fmt.Errorf("agent: iNFT mint failed for task %s: %w", task.TaskID, err)
    }

    // 6. Publish audit event: inference completed
    auditID, _ := a.audit.Publish(ctx, da.AuditEvent{
        EventType:  da.EventInferenceCompleted,
        JobID:      task.TaskID,
        AgentID:    a.cfg.AgentID,
        Timestamp:  time.Now(),
        StorageRef: contentID,
        INFTRef:    tokenID,
    })

    // 7. Report result back to coordinator via HCS
    err = a.hcs.PublishResult(ctx, hcs.TaskResult{
        TaskID:            task.TaskID,
        Status:            "completed",
        Output:            string(result.Output),
        DurationMs:        result.Duration.Milliseconds(),
        StorageContentID:  contentID,
        INFTTokenID:       tokenID,
        AuditSubmissionID: auditID,
    })
    if err != nil {
        return fmt.Errorf("agent: result publish failed for task %s: %w", task.TaskID, err)
    }

    a.completedTasks++
    a.log.Info("task completed", "task_id", task.TaskID, "total_completed", a.completedTasks)
    return nil
}
```

### Step 5: Implement health reporting loop

```go
// healthLoop sends periodic health updates to the coordinator via HCS.
func (a *Agent) healthLoop(ctx context.Context) {
    ticker := time.NewTicker(a.cfg.HealthInterval)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            status := "idle"
            // Determine status based on current activity
            a.hcs.PublishHealth(ctx, hcs.HealthStatus{
                AgentID:        a.cfg.AgentID,
                Status:         status,
                UptimeSeconds:  int64(time.Since(a.startTime).Seconds()),
                CompletedTasks: a.completedTasks,
            })
        }
    }
}
```

### Step 6: Implement the entry point

In `cmd/agent-inference/main.go`:

```go
package main

import (
    "context"
    "log/slog"
    "os"
    "os/signal"
    "syscall"

    "agent-inference/internal/agent"
    "agent-inference/internal/zerog/compute"
    "agent-inference/internal/zerog/storage"
    "agent-inference/internal/zerog/inft"
    "agent-inference/internal/zerog/da"
    "agent-inference/internal/hcs"
)

func main() {
    log := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))

    // Load configuration from environment
    cfg, err := agent.LoadConfig()
    if err != nil {
        log.Error("failed to load config", "error", err)
        os.Exit(1)
    }

    // Create context with signal handling for graceful shutdown
    ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
    defer cancel()

    // Initialize all dependencies
    cb, err := compute.NewBroker(cfg.Compute)
    // ... error handling ...

    sc, err := storage.NewClient(cfg.Storage)
    // ... error handling ...

    im, err := inft.NewMinter(cfg.INFT)
    // ... error handling ...

    ap, err := da.NewPublisher(cfg.DA)
    // ... error handling ...

    h, err := hcs.NewHandler(cfg.HCS)
    // ... error handling ...

    // Create and run the agent
    a := agent.New(*cfg, log, cb, sc, im, ap, h)

    log.Info("inference agent starting", "agent_id", cfg.AgentID)
    if err := a.Run(ctx); err != nil && err != context.Canceled {
        log.Error("agent exited with error", "error", err)
        os.Exit(1)
    }
    log.Info("inference agent stopped gracefully")
}
```

### Step 7: Write unit tests

Create `internal/agent/agent_test.go`:

1. **TestAgent_ProcessTask_Success**: Mock all dependencies, verify full pipeline executes
2. **TestAgent_ProcessTask_ComputeFails**: Mock compute failure, verify error reported
3. **TestAgent_ProcessTask_StorageFails**: Mock storage failure after compute succeeds
4. **TestAgent_ProcessTask_ContextCancelled**: Cancel during processing, verify clean exit
5. **TestAgent_Run_ReceivesAndProcesses**: Send task via channel, verify processing
6. **TestAgent_Run_GracefulShutdown**: Cancel context, verify clean shutdown
7. **TestAgent_HealthLoop**: Verify health messages sent at configured interval
8. **TestLoadConfig_RequiredFields**: Verify required env vars checked
9. **TestLoadConfig_Defaults**: Verify default values applied

### Step 8: Verify the full build

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go build ./...
go test ./... -v
go vet ./...
```

The binary should be buildable even if external services are not available (all I/O is behind interfaces that can be mocked).

## Done When

- [ ] `internal/agent/agent.go` implements the Agent struct with Run and processTask methods
- [ ] `internal/agent/config.go` loads all configuration from environment variables
- [ ] `cmd/agent-inference/main.go` wires all dependencies and handles graceful shutdown
- [ ] Task processing pipeline: HCS receive -> compute -> store -> mint -> audit -> report
- [ ] Health reporting loop sends updates at configurable intervals
- [ ] Graceful shutdown on SIGINT/SIGTERM cancels context and waits for cleanup
- [ ] All dependencies injected via constructor (no global state)
- [ ] Table-driven unit tests cover the processing pipeline and lifecycle
- [ ] `go build ./...` produces a runnable binary
- [ ] `go test ./...` and `go vet ./...` pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
