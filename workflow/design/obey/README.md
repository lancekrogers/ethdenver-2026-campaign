# Obey Agent Session Architecture

Design documents for the obey daemon's agent session management system. This directory contains the interface specs, architecture diagrams, and requirements needed to implement agent sessions in obeyd.

## Context

The obey daemon (`obeyd`) currently provides event routing, command sandboxing, and state tracking. It does **not** manage agent sessions. These documents specify the agent session layer that needs to be built on top of the existing daemon infrastructure.

**Key concept**: An **agent session** in obey is a provider-agnostic execution context tied to a campaign. Sessions can use any supported provider (claude-code, openclaw, codex, openai-api, etc.) but are sandboxed to operate only within their bound campaign.

## Documents

| Doc | Title | Purpose |
|-----|-------|---------|
| [01](./01-agent-session-architecture.md) | Agent Session Architecture | Core session model, lifecycle, campaign scoping |
| [02](./02-grpc-interface-spec.md) | gRPC Interface Specification | Protobuf service definitions for local agent session management |
| [03](./03-provider-adapters.md) | Provider Adapter System | How each AI provider is adapted into the session model |
| [04](./04-sandbox-and-security.md) | Sandbox & Security Model | Campaign-scoped isolation, credential handling, boundary enforcement |
| [05](./05-websocket-remote-spec.md) | WebSocket Remote Access (Stretch) | Obey hub remote session management via WebSocket |

## Implementation Priority

```
Phase 1: Local gRPC agent sessions (PRIORITY — hackathon demo)
  ├── Session CRUD (create, get, list, stop)
  ├── Provider adapter interface + claude-code adapter
  ├── Campaign sandbox scoping
  └── Activity streaming through existing pipeline

Phase 2: Additional providers
  ├── openclaw adapter
  ├── codex adapter
  └── openai-api adapter

Phase 3: Remote access via obey-hub (STRETCH — post-hackathon if time)
  ├── WebSocket session proxy
  ├── Hub-side session registry
  └── Public demo link generation
```

## Relationship to Existing Docs

These docs extend the daemon requirements in `../ethdenver-agent-economy/tools/daemon-requirements.md`. That document covers the agent registry and process management for the ETHDenver agent economy specifically. This directory covers the **general-purpose agent session system** that obeyd provides — the ETHDenver agents are just one consumer of this capability.

## For the Obey Team

These documents are designed to be handed to the obey team for implementation. Each document includes:
- Architectural diagrams (mermaid + ASCII)
- Protobuf definitions (ready to compile)
- Implementation notes with suggested package structure
- Test scenarios
