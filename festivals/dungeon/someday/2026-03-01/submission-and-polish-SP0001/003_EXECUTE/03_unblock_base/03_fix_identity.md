---
fest_type: task
fest_id: 03_fix_identity.md
fest_name: fix_identity
fest_parent: 03_unblock_base
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Fix Identity Registration

## Objective

Fix `projects/agent-defi/internal/base/identity/register.go` to use proper ABI encoding for both `getIdentity` and `register` calls instead of the current string concatenation that produces malformed calldata.

## Context

The current `register.go` builds calldata by concatenating `"0x"` with the raw `agentID` string. This is not valid ABI encoding and causes the ERC-8004 IdentityRegistry contract at `0x8004A818BFB912233c491871b3d84c89A494BD9e` to revert on every call. Identity registration is a prerequisite for the ERC-8021 attribution flow, so this must be fixed before end-to-end testing.

The fix is straightforward: replace the string concatenation with `abi.Pack` calls that correctly encode the function selector and parameters per the ABI spec.

## Implementation Steps

### 1. Fix GetIdentity

The `getIdentity(bytes32 agentId)` function reads an existing identity from the registry.

Current broken pattern:
```go
calldata := "0x" + agentID  // WRONG: raw string, not ABI encoded
```

Correct pattern:
```go
// Parse agentID into a [32]byte
var agentIDBytes32 [32]byte
idBytes, err := hex.DecodeString(strings.TrimPrefix(agentID, "0x"))
if err != nil {
    return nil, fmt.Errorf("invalid agentID: %w", err)
}
copy(agentIDBytes32[32-len(idBytes):], idBytes)

// ABI-encode the call
parsedABI, err := abi.JSON(strings.NewReader(identityRegistryABI))
calldata, err := parsedABI.Pack("getIdentity", agentIDBytes32)
```

Alternatively, manually encode as: `selector (4 bytes) + left-padded bytes32 (32 bytes)`.

### 2. Fix Register

The `register` function writes an identity entry to the registry. Inspect the ERC-8004 IdentityRegistry ABI to determine the exact function signature and parameter types. Apply the same `abi.Pack` approach:

```go
calldata, err := parsedABI.Pack("register", agentIDBytes32, metadataParam, ...)
```

Do not assume parameter types — read the contract ABI or the ERC-8004 spec to get the exact signature before encoding.

### 3. Verify with eth_call before broadcasting

After fixing the encoding, use `eth_call` (read-only) to test the `getIdentity` call against the live contract on Base Sepolia before sending a write transaction. A successful `eth_call` that does not revert confirms the calldata is correctly formed.

### 4. Update tests

Update `register_test.go` (or equivalent) to:
- Verify `getIdentity` produces a calldata hex that starts with the correct function selector
- Verify the bytes32 agentID is correctly left-padded in the encoded calldata
- Verify `register` calldata encodes all parameters in the correct order

## Done When

- `GetIdentity` builds calldata using `abi.Pack` with a proper `[32]byte` agentID
- `Register` builds calldata using `abi.Pack` with all required parameters
- No string concatenation is used for ABI encoding anywhere in `register.go`
- `eth_call` to `getIdentity` on Base Sepolia returns without reverting
- All identity unit tests pass
