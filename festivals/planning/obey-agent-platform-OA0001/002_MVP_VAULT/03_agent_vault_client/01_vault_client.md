---
fest_type: task
fest_id: 01_vault_client.md
fest_name: vault_client
fest_parent: 03_agent_vault_client
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.395802-06:00
fest_tracking: true
---

# Task: Go Vault Client for Agent Integration

## Objective

Build a Go client that the OBEY Predictor agent uses to interact with the on-chain MVP vault program — reading vault state, submitting NAV updates, and monitoring deposit/withdrawal events.

## Requirements

- [ ] Go package `vaultclient` under the agent-defi project or a shared `pkg/` directory
- [ ] Read vault state (total_shares, total_nav, paused, etc.) from on-chain account
- [ ] Submit `update_nav` transactions signed by admin keypair
- [ ] Derive all PDAs (vault_state, share_mint, vault_usdc_ata) deterministically
- [ ] Subscribe to vault events (deposits, withdrawals, NAV updates) via WebSocket
- [ ] Context propagation and proper error handling per CLAUDE.md standards
- [ ] Configuration loaded from environment or config file (RPC URL, program ID, admin keypair path)

## Implementation

### Step 1: Package structure

Create the package at the appropriate location in the project:

```
pkg/vaultclient/
  client.go       — main client struct, constructor, config
  state.go        — account deserialization, PDA derivation
  transactions.go — update_nav, pause, unpause transaction builders
  events.go       — event subscription and parsing
  errors.go       — error types
```

### Step 2: Client struct and configuration

File: `pkg/vaultclient/client.go`

```go
package vaultclient

import (
    "context"
    "fmt"

    "github.com/gagliardetto/solana-go"
    "github.com/gagliardetto/solana-go/rpc"
    "github.com/gagliardetto/solana-go/rpc/ws"
)

// Config holds vault client configuration
type Config struct {
    // Solana RPC endpoint (e.g., https://api.devnet.solana.com)
    RPCURL string
    // WebSocket endpoint for subscriptions
    WSURL string
    // The deployed obey_mvp_vault program ID
    ProgramID solana.PublicKey
    // Admin keypair for signing NAV updates
    AdminKey solana.PrivateKey
    // USDC mint on the target cluster
    USDCMint solana.PublicKey
}

// Client interacts with the on-chain MVP vault program
type Client struct {
    cfg       Config
    rpc       *rpc.Client
    ws        *ws.Client
    vaultPDA  solana.PublicKey
    vaultBump uint8
}

// New creates a vault client. Derives PDAs from the admin key and program ID.
func New(ctx context.Context, cfg Config) (*Client, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("context cancelled before client creation: %w", err)
    }

    rpcClient := rpc.New(cfg.RPCURL)

    // Derive vault PDA: seeds = ["vault", admin_pubkey]
    vaultPDA, vaultBump, err := solana.FindProgramAddress(
        [][]byte{
            []byte("vault"),
            cfg.AdminKey.PublicKey().Bytes(),
        },
        cfg.ProgramID,
    )
    if err != nil {
        return nil, fmt.Errorf("deriving vault PDA: %w", err)
    }

    return &Client{
        cfg:       cfg,
        rpc:       rpcClient,
        vaultPDA:  vaultPDA,
        vaultBump: vaultBump,
    }, nil
}

// VaultPDA returns the derived vault state PDA address
func (c *Client) VaultPDA() solana.PublicKey {
    return c.vaultPDA
}

// ShareMintPDA derives the share mint PDA from the vault PDA
func (c *Client) ShareMintPDA() (solana.PublicKey, uint8, error) {
    return solana.FindProgramAddress(
        [][]byte{
            []byte("share_mint"),
            c.vaultPDA.Bytes(),
        },
        c.cfg.ProgramID,
    )
}
```

### Step 3: On-chain state deserialization

File: `pkg/vaultclient/state.go`

```go
package vaultclient

import (
    "context"
    "encoding/binary"
    "fmt"

    "github.com/gagliardetto/solana-go"
    "github.com/gagliardetto/solana-go/rpc"
)

// VaultState mirrors the on-chain VaultState account
type VaultState struct {
    Admin              solana.PublicKey
    AgentWallet        solana.PublicKey
    ShareMint          solana.PublicKey
    VaultUsdcATA       solana.PublicKey
    UsdcMint           solana.PublicKey
    TotalShares        uint64
    TotalNav           uint64
    NavLastUpdated     int64
    AllTimeHighNav     uint64
    WithdrawalDelay    int64
    Paused             bool
    Bump               uint8
    ShareMintBump      uint8
    VaultUsdcBump      uint8
}

// SharePrice returns the current price per share in USDC base units.
// Returns 1_000_000 (1.0 USDC) if no shares exist.
func (v *VaultState) SharePrice() uint64 {
    if v.TotalShares == 0 {
        return 1_000_000 // 1:1 bootstrap price
    }
    // price = total_nav * 1_000_000 / total_shares (6 decimal precision)
    return v.TotalNav * 1_000_000 / v.TotalShares
}

// FetchVaultState reads and deserializes the vault state from chain
func (c *Client) FetchVaultState(ctx context.Context) (*VaultState, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("context cancelled: %w", err)
    }

    acct, err := c.rpc.GetAccountInfo(ctx, c.vaultPDA)
    if err != nil {
        return nil, fmt.Errorf("fetching vault account %s: %w", c.vaultPDA, err)
    }
    if acct == nil || acct.Value == nil {
        return nil, fmt.Errorf("vault account %s not found", c.vaultPDA)
    }

    data := acct.Value.Data.GetBinary()
    if len(data) < 8 {
        return nil, fmt.Errorf("account data too short: %d bytes", len(data))
    }

    // Skip 8-byte Anchor discriminator
    d := data[8:]

    state := &VaultState{}
    offset := 0

    // Deserialize in field order matching the Rust struct
    copy(state.Admin[:], d[offset:offset+32]); offset += 32
    copy(state.AgentWallet[:], d[offset:offset+32]); offset += 32
    copy(state.ShareMint[:], d[offset:offset+32]); offset += 32
    copy(state.VaultUsdcATA[:], d[offset:offset+32]); offset += 32
    copy(state.UsdcMint[:], d[offset:offset+32]); offset += 32

    state.TotalShares = binary.LittleEndian.Uint64(d[offset:]); offset += 8
    state.TotalNav = binary.LittleEndian.Uint64(d[offset:]); offset += 8
    state.NavLastUpdated = int64(binary.LittleEndian.Uint64(d[offset:])); offset += 8
    state.AllTimeHighNav = binary.LittleEndian.Uint64(d[offset:]); offset += 8
    state.WithdrawalDelay = int64(binary.LittleEndian.Uint64(d[offset:])); offset += 8

    state.Paused = d[offset] != 0; offset += 1
    state.Bump = d[offset]; offset += 1
    state.ShareMintBump = d[offset]; offset += 1
    state.VaultUsdcBump = d[offset]; offset += 1

    return state, nil
}

// FetchVaultUSDCBalance returns the USDC balance in the vault's token account
func (c *Client) FetchVaultUSDCBalance(ctx context.Context, vaultUsdcATA solana.PublicKey) (uint64, error) {
    if err := ctx.Err(); err != nil {
        return 0, fmt.Errorf("context cancelled: %w", err)
    }

    result, err := c.rpc.GetTokenAccountBalance(ctx, vaultUsdcATA, rpc.CommitmentFinalized)
    if err != nil {
        return 0, fmt.Errorf("fetching vault USDC balance: %w", err)
    }

    amount := result.Value.Amount
    var bal uint64
    fmt.Sscanf(amount, "%d", &bal)
    return bal, nil
}
```

### Step 4: Transaction builders

File: `pkg/vaultclient/transactions.go`

```go
package vaultclient

import (
    "context"
    "crypto/sha256"
    "encoding/binary"
    "fmt"

    "github.com/gagliardetto/solana-go"
    "github.com/gagliardetto/solana-go/rpc"
)

// anchorDiscriminator returns the 8-byte discriminator for an Anchor instruction
func anchorDiscriminator(namespace, name string) [8]byte {
    h := sha256.Sum256([]byte(fmt.Sprintf("%s:%s", namespace, name)))
    var disc [8]byte
    copy(disc[:], h[:8])
    return disc
}

// UpdateNAV submits an update_nav transaction to set the vault's NAV
func (c *Client) UpdateNAV(ctx context.Context, newNav uint64) (solana.Signature, error) {
    if err := ctx.Err(); err != nil {
        return solana.Signature{}, fmt.Errorf("context cancelled: %w", err)
    }

    // Build instruction data: discriminator + new_nav (u64 LE)
    disc := anchorDiscriminator("global", "update_nav")
    data := make([]byte, 16) // 8 disc + 8 u64
    copy(data[:8], disc[:])
    binary.LittleEndian.PutUint64(data[8:], newNav)

    ix := solana.NewInstruction(
        c.cfg.ProgramID,
        solana.AccountMetaSlice{
            solana.Meta(c.cfg.AdminKey.PublicKey()).SIGNER().WRITE(),
            solana.Meta(c.vaultPDA).WRITE(),
        },
        data,
    )

    // Build and send transaction
    recent, err := c.rpc.GetLatestBlockhash(ctx, rpc.CommitmentFinalized)
    if err != nil {
        return solana.Signature{}, fmt.Errorf("getting blockhash: %w", err)
    }

    tx, err := solana.NewTransaction(
        []solana.Instruction{ix},
        recent.Value.Blockhash,
        solana.TransactionPayer(c.cfg.AdminKey.PublicKey()),
    )
    if err != nil {
        return solana.Signature{}, fmt.Errorf("building transaction: %w", err)
    }

    _, err = tx.Sign(func(key solana.PublicKey) *solana.PrivateKey {
        if key.Equals(c.cfg.AdminKey.PublicKey()) {
            return &c.cfg.AdminKey
        }
        return nil
    })
    if err != nil {
        return solana.Signature{}, fmt.Errorf("signing transaction: %w", err)
    }

    sig, err := c.rpc.SendTransactionWithOpts(ctx, tx,
        rpc.TransactionOpts{SkipPreflight: false},
    )
    if err != nil {
        return solana.Signature{}, fmt.Errorf("sending update_nav tx: %w", err)
    }

    return sig, nil
}

// Pause submits a pause transaction
func (c *Client) Pause(ctx context.Context) (solana.Signature, error) {
    // Similar pattern to UpdateNAV but with pause discriminator and no extra data
    // disc = anchorDiscriminator("global", "pause")
    // Same accounts: admin (signer) + vault_state (mut)
    // ...
}

// Unpause submits an unpause transaction
func (c *Client) Unpause(ctx context.Context) (solana.Signature, error) {
    // Same pattern as Pause with unpause discriminator
    // ...
}
```

### Step 5: Configuration loading

Add a constructor that loads from environment:

```go
// NewFromEnv creates a Client from environment variables:
//   SOLANA_RPC_URL, SOLANA_WS_URL, VAULT_PROGRAM_ID,
//   ADMIN_KEYPAIR_PATH, USDC_MINT
func NewFromEnv(ctx context.Context) (*Client, error) {
    rpcURL := os.Getenv("SOLANA_RPC_URL")
    if rpcURL == "" {
        rpcURL = "https://api.devnet.solana.com"
    }

    programID, err := solana.PublicKeyFromBase58(os.Getenv("VAULT_PROGRAM_ID"))
    if err != nil {
        return nil, fmt.Errorf("parsing VAULT_PROGRAM_ID: %w", err)
    }

    keypairPath := os.Getenv("ADMIN_KEYPAIR_PATH")
    if keypairPath == "" {
        keypairPath = filepath.Join(os.Getenv("HOME"), ".config/solana/id.json")
    }
    adminKey, err := solana.PrivateKeyFromSolanaKeygenFile(keypairPath)
    if err != nil {
        return nil, fmt.Errorf("loading admin keypair from %s: %w", keypairPath, err)
    }

    usdcMint, err := solana.PublicKeyFromBase58(os.Getenv("USDC_MINT"))
    if err != nil {
        return nil, fmt.Errorf("parsing USDC_MINT: %w", err)
    }

    return New(ctx, Config{
        RPCURL:    rpcURL,
        WSURL:     os.Getenv("SOLANA_WS_URL"),
        ProgramID: programID,
        AdminKey:  adminKey,
        USDCMint:  usdcMint,
    })
}
```

## Done When

- [ ] All requirements met
- [ ] `vaultclient.New()` derives correct PDAs matching the Anchor program
- [ ] `FetchVaultState()` correctly deserializes on-chain vault state
- [ ] `UpdateNAV()` sends a valid transaction that the on-chain program accepts
- [ ] `SharePrice()` returns correct share pricing math
- [ ] All functions accept `context.Context` as first parameter
- [ ] All errors are wrapped with contextual information
- [ ] Unit tests pass for PDA derivation and state deserialization
- [ ] Integration test against devnet vault succeeds (read state, update NAV)
