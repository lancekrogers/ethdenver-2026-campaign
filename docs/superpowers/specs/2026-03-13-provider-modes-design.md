# Provider Execution Modes Design

**Date:** 2026-03-13
**Status:** Approved
**Scope:** obey daemon — provider mode abstraction, per-turn override, mode discovery

## Problem

Codex and Claude Code both support execution modes (approval policies, permission modes, sandbox levels) that control how autonomous an agent session operates. Today these modes are:

- Buried in `config_json` — an untyped JSON string parsed into a generic `Options` map
- Not discoverable — callers must know vendor-specific mode names
- Not overridable per-turn — locked at session creation
- Not abstracted — no obey-level concept, each provider handles modes independently

## Requirements

1. Three obey-level intent modes: `autonomous` (default), `supervised`, `plan`
2. `vendor:<provider>/<value>` pass-through for direct vendor control
3. Modes discoverable via adapter interface (`SupportedModes()`)
4. Per-turn override via `SetMode()` on adapter instances
5. First-class `mode` field in gRPC proto (`CreateSessionRequest`, `SendMessageRequest`)
6. Default to `autonomous` (bypass permissions / full access) when no mode specified
7. Extensible for future modes (e.g., `fest`) without interface changes

## Design

### Core Interface

Defined in `internal/session/mode.go`:

```go
// Mode represents an execution mode that controls how an adapter
// handles permissions, tool approval, and sandbox access.
type Mode interface {
    // Name returns the obey-level mode identifier.
    Name() string

    // Description returns a human-readable explanation.
    Description() string

    // VendorValue returns the provider-specific value for the given provider.
    // Returns empty string if not applicable.
    VendorValue(provider string) string
}

// SandboxAware is optionally implemented by modes that control sandbox behavior.
// Adapters type-assert for this when they need sandbox configuration.
type SandboxAware interface {
    SandboxValue(provider string) string
}
```

### Error Handling

Mode resolution uses sentinel errors from the project's error framework:

```go
var (
    ErrUnknownMode       = errors.New("unknown mode")
    ErrInvalidVendorMode = errors.New("invalid vendor mode format")
    ErrModeMismatch      = errors.New("vendor mode targets a different provider")
)
```

### Built-in Mode Implementations

#### AutonomousMode (default)

Full access, no approval required. Maps to:

| Provider | VendorValue | SandboxValue |
|----------|-------------|--------------|
| codex | `never` (approval_policy) | `danger-full-access` |
| claude-code | `bypassPermissions` | — |

#### SupervisedMode

Ask before tool use or destructive actions. Maps to:

| Provider | VendorValue | SandboxValue |
|----------|-------------|--------------|
| codex | `on-request` | `workspace-write` |
| claude-code | `default` | — |

#### PlanMode

Read-only, plan but don't execute. Maps to:

| Provider | VendorValue | SandboxValue |
|----------|-------------|--------------|
| codex | `never` (approval_policy) | `read-only` |
| claude-code | `plan` | — |

**Note:** Codex `PlanMode` uses `approval_policy: "never"` (not `"on-request"`) because the `read-only` sandbox already prevents all writes. Prompting for approval on actions the sandbox would block is confusing. The sandbox is the enforcement mechanism; approval is set to `never` to avoid unnecessary prompts.

**SandboxAware:** All three built-in modes implement `SandboxAware` for Codex:
- `AutonomousMode.SandboxValue("codex")` → `"danger-full-access"`
- `SupervisedMode.SandboxValue("codex")` → `"workspace-write"`
- `PlanMode.SandboxValue("codex")` → `"read-only"`

For all other providers, `SandboxValue()` returns empty string (sandbox is a Codex-specific concept).

#### VendorMode

Raw pass-through. Created from strings like `vendor:codex/never` or `vendor:codex/never:read-only`.

```go
type VendorMode struct {
    provider string
    value    string   // primary vendor value (approval_policy, permission_mode)
    sandbox  string   // optional sandbox value (Codex only)
    desc     string
}
```

`VendorMode` implements `SandboxAware` when `sandbox` is non-empty. Format:
- `vendor:codex/never` — sets approval policy only, sandbox unchanged
- `vendor:codex/never:read-only` — sets both approval policy and sandbox
- `vendor:claude-code/bypassPermissions` — sets permission mode

### Mode Resolution

```go
func ResolveMode(name string) (Mode, error) {
    switch name {
    case "", "autonomous": return AutonomousMode{}, nil
    case "supervised":     return SupervisedMode{}, nil
    case "plan":           return PlanMode{}, nil
    default:
        if strings.HasPrefix(name, "vendor:") {
            return parseVendorMode(name[7:])
        }
        return nil, fmt.Errorf("%w: %s", ErrUnknownMode, name)
    }
}

func parseVendorMode(raw string) (Mode, error) {
    // Format: "provider/value" or "provider/value:sandbox"
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

### Interface Changes

#### SessionAdapter (factory)

```go
// SupportedModes returns the modes this adapter can operate in.
// The first entry is the default mode. Returns nil if modes are not applicable.
SupportedModes() []Mode
```

Codex and Claude Code return `[AutonomousMode, SupervisedMode, PlanMode]`.
OpenAI, OpenRouter, Ollama, OpenClaw, External return `nil`.

#### AdapterInstance (running session)

```go
// SetMode changes the execution mode for subsequent turns.
// The mode persists until explicitly changed by another SetMode call.
// Per-turn overrides via SendMessageRequest.mode are sticky — they
// do NOT revert after the turn completes.
//
// Error conditions:
//   - ErrModeMismatch: VendorMode targets a different provider
//   - ErrUnknownMode: mode is not in the adapter's SupportedModes list
//     (does not apply to VendorMode pass-through)
SetMode(mode Mode) error

// Mode returns the current active mode.
Mode() Mode
```

#### AdapterConfig (session creation)

```go
type AdapterConfig struct {
    // ... existing fields ...
    Mode Mode  // Initial mode, defaults to AutonomousMode if nil
}
```

### Concurrency Safety

Adapter instances already use `sync.Mutex` for status field access. `SetMode()` acquires the same mutex before modifying mode state. For the Codex adapter, `SetMode()` holds the lock while nilling the cached thread and updating config fields, preventing a concurrent `SendMessage()` from reading a partially-updated state.

The session manager serializes per-session access — `SendMessage` acquires a per-session lock before calling `SetMode()` and `instance.SendMessage()` sequentially. This prevents concurrent mode changes and message sends on the same session.

### Per-Turn Mechanics

#### Codex

`SetMode()` stores the mode, then calls provider methods:

- `Client.SetApprovalPolicy(policy)` — updates config, nils cached thread
- `Client.SetSandboxMode(sandbox)` — updates config, nils cached thread

Nilling the cached thread handle (not the thread ID) forces `getOrCreateThread()` to call `ResumeThread(threadID, newOpts)` on the next turn — same conversation context, updated mode options. When `threadID` is empty (first turn), `getOrCreateThread()` calls `StartThread(newOpts)` as normal — nilling a nil thread handle is a no-op.

New fields on `codex.Config`:

```go
ApprovalPolicy codexsdk.ApprovalMode `json:"approval_policy,omitempty"`
SandboxMode    codexsdk.SandboxMode  `json:"sandbox_mode,omitempty"`
```

Wired through `buildThreadOptions()`.

**VendorMode validation:** The Codex adapter's `SetMode()` checks `VendorMode.provider` — if it doesn't match `"codex"`, `SetMode` returns `ErrModeMismatch`. If the VendorMode targets codex but `VendorValue("codex")` returns a value not in the known `ApprovalMode` constants, it is passed through as-is (the Codex CLI validates it).

#### Claude Code

`SetMode()` stores the mode, then updates the SDK's default options:

```go
c.sdk.DefaultOptions.PermissionMode = claude.PermissionMode(vendorValue)
```

Takes effect immediately since `buildRunOptions()` inherits from `DefaultOptions` on every turn.

**VendorMode validation:** Same pattern — `VendorMode.provider` must match `"claude-code"` or `SetMode` returns `ErrModeMismatch`.

#### OpenAI-compatible (OpenAI, OpenRouter, Ollama, OpenClaw)

`SetMode()` stores the mode for status reporting. No-op for the provider — these are stateless API providers without native mode concepts. `VendorMode` targeting these providers is accepted and stored but has no effect. Future enhancement: `supervised` could strip tools from `ChatRequest.Tools`, `plan` could inject a system message (tracked in GH issue #39).

### Data Flow

#### Session Creation

```
gRPC CreateSessionRequest { mode: "autonomous" }
  → session_handlers.go: ResolveMode(req.Mode)
    - empty string resolves to AutonomousMode (default)
  → Manager.CreateSession { Mode: resolvedMode }
  → AdapterConfig { Mode: resolvedMode }
  → Adapter.Start(): instance.SetMode(cfg.Mode)
  → Provider: vendor-specific config applied
```

#### Per-Turn Override

```
gRPC SendMessageRequest { session_id, message, mode: "supervised" }
  → session_handlers.go:
    - if req.Mode == "": mode = nil (no override, keep current)
    - if req.Mode != "": mode = ResolveMode(req.Mode)
  → Manager.SendMessage(ctx, sessionID, msg, mode):
    - if mode != nil: instance.SetMode(mode)
  → instance.SendMessage(ctx, msg)
  → Provider uses current mode config
```

**Important distinction:** In `CreateSessionRequest`, an empty `mode` string means "use default" (autonomous). In `SendMessageRequest`, an empty `mode` string means "no override" (keep whatever mode the session is currently in). The gRPC handler distinguishes these two contexts — it only calls `ResolveMode` on `SendMessageRequest.mode` when the field is non-empty.

#### Mode Discovery

```
gRPC ListModesRequest { provider: "codex" }
  → adapter.SupportedModes() → []Mode
  → ModeInfo proto responses
```

### Proto Changes

```protobuf
// In session.proto — additions to the SessionService

service SessionService {
    // ... existing RPCs ...
    rpc ListModes(ListModesRequest) returns (ListModesResponse);
}

message CreateSessionRequest {
    // ... existing fields ...
    string mode = 11;  // obey mode name or "vendor:provider/value"; empty = autonomous
}

message SendMessageRequest {
    string session_id = 1;
    string message = 2;
    string mode = 3;  // optional per-turn override; empty = no change
}

message ModeInfo {
    string name = 1;
    string description = 2;
    bool is_default = 3;
}

message ListModesRequest {
    string provider = 1;  // optional filter; empty = all providers
}

message ListModesResponse {
    repeated ModeInfo modes = 1;
}
```

### Testing Strategy

1. **Mode resolution** — table-driven: `""` → autonomous, `"supervised"` → supervised, `"vendor:codex/never"` → VendorMode, `"vendor:codex/never:read-only"` → VendorMode with sandbox, `"garbage"` → ErrUnknownMode, `"vendor:bad"` → ErrInvalidVendorMode
2. **SupportedModes** — Codex and Claude Code return `[autonomous, supervised, plan]`, OpenAI/Ollama/OpenRouter/OpenClaw return nil
3. **SetMode integration** — mock provider with capture, verify vendor values reach provider config after SetMode
4. **Per-turn override** — set autonomous → send → set supervised → send → verify both mode values applied to respective provider calls
5. **Thread invalidation** — Codex: verify SetMode nils cached thread handle (not thread ID), next SendMessage resumes with new options, conversation context preserved
6. **Default mode** — session created with empty mode string gets autonomous
7. **VendorMode provider mismatch** — VendorMode targeting codex on a claude-code adapter returns ErrModeMismatch
8. **Empty mode in SendMessage** — empty string means no override, current mode preserved
9. **Concurrency** — concurrent SetMode and SendMessage on same instance don't race (verified via `-race` flag)
10. **First turn with nil thread** — SetMode before first SendMessage on Codex doesn't panic (nil thread handle is safe)
11. **Mode persistence** — SetMode("supervised") persists across multiple SendMessage calls, doesn't revert
12. **Codex thread resume failure** — if ResumeThread fails after mode change, error propagates through SendMessage; cached thread stays nil so next attempt retries
13. **gRPC integration** — CreateSessionRequest with mode → verify provider receives correct vendor config end-to-end through gRPC handler → manager → adapter → provider

### Files Changed

| File | Change |
|------|--------|
| `session/mode.go` | **New** — Mode interface, SandboxAware, built-in modes, sentinel errors, ResolveMode(), parseVendorMode() |
| `session/mode_test.go` | **New** — resolution, vendor parsing, provider mismatch, concurrency tests |
| `session/adapter.go` | Add Mode to AdapterConfig, SupportedModes() to SessionAdapter, SetMode()/Mode() to AdapterInstance |
| `session/manager.go` | Add Mode to CreateSessionRequest, mode handling in SendMessage (nil = no override) |
| `provider/codex/config.go` | Add ApprovalPolicy, SandboxMode fields |
| `provider/codex/client.go` | Add SetApprovalPolicy(), SetSandboxMode(), wire in buildThreadOptions |
| `provider/claudecode/client.go` | Add SetPermissionMode() |
| `adapters/codex.go` | Implement SetMode()/Mode(), VendorMode provider validation, wire in Start() |
| `adapters/claude_code.go` | Implement SetMode()/Mode(), VendorMode provider validation, wire in Start() |
| `adapters/openai.go` | Implement SetMode()/Mode() as no-op store |
| `adapters/openrouter.go` | Same |
| `adapters/ollama.go` | Same |
| `adapters/openclaw.go` | Same |
| `adapters/external.go` | Same |
| `adapters/mock.go` | Add mode support for tests |
| `protos/local/v1/session.proto` | Add mode to CreateSessionRequest/SendMessageRequest, add ListModes RPC to SessionService |
| `grpc/session_handlers.go` | Mode resolution (context-aware: create vs send), ListModes handler |
| `adapters/*_test.go` | Mode integration tests |

## Future Work

- **#38 `fest` mode** — Festival methodology execution mode
- **#39 OpenAI-compatible mode enforcement** — supervised strips tools, plan injects system message
- **Additional modes** — extensible via Mode interface without changes to existing code
