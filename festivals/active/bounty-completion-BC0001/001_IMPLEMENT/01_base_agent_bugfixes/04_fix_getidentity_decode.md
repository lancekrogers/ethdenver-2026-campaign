---
fest_type: task
fest_id: 05_fix_getidentity_decode.md
fest_name: fix getidentity decode
fest_parent: 01_base_agent_bugfixes
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:06.904341-07:00
fest_tracking: true
---

# Task: Fix ERC-8004 GetIdentity ABI Decoding

## Objective

Replace the hardcoded stub response in `GetIdentity` with proper ABI decoding of the on-chain ERC-8004 registry response so identity reads reflect actual on-chain state.

## Requirements

- [ ] `GetIdentity` in `projects/agent-defi/internal/base/identity/register.go` ABI-decodes the response bytes from the `eth_call` into an `Identity` struct with real `Status`, `Metadata`, and `Signature` fields
- [ ] If the on-chain call returns empty bytes (agent not registered), `GetIdentity` returns a clear `ErrNotRegistered` error instead of a fake active identity

## Implementation

### Step 1: Read the current stub

In `projects/agent-defi/internal/base/identity/register.go`, find `GetIdentity`. It currently does an `eth_call` with selector `0xf4c714b4` but returns a hardcoded `Identity{Status: StatusActive}` regardless of the response. The comment says "In production, ABI-decode the result bytes."

### Step 2: Define the ABI decoding

Use go-ethereum's `abi` package:

```go
import "github.com/ethereum/go-ethereum/accounts/abi"

identityABI, _ := abi.JSON(strings.NewReader(`[{
    "name": "getIdentity",
    "type": "function",
    "outputs": [
        {"name": "status", "type": "uint8"},
        {"name": "metadata", "type": "bytes"},
        {"name": "signature", "type": "bytes"}
    ]
}]`))
```

### Step 3: Replace the stub

After the `eth_call` returns `result` bytes:

```go
if len(result) == 0 {
    return Identity{}, ErrNotRegistered
}
outputs, err := identityABI.Methods["getIdentity"].Outputs.Unpack(result)
if err != nil {
    return Identity{}, fmt.Errorf("decode identity: %w", err)
}
return Identity{
    Status:    IdentityStatus(outputs[0].(uint8)),
    Metadata:  outputs[1].([]byte),
    Signature: outputs[2].([]byte),
}, nil
```

### Step 4: Add ErrNotRegistered

Define `var ErrNotRegistered = errors.New("agent not registered on-chain")` in the identity package if it doesn't exist.

### Step 5: Update tests

In `projects/agent-defi/internal/base/identity/register_test.go`:

- Test with mock ABI-encoded bytes verifies correct decoding of all three fields
- Test with empty response returns `ErrNotRegistered`

## Done When

- [ ] All requirements met
- [ ] Test with mock ABI-encoded response verifies all three fields decoded correctly; test with empty response returns `ErrNotRegistered`
