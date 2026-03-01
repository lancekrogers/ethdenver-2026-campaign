---
fest_type: task
fest_id: 02_fix_serving_abi.md
fest_name: fix_serving_abi
fest_parent: 02_unblock_0g
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Fix Serving Contract ABI Mismatch

**Task Number:** 02 | **Sequence:** 02_unblock_0g | **Autonomy:** medium

## Objective

Fix the ABI mismatch in `projects/agent-inference/internal/zerog/compute/broker.go`. The current ABI declares `getServiceCount()` and `getService(uint256 index)`, which do not exist on the real pre-deployed serving contract. The real contract uses `getAllServices(uint256 offset, uint256 limit)` and `getService(address provider)`. Update the ABI constant and rewrite `listFromChain()` accordingly.

## Requirements

- [ ] The `servingABIJSON` constant reflects the real contract methods
- [ ] `listFromChain()` calls `getAllServices(0, 100)` instead of iterating by index
- [ ] `listFromChain()` maps the returned struct fields correctly to the `Model` type
- [ ] `getService(address)` is available in the ABI for per-provider lookup (even if not called by `listFromChain` directly)
- [ ] All existing error-handling patterns are preserved (context propagation, error wrapping)
- [ ] No `fmt.Errorf` calls introduced — use the existing error wrapping style
- [ ] `go build ./...` passes after changes
- [ ] Existing tests pass or are updated to match the new ABI

## Context: The Current Problem

The file at `projects/agent-inference/internal/zerog/compute/broker.go` currently declares:

```go
const servingABIJSON = `[
  {
    "name": "getServiceCount",
    ...
  },
  {
    "name": "getService",
    "inputs": [{"name": "index", "type": "uint256"}],
    ...
  }
]`
```

And `listFromChain()` calls:

```go
b.contract.Call(..., &countResult, "getServiceCount")
// then loops i = 0..n-1:
b.contract.Call(..., &svcResult, "getService", big.NewInt(int64(i)))
```

These methods do not exist. Every call fails silently with an ABI encoding error.

## Implementation

### Step 1: Confirm the real ABI

Before writing code, confirm the actual method signatures by querying the contract on Galileo testnet. Use `cast` from foundry or the 0G block explorer:

```bash
# Option A: cast (if foundry is available)
cast abi-decode --abi-file <(cast etherscan-source \
  --rpc-url https://evmrpc-testnet.0g.ai \
  0xa79F4c8311FF93C06b8CfB403690cc987c93F91E) \
  "getAllServices(uint256,uint256)"

# Option B: call the contract directly to probe
cast call --rpc-url https://evmrpc-testnet.0g.ai \
  0xa79F4c8311FF93C06b8CfB403690cc987c93F91E \
  "getAllServices(uint256,uint256)(tuple[],uint256)" 0 10
```

If the exact return struct differs from the specification below, adjust the ABI accordingly. The specification below is based on the 0G serving contract source.

### Step 2: Update the ABI constant

Replace `servingABIJSON` in `broker.go` with:

```go
const servingABIJSON = `[
  {
    "name": "getAllServices",
    "type": "function",
    "stateMutability": "view",
    "inputs": [
      {"name": "offset", "type": "uint256"},
      {"name": "limit",  "type": "uint256"}
    ],
    "outputs": [
      {
        "name": "services",
        "type": "tuple[]",
        "components": [
          {"name": "provider",    "type": "address"},
          {"name": "name",        "type": "string"},
          {"name": "serviceType", "type": "string"},
          {"name": "url",         "type": "string"},
          {"name": "model",       "type": "string"}
        ]
      },
      {"name": "total", "type": "uint256"}
    ]
  },
  {
    "name": "getService",
    "type": "function",
    "stateMutability": "view",
    "inputs": [
      {"name": "provider", "type": "address"}
    ],
    "outputs": [
      {
        "name": "service",
        "type": "tuple",
        "components": [
          {"name": "provider",    "type": "address"},
          {"name": "name",        "type": "string"},
          {"name": "serviceType", "type": "string"},
          {"name": "url",         "type": "string"},
          {"name": "model",       "type": "string"}
        ]
      }
    ]
  }
]`
```

If the real contract struct has additional fields (e.g., `inputPrice`, `outputPrice`, `updatedAt`), add them to both `components` arrays.

### Step 3: Define the service struct for ABI decoding

Add a struct that matches the ABI tuple layout. go-ethereum's `bind.BoundContract.Call` returns `[]interface{}` — for tuple arrays, each element is a `struct` generated at runtime or a `map[string]interface{}`. The safest approach is to decode into a concrete struct:

```go
// serviceStruct mirrors the ABI tuple for a single service entry.
type serviceStruct struct {
	Provider    common.Address `abi:"provider"`
	Name        string         `abi:"name"`
	ServiceType string         `abi:"serviceType"`
	URL         string         `abi:"url"`
	Model       string         `abi:"model"`
}
```

### Step 4: Rewrite listFromChain()

Replace the existing `listFromChain()` implementation:

```go
func (b *broker) listFromChain(ctx context.Context) ([]Model, error) {
	var out []interface{}
	err := b.contract.Call(
		&bind.CallOpts{Context: ctx},
		&out,
		"getAllServices",
		big.NewInt(0),   // offset
		big.NewInt(100), // limit
	)
	if err != nil {
		return nil, fmt.Errorf("getAllServices: %w", err)
	}

	if len(out) == 0 {
		return nil, nil
	}

	// The ABI returns (tuple[], uint256). First element is the service slice.
	raw, ok := out[0].([]struct {
		Provider    common.Address
		Name        string
		ServiceType string
		URL         string
		Model       string
	})
	if !ok {
		// go-ethereum may decode as []interface{} depending on ABI binding version;
		// handle both forms.
		return b.decodeServiceSlice(out[0])
	}

	models := make([]Model, 0, len(raw))
	for _, svc := range raw {
		if svc.URL == "" {
			continue
		}
		models = append(models, Model{
			ID:          svc.Model,
			Name:        svc.Name,
			Provider:    svc.Provider.Hex(),
			ServiceType: svc.ServiceType,
			URL:         svc.URL,
		})
	}
	return models, nil
}
```

Note: The exact type assertion on `out[0]` depends on how go-ethereum decodes the anonymous struct. If the type assertion fails, use `abi.Arguments.Unpack` directly or cast via reflection. Add a `decodeServiceSlice` helper if needed. The key requirement is that the code compiles and the live call succeeds — adapt as needed after Step 1 confirms the exact ABI.

### Step 5: Remove the dead import

After removing `getServiceCount` usage, verify `ethereum.CallMsg` sentinel at the bottom of the file is still needed. If not, remove it and the import.

### Step 6: Build and test

```bash
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
just build
go test ./internal/zerog/compute/... -v -count=1
```

## Done When

- [ ] `servingABIJSON` reflects the real contract methods (`getAllServices`, `getService(address)`)
- [ ] `listFromChain()` calls `getAllServices(0, 100)` — no index-based loop
- [ ] `go build ./...` passes with no errors
- [ ] `go test ./internal/zerog/compute/...` passes (update mocks/stubs as needed)
- [ ] No `fmt.Errorf` introduced — wrapping style consistent with existing code
- [ ] Context propagation unchanged throughout
