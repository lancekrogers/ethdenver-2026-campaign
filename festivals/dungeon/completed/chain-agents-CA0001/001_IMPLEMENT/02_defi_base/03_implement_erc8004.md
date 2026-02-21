---
fest_type: task
fest_id: 03_implement_erc8004.md
fest_name: implement_erc8004
fest_parent: 02_defi_base
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement ERC-8004 Identity Registration

## Objective

Implement the `IdentityRegistry` interface to register the DeFi agent's on-chain identity via ERC-8004 on Base. Agent identity registration allows the coordinator and other agents to verify this agent's legitimacy on-chain. The identity persists across agent restarts and serves as the agent's public credential.

**Project:** `agent-defi` at `projects/agent-defi/`
**Package:** `internal/base/identity/`

## Requirements

- [ ] Implement the `IdentityRegistry` interface defined in the architecture task
- [ ] Register agent identity on Base testnet via ERC-8004 contract
- [ ] Verify registered identities on-chain
- [ ] Retrieve full identity records by agent ID
- [ ] Handle all errors with contextual wrapping
- [ ] Pass `context.Context` through all I/O operations

## Implementation

### Step 1: Research ERC-8004

Before writing code, research the ERC-8004 standard:

1. Read the ERC-8004 specification -- understand the identity registration interface
2. Find any deployed ERC-8004 contracts on Base testnet (Base Sepolia)
3. Determine the registration parameters: what data is required to register an agent?
4. Understand the verification mechanism: how do other agents check identity?
5. Find the Base Sepolia RPC endpoint and chain ID (84532)
6. Check if there are existing Go libraries or ABI definitions for ERC-8004

If no ERC-8004 contract is deployed on Base testnet, you may need to deploy one. Document the contract address and deployment process.

Document findings in comments at the top of `register.go`.

### Step 2: Define the model types

In `internal/base/identity/models.go`:

```go
package identity

import "time"

// RegistrationRequest contains the data needed to register an agent identity.
type RegistrationRequest struct {
    // AgentID is the unique identifier for this agent.
    AgentID string

    // AgentType classifies the agent (e.g., "defi", "inference", "coordinator").
    AgentType string

    // PublicKey is the agent's public key for verification.
    PublicKey string

    // Metadata contains optional key-value pairs describing the agent's capabilities.
    Metadata map[string]string

    // OwnerAddress is the Ethereum address that owns this identity.
    OwnerAddress string
}

// Identity represents a registered on-chain agent identity.
type Identity struct {
    // AgentID is the unique identifier.
    AgentID string

    // AgentType classifies the agent.
    AgentType string

    // ContractAddress is the ERC-8004 contract where this identity is registered.
    ContractAddress string

    // OwnerAddress is the Ethereum address that owns this identity.
    OwnerAddress string

    // RegisteredAt is when the identity was registered on-chain.
    RegisteredAt time.Time

    // IsVerified indicates whether the identity has been verified.
    IsVerified bool

    // TxHash is the transaction hash of the registration.
    TxHash string

    // ChainID is the chain where the identity is registered.
    ChainID int64
}
```

### Step 3: Implement the identity registry

In `internal/base/identity/register.go`:

```go
package identity

// RegistryConfig holds configuration for the ERC-8004 identity registry.
type RegistryConfig struct {
    // ChainRPC is the Base chain RPC endpoint (e.g., Base Sepolia).
    ChainRPC string

    // ChainID is the Base chain network identifier (84532 for Base Sepolia).
    ChainID int64

    // ContractAddress is the ERC-8004 contract address on Base.
    ContractAddress string

    // PrivateKey is the agent's private key for signing transactions.
    PrivateKey string
}
```

Key implementation details:

**Register(ctx, req)**:

1. Check `ctx.Err()` before starting
2. Connect to Base via the configured RPC endpoint using go-ethereum
3. Build the ERC-8004 registration transaction:
   - Encode the agent ID, type, public key, and metadata into the contract call
   - Estimate gas
   - Sign the transaction with the agent's private key
4. Submit the transaction to Base
5. Wait for the transaction receipt (with context-aware polling)
6. Parse the registration event from the receipt logs
7. Return the Identity struct populated with on-chain data
8. Wrap errors: `fmt.Errorf("identity: failed to register agent %s: %w", req.AgentID, err)`

**Verify(ctx, agentID)**:

1. Call the contract's verification read method (view function, no gas)
2. Return true if the agent ID is registered and active
3. Wrap errors: `fmt.Errorf("identity: failed to verify agent %s: %w", agentID, err)`

**GetIdentity(ctx, agentID)**:

1. Call the contract's identity retrieval read method
2. Parse the response into an Identity struct
3. Return ErrIdentityNotFound if not registered
4. Wrap errors appropriately

Use `go-ethereum` (`github.com/ethereum/go-ethereum`) for EVM interactions. If an ABI is available, use `abigen` to generate type-safe bindings. Otherwise, use raw contract calls with the function selector and ABI encoding.

### Step 4: Define sentinel errors

```go
var (
    ErrIdentityNotFound  = errors.New("identity: agent identity not found")
    ErrAlreadyRegistered = errors.New("identity: agent already registered")
    ErrRegistrationFailed = errors.New("identity: registration transaction failed")
    ErrChainUnreachable  = errors.New("identity: Base chain RPC unreachable")
    ErrInsufficientFunds = errors.New("identity: insufficient funds for gas")
)
```

### Step 5: Write unit tests

Create `internal/base/identity/register_test.go`:

1. **TestRegister_Success**: Mock successful registration transaction, verify Identity returned
2. **TestRegister_AlreadyRegistered**: Mock duplicate registration, verify ErrAlreadyRegistered
3. **TestRegister_InsufficientFunds**: Mock gas estimation failure, verify ErrInsufficientFunds
4. **TestRegister_ContextCancelled**: Cancel during transaction wait, verify clean exit
5. **TestVerify_Registered**: Mock registered identity, verify returns true
6. **TestVerify_NotRegistered**: Mock unregistered agent, verify returns false
7. **TestGetIdentity_Success**: Mock identity retrieval, verify all fields populated
8. **TestGetIdentity_NotFound**: Mock missing identity, verify ErrIdentityNotFound

Use a mock EVM client or simulated backend from go-ethereum for testing.

### Step 6: Verify compilation and tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go build ./internal/base/identity/...
go test ./internal/base/identity/... -v
go vet ./internal/base/identity/...
```

## Done When

- [ ] `IdentityRegistry` interface fully implemented in `internal/base/identity/register.go`
- [ ] All model types defined in `internal/base/identity/models.go`
- [ ] Agent can register identity on Base Sepolia testnet
- [ ] Identity verification and retrieval work for registered agents
- [ ] Sentinel errors defined for all failure modes
- [ ] Table-driven unit tests cover registration, verification, retrieval, and error cases
- [ ] `go build`, `go test`, and `go vet` all pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
- [ ] ERC-8004 research findings documented in code comments
