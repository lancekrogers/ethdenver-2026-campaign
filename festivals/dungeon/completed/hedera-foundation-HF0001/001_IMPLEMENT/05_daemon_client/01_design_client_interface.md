---
fest_type: task
fest_id: 01_design_client_interface.md
fest_name: design_client_interface
fest_parent: 05_daemon_client
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design Client Interface

**Task Number:** 01 | **Sequence:** 05_daemon_client | **Autonomy:** medium

## Objective

Design the daemon client interface at `pkg/daemon/`. This is a public package (under `pkg/`, not `internal/`) because it is imported by all three agents in the project. The interface must be DI-friendly -- consumers depend on the `DaemonClient` interface, not on the gRPC implementation directly.

## Requirements

- [ ] Create the package directory `pkg/daemon/`
- [ ] Define the `DaemonClient` interface with Execute, Register, and Heartbeat methods
- [ ] Define request/response types for each method
- [ ] Define client configuration struct with daemon address and TLS settings
- [ ] Write `pkg/daemon/client.go` with the interface and types
- [ ] Write `pkg/daemon/config.go` with configuration

## Implementation

### Step 1: Create the package directory

Working in the agent-coordinator project:

```
pkg/
  daemon/
    client.go
    config.go
```

Note: This is under `pkg/` (public), not `internal/` (private). The `pkg/` convention signals that this package is intended for import by other packages and agents within the project.

### Step 2: Write client.go

Create `pkg/daemon/client.go`:

```go
package daemon

import (
    "context"
    "io"
    "time"
)

// DaemonClient defines the interface for communicating with the obey daemon.
// All three agents (coordinator, worker-1, worker-2) import and use this interface.
// The interface is intentionally small -- it covers the minimum surface needed
// for agent coordination via the daemon.
type DaemonClient interface {
    // Register registers this agent with the daemon, providing agent metadata.
    // Must be called before Execute or Heartbeat.
    // Returns the assigned agent ID from the daemon.
    Register(ctx context.Context, req RegisterRequest) (*RegisterResponse, error)

    // Execute sends a task execution request to the daemon.
    // The daemon routes the task to the appropriate handler.
    Execute(ctx context.Context, req ExecuteRequest) (*ExecuteResponse, error)

    // Heartbeat sends a liveness signal to the daemon.
    // Should be called periodically to maintain agent registration.
    Heartbeat(ctx context.Context, req HeartbeatRequest) error

    // Close cleanly shuts down the client connection.
    io.Closer
}

// RegisterRequest contains the data needed to register an agent with the daemon.
type RegisterRequest struct {
    // AgentName is the human-readable name for this agent.
    AgentName string

    // AgentType is the type of agent (e.g., "coordinator", "worker").
    AgentType string

    // Capabilities lists what this agent can do (e.g., "hcs", "hts", "schedule").
    Capabilities []string

    // HederaAccountID is the Hedera account this agent uses for transactions.
    HederaAccountID string
}

// RegisterResponse contains the daemon's response to a registration request.
type RegisterResponse struct {
    // AgentID is the unique identifier assigned by the daemon.
    AgentID string

    // SessionID is the session identifier for this registration.
    SessionID string

    // RegisteredAt is when the registration was accepted.
    RegisteredAt time.Time
}

// ExecuteRequest contains a task execution request.
type ExecuteRequest struct {
    // TaskID is the festival task identifier.
    TaskID string

    // TaskType describes what kind of work to perform.
    TaskType string

    // Payload is the task-specific data as JSON bytes.
    Payload []byte

    // Timeout is the maximum time the daemon should allow for execution.
    Timeout time.Duration
}

// ExecuteResponse contains the result of a task execution.
type ExecuteResponse struct {
    // TaskID echoes back the requested task.
    TaskID string

    // Status is the execution result status.
    Status string

    // Result is the task-specific result data as JSON bytes.
    Result []byte

    // Duration is how long the execution took.
    Duration time.Duration
}

// HeartbeatRequest contains the data for a heartbeat signal.
type HeartbeatRequest struct {
    // AgentID is the registered agent identifier.
    AgentID string

    // SessionID is the current session identifier.
    SessionID string

    // Timestamp is when this heartbeat was generated.
    Timestamp time.Time
}
```

Design decisions:

- The interface has exactly 3 domain methods plus `io.Closer` for cleanup
- All methods take `context.Context` as first parameter
- Request/response types use simple Go types (no protobuf types in the interface)
- `io.Closer` is embedded for graceful connection shutdown
- `Payload` and `Result` use `[]byte` for flexibility (JSON-encoded)
- The interface does not expose gRPC details -- it is transport-agnostic

### Step 3: Write config.go

Create `pkg/daemon/config.go`:

```go
package daemon

import (
    "fmt"
    "time"
)

const (
    defaultDaemonAddr    = "localhost:50051"
    defaultDialTimeout   = 10 * time.Second
    defaultCallTimeout   = 30 * time.Second
)

// Config holds configuration for connecting to the obey daemon.
type Config struct {
    // Address is the daemon gRPC endpoint (host:port).
    Address string

    // DialTimeout is the maximum time to wait for initial connection.
    DialTimeout time.Duration

    // CallTimeout is the default timeout for individual RPC calls.
    CallTimeout time.Duration

    // TLSEnabled enables TLS for the gRPC connection.
    TLSEnabled bool

    // TLSCertPath is the path to the TLS certificate (required if TLSEnabled).
    TLSCertPath string
}

// DefaultConfig returns sensible defaults for local development.
func DefaultConfig() Config {
    return Config{
        Address:     defaultDaemonAddr,
        DialTimeout: defaultDialTimeout,
        CallTimeout: defaultCallTimeout,
        TLSEnabled:  false,
    }
}

// Validate checks the config for required fields.
func (c Config) Validate() error {
    if c.Address == "" {
        return fmt.Errorf("daemon config: address is required")
    }
    if c.DialTimeout <= 0 {
        return fmt.Errorf("daemon config: dial timeout must be positive")
    }
    if c.CallTimeout <= 0 {
        return fmt.Errorf("daemon config: call timeout must be positive")
    }
    if c.TLSEnabled && c.TLSCertPath == "" {
        return fmt.Errorf("daemon config: TLS cert path required when TLS is enabled")
    }
    return nil
}
```

### Step 4: Verify compilation

```bash
go build ./pkg/daemon/...
go vet ./pkg/daemon/...
```

## Done When

- [ ] `pkg/daemon/client.go` exists with DaemonClient interface and all request/response types
- [ ] `pkg/daemon/config.go` exists with Config, DefaultConfig, and Validate
- [ ] DaemonClient has exactly 3 domain methods (Register, Execute, Heartbeat) + io.Closer
- [ ] All methods accept `context.Context` as first parameter
- [ ] No gRPC or protobuf types in the interface (transport-agnostic)
- [ ] Config has sensible defaults for local development
- [ ] `go build ./pkg/daemon/...` passes
- [ ] `go vet ./pkg/daemon/...` passes
