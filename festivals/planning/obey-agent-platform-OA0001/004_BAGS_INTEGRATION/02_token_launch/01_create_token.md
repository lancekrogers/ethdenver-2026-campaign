---
fest_type: task
fest_id: 01_create_token.md
fest_name: create_token
fest_parent: 02_token_launch
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.492609-06:00
fest_tracking: true
---

# Task: Create OBEY Token via Bags API

## Objective

Implement the OBEY token creation workflow in `projects/agent-bags/internal/token/token.go` that creates the token on Bags with metadata, image, and social links.

## Requirements

- [ ] `TokenManager` struct that orchestrates the full token creation lifecycle
- [ ] Token metadata: Name="OBEY Agent Economy", Symbol="OBEY", description explaining the platform
- [ ] Image upload: 512x512 PNG logo (stored at `assets/obey-logo.png` in the project)
- [ ] Social links: Twitter, Telegram, Website URLs from config
- [ ] Persist the returned mint address to config/environment for subsequent steps
- [ ] Idempotency: if token already exists (mint address in config), skip creation and return existing
- [ ] Error handling for API failures with retry logic (max 3 retries with exponential backoff)

## Implementation

### Step 1: Define TokenManager

In `projects/agent-bags/internal/token/token.go`:

```go
package token

import (
    "context"
    "fmt"
    "time"

    "github.com/lancekrogers/agent-bags/internal/bags"
)

// TokenConfig holds OBEY token parameters.
type TokenConfig struct {
    Name        string
    Symbol      string
    Description string
    ImagePath   string // path to 512x512 PNG
    Twitter     string
    Telegram    string
    Website     string
}

// DefaultTokenConfig returns the standard OBEY token configuration.
func DefaultTokenConfig() TokenConfig {
    return TokenConfig{
        Name:   "OBEY Agent Economy",
        Symbol: "OBEY",
        Description: "AI agents autonomously trade prediction markets across Polymarket, Limitless, and Drift. " +
            "Users fund agents through smart contract custody on Solana. " +
            "OBEY token holders share in platform revenue via Bags fee distribution. " +
            "1% creator fee on all OBEY trading volume is split: 40% treasury, 30% agent performance pool, " +
            "20% community/holders, 10% creator.",
        ImagePath: "assets/obey-logo.png",
        Twitter:   "https://twitter.com/obeyplatform",
        Website:   "https://obeyplatform.xyz",
    }
}

// Manager handles OBEY token lifecycle operations.
type Manager struct {
    client    *bags.Client
    signer    *bags.Signer
    config    TokenConfig
    mintAddr  string // populated after creation or loaded from env
}

// NewManager creates a new token manager.
func NewManager(client *bags.Client, signer *bags.Signer, config TokenConfig) *Manager {
    return &Manager{
        client: client,
        signer: signer,
        config: config,
    }
}

// SetMintAddress sets the mint address for an already-created token.
// Use this when loading from env/config on startup.
func (m *Manager) SetMintAddress(mint string) {
    m.mintAddr = mint
}

// MintAddress returns the OBEY token mint address.
func (m *Manager) MintAddress() string {
    return m.mintAddr
}
```

### Step 2: Implement token creation with retry logic

```go
// CreateToken creates the OBEY token on Bags.
// If mintAddr is already set, this is a no-op and returns the existing address.
// On success, stores the mint address internally.
func (m *Manager) CreateToken(ctx context.Context) (string, error) {
    if err := ctx.Err(); err != nil {
        return "", err
    }

    // Idempotency: skip if already created
    if m.mintAddr != "" {
        return m.mintAddr, nil
    }

    req := bags.CreateTokenRequest{
        Name:        m.config.Name,
        Symbol:      m.config.Symbol,
        Description: m.config.Description,
        ImagePath:   m.config.ImagePath,
        Twitter:     m.config.Twitter,
        Telegram:    m.config.Telegram,
        Website:     m.config.Website,
    }

    var result *bags.CreateTokenResponse
    var lastErr error

    // Retry with exponential backoff: 1s, 2s, 4s
    for attempt := 0; attempt < 3; attempt++ {
        if attempt > 0 {
            backoff := time.Duration(1<<uint(attempt-1)) * time.Second
            select {
            case <-ctx.Done():
                return "", ctx.Err()
            case <-time.After(backoff):
            }
        }

        result, lastErr = m.client.CreateToken(ctx, req)
        if lastErr == nil {
            break
        }

        // Don't retry on client errors (4xx)
        if apiErr, ok := lastErr.(*bags.APIError); ok && apiErr.StatusCode < 500 {
            return "", fmt.Errorf("creating OBEY token (non-retryable): %w", lastErr)
        }
    }
    if lastErr != nil {
        return "", fmt.Errorf("creating OBEY token after 3 attempts: %w", lastErr)
    }

    m.mintAddr = result.Mint
    return result.Mint, nil
}
```

### Step 3: Wire into main.go

Update `projects/agent-bags/cmd/agent-bags/main.go` to load config and call `CreateToken` on startup:

```go
func run(ctx context.Context) error {
    cfg := loadConfig() // from env vars

    client := bags.New(bags.Config{
        BaseURL: cfg.BagsAPIURL,
        APIKey:  cfg.BagsAPIKey,
        JWT:     cfg.BagsJWT,
    })

    signer, err := bags.NewSigner(cfg.SolanaPrivateKey)
    if err != nil {
        return fmt.Errorf("creating signer: %w", err)
    }

    tokenMgr := token.NewManager(client, signer, token.DefaultTokenConfig())

    // If mint already known, skip creation
    if cfg.OBEYTokenMint != "" {
        tokenMgr.SetMintAddress(cfg.OBEYTokenMint)
    }

    mint, err := tokenMgr.CreateToken(ctx)
    if err != nil {
        return fmt.Errorf("creating OBEY token: %w", err)
    }
    fmt.Printf("OBEY token mint: %s\n", mint)

    // ... continue to fee configuration, launch, etc.
    <-ctx.Done()
    return nil
}
```

### Step 4: Create the logo asset

Create directory `projects/agent-bags/assets/` and add a placeholder `obey-logo.png` (512x512). The actual logo should be the OBEY platform branding. For development, generate a simple placeholder.

### Step 5: Write tests

Create `projects/agent-bags/internal/token/token_test.go`:

1. `TestCreateTokenSuccess` — mock Bags API, verify correct multipart fields, returns mint
2. `TestCreateTokenIdempotent` — set mint first, verify no API call made
3. `TestCreateTokenRetry` — first call returns 500, second succeeds, verify retry worked
4. `TestCreateTokenNonRetryable` — 400 error, verify no retry attempted
5. `TestCreateTokenContextCancelled` — cancel context during backoff, verify early exit

## Done When

- [ ] All requirements met
- [ ] `TokenManager.CreateToken` successfully calls `POST /tokens/create` with all metadata fields
- [ ] Returned mint address is stored and retrievable via `MintAddress()`
- [ ] Idempotency works: calling CreateToken when mint is already set returns existing mint
- [ ] Retry logic handles transient 5xx errors with exponential backoff
- [ ] `go test ./internal/token/...` passes with all creation tests green
