---
fest_type: task
fest_id: 03_implement_0g_compute.md
fest_name: implement_0g_compute
fest_parent: 01_inference_0g
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement 0G Compute Integration

## Objective

Implement the `ComputeBroker` interface to connect the inference agent to 0G decentralized GPU compute. This package handles job submission, result polling, model listing, and error recovery. This is the core capability for the 0G Track 2 bounty ($7k, decentralized GPU inference).

**Project:** `agent-inference` at `projects/agent-inference/`
**Package:** `internal/zerog/compute/`

## Requirements

- [ ] Implement the `ComputeBroker` interface defined in the architecture task
- [ ] Support submitting inference jobs with model selection and input data
- [ ] Support polling for job results with configurable timeout
- [ ] Support listing available models on the 0G compute network
- [ ] Handle all errors with contextual wrapping
- [ ] Pass `context.Context` through all I/O operations
- [ ] Determine if 0G has a Go SDK or requires direct HTTP/gRPC calls

## Implementation

### Step 1: Research 0G Compute API

Before writing code, determine how to communicate with 0G Compute:

1. Check if 0G provides a Go SDK: search for `github.com/0glabs` Go packages
2. If no Go SDK exists, find the 0G Compute API documentation for HTTP/gRPC endpoints
3. Look for the 0G Compute broker contract address on testnet
4. Identify the API endpoints for: job submission, result retrieval, model listing

Document your findings in a comment at the top of `broker.go`. This is critical context for anyone maintaining this code later.

### Step 2: Define the model types

In `internal/zerog/compute/models.go`, define the request and response types:

```go
package compute

import "time"

// JobRequest contains the parameters for an inference job submission.
type JobRequest struct {
    // ModelID is the identifier of the AI model to use for inference.
    ModelID string

    // Input is the serialized input data for the model (prompt, image bytes, etc).
    Input []byte

    // MaxTokens limits the output length for text generation models.
    MaxTokens int

    // Temperature controls randomness in text generation (0.0 to 1.0).
    Temperature float64

    // Metadata contains optional key-value pairs for tracking.
    Metadata map[string]string
}

// JobResult contains the output of a completed inference job.
type JobResult struct {
    // JobID is the unique identifier for this job.
    JobID string

    // Output is the serialized inference result.
    Output []byte

    // ModelID identifies which model produced the result.
    ModelID string

    // Duration is how long the inference took.
    Duration time.Duration

    // TokensUsed is the number of tokens consumed (for text models).
    TokensUsed int

    // Status indicates the job completion status.
    Status JobStatus
}

// JobStatus represents the state of an inference job.
type JobStatus string

const (
    JobStatusPending   JobStatus = "pending"
    JobStatusRunning   JobStatus = "running"
    JobStatusCompleted JobStatus = "completed"
    JobStatusFailed    JobStatus = "failed"
)

// Model describes an available AI model on the 0G compute network.
type Model struct {
    ID          string
    Name        string
    Description string
    MaxInput    int
    MaxOutput   int
}
```

### Step 3: Implement the broker

In `internal/zerog/compute/broker.go`, implement the `ComputeBroker` interface:

```go
package compute

import (
    "context"
    "fmt"
    "time"
)

// BrokerConfig holds configuration for the 0G Compute broker connection.
type BrokerConfig struct {
    // Endpoint is the 0G Compute API base URL or gRPC address.
    Endpoint string

    // APIKey is the authentication credential for the 0G API.
    APIKey string

    // PollInterval is how often to check for job completion.
    PollInterval time.Duration

    // PollTimeout is the maximum time to wait for a job to complete.
    PollTimeout time.Duration
}

// broker implements the ComputeBroker interface using 0G Compute API.
type broker struct {
    cfg    BrokerConfig
    client *http.Client // or gRPC client depending on API
}

// NewBroker creates a new ComputeBroker connected to the 0G network.
func NewBroker(cfg BrokerConfig) (ComputeBroker, error) {
    // Validate configuration
    // Create HTTP/gRPC client
    // Return initialized broker
}
```

Key implementation details:

1. **SubmitJob**: POST the job request to the 0G compute endpoint. Parse the response to extract the job ID. If the API is contract-based, this may involve calling a smart contract method instead.

2. **GetResult**: Poll the job status endpoint using the job ID. Return `ErrJobPending` if still running. Implement a polling loop with `cfg.PollInterval` and `cfg.PollTimeout`. Always check `ctx.Err()` between polls.

3. **ListModels**: GET the available models endpoint. Cache the result with a reasonable TTL (5 minutes) to avoid excessive API calls.

Define sentinel errors:

```go
var (
    ErrJobPending  = errors.New("compute: job is still pending")
    ErrJobFailed   = errors.New("compute: job execution failed")
    ErrNoModels    = errors.New("compute: no models available")
    ErrBrokerDown  = errors.New("compute: broker is unreachable")
)
```

### Step 4: Implement polling with context awareness

The result polling loop is the most critical piece. It must respect context cancellation:

```go
func (b *broker) GetResult(ctx context.Context, jobID string) (*JobResult, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("compute: context already cancelled: %w", err)
    }

    deadline := time.After(b.cfg.PollTimeout)
    ticker := time.NewTicker(b.cfg.PollInterval)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            return nil, fmt.Errorf("compute: context cancelled while polling job %s: %w", jobID, ctx.Err())
        case <-deadline:
            return nil, fmt.Errorf("compute: timeout waiting for job %s after %v", jobID, b.cfg.PollTimeout)
        case <-ticker.C:
            result, err := b.fetchJobStatus(ctx, jobID)
            if err != nil {
                return nil, fmt.Errorf("compute: failed to fetch status for job %s: %w", jobID, err)
            }
            if result.Status == JobStatusCompleted {
                return result, nil
            }
            if result.Status == JobStatusFailed {
                return nil, fmt.Errorf("compute: job %s failed: %w", jobID, ErrJobFailed)
            }
            // Still pending or running, continue polling
        }
    }
}
```

### Step 5: Write unit tests

Create `internal/zerog/compute/broker_test.go` with table-driven tests:

1. **TestSubmitJob_Success**: Mock the HTTP endpoint, verify job ID returned
2. **TestSubmitJob_BrokerDown**: Mock connection failure, verify ErrBrokerDown
3. **TestGetResult_Completed**: Mock a completed job, verify result returned
4. **TestGetResult_Pending**: Mock a pending job, verify polling behavior
5. **TestGetResult_ContextCancelled**: Cancel context during polling, verify graceful exit
6. **TestGetResult_Timeout**: Set short timeout, verify timeout error
7. **TestListModels_Success**: Mock model list, verify parsed correctly
8. **TestListModels_Empty**: Mock empty response, verify ErrNoModels

Use `httptest.NewServer` for HTTP mocking or implement a mock `ComputeBroker` interface for higher-level tests.

### Step 6: Verify compilation and tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go build ./internal/zerog/compute/...
go test ./internal/zerog/compute/... -v
go vet ./internal/zerog/compute/...
```

## Done When

- [ ] `ComputeBroker` interface fully implemented in `internal/zerog/compute/broker.go`
- [ ] All model types defined in `internal/zerog/compute/models.go`
- [ ] Sentinel errors defined for all failure modes
- [ ] Polling loop respects context cancellation and configurable timeouts
- [ ] Table-driven unit tests cover success, error, timeout, and cancellation cases
- [ ] `go build`, `go test`, and `go vet` all pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
- [ ] 0G API research findings documented in code comments
