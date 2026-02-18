---
fest_type: task
fest_id: 02_implement_grpc_client.md
fest_name: implement_grpc_client
fest_parent: 05_daemon_client
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement gRPC Client

**Task Number:** 02 | **Sequence:** 05_daemon_client | **Autonomy:** medium

## Objective

Implement the `DaemonClient` interface using gRPC as the transport. This concrete implementation wraps the daemon proto definitions and handles connection management, context-aware calls, and graceful shutdown. The file lives at `pkg/daemon/grpc.go`.

## Requirements

- [ ] Create `pkg/daemon/grpc.go` implementing `DaemonClient`
- [ ] Establish gRPC connection in the constructor with dial timeout
- [ ] Implement Register, Execute, and Heartbeat using gRPC calls
- [ ] Implement Close for graceful connection shutdown
- [ ] Map between Go types (RegisterRequest, etc.) and proto types
- [ ] All methods propagate `context.Context` with call timeout
- [ ] All errors wrapped with operation name and relevant IDs
- [ ] Create `pkg/daemon/grpc_test.go` with table-driven tests

## Implementation

### Step 1: Check proto dependencies

Before implementing, verify the daemon proto definitions are available. Check for:
- A `proto/` directory in the project with daemon service definitions
- Or a Go package generated from the protos

If proto definitions are not yet available, create a minimal placeholder proto for the daemon service. The proto should define:

```protobuf
syntax = "proto3";
package daemon;
option go_package = "your-module/pkg/daemon/pb";

service DaemonService {
  rpc Register(RegisterReq) returns (RegisterResp);
  rpc Execute(ExecuteReq) returns (ExecuteResp);
  rpc Heartbeat(HeartbeatReq) returns (HeartbeatResp);
}

message RegisterReq {
  string agent_name = 1;
  string agent_type = 2;
  repeated string capabilities = 3;
  string hedera_account_id = 4;
}

message RegisterResp {
  string agent_id = 1;
  string session_id = 2;
  int64 registered_at_unix = 3;
}

message ExecuteReq {
  string task_id = 1;
  string task_type = 2;
  bytes payload = 3;
  int64 timeout_ms = 4;
}

message ExecuteResp {
  string task_id = 1;
  string status = 2;
  bytes result = 3;
  int64 duration_ms = 4;
}

message HeartbeatReq {
  string agent_id = 1;
  string session_id = 2;
  int64 timestamp_unix = 3;
}

message HeartbeatResp {}
```

Generate Go code from the proto:

```bash
protoc --go_out=. --go-grpc_out=. proto/daemon.proto
```

### Step 2: Create grpc.go

Create `pkg/daemon/grpc.go`:

```go
package daemon

import (
    "context"
    "fmt"
    "time"

    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials"
    "google.golang.org/grpc/credentials/insecure"

    pb "your-module/pkg/daemon/pb"
)

// GRPCClient implements DaemonClient using gRPC transport.
type GRPCClient struct {
    conn    *grpc.ClientConn
    client  pb.DaemonServiceClient
    config  Config
}

// NewGRPCClient creates a new gRPC daemon client and establishes the connection.
func NewGRPCClient(ctx context.Context, config Config) (*GRPCClient, error) {
    if err := config.Validate(); err != nil {
        return nil, fmt.Errorf("new grpc client: %w", err)
    }

    dialCtx, cancel := context.WithTimeout(ctx, config.DialTimeout)
    defer cancel()

    opts := []grpc.DialOption{}
    if config.TLSEnabled {
        creds, err := credentials.NewClientTLSFromFile(config.TLSCertPath, "")
        if err != nil {
            return nil, fmt.Errorf("new grpc client: load TLS credentials: %w", err)
        }
        opts = append(opts, grpc.WithTransportCredentials(creds))
    } else {
        opts = append(opts, grpc.WithTransportCredentials(insecure.NewCredentials()))
    }

    conn, err := grpc.DialContext(dialCtx, config.Address, opts...)
    if err != nil {
        return nil, fmt.Errorf("new grpc client: dial %s: %w", config.Address, err)
    }

    return &GRPCClient{
        conn:   conn,
        client: pb.NewDaemonServiceClient(conn),
        config: config,
    }, nil
}

// Compile-time interface assertion.
var _ DaemonClient = (*GRPCClient)(nil)
```

### Step 3: Implement Register

```go
func (c *GRPCClient) Register(ctx context.Context, req RegisterRequest) (*RegisterResponse, error) {
    callCtx, cancel := context.WithTimeout(ctx, c.config.CallTimeout)
    defer cancel()

    resp, err := c.client.Register(callCtx, &pb.RegisterReq{
        AgentName:       req.AgentName,
        AgentType:       req.AgentType,
        Capabilities:    req.Capabilities,
        HederaAccountId: req.HederaAccountID,
    })
    if err != nil {
        return nil, fmt.Errorf("register agent %q: %w", req.AgentName, err)
    }

    return &RegisterResponse{
        AgentID:      resp.AgentId,
        SessionID:    resp.SessionId,
        RegisteredAt: time.Unix(resp.RegisteredAtUnix, 0),
    }, nil
}
```

### Step 4: Implement Execute

```go
func (c *GRPCClient) Execute(ctx context.Context, req ExecuteRequest) (*ExecuteResponse, error) {
    timeout := req.Timeout
    if timeout == 0 {
        timeout = c.config.CallTimeout
    }

    callCtx, cancel := context.WithTimeout(ctx, timeout)
    defer cancel()

    resp, err := c.client.Execute(callCtx, &pb.ExecuteReq{
        TaskId:    req.TaskID,
        TaskType:  req.TaskType,
        Payload:   req.Payload,
        TimeoutMs: req.Timeout.Milliseconds(),
    })
    if err != nil {
        return nil, fmt.Errorf("execute task %s type %s: %w", req.TaskID, req.TaskType, err)
    }

    return &ExecuteResponse{
        TaskID:   resp.TaskId,
        Status:   resp.Status,
        Result:   resp.Result,
        Duration: time.Duration(resp.DurationMs) * time.Millisecond,
    }, nil
}
```

### Step 5: Implement Heartbeat and Close

```go
func (c *GRPCClient) Heartbeat(ctx context.Context, req HeartbeatRequest) error {
    callCtx, cancel := context.WithTimeout(ctx, c.config.CallTimeout)
    defer cancel()

    _, err := c.client.Heartbeat(callCtx, &pb.HeartbeatReq{
        AgentId:       req.AgentID,
        SessionId:     req.SessionID,
        TimestampUnix: req.Timestamp.Unix(),
    })
    if err != nil {
        return fmt.Errorf("heartbeat for agent %s: %w", req.AgentID, err)
    }

    return nil
}

func (c *GRPCClient) Close() error {
    if c.conn != nil {
        return c.conn.Close()
    }
    return nil
}
```

### Step 6: Create grpc_test.go

Create `pkg/daemon/grpc_test.go`:

```go
package daemon_test

import (
    "testing"
    "time"

    "your-module/pkg/daemon"
)

func TestConfig_Validate(t *testing.T) {
    tests := []struct {
        name    string
        config  daemon.Config
        wantErr bool
    }{
        {
            name:    "valid default config",
            config:  daemon.DefaultConfig(),
            wantErr: false,
        },
        {
            name:    "empty address",
            config:  daemon.Config{Address: "", DialTimeout: 10 * time.Second, CallTimeout: 30 * time.Second},
            wantErr: true,
        },
        {
            name:    "zero dial timeout",
            config:  daemon.Config{Address: "localhost:50051", DialTimeout: 0, CallTimeout: 30 * time.Second},
            wantErr: true,
        },
        {
            name:    "TLS enabled without cert",
            config:  daemon.Config{Address: "localhost:50051", DialTimeout: 10 * time.Second, CallTimeout: 30 * time.Second, TLSEnabled: true},
            wantErr: true,
        },
        {
            name:    "TLS enabled with cert",
            config:  daemon.Config{Address: "localhost:50051", DialTimeout: 10 * time.Second, CallTimeout: 30 * time.Second, TLSEnabled: true, TLSCertPath: "/path/to/cert.pem"},
            wantErr: false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := tt.config.Validate()
            if (err != nil) != tt.wantErr {
                t.Errorf("Validate() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}

func TestDefaultConfig(t *testing.T) {
    cfg := daemon.DefaultConfig()
    if cfg.Address != "localhost:50051" {
        t.Errorf("Address = %q, want localhost:50051", cfg.Address)
    }
    if cfg.DialTimeout != 10*time.Second {
        t.Errorf("DialTimeout = %v, want 10s", cfg.DialTimeout)
    }
    if cfg.CallTimeout != 30*time.Second {
        t.Errorf("CallTimeout = %v, want 30s", cfg.CallTimeout)
    }
    if cfg.TLSEnabled {
        t.Error("TLSEnabled should be false by default")
    }
}

func TestNewGRPCClient_InvalidConfig(t *testing.T) {
    badConfig := daemon.Config{} // empty config
    _, err := daemon.NewGRPCClient(context.Background(), badConfig)
    if err == nil {
        t.Error("expected error for invalid config")
    }
}

func TestNewGRPCClient_ConnectionRefused(t *testing.T) {
    // This test verifies that connecting to a non-existent server
    // either fails immediately or fails on first RPC call.
    // gRPC may use lazy connection, so the dial itself might not fail.
    cfg := daemon.Config{
        Address:     "localhost:19999", // unlikely to be in use
        DialTimeout: 2 * time.Second,
        CallTimeout: 2 * time.Second,
    }

    // This may or may not fail depending on gRPC lazy connect behavior
    client, err := daemon.NewGRPCClient(context.Background(), cfg)
    if err != nil {
        return // dial failed, which is acceptable
    }
    defer client.Close()

    // If dial succeeded (lazy connect), the first RPC call should fail
    _, err = client.Register(context.Background(), daemon.RegisterRequest{
        AgentName: "test",
        AgentType: "test",
    })
    if err == nil {
        t.Error("expected error when connecting to non-existent server")
    }
}
```

Replace `your-module` with the actual module path.

### Step 7: Verify

```bash
go build ./pkg/daemon/...
go vet ./pkg/daemon/...
go test ./pkg/daemon/... -v -count=1
```

## Done When

- [ ] `pkg/daemon/grpc.go` implements `DaemonClient`
- [ ] gRPC connection established in constructor with dial timeout
- [ ] Register maps Go types to proto and back
- [ ] Execute uses task-specific timeout or falls back to default
- [ ] Heartbeat sends liveness signal
- [ ] Close gracefully shuts down the gRPC connection
- [ ] All errors include operation name and relevant IDs
- [ ] Proto definitions exist (generated or placeholder)
- [ ] Tests cover config validation, default config, invalid config, and connection errors
- [ ] `go test ./pkg/daemon/...` passes
- [ ] File under 500 lines, functions under 50 lines
