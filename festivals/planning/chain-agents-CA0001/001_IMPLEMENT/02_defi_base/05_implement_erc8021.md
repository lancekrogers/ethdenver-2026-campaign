---
fest_type: task
fest_id: 05_implement_erc8021.md
fest_name: implement_erc8021
fest_parent: 02_defi_base
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement ERC-8021 Builder Attribution

## Objective

Implement the `AttributionEncoder` interface to add ERC-8021 builder attribution codes to all transactions the DeFi agent submits on Base. Builder attribution allows Base to track which builders (developers, teams, agents) are generating on-chain activity. Every transaction the DeFi agent submits must include this attribution to qualify for the Base bounty and to demonstrate proper builder identification.

**Project:** `agent-defi` at `projects/agent-defi/`
**Package:** `internal/base/attribution/`

## Requirements

- [ ] Implement the `AttributionEncoder` interface defined in the architecture task
- [ ] Encode builder attribution codes into transaction calldata
- [ ] Decode attribution codes from existing transaction calldata
- [ ] Integrate with the trading executor so all trades include attribution
- [ ] Handle all errors with contextual wrapping
- [ ] Pass `context.Context` through all I/O operations

## Implementation

### Step 1: Research ERC-8021

Before writing code, research the ERC-8021 builder attribution standard:

1. Read the ERC-8021 specification -- understand the attribution code format
2. Determine how the attribution code is appended to transaction calldata
3. Find the expected format: is it a fixed-length suffix? A specific byte pattern?
4. Identify how to register as a builder to get your attribution code
5. Check if Base provides tooling or SDKs for attribution
6. Look for examples of other projects implementing ERC-8021

The typical pattern for builder attribution is appending a fixed-length code (e.g., 20 bytes) to the end of transaction calldata. This does not affect the contract execution because Solidity ignores trailing calldata bytes.

Document findings in comments at the top of `builder.go`.

### Step 2: Define the model types

In `internal/base/attribution/models.go`:

```go
package attribution

// Attribution represents a decoded builder attribution from transaction calldata.
type Attribution struct {
    // BuilderCode is the unique builder identifier.
    BuilderCode []byte

    // BuilderName is the human-readable name (if registered).
    BuilderName string

    // Version is the attribution protocol version.
    Version uint8
}

// Config holds configuration for the attribution encoder.
type Config struct {
    // BuilderCode is this agent's registered builder attribution code.
    // This is a fixed-length byte sequence assigned by the Base builder registry.
    BuilderCode []byte

    // Enabled controls whether attribution is appended.
    // Set to false to disable during testing.
    Enabled bool
}
```

### Step 3: Implement the attribution encoder

In `internal/base/attribution/builder.go`:

```go
package attribution

import (
    "context"
    "fmt"
)

// attributionSuffix is the byte pattern that marks the start of attribution data.
// This is defined by the ERC-8021 specification.
var attributionSuffix = []byte{/* ERC-8021 marker bytes */}

// encoder implements the AttributionEncoder interface.
type encoder struct {
    cfg Config
}

// NewEncoder creates a new AttributionEncoder with the given builder code.
func NewEncoder(cfg Config) (AttributionEncoder, error) {
    if len(cfg.BuilderCode) == 0 {
        return nil, fmt.Errorf("attribution: builder code is required")
    }
    // Validate builder code length matches ERC-8021 requirements
    return &encoder{cfg: cfg}, nil
}
```

Key implementation details:

**Encode(ctx, txData)**:
1. If attribution is disabled, return the original txData unchanged
2. Validate the builder code is the correct length
3. Append the ERC-8021 marker bytes to the end of txData
4. Append the builder code after the marker
5. Return the modified txData
6. This operation is purely in-memory (no I/O), but context is accepted for interface consistency

```go
func (e *encoder) Encode(ctx context.Context, txData []byte) ([]byte, error) {
    if !e.cfg.Enabled {
        return txData, nil
    }

    // Create a new byte slice to avoid mutating the input
    result := make([]byte, 0, len(txData)+len(attributionSuffix)+len(e.cfg.BuilderCode))
    result = append(result, txData...)
    result = append(result, attributionSuffix...)
    result = append(result, e.cfg.BuilderCode...)

    return result, nil
}
```

**Decode(ctx, txData)**:
1. Check if txData ends with the ERC-8021 marker pattern
2. If not found, return nil (no attribution present)
3. Extract the builder code from after the marker
4. Return an Attribution struct with the decoded data

```go
func (e *encoder) Decode(ctx context.Context, txData []byte) (*Attribution, error) {
    // Check if txData is long enough to contain attribution
    minLen := len(attributionSuffix) + len(e.cfg.BuilderCode)
    if len(txData) < minLen {
        return nil, nil // No attribution present
    }

    // Check for the marker suffix
    markerStart := len(txData) - len(e.cfg.BuilderCode) - len(attributionSuffix)
    marker := txData[markerStart : markerStart+len(attributionSuffix)]

    if !bytes.Equal(marker, attributionSuffix) {
        return nil, nil // No attribution present
    }

    // Extract builder code
    code := txData[markerStart+len(attributionSuffix):]

    return &Attribution{
        BuilderCode: code,
    }, nil
}
```

### Step 4: Integration with trading executor

The attribution encoder must be called by the trading executor before every transaction is submitted. In the trading executor (task 06), every transaction's calldata should pass through `Encode()` before signing:

```go
// In the trade executor:
func (e *executor) Execute(ctx context.Context, trade Trade) (*TradeResult, error) {
    // Build the swap transaction calldata
    txData := buildSwapCalldata(trade)

    // Add builder attribution
    txData, err = e.attribution.Encode(ctx, txData)
    if err != nil {
        return nil, fmt.Errorf("trading: attribution encoding failed: %w", err)
    }

    // Sign and submit the transaction with the attributed calldata
    // ...
}
```

Document this integration pattern in comments so the trading task (task 06) knows to use it.

### Step 5: Define sentinel errors

```go
var (
    ErrInvalidBuilderCode = errors.New("attribution: builder code is invalid or wrong length")
    ErrEncodingFailed     = errors.New("attribution: failed to encode attribution")
)
```

### Step 6: Write unit tests

Create `internal/base/attribution/builder_test.go`:

1. **TestEncode_AppendsAttribution**: Encode calldata, verify suffix appended correctly
2. **TestEncode_DisabledReturnsOriginal**: Set Enabled=false, verify calldata unchanged
3. **TestEncode_DoesNotMutateInput**: Verify original byte slice is not modified
4. **TestDecode_WithAttribution**: Encode then decode, verify roundtrip
5. **TestDecode_WithoutAttribution**: Decode plain calldata, verify nil returned
6. **TestDecode_TooShort**: Decode very short calldata, verify nil returned
7. **TestNewEncoder_EmptyCode**: Pass empty builder code, verify error
8. **TestEncode_EmptyCalldata**: Encode with no original calldata, verify attribution only
9. **TestEncode_LargeCalldata**: Encode with large calldata, verify correct append

### Step 7: Verify compilation and tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go build ./internal/base/attribution/...
go test ./internal/base/attribution/... -v
go vet ./internal/base/attribution/...
```

## Done When

- [ ] `AttributionEncoder` interface fully implemented in `internal/base/attribution/builder.go`
- [ ] Model types defined in `internal/base/attribution/models.go`
- [ ] Encode appends ERC-8021 marker and builder code to calldata
- [ ] Decode extracts builder code from attributed calldata
- [ ] Integration pattern documented for trading executor
- [ ] Sentinel errors defined
- [ ] Table-driven unit tests cover encode, decode, roundtrip, disabled mode, and edge cases
- [ ] `go build`, `go test`, and `go vet` all pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
- [ ] ERC-8021 research findings documented in code comments
