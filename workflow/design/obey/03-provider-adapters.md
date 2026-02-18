# 03 — Provider Adapter System

## Overview

Provider adapters are the bridge between the daemon's session manager and the actual AI providers. Each adapter implements a common interface but handles the provider-specific details of spawning, communicating with, and shutting down the AI backend.

The adapter system is designed for extensibility — adding a new provider means implementing one interface, not modifying the session manager.

## Adapter Interface Recap

```go
// Adapter is a factory for a specific provider.
type Adapter interface {
    Provider() Provider
    SupportedModels() []string
    Start(ctx context.Context, config AdapterConfig) (AdapterInstance, error)
}

// AdapterInstance is a running provider session.
type AdapterInstance interface {
    SendMessage(ctx context.Context, message string) (<-chan *Activity, error)
    Stop(ctx context.Context, graceful bool) error
    Status() AdapterStatus
    PID() int
}
```

## Provider Comparison Matrix

```
┌──────────────┬─────────────┬───────────┬──────────────┬───────────────┐
│              │ claude-code │ openclaw  │ codex        │ openai-api    │
├──────────────┼─────────────┼───────────┼──────────────┼───────────────┤
│ Type         │ CLI process │ CLI proc  │ CLI process  │ HTTP API      │
│ Communication│ stdin/stdout│ stdin/out │ stdin/stdout │ REST/SSE      │
│ Stateful?    │ Yes (conv.) │ Yes       │ Yes          │ Stateless*    │
│ Streams?     │ Yes         │ Yes       │ Yes          │ Yes (SSE)     │
│ Sandbox      │ Built-in    │ Custom    │ Built-in     │ N/A (no tools)│
│ Tool use     │ Yes (native)│ Yes       │ Yes          │ Via functions │
│ Models       │ opus, sonnet│ varies    │ codex        │ gpt-4o, o1    │
│              │ haiku       │           │              │ gpt-4o-mini   │
│ Auth         │ API key env │ API key   │ API key env  │ API key env   │
│ Priority     │ P0 (first)  │ P1        │ P1           │ P2            │
└──────────────┴─────────────┴───────────┴──────────────┴───────────────┘

* openai-api maintains conversation state in the adapter via message history
```

## Adapter 1: claude-code (Priority: P0)

Claude Code is the primary adapter and the first to be implemented. It spawns the `claude` CLI as a child process and communicates via stdin/stdout using Claude Code's JSON streaming protocol.

### Architecture

```
┌───────────────────────────────────────────────────────┐
│                 claude-code Adapter                     │
│                                                        │
│  ┌──────────┐    ┌────────────┐    ┌──────────────┐   │
│  │ Process   │───▶│ Output     │───▶│ Activity     │   │
│  │ Manager   │    │ Parser     │    │ Emitter      │   │
│  │           │    │            │    │              │   │
│  │ spawn     │    │ JSON lines │    │ thinking     │   │
│  │ signal    │    │ parse      │    │ tool_call    │   │
│  │ wait      │    │ classify   │    │ tool_result  │   │
│  └─────┬─────┘    └────────────┘    │ completion   │   │
│        │                            └──────────────┘   │
│        │                                               │
│        ▼                                               │
│  ┌──────────┐                                          │
│  │ stdin     │◀── SendMessage() writes here             │
│  │ writer    │                                          │
│  └──────────┘                                          │
│                                                        │
└───────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────┐
│  claude CLI  │  (child process)
│              │
│  --json      │  JSON streaming output
│  --model X   │  model selection
│  --cwd DIR   │  campaign root
│  --dangerously-skip-permissions │  for automated use
└──────────────┘
```

### Spawn Command

```bash
claude \
  --json \
  --model <model> \
  --cwd <campaign_root> \
  --dangerously-skip-permissions \
  --verbose
```

**Environment variables injected**:
```bash
ANTHROPIC_API_KEY=<from daemon config or env>
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
OBEY_SESSION_ID=<session_id>
OBEY_CAMPAIGN_ID=<campaign_id>
```

### Output Parsing

Claude Code with `--json` emits newline-delimited JSON objects. Each object has a `type` field:

```json
{"type": "assistant", "message": {"content": [{"type": "text", "text": "..."}]}}
{"type": "tool_use", "tool": {"name": "Read", "input": {"file_path": "..."}}}
{"type": "tool_result", "tool": {"name": "Read", "output": "..."}}
{"type": "result", "message": {"content": [{"type": "text", "text": "..."}]}, "usage": {"input_tokens": 500, "output_tokens": 200}}
```

The adapter maps these to `Activity` events:

| Claude Code JSON type | Activity type | Notes |
|----------------------|---------------|-------|
| `assistant` (mid-stream) | `AGENT_THINKING` | Content text |
| `tool_use` | `AGENT_TOOL_CALL` | tool_name, tool_call_id |
| `tool_result` | `AGENT_TOOL_RESULT` | tool_name, success |
| `result` | `AGENT_COMPLETION` | Final content + token counts |

### Message Sending

Messages are sent by writing to the process's stdin:

```go
func (a *claudeCodeInstance) SendMessage(ctx context.Context, msg string) (<-chan *Activity, error) {
    // Write message to stdin (the claude process reads from stdin for follow-up messages)
    _, err := fmt.Fprintf(a.stdin, "%s\n", msg)
    if err != nil {
        return nil, fmt.Errorf("writing to claude stdin: %w", err)
    }

    // Return the activity channel — parser goroutine populates this
    return a.activities, nil
}
```

### Graceful Shutdown

```
1. Write "/exit\n" to stdin
2. Wait up to 5 seconds for process to exit
3. If still running: SIGTERM
4. Wait up to 5 seconds
5. If still running: SIGKILL
```

### Implementation Notes

```go
package adapters

import (
    "bufio"
    "context"
    "encoding/json"
    "fmt"
    "os"
    "os/exec"
    "sync"

    "github.com/obedience-corp/obey/internal/session"
)

type ClaudeCodeAdapter struct{}

func (a *ClaudeCodeAdapter) Provider() session.Provider {
    return session.ProviderClaudeCode
}

func (a *ClaudeCodeAdapter) SupportedModels() []string {
    return []string{"opus", "sonnet", "haiku"}
}

func (a *ClaudeCodeAdapter) Start(ctx context.Context, cfg session.AdapterConfig) (session.AdapterInstance, error) {
    args := []string{
        "--json",
        "--model", cfg.Model,
        "--cwd", cfg.CampaignDir,
        "--dangerously-skip-permissions",
        "--verbose",
    }

    cmd := exec.CommandContext(ctx, "claude", args...)
    cmd.Dir = cfg.CampaignDir
    cmd.Env = buildEnv(cfg)

    stdin, err := cmd.StdinPipe()
    if err != nil {
        return nil, fmt.Errorf("creating stdin pipe: %w", err)
    }

    stdout, err := cmd.StdoutPipe()
    if err != nil {
        return nil, fmt.Errorf("creating stdout pipe: %w", err)
    }

    if err := cmd.Start(); err != nil {
        return nil, fmt.Errorf("starting claude process: %w", err)
    }

    inst := &claudeCodeInstance{
        cmd:        cmd,
        stdin:      stdin,
        activities: make(chan *session.Activity, 100),
    }

    // Start output parser goroutine
    go inst.parseOutput(bufio.NewScanner(stdout))

    return inst, nil
}
```

---

## Adapter 2: openclaw (Priority: P1)

OpenClaw is a CLI-based AI agent runtime. Like claude-code, it runs as a child process.

### Architecture

```
┌───────────────────────────────────────────────────────┐
│                  openclaw Adapter                       │
│                                                        │
│  ┌──────────┐    ┌────────────┐    ┌──────────────┐   │
│  │ Process   │───▶│ Output     │───▶│ Activity     │   │
│  │ Manager   │    │ Parser     │    │ Emitter      │   │
│  └─────┬─────┘    └────────────┘    └──────────────┘   │
│        │                                               │
│        ▼                                               │
│  ┌──────────┐                                          │
│  │ stdin     │◀── SendMessage()                         │
│  │ writer    │                                          │
│  └──────────┘                                          │
└───────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────┐
│  openclaw    │  (child process)
│  CLI         │
└──────────────┘
```

### Spawn Command

```bash
openclaw run \
  --dir <campaign_root> \
  --output json
```

### Implementation Notes

- The adapter structure mirrors claude-code but with openclaw-specific output parsing
- OpenClaw's JSON output format needs to be mapped to the universal `Activity` types
- If openclaw doesn't support JSON streaming, fall back to line-based parsing of stdout
- Authentication via `OPENCLAW_API_KEY` environment variable

---

## Adapter 3: codex (Priority: P1)

OpenAI Codex CLI agent. Process-based, similar architecture to claude-code.

### Architecture

Same process-based pattern as claude-code and openclaw.

### Spawn Command

```bash
codex \
  --json \
  --model <model> \
  --cwd <campaign_root>
```

### Implementation Notes

- Codex CLI output format needs investigation once the tool stabilizes
- Map codex-specific events to universal `Activity` types
- Authentication via `OPENAI_API_KEY` environment variable
- Model options: codex-specific models

---

## Adapter 4: openai-api (Priority: P2)

Unlike the other adapters, this one doesn't spawn a process. It maintains a conversation via the OpenAI Chat Completions API with tool use.

### Architecture

```
┌───────────────────────────────────────────────────────┐
│                  openai-api Adapter                     │
│                                                        │
│  ┌──────────┐    ┌────────────┐    ┌──────────────┐   │
│  │ API       │───▶│ SSE        │───▶│ Activity     │   │
│  │ Client    │    │ Parser     │    │ Emitter      │   │
│  │           │    │            │    │              │   │
│  │ POST /v1/ │    │ stream     │    │ thinking     │   │
│  │ chat/     │    │ deltas     │    │ tool_call    │   │
│  │ completions    │ assemble   │    │ tool_result  │   │
│  └───────────┘    └────────────┘    │ completion   │   │
│                                     └──────────────┘   │
│  ┌────────────────────────────────────────────────┐    │
│  │ Conversation History                            │    │
│  │                                                 │    │
│  │ [system, user, assistant, user, assistant, ...] │    │
│  │ Maintained in-memory for session duration       │    │
│  └────────────────────────────────────────────────┘    │
│                                                        │
│  ┌────────────────────────────────────────────────┐    │
│  │ Tool Executor                                   │    │
│  │                                                 │    │
│  │ Maps OpenAI function calls → sandbox Execute()  │    │
│  │ Returns tool results back to the conversation   │    │
│  └────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────┘
         │
         ▼ (HTTP)
┌──────────────┐
│  OpenAI API  │
│  api.openai  │
│  .com/v1/    │
└──────────────┘
```

### Key Differences from Process-Based Adapters

1. **No child process** — communicates via HTTP API
2. **Stateless API** — adapter maintains conversation history in-memory
3. **Tool execution** — adapter must execute tool calls via the daemon's command sandbox, then feed results back as tool_result messages
4. **No stdin/stdout** — messages sent via API calls

### Tool Use Loop

```
Client: SendMessage("Fix the bug in auth.go")
  │
  ├── Adapter: POST /v1/chat/completions (stream: true)
  │     messages: [system, ..., user: "Fix the bug in auth.go"]
  │     tools: [read_file, write_file, run_command, ...]
  │
  ├── API streams: thinking + tool_call("read_file", {"path": "auth.go"})
  │     → Emit THINKING + TOOL_CALL activities
  │
  ├── Adapter: Execute tool via sandbox
  │     → sandbox.Execute("cat auth.go") within campaign boundary
  │     → Emit TOOL_RESULT activity
  │
  ├── Adapter: POST /v1/chat/completions (with tool result)
  │     messages: [..., tool_result: {content: "<file contents>"}]
  │
  ├── API streams: thinking + tool_call("write_file", ...)
  │     → Emit THINKING + TOOL_CALL activities
  │
  ├── Adapter: Execute tool via sandbox
  │     → Emit TOOL_RESULT activity
  │
  ├── Adapter: POST /v1/chat/completions (with tool result)
  │
  └── API streams: completion
        → Emit COMPLETION activity
```

### Tool Definitions

The openai-api adapter exposes a set of tools that map to the daemon's sandbox capabilities:

```json
{
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "read_file",
        "description": "Read the contents of a file within the campaign directory",
        "parameters": {
          "type": "object",
          "properties": {
            "path": { "type": "string", "description": "Relative path from campaign root" }
          },
          "required": ["path"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "write_file",
        "description": "Write content to a file within the campaign directory",
        "parameters": {
          "type": "object",
          "properties": {
            "path": { "type": "string" },
            "content": { "type": "string" }
          },
          "required": ["path", "content"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "run_command",
        "description": "Run an allowed command within the campaign sandbox (fest, camp, just, git)",
        "parameters": {
          "type": "object",
          "properties": {
            "command": { "type": "string" },
            "args": { "type": "array", "items": { "type": "string" } }
          },
          "required": ["command"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "list_files",
        "description": "List files in a directory within the campaign",
        "parameters": {
          "type": "object",
          "properties": {
            "path": { "type": "string" },
            "pattern": { "type": "string" }
          }
        }
      }
    }
  ]
}
```

### Implementation Notes

- Uses the `OPENAI_API_KEY` environment variable
- Maintains full conversation history in memory — watch for context window limits
- Needs a system prompt that describes the campaign, available tools, and boundaries
- Token counting comes directly from the API response `usage` field
- Does NOT support the full breadth of tools that claude-code has natively — limited to sandbox operations

---

## Adapter Registration

Adapters are registered at daemon startup:

```go
func NewManager(db *state.DB, router *event.Router, sandbox *sandbox.Sandbox) *Manager {
    m := &Manager{
        db:       db,
        router:   router,
        sandbox:  sandbox,
        adapters: make(map[Provider]Adapter),
        sessions: make(map[string]*Session),
    }

    // Register built-in adapters
    m.RegisterAdapter(&adapters.ClaudeCodeAdapter{})
    m.RegisterAdapter(&adapters.OpenClawAdapter{})
    m.RegisterAdapter(&adapters.CodexAdapter{})
    m.RegisterAdapter(&adapters.OpenAIAPIAdapter{})

    return m
}

func (m *Manager) RegisterAdapter(a Adapter) {
    m.adapters[a.Provider()] = a
}
```

## Testing Strategy

### Per-Adapter Tests

Each adapter needs:
1. **Unit tests** with a mock process/API (no real provider needed)
2. **Integration test** with the real provider (requires API key, run manually)
3. **Crash recovery test** — kill the process, verify adapter reports FAILED
4. **Timeout test** — simulate a hung provider

### Activity Event Tests

Verify that all adapters produce the same `Activity` event types for equivalent operations:
- All produce `THINKING` when the model reasons
- All produce `TOOL_CALL` with `tool_name` when tools are invoked
- All produce `TOOL_RESULT` with `success` flag
- All produce `COMPLETION` with token counts

### Mock Adapter (for testing)

```go
type MockAdapter struct {
    responses []Activity
}

func (m *MockAdapter) Provider() Provider { return "mock" }
func (m *MockAdapter) SupportedModels() []string { return []string{"mock-v1"} }
func (m *MockAdapter) Start(ctx context.Context, cfg AdapterConfig) (AdapterInstance, error) {
    return &mockInstance{responses: m.responses}, nil
}
```
