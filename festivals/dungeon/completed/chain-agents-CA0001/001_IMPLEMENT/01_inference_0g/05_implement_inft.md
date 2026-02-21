---
fest_type: task
fest_id: 05_implement_inft.md
fest_name: implement_inft
fest_parent: 01_inference_0g
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement ERC-7857 iNFT Minting

## Objective

Implement the `INFTMinter` interface to mint ERC-7857 iNFTs (intelligent NFTs) with encrypted metadata on 0G Chain. Each inference result is minted as an iNFT, creating a verifiable on-chain record of the agent's work with privacy-preserving encrypted metadata. This is the primary deliverable for the 0G Track 3 bounty ($7k, ERC-7857 iNFT).

**Project:** `agent-inference` at `projects/agent-inference/`
**Package:** `internal/zerog/inft/`

## Requirements

- [ ] Implement the `INFTMinter` interface defined in the architecture task
- [ ] Mint ERC-7857 iNFTs on 0G Chain testnet
- [ ] Encrypt metadata before attaching to the iNFT
- [ ] Support updating encrypted metadata on existing iNFTs
- [ ] Support querying the status of minted iNFTs
- [ ] Handle all errors with contextual wrapping
- [ ] Pass `context.Context` through all I/O operations

## Implementation

### Step 1: Research ERC-7857 and 0G Chain

Before writing code, research the ERC-7857 standard and 0G Chain:

1. Read the ERC-7857 specification -- understand the iNFT interface, encrypted metadata format, and minting requirements
2. Find the 0G Chain testnet RPC endpoint and chain ID
3. Determine if there is an existing ERC-7857 factory contract deployed on 0G Chain testnet, or if you need to deploy one
4. Identify what encryption scheme ERC-7857 requires for metadata (likely AES-256-GCM or similar)
5. Check if 0G provides helper libraries for iNFT operations

Document findings in comments at the top of `minter.go`.

### Step 2: Define the model types

In `internal/zerog/inft/models.go`:

```go
package inft

import "time"

// MintRequest contains the parameters for minting a new iNFT.
type MintRequest struct {
    // Name is the human-readable name for this iNFT.
    Name string

    // Description describes what this iNFT represents.
    Description string

    // InferenceJobID links this iNFT to the inference job that produced it.
    InferenceJobID string

    // ResultHash is the hash of the inference result for integrity verification.
    ResultHash string

    // PlaintextMeta is the metadata to encrypt before attaching to the iNFT.
    PlaintextMeta map[string]string

    // StorageContentID is the 0G Storage content ID where the full result is stored.
    StorageContentID string
}

// EncryptedMeta holds encrypted metadata for an iNFT.
type EncryptedMeta struct {
    // Ciphertext is the encrypted metadata bytes.
    Ciphertext []byte

    // Nonce is the encryption nonce used.
    Nonce []byte

    // KeyID identifies which encryption key was used (for key rotation).
    KeyID string

    // Algorithm identifies the encryption algorithm (e.g., "AES-256-GCM").
    Algorithm string
}

// INFTStatus represents the current state of a minted iNFT.
type INFTStatus struct {
    // TokenID is the on-chain token identifier.
    TokenID string

    // Owner is the current owner address.
    Owner string

    // MintedAt is when the iNFT was minted.
    MintedAt time.Time

    // MetadataHash is the hash of the current encrypted metadata.
    MetadataHash string

    // ChainID identifies which chain the iNFT is on.
    ChainID int64

    // ContractAddress is the iNFT contract address.
    ContractAddress string
}
```

### Step 3: Implement metadata encryption

Create a helper for encrypting metadata before minting. This should be in a separate file to keep functions small:

In `internal/zerog/inft/encrypt.go`:

```go
package inft

import (
    "crypto/aes"
    "crypto/cipher"
    "crypto/rand"
    "encoding/json"
    "io"
)

// encryptMetadata encrypts the plaintext metadata map using AES-256-GCM.
func encryptMetadata(key []byte, meta map[string]string) (*EncryptedMeta, error) {
    // 1. Serialize metadata to JSON
    plaintext, err := json.Marshal(meta)
    // 2. Create AES cipher block from key
    block, err := aes.NewCipher(key)
    // 3. Create GCM wrapper
    gcm, err := cipher.NewGCM(block)
    // 4. Generate random nonce
    nonce := make([]byte, gcm.NonceSize())
    io.ReadFull(rand.Reader, nonce)
    // 5. Encrypt and seal
    ciphertext := gcm.Seal(nil, nonce, plaintext, nil)
    // 6. Return EncryptedMeta with algorithm identifier
}
```

### Step 4: Implement the minter

In `internal/zerog/inft/minter.go`:

```go
package inft

// MinterConfig holds configuration for the iNFT minter.
type MinterConfig struct {
    // ChainRPC is the 0G Chain RPC endpoint.
    ChainRPC string

    // ChainID is the 0G Chain network identifier.
    ChainID int64

    // ContractAddress is the ERC-7857 contract address on 0G Chain.
    ContractAddress string

    // PrivateKey is the agent's private key for signing transactions.
    PrivateKey string

    // EncryptionKey is the AES-256 key for metadata encryption (32 bytes).
    EncryptionKey []byte
}
```

Key implementation details:

**Mint(ctx, req)**:

1. Check `ctx.Err()` before starting
2. Encrypt the plaintext metadata using `encryptMetadata`
3. Build the ERC-7857 mint transaction:
   - Encode the encrypted metadata into the contract call
   - Include the result hash and storage content ID in the token URI or metadata
4. Sign and submit the transaction to 0G Chain
5. Wait for transaction receipt (with context-aware polling)
6. Extract the token ID from the mint event logs
7. Return the token ID
8. Wrap all errors: `fmt.Errorf("inft: failed to mint iNFT for job %s: %w", req.InferenceJobID, err)`

**UpdateMetadata(ctx, tokenID, meta)**:

1. Build the update transaction with the new encrypted metadata
2. Sign and submit to 0G Chain
3. Wait for confirmation
4. Wrap errors: `fmt.Errorf("inft: failed to update metadata for token %s: %w", tokenID, err)`

**GetStatus(ctx, tokenID)**:

1. Call the contract's read methods (ownerOf, tokenURI, etc.)
2. Parse the response into INFTStatus
3. Wrap errors: `fmt.Errorf("inft: failed to get status for token %s: %w", tokenID, err)`

You will likely need an Ethereum client library for 0G Chain interactions. Use `go-ethereum` (`github.com/ethereum/go-ethereum`) since 0G Chain is EVM-compatible. Generate contract bindings using `abigen` if an ABI is available, or use raw contract calls.

### Step 5: Define sentinel errors

```go
var (
    ErrMintFailed      = errors.New("inft: minting transaction failed")
    ErrTokenNotFound   = errors.New("inft: token not found")
    ErrEncryptionFailed = errors.New("inft: metadata encryption failed")
    ErrChainUnreachable = errors.New("inft: 0G Chain RPC unreachable")
    ErrInsufficientGas  = errors.New("inft: insufficient gas for transaction")
)
```

### Step 6: Write unit tests

Create `internal/zerog/inft/minter_test.go` and `internal/zerog/inft/encrypt_test.go`:

**Encryption tests:**

1. **TestEncryptMetadata_Success**: Encrypt and decrypt, verify roundtrip
2. **TestEncryptMetadata_EmptyMap**: Handle empty metadata gracefully
3. **TestEncryptMetadata_InvalidKey**: Wrong key size, verify error

**Minter tests (use mock chain client):**

1. **TestMint_Success**: Mock successful mint transaction, verify token ID
2. **TestMint_ChainUnreachable**: Mock RPC failure, verify ErrChainUnreachable
3. **TestMint_InsufficientGas**: Mock gas estimation failure, verify error
4. **TestMint_ContextCancelled**: Cancel during transaction wait, verify clean exit
5. **TestUpdateMetadata_Success**: Mock successful update, verify no error
6. **TestGetStatus_Success**: Mock contract reads, verify INFTStatus populated
7. **TestGetStatus_TokenNotFound**: Mock missing token, verify ErrTokenNotFound

### Step 7: Verify compilation and tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go build ./internal/zerog/inft/...
go test ./internal/zerog/inft/... -v
go vet ./internal/zerog/inft/...
```

## Done When

- [ ] `INFTMinter` interface fully implemented in `internal/zerog/inft/minter.go`
- [ ] Metadata encryption implemented in `internal/zerog/inft/encrypt.go`
- [ ] All model types defined in `internal/zerog/inft/models.go`
- [ ] Encryption uses AES-256-GCM with random nonces
- [ ] EVM transaction signing and submission works against 0G Chain testnet
- [ ] Sentinel errors defined for all failure modes
- [ ] Table-driven unit tests cover minting, encryption, update, status, and error cases
- [ ] `go build`, `go test`, and `go vet` all pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
- [ ] ERC-7857 research findings documented in code comments
