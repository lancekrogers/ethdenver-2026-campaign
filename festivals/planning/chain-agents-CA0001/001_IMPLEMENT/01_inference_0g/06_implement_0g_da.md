---
fest_type: task
fest_id: 06_implement_0g_da.md
fest_name: implement_0g_da
fest_parent: 01_inference_0g
fest_order: 6
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement 0G DA Audit Trail

## Objective

Implement the `AuditPublisher` interface to publish inference audit events to 0G Data Availability (DA). Every inference operation produces an audit event that is posted to 0G DA, creating a verifiable, tamper-proof record of the agent's actions. This audit trail is critical for demonstrating trustworthy AI agent behavior and supports the 0G bounty submission narrative.

**Project:** `agent-inference` at `projects/agent-inference/`
**Package:** `internal/zerog/da/`

## Requirements

- [ ] Implement the `AuditPublisher` interface defined in the architecture task
- [ ] Serialize audit events into a structured format suitable for DA submission
- [ ] Submit audit events to the 0G DA layer
- [ ] Support verifying that a previously submitted event is available
- [ ] Handle all errors with contextual wrapping
- [ ] Pass `context.Context` through all I/O operations

## Implementation

### Step 1: Research 0G DA

Before writing code, investigate the 0G Data Availability layer:

1. Find the 0G DA documentation -- understand how data is submitted and verified
2. Identify the DA node endpoint on testnet
3. Determine the submission format: raw bytes? Structured blobs? Namespaced data?
4. Understand the verification mechanism: how do you prove data availability after submission?
5. Check for Go libraries or if direct HTTP/gRPC calls are needed

Document findings in comments at the top of `publisher.go`.

### Step 2: Define the model types

In `internal/zerog/da/models.go`:

```go
package da

import "time"

// AuditEvent represents a single auditable action by the inference agent.
type AuditEvent struct {
    // EventID is a unique identifier for this audit event.
    EventID string

    // EventType classifies the action (e.g., "inference_started",
    // "inference_completed", "result_stored", "inft_minted").
    EventType AuditEventType

    // AgentID identifies the agent that produced this event.
    AgentID string

    // JobID links the event to a specific inference job.
    JobID string

    // Timestamp is when the event occurred.
    Timestamp time.Time

    // Details contains event-specific key-value data.
    Details map[string]string

    // InputHash is the hash of the input data (for integrity without revealing content).
    InputHash string

    // OutputHash is the hash of the output data.
    OutputHash string

    // StorageRef is the 0G Storage content ID where full data is stored.
    StorageRef string

    // INFTRef is the iNFT token ID if one was minted.
    INFTRef string
}

// AuditEventType classifies audit events.
type AuditEventType string

const (
    EventInferenceStarted   AuditEventType = "inference_started"
    EventInferenceCompleted AuditEventType = "inference_completed"
    EventResultStored       AuditEventType = "result_stored"
    EventINFTMinted         AuditEventType = "inft_minted"
    EventTaskReceived       AuditEventType = "task_received"
    EventResultReported     AuditEventType = "result_reported"
)

// Submission represents a successful DA submission.
type Submission struct {
    // SubmissionID is the identifier returned by the DA layer.
    SubmissionID string

    // EventID is the audit event that was submitted.
    EventID string

    // Namespace is the DA namespace used for this submission.
    Namespace string

    // BlockHeight is the DA block where this submission was included.
    BlockHeight uint64

    // SubmittedAt is when the submission was confirmed.
    SubmittedAt time.Time
}
```

### Step 3: Implement the audit publisher

In `internal/zerog/da/publisher.go`:

```go
package da

// PublisherConfig holds configuration for the 0G DA audit publisher.
type PublisherConfig struct {
    // Endpoint is the 0G DA node URL.
    Endpoint string

    // Namespace is the DA namespace for this agent's audit events.
    // Use a unique namespace per agent to organize data.
    Namespace string

    // APIKey is the authentication credential for the DA node.
    APIKey string

    // MaxRetries is the number of retry attempts for failed submissions.
    MaxRetries int
}
```

Key implementation details:

**Publish(ctx, event)**:
1. Check `ctx.Err()` before starting
2. Serialize the AuditEvent to JSON bytes
3. Create a DA submission request with the serialized bytes and namespace
4. Submit to the 0G DA endpoint
5. Parse the response to extract the submission ID and block height
6. Return the submission ID
7. Implement retry logic for transient failures (up to `cfg.MaxRetries`)
8. Wrap errors: `fmt.Errorf("da: failed to publish event %s: %w", event.EventID, err)`

**Verify(ctx, submissionID)**:
1. Check `ctx.Err()` before starting
2. Query the DA node for the submission status
3. Return `true` if the data is confirmed available, `false` if pending
4. Wrap errors: `fmt.Errorf("da: failed to verify submission %s: %w", submissionID, err)`

### Step 4: Implement event serialization

Create a helper for consistent event serialization:

```go
// serializeEvent converts an AuditEvent to a deterministic JSON byte representation.
func serializeEvent(event AuditEvent) ([]byte, error) {
    // Use json.Marshal with sorted keys for deterministic output
    // This ensures the same event always produces the same bytes
    // which is important for hash verification
}
```

### Step 5: Implement retry logic

```go
// publishWithRetry attempts to submit data to DA with retries.
func (p *publisher) publishWithRetry(ctx context.Context, data []byte) (*Submission, error) {
    var lastErr error
    for attempt := 0; attempt <= p.cfg.MaxRetries; attempt++ {
        if err := ctx.Err(); err != nil {
            return nil, fmt.Errorf("da: context cancelled on attempt %d: %w", attempt+1, err)
        }

        sub, err := p.submitToDA(ctx, data)
        if err == nil {
            return sub, nil
        }
        lastErr = err

        // Exponential backoff between retries
        if attempt < p.cfg.MaxRetries {
            backoff := time.Duration(1<<uint(attempt)) * time.Second
            select {
            case <-ctx.Done():
                return nil, fmt.Errorf("da: context cancelled during backoff: %w", ctx.Err())
            case <-time.After(backoff):
            }
        }
    }
    return nil, fmt.Errorf("da: all %d attempts failed, last error: %w", p.cfg.MaxRetries+1, lastErr)
}
```

### Step 6: Define sentinel errors

```go
var (
    ErrSubmissionFailed  = errors.New("da: submission to DA layer failed")
    ErrNotAvailable      = errors.New("da: data not yet available")
    ErrDANodeUnreachable = errors.New("da: DA node unreachable")
    ErrSerializeFailed   = errors.New("da: event serialization failed")
)
```

### Step 7: Write unit tests

Create `internal/zerog/da/publisher_test.go`:

1. **TestPublish_Success**: Mock DA endpoint, verify submission ID returned
2. **TestPublish_Retry**: Mock transient failure then success, verify retry works
3. **TestPublish_AllRetriesFail**: Mock persistent failure, verify error after max retries
4. **TestPublish_ContextCancelled**: Cancel during retry backoff, verify clean exit
5. **TestVerify_Available**: Mock available data, verify returns true
6. **TestVerify_NotAvailable**: Mock pending data, verify returns false
7. **TestVerify_NodeDown**: Mock connection failure, verify ErrDANodeUnreachable
8. **TestSerializeEvent_Deterministic**: Serialize same event twice, verify identical bytes
9. **TestSerializeEvent_AllFields**: Verify all AuditEvent fields are included

### Step 8: Verify compilation and tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go build ./internal/zerog/da/...
go test ./internal/zerog/da/... -v
go vet ./internal/zerog/da/...
```

## Done When

- [ ] `AuditPublisher` interface fully implemented in `internal/zerog/da/publisher.go`
- [ ] All model types and event types defined in `internal/zerog/da/models.go`
- [ ] Deterministic event serialization produces consistent JSON
- [ ] Retry logic with exponential backoff respects context cancellation
- [ ] Sentinel errors defined for all failure modes
- [ ] Table-driven unit tests cover publish, verify, retry, serialization, and error cases
- [ ] `go build`, `go test`, and `go vet` all pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
- [ ] 0G DA research findings documented in code comments
