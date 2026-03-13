# Provider Execution Modes Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a unified mode abstraction (autonomous/supervised/plan) across all adapters with per-turn override and gRPC discovery.

**Architecture:** Mode interface in session package with built-in implementations. Each adapter implements SetMode()/Mode(). Codex and Claude Code adapters map obey modes to vendor-specific config. Proto gets first-class mode fields.

**Tech Stack:** Go, gRPC/protobuf, codex SDK, claude-code-go SDK

**Spec:** `docs/superpowers/specs/2026-03-13-provider-modes-design.md`

---

## File Structure

| File | Responsibility |
|------|---------------|
| `internal/session/mode.go` | **New** — Mode interface, SandboxAware, built-in modes, errors, ResolveMode() |
| `internal/session/mode_test.go` | **New** — Mode resolution, vendor parsing, provider mismatch tests |
| `internal/session/adapter.go` | Add Mode to AdapterConfig, SupportedModes() to Adapter, SetMode()/Mode() to AdapterInstance |
| `internal/session/manager.go` | Add Mode to CreateSessionRequest, mode param in SendMessage |
| `internal/provider/codex/config.go` | Add ApprovalPolicy, SandboxMode fields |
| `internal/provider/codex/client.go` | Add SetApprovalPolicy(), SetSandboxMode(), wire buildThreadOptions |
| `internal/provider/claudecode/client.go` | Add SetPermissionMode() |
| `internal/session/adapters/codex.go` | Implement SetMode()/Mode(), wire Start() |
| `internal/session/adapters/claude_code.go` | Implement SetMode()/Mode(), wire Start() |
| `internal/session/adapters/openai.go` | Implement SetMode()/Mode() (no-op store) |
| `internal/session/adapters/openrouter.go` | Same |
| `internal/session/adapters/ollama.go` | Same |
| `internal/session/adapters/openclaw.go` | Same |
| `internal/session/adapters/external.go` | Same |
| `internal/session/adapters/mock.go` | Add mode for tests |
| `protos/local/v1/session.proto` | Add mode to CreateSessionRequest, SendMessageRequest; add ListModes messages |
| `protos/local/v1/service.proto` | Add ListModes RPC |
| `internal/grpc/session_handlers.go` | Mode resolution, ListModes handler, mode in SendMessage |

---

## Chunk 1: Core Mode Types

### Task 1: Mode interface and built-in implementations

**Files:**
- Create: `internal/session/mode.go`
- Create: `internal/session/mode_test.go`

- [ ] **Step 1: Write failing tests for mode resolution**

```go
// internal/session/mode_test.go
package session

import (
	"testing"
)

func TestResolveMode(t *testing.T) {
	tests := []struct {
		name    string
		input   string
		want    string
		wantErr error
	}{
		{"empty defaults to autonomous", "", "autonomous", nil},
		{"explicit autonomous", "autonomous", "autonomous", nil},
		{"supervised", "supervised", "supervised", nil},
		{"plan", "plan", "plan", nil},
		{"vendor codex", "vendor:codex/never", "vendor:codex/never", nil},
		{"vendor codex with sandbox", "vendor:codex/never:read-only", "vendor:codex/never:read-only", nil},
		{"vendor claude-code", "vendor:claude-code/bypassPermissions", "vendor:claude-code/bypassPermissions", nil},
		{"unknown mode", "garbage", "", ErrUnknownMode},
		{"invalid vendor format", "vendor:bad", "", ErrInvalidVendorMode},
		{"vendor empty provider", "vendor:/value", "", ErrInvalidVendorMode},
		{"vendor empty value", "vendor:codex/", "", ErrInvalidVendorMode},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mode, err := ResolveMode(tt.input)
			if tt.wantErr != nil {
				if err == nil {
					t.Fatalf("expected error %v, got nil", tt.wantErr)
				}
				if !errors.Is(err, tt.wantErr) {
					t.Fatalf("expected error %v, got %v", tt.wantErr, err)
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if mode.Name() != tt.want {
				t.Errorf("Name() = %q, want %q", mode.Name(), tt.want)
			}
		})
	}
}

func TestAutonomousMode_VendorValues(t *testing.T) {
	m := AutonomousMode{}
	if v := m.VendorValue("codex"); v != "never" {
		t.Errorf("codex VendorValue = %q, want %q", v, "never")
	}
	if v := m.VendorValue("claude-code"); v != "bypassPermissions" {
		t.Errorf("claude-code VendorValue = %q, want %q", v, "bypassPermissions")
	}
	if v := m.VendorValue("openai"); v != "" {
		t.Errorf("openai VendorValue = %q, want empty", v)
	}
}

func TestAutonomousMode_SandboxAware(t *testing.T) {
	m := AutonomousMode{}
	if v := m.SandboxValue("codex"); v != "danger-full-access" {
		t.Errorf("codex SandboxValue = %q, want %q", v, "danger-full-access")
	}
}

func TestSupervisedMode_VendorValues(t *testing.T) {
	m := SupervisedMode{}
	if v := m.VendorValue("codex"); v != "on-request" {
		t.Errorf("codex VendorValue = %q, want %q", v, "on-request")
	}
	if v := m.VendorValue("claude-code"); v != "default" {
		t.Errorf("claude-code VendorValue = %q, want %q", v, "default")
	}
	if v := m.SandboxValue("codex"); v != "workspace-write" {
		t.Errorf("codex SandboxValue = %q, want %q", v, "workspace-write")
	}
}

func TestPlanMode_VendorValues(t *testing.T) {
	m := PlanMode{}
	if v := m.VendorValue("codex"); v != "never" {
		t.Errorf("codex VendorValue = %q, want %q", v, "never")
	}
	if v := m.VendorValue("claude-code"); v != "plan" {
		t.Errorf("claude-code VendorValue = %q, want %q", v, "plan")
	}
	if v := m.SandboxValue("codex"); v != "read-only" {
		t.Errorf("codex SandboxValue = %q, want %q", v, "read-only")
	}
}

func TestVendorMode_ProviderScoped(t *testing.T) {
	m, _ := ResolveMode("vendor:codex/never")
	if v := m.VendorValue("codex"); v != "never" {
		t.Errorf("codex VendorValue = %q, want %q", v, "never")
	}
	if v := m.VendorValue("claude-code"); v != "" {
		t.Errorf("claude-code VendorValue = %q, want empty", v)
	}
}

func TestVendorMode_WithSandbox(t *testing.T) {
	m, _ := ResolveMode("vendor:codex/never:read-only")
	sa, ok := m.(SandboxAware)
	if !ok {
		t.Fatal("expected SandboxAware")
	}
	if v := sa.SandboxValue("codex"); v != "read-only" {
		t.Errorf("SandboxValue = %q, want %q", v, "read-only")
	}
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go test ./internal/session/ -run TestResolveMode -v`
Expected: FAIL — mode.go doesn't exist

- [ ] **Step 3: Implement mode.go**

```go
// internal/session/mode.go
package session

import (
	"errors"
	"fmt"
	"strings"
)

var (
	ErrUnknownMode       = errors.New("unknown mode")
	ErrInvalidVendorMode = errors.New("invalid vendor mode format")
	ErrModeMismatch      = errors.New("vendor mode targets a different provider")
)

// Mode represents an execution mode that controls how an adapter
// handles permissions, tool approval, and sandbox access.
type Mode interface {
	Name() string
	Description() string
	VendorValue(provider string) string
}

// SandboxAware is optionally implemented by modes that control sandbox behavior.
type SandboxAware interface {
	SandboxValue(provider string) string
}

// AutonomousMode grants full access with no approval required.
type AutonomousMode struct{}

func (AutonomousMode) Name() string        { return "autonomous" }
func (AutonomousMode) Description() string { return "Full access, no approval required" }
func (AutonomousMode) VendorValue(provider string) string {
	switch provider {
	case "codex":
		return "never"
	case "claude-code":
		return "bypassPermissions"
	default:
		return ""
	}
}
func (AutonomousMode) SandboxValue(provider string) string {
	if provider == "codex" {
		return "danger-full-access"
	}
	return ""
}

// SupervisedMode requires approval before tool use or destructive actions.
type SupervisedMode struct{}

func (SupervisedMode) Name() string        { return "supervised" }
func (SupervisedMode) Description() string { return "Ask before tool use or destructive actions" }
func (SupervisedMode) VendorValue(provider string) string {
	switch provider {
	case "codex":
		return "on-request"
	case "claude-code":
		return "default"
	default:
		return ""
	}
}
func (SupervisedMode) SandboxValue(provider string) string {
	if provider == "codex" {
		return "workspace-write"
	}
	return ""
}

// PlanMode is read-only — plan but don't execute.
type PlanMode struct{}

func (PlanMode) Name() string        { return "plan" }
func (PlanMode) Description() string { return "Read-only, plan but don't execute" }
func (PlanMode) VendorValue(provider string) string {
	switch provider {
	case "codex":
		return "never"
	case "claude-code":
		return "plan"
	default:
		return ""
	}
}
func (PlanMode) SandboxValue(provider string) string {
	if provider == "codex" {
		return "read-only"
	}
	return ""
}

// VendorMode passes a raw vendor-specific value through.
type VendorMode struct {
	provider string
	value    string
	sandbox  string
}

func (m VendorMode) Name() string {
	if m.sandbox != "" {
		return fmt.Sprintf("vendor:%s/%s:%s", m.provider, m.value, m.sandbox)
	}
	return fmt.Sprintf("vendor:%s/%s", m.provider, m.value)
}
func (m VendorMode) Description() string { return fmt.Sprintf("Vendor pass-through: %s", m.Name()) }
func (m VendorMode) VendorValue(provider string) string {
	if provider == m.provider {
		return m.value
	}
	return ""
}
func (m VendorMode) SandboxValue(provider string) string {
	if provider == m.provider {
		return m.sandbox
	}
	return ""
}

// Provider returns the target provider for this vendor mode.
func (m VendorMode) Provider() string { return m.provider }

// ResolveMode converts a mode name string to a Mode instance.
// Empty string resolves to AutonomousMode (the default).
func ResolveMode(name string) (Mode, error) {
	switch name {
	case "", "autonomous":
		return AutonomousMode{}, nil
	case "supervised":
		return SupervisedMode{}, nil
	case "plan":
		return PlanMode{}, nil
	default:
		if strings.HasPrefix(name, "vendor:") {
			return parseVendorMode(name[7:])
		}
		return nil, fmt.Errorf("%w: %s", ErrUnknownMode, name)
	}
}

func parseVendorMode(raw string) (Mode, error) {
	parts := strings.SplitN(raw, "/", 2)
	if len(parts) != 2 || parts[0] == "" || parts[1] == "" {
		return nil, fmt.Errorf("%w: expected vendor:provider/value, got vendor:%s", ErrInvalidVendorMode, raw)
	}
	vm := VendorMode{provider: parts[0]}
	if idx := strings.Index(parts[1], ":"); idx >= 0 {
		vm.value = parts[1][:idx]
		vm.sandbox = parts[1][idx+1:]
	} else {
		vm.value = parts[1]
	}
	return vm, nil
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go test ./internal/session/ -run "TestResolveMode|TestAutonomous|TestSupervised|TestPlan|TestVendor" -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey
git add internal/session/mode.go internal/session/mode_test.go
git commit -m "feat: add Mode interface with built-in autonomous/supervised/plan modes"
```

---

## Chunk 2: Adapter Interface Changes

### Task 2: Add Mode to AdapterConfig and interface methods

**Files:**
- Modify: `internal/session/adapter.go:14-36` (Adapter and AdapterInstance interfaces)
- Modify: `internal/session/adapter.go:38-51` (AdapterConfig struct)

- [ ] **Step 1: Add SupportedModes() to Adapter interface**

In `internal/session/adapter.go`, add to the `Adapter` interface:

```go
type Adapter interface {
	Provider() string
	SupportedModels() []string
	SupportedModes() []Mode
	Start(ctx context.Context, cfg AdapterConfig) (AdapterInstance, error)
}
```

- [ ] **Step 2: Add SetMode()/Mode() to AdapterInstance interface**

```go
type AdapterInstance interface {
	SendMessage(ctx context.Context, msg string) (ActivityStream, error)
	Stop(ctx context.Context) error
	Status() Status
	PID() int
	SetMode(mode Mode) error
	Mode() Mode
}
```

- [ ] **Step 3: Add Mode to AdapterConfig**

```go
type AdapterConfig struct {
	// ... existing fields ...
	Mode Mode // Initial mode, defaults to AutonomousMode if nil
}
```

- [ ] **Step 4: Build to identify all compilation failures**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go build ./... 2>&1 | head -50`
Expected: Compilation errors in all adapter files and test mocks that don't implement new methods

- [ ] **Step 5: Commit interface changes**

```bash
git add internal/session/adapter.go
git commit -m "feat: add SupportedModes, SetMode, Mode to adapter interfaces"
```

### Task 3: Add mode stubs to all adapters (make it compile)

**Files:**
- Modify: `internal/session/adapters/codex.go`
- Modify: `internal/session/adapters/claude_code.go`
- Modify: `internal/session/adapters/openai.go`
- Modify: `internal/session/adapters/openrouter.go`
- Modify: `internal/session/adapters/ollama.go`
- Modify: `internal/session/adapters/openclaw.go`
- Modify: `internal/session/adapters/external.go`
- Modify: `internal/session/adapters/mock.go`
- Modify: test files with mock adapters in `internal/session/manager_test.go`

For each adapter factory, add:

```go
func (a *XxxAdapter) SupportedModes() []session.Mode { return nil }
```

For each adapter instance, add a `mode` field and:

```go
func (c *XxxInstance) SetMode(mode session.Mode) error {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.mode = mode
	return nil
}

func (c *XxxInstance) Mode() session.Mode {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.mode
}
```

- [ ] **Step 1: Add stubs to all 7 adapters + mock + test mocks**

Add `mode session.Mode` field to every instance struct. Add `SupportedModes()` to every adapter factory. Add `SetMode()`/`Mode()` to every instance. For Codex and Claude Code adapters, `SupportedModes()` returns `[]session.Mode{session.AutonomousMode{}, session.SupervisedMode{}, session.PlanMode{}}`.

- [ ] **Step 2: Update all test mocks in manager_test.go**

Every test adapter/instance mock needs `SupportedModes()`, `SetMode()`, and `Mode()`. These are no-op stubs.

- [ ] **Step 3: Build and run full test suite**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go build ./... && go test ./... -count=1 -timeout 120s`
Expected: All pass

- [ ] **Step 4: Commit**

```bash
git add internal/session/adapters/ internal/session/manager_test.go
git commit -m "feat: add mode stubs to all adapters and test mocks"
```

---

## Chunk 3: Provider-Level Mode Support

### Task 4: Codex provider mode setters

**Files:**
- Modify: `internal/provider/codex/config.go`
- Modify: `internal/provider/codex/client.go`

- [ ] **Step 1: Write failing test for SetApprovalPolicy**

Add to `internal/provider/codex/client_test.go`:

```go
func TestClient_SetApprovalPolicy_InvalidatesThread(t *testing.T) {
	mockSDK := &mockSDKClient{}
	client := NewWithSDK(mockSDK, &Config{Model: "codex-mini-latest"})

	// Create a thread via getOrCreateThread
	req := provider.ChatRequest{Model: "codex-mini-latest"}
	_ = client.getOrCreateThread(req)
	if client.thread == nil {
		t.Fatal("expected thread to be created")
	}

	// Set approval policy should nil the thread
	client.SetApprovalPolicy(codexsdk.ApprovalNever)
	client.mu.Lock()
	threadNil := client.thread == nil
	client.mu.Unlock()

	if !threadNil {
		t.Fatal("expected thread to be nil after SetApprovalPolicy")
	}
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go test ./internal/provider/codex/ -run TestClient_SetApprovalPolicy -v`
Expected: FAIL — SetApprovalPolicy undefined

- [ ] **Step 3: Add ApprovalPolicy and SandboxMode to Config**

In `internal/provider/codex/config.go`, add fields:

```go
ApprovalPolicy codexsdk.ApprovalMode `json:"approval_policy,omitempty"`
SandboxMode    codexsdk.SandboxMode  `json:"sandbox_mode,omitempty"`
```

- [ ] **Step 4: Add SetApprovalPolicy and SetSandboxMode to Client**

In `internal/provider/codex/client.go`:

```go
func (c *Client) SetApprovalPolicy(policy codexsdk.ApprovalMode) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.config.ApprovalPolicy = policy
	c.thread = nil
}

func (c *Client) SetSandboxMode(mode codexsdk.SandboxMode) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.config.SandboxMode = mode
	c.thread = nil
}
```

- [ ] **Step 5: Wire into buildThreadOptions**

In `buildThreadOptions`, add after existing fields:

```go
if c.config.ApprovalPolicy != "" {
	opts.ApprovalPolicy = c.config.ApprovalPolicy
}
if c.config.SandboxMode != "" {
	opts.SandboxMode = c.config.SandboxMode
}
```

- [ ] **Step 6: Run tests**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go test ./internal/provider/codex/ -v`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add internal/provider/codex/config.go internal/provider/codex/client.go internal/provider/codex/client_test.go
git commit -m "feat: add mode setters to codex provider with thread invalidation"
```

### Task 5: Claude Code provider mode setter

**Files:**
- Modify: `internal/provider/claudecode/client.go`

- [ ] **Step 1: Add SetPermissionMode to Client**

```go
func (c *Client) SetPermissionMode(mode string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.sdk.DefaultOptions.PermissionMode = claude.PermissionMode(mode)
}
```

- [ ] **Step 2: Run tests**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go test ./internal/provider/claudecode/ -v`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add internal/provider/claudecode/client.go
git commit -m "feat: add SetPermissionMode to claude-code provider"
```

---

## Chunk 4: Adapter Mode Wiring

### Task 6: Wire SetMode on Codex adapter

**Files:**
- Modify: `internal/session/adapters/codex.go`
- Modify: `internal/session/adapters/codex_test.go`

- [ ] **Step 1: Write failing test for SetMode vendor mapping**

```go
func TestCodexInstance_SetMode_AppliesVendorValues(t *testing.T) {
	// Use a mock factory that captures the provider
	var capturedProvider *codex.Client
	a := &CodexAdapter{
		factory: func(cfg provider.ProviderConfig) (provider.Provider, error) {
			p, err := codex.New(cfg)
			if err != nil {
				return nil, err
			}
			capturedProvider = p
			return p, nil
		},
	}

	inst, err := a.Start(context.Background(), session.AdapterConfig{
		SessionID: "test-1",
		Mode:      session.AutonomousMode{},
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if inst.Mode().Name() != "autonomous" {
		t.Errorf("initial mode = %q, want autonomous", inst.Mode().Name())
	}

	if err := inst.SetMode(session.SupervisedMode{}); err != nil {
		t.Fatalf("SetMode error: %v", err)
	}
	if inst.Mode().Name() != "supervised" {
		t.Errorf("mode after SetMode = %q, want supervised", inst.Mode().Name())
	}
}

func TestCodexInstance_SetMode_VendorModeMismatch(t *testing.T) {
	a := NewCodexAdapter()
	inst, _ := a.Start(context.Background(), session.AdapterConfig{
		SessionID: "test-2",
		Mode:      session.AutonomousMode{},
	})

	wrongProvider, _ := session.ResolveMode("vendor:claude-code/bypassPermissions")
	err := inst.SetMode(wrongProvider)
	if !errors.Is(err, session.ErrModeMismatch) {
		t.Fatalf("expected ErrModeMismatch, got %v", err)
	}
}
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL

- [ ] **Step 3: Implement full SetMode on CodexInstance**

Replace the stub `SetMode` with the real implementation that type-asserts the provider and applies vendor config. Check `VendorMode.Provider()` for mismatch. Wire `Start()` to call `SetMode(cfg.Mode)` when mode is non-nil.

- [ ] **Step 4: Run tests**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go test ./internal/session/adapters/ -run TestCodex -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add internal/session/adapters/codex.go internal/session/adapters/codex_test.go
git commit -m "feat: wire mode support in codex adapter with vendor validation"
```

### Task 7: Wire SetMode on Claude Code adapter

**Files:**
- Modify: `internal/session/adapters/claude_code.go`
- Modify: `internal/session/adapters/claude_code_test.go`

Same pattern as Task 6 but for Claude Code. Type-assert provider as `*claudecode.Client`, call `SetPermissionMode()`. Check VendorMode provider match.

- [ ] **Step 1: Write failing test**
- [ ] **Step 2: Run to verify fail**
- [ ] **Step 3: Implement SetMode with vendor mapping**
- [ ] **Step 4: Run tests — expect PASS**
- [ ] **Step 5: Commit**

```bash
git add internal/session/adapters/claude_code.go internal/session/adapters/claude_code_test.go
git commit -m "feat: wire mode support in claude-code adapter"
```

---

## Chunk 5: Manager and gRPC Integration

### Task 8: Add Mode to Manager.SendMessage

**Files:**
- Modify: `internal/session/manager.go:306` (SendMessage signature)
- Modify: `internal/grpc/session_handlers.go` (SessionManager interface, SendMessage handler)

- [ ] **Step 1: Add Mode to CreateSessionRequest**

In `internal/session/manager.go`, add `Mode Mode` field to `CreateSessionRequest`.

- [ ] **Step 2: Update Manager.SendMessage signature**

Change from:
```go
func (m *Manager) SendMessage(ctx context.Context, sessionID string, msg string) (ActivityStream, error)
```
To:
```go
func (m *Manager) SendMessage(ctx context.Context, sessionID string, msg string, mode Mode) (ActivityStream, error)
```

Add before the `instance.SendMessage` call:
```go
if mode != nil {
	if err := instance.SetMode(mode); err != nil {
		return nil, err
	}
}
```

- [ ] **Step 3: Update SessionManager interface in grpc package**

In `internal/grpc/session_handlers.go`, update the interface:
```go
SendMessage(ctx context.Context, sessionID string, msg string, mode session.Mode) (session.ActivityStream, error)
```

- [ ] **Step 4: Update all callers**

Update the gRPC `SendMessage` handler to pass `nil` for now (mode proto field comes in Task 9). Update any other callers of `Manager.SendMessage` to pass `nil`.

- [ ] **Step 5: Build and test**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go build ./... && go test ./... -count=1 -timeout 120s`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add internal/session/manager.go internal/grpc/session_handlers.go
git commit -m "feat: add Mode to CreateSessionRequest and SendMessage"
```

### Task 9: Proto changes and gRPC mode wiring

**Files:**
- Modify: `protos/local/v1/session.proto`
- Modify: `protos/local/v1/service.proto`
- Modify: `internal/grpc/session_handlers.go`

- [ ] **Step 1: Add mode to proto messages**

In `session.proto`:
```protobuf
message CreateSessionRequest {
  // ... existing fields 1-10 ...
  string mode = 11;
}

message SendMessageRequest {
  string session_id = 1;
  string message = 2;
  string mode = 3;
}

message ModeInfo {
  string name = 1;
  string description = 2;
  bool is_default = 3;
}

message ListModesRequest {
  string provider = 1;
}

message ListModesResponse {
  repeated ModeInfo modes = 1;
}
```

In `service.proto`, add to `LocalDaemonService`:
```protobuf
rpc ListModes(ListModesRequest) returns (ListModesResponse);
```

- [ ] **Step 2: Regenerate proto**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && just proto` (or whatever the proto generation command is)

- [ ] **Step 3: Wire mode in gRPC handlers**

In the `CreateSession` handler, resolve mode from `req.Mode`:
```go
var mode session.Mode
if req.Mode != "" {
	var err error
	mode, err = session.ResolveMode(req.Mode)
	if err != nil {
		return nil, mapError(err)
	}
}
```
Pass into `CreateSessionRequest{Mode: mode}`.

In the `SendMessage` handler:
```go
var mode session.Mode
if req.Mode != "" {
	var err error
	mode, err = session.ResolveMode(req.Mode)
	if err != nil {
		return mapError(err)
	}
}
// Pass mode to manager
stream, err := s.sessionMgr.SendMessage(ctx, req.SessionId, req.Message, mode)
```

- [ ] **Step 4: Implement ListModes handler**

```go
func (s *Server) ListModes(ctx context.Context, req *localv1.ListModesRequest) (*localv1.ListModesResponse, error) {
	// If provider specified, get modes for that adapter
	// Otherwise, return all unique modes across adapters
	// Use adapter registry to look up SupportedModes()
}
```

- [ ] **Step 5: Build and test**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go build ./... && go test ./... -count=1 -timeout 120s`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add protos/ internal/proto/ internal/grpc/
git commit -m "feat: add mode to gRPC proto and wire handlers"
```

---

## Chunk 6: Integration Tests and Final Verification

### Task 10: Mode integration tests

**Files:**
- Modify: `internal/session/manager_test.go`

- [ ] **Step 1: Write integration test for mode through manager**

```go
func TestManager_SendMessage_ModeOverride(t *testing.T) {
	// Create manager with a mode-tracking mock adapter
	// Send message with nil mode (no override)
	// Send message with SupervisedMode
	// Verify mode was applied and persisted
}
```

- [ ] **Step 2: Write concurrency test**

```go
func TestManager_SendMessage_ModeConcurrency(t *testing.T) {
	// Verify no race conditions with -race flag
}
```

- [ ] **Step 3: Run full test suite with race detector**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go test ./... -race -count=1 -timeout 120s`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add internal/session/manager_test.go
git commit -m "test: add mode integration and concurrency tests"
```

### Task 11: Final build verification and PR

- [ ] **Step 1: Run full test suite**

Run: `cd /Users/lancerogers/Dev/AI/obey-campaign/projects/obey-platform-monorepo/obey && go build ./... && go test ./... -race -count=1 -timeout 180s`
Expected: All packages pass

- [ ] **Step 2: Open PR**

```bash
gh pr create --title "feat: provider execution modes (autonomous/supervised/plan)" --body "..."
```
