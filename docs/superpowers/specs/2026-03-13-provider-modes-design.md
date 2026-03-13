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
| codex | `on-request` | `read-only` |
| claude-code | `plan` | — |

#### VendorMode

Raw pass-through. Created from strings like `vendor:codex/never`.

```go
type VendorMode struct {
    provider string
    value    string
    desc     string
}
```

### Mode Resolution

```go
func ResolveMode(name string) (Mode, error) {
    switch name {
    case "", "autonomous": return AutonomousMode{}, nil
    case "supervised":     return SupervisedMode{}, nil
    case "plan":           return PlanMode{}, nil
    default:
        if strings.HasPrefix(name, "vendor:") {
            // Format: "vendor:codex/never"
            parts := strings.SplitN(name[7:], "/", 2)
            if len(parts) != 2 {
                return nil, fmt.Errorf("invalid vendor mode format: %s (expected vendor:provider/value)", name)
            }
            return VendorMode{provider: parts[0], value: parts[1]}, nil
        }
        return nil, fmt.Errorf("unknown mode: %s", name)
    }
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

### Per-Turn Mechanics

#### Codex

`SetMode()` stores the mode, then calls provider methods:

- `Client.SetApprovalPolicy(policy)` — updates config, nils cached thread
- `Client.SetSandboxMode(sandbox)` — updates config, nils cached thread

Nilling the cached thread forces `getOrCreateThread()` to call `ResumeThread(threadID, newOpts)` on the next turn — same conversation context, updated mode options.

New fields on `codex.Config`:

```go
ApprovalPolicy codexsdk.ApprovalMode `json:"approval_policy,omitempty"`
SandboxMode    codexsdk.SandboxMode  `json:"sandbox_mode,omitempty"`
```

Wired through `buildThreadOptions()`.

#### Claude Code

`SetMode()` stores the mode, then updates the SDK's default options:

```go
c.sdk.DefaultOptions.PermissionMode = claude.PermissionMode(vendorValue)
```

Takes effect immediately since `buildRunOptions()` inherits from `DefaultOptions` on every turn.

#### OpenAI-compatible (OpenAI, OpenRouter, Ollama, OpenClaw)

`SetMode()` stores the mode for status reporting. No-op for the provider — these are stateless API providers without native mode concepts. Future enhancement: `supervised` could strip tools from `ChatRequest.Tools`, `plan` could inject a system message.

### Data Flow

#### Session Creation

```
gRPC CreateSessionRequest { mode: "autonomous" }
  → session_handlers.go: ResolveMode(req.Mode)
  → Manager.CreateSession { Mode: resolvedMode }
  → AdapterConfig { Mode: resolvedMode }
  → Adapter.Start(): instance.SetMode(cfg.Mode)
  → Provider: vendor-specific config applied
```

#### Per-Turn Override

```
gRPC SendMessageRequest { session_id, message, mode: "supervised" }
  → session_handlers.go: ResolveMode(req.Mode)
  → Manager.SendMessage: instance.SetMode(mode)
  → instance.SendMessage(ctx, msg)
  → Provider uses updated mode config
```

#### Mode Discovery

```
gRPC ListModesRequest { provider: "codex" }
  → adapter.SupportedModes() → []Mode
  → ModeInfo proto responses
```

### Proto Changes

```protobuf
// In session.proto

message CreateSessionRequest {
    // ... existing fields ...
    string mode = 11;  // obey mode name or "vendor:provider/value"
}

message SendMessageRequest {
    string session_id = 1;
    string message = 2;
    string mode = 3;  // optional per-turn override
}

message ModeInfo {
    string name = 1;
    string description = 2;
    bool is_default = 3;
}

message ListModesRequest {
    string provider = 1;  // optional filter
}

message ListModesResponse {
    repeated ModeInfo modes = 1;
}
```

### Testing Strategy

1. **Mode resolution** — table-driven: `""` → autonomous, `"supervised"` → supervised, `"vendor:codex/never"` → VendorMode, `"garbage"` → error
2. **SupportedModes** — Codex and Claude Code return `[autonomous, supervised, plan]`, OpenAI/Ollama/OpenRouter/OpenClaw return nil
3. **SetMode integration** — mock provider with capture, verify vendor values reach provider config
4. **Per-turn override** — set autonomous → send → set supervised → send → verify both applied
5. **Thread invalidation** — Codex: verify SetMode nils cached thread, next SendMessage resumes with new options
6. **Default mode** — session created with nil/empty mode gets autonomous

### Files Changed

| File | Change |
|------|--------|
| `session/mode.go` | **New** — Mode interface, SandboxAware, built-in modes, ResolveMode() |
| `session/mode_test.go` | **New** — resolution and mode behavior tests |
| `session/adapter.go` | Add Mode to AdapterConfig, SupportedModes() to SessionAdapter, SetMode()/Mode() to AdapterInstance |
| `session/manager.go` | Add Mode to CreateSessionRequest, mode handling in SendMessage |
| `provider/codex/config.go` | Add ApprovalPolicy, SandboxMode fields |
| `provider/codex/client.go` | Add SetApprovalPolicy(), SetSandboxMode(), wire in buildThreadOptions |
| `provider/claudecode/client.go` | Add SetPermissionMode() |
| `adapters/codex.go` | Implement SetMode()/Mode(), wire in Start() |
| `adapters/claude_code.go` | Implement SetMode()/Mode(), wire in Start() |
| `adapters/openai.go` | Implement SetMode()/Mode() as no-op store |
| `adapters/openrouter.go` | Same |
| `adapters/ollama.go` | Same |
| `adapters/openclaw.go` | Same |
| `adapters/external.go` | Same |
| `adapters/mock.go` | Add mode support for tests |
| `protos/local/v1/session.proto` | Add mode fields to CreateSessionRequest, SendMessageRequest; add ListModes RPC |
| `grpc/session_handlers.go` | Mode resolution, pass to manager, ListModes handler |
| `adapters/*_test.go` | Mode integration tests |

## Future Work

- **`fest` mode** — Festival methodology execution mode (GH issue)
- **OpenAI-compatible mode enforcement** — supervised strips tools, plan injects system message (GH issue)
- **Additional modes** — extensible via Mode interface without changes to existing code
