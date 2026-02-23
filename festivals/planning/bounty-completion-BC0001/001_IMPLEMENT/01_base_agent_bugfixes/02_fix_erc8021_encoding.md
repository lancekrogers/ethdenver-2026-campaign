---
fest_type: task
fest_id: 02_fix_erc8021_encoding.md
fest_name: fix erc8021 encoding
fest_parent: 01_base_agent_bugfixes
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:06.903485-07:00
fest_tracking: true
---

# Task: Fix ERC-8021 Builder Code Encoding

## Objective

Fix the ERC-8021 attribution encoder to hex-decode the builder code address instead of copying raw ASCII string bytes, so transactions contain valid 20-byte builder attribution.

## Requirements

- [ ] The `BuilderCode` field in the Attribution config is populated with hex-decoded bytes from `DEFI_BUILDER_CODE` env var (e.g., `0xc71d...` becomes 20 bytes, not 42 ASCII characters)
- [ ] The `Encode` method in `projects/agent-defi/internal/base/attribution/builder.go` appends the correct 4-byte magic (`\x45\x52\x43\x38`) + 20-byte address to calldata

## Implementation

### Step 1: Find the config loading code

In `projects/agent-defi/internal/agent/agent.go` (or wherever the Attribution config is constructed from env vars), find where `DEFI_BUILDER_CODE` is read. The current code does:

```go
copy(cfg.Attribution.BuilderCode[:], builderCode)
```

where `builderCode` is a string like `"0xc71d8a19422c649fe9bdcbf3ffa536326c82b58b"`. This copies the ASCII bytes of the hex string, not the actual 20-byte address.

### Step 2: Fix the encoding

Replace the raw string copy with proper hex decoding:

```go
import "encoding/hex"

clean := strings.TrimPrefix(builderCode, "0x")
decoded, err := hex.DecodeString(clean)
if err != nil {
    return fmt.Errorf("invalid builder code hex: %w", err)
}
if len(decoded) != 20 {
    return fmt.Errorf("builder code must be 20 bytes, got %d", len(decoded))
}
copy(cfg.Attribution.BuilderCode[:], decoded)
```

### Step 3: Update the test

In `projects/agent-defi/internal/base/attribution/builder_test.go`, verify that `Encode` appends exactly 24 bytes (4 magic + 20 address) to the calldata, and that the address bytes match the hex-decoded input — not the ASCII representation.

## Done When

- [ ] All requirements met
- [ ] Test asserts: given builder code `0xc71d8a19422c649fe9bdcbf3ffa536326c82b58b`, the last 20 bytes of encoded calldata equal `[0xc7, 0x1d, 0x8a, ...]` (hex-decoded), not `[0x30, 0x78, 0x63, ...]` (ASCII of "0xc")
