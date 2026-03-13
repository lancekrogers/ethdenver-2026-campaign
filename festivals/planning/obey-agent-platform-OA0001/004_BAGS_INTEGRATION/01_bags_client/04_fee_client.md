---
fest_type: task
fest_id: 04_fee_client.md
fest_name: fee_client
fest_parent: 01_bags_client
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.473819-06:00
fest_tracking: true
---

# Task: Fee Sharing & Claiming Client

## Objective

Implement Bags API methods for fee share configuration, fee claiming, partner management, and claim statistics in `projects/agent-bags/internal/bags/client.go`.

## Requirements

- [ ] `ConfigureFeeShare` method: `POST /fee-share/config` to set fee claimers with basis point allocations
- [ ] `CreatePartner` method: `POST /fee-share/partner` to create a partner fee config for a wallet
- [ ] `UpdateFeeShareConfig` method: `PUT /fee-share/admin/config` to update claimers/allocations
- [ ] `ListFeeShareTokens` method: `GET /fee-share/admin/list` to list tokens where wallet is admin
- [ ] `GetClaimablePositions` method: `GET /claim/positions` to fetch claimable fee positions
- [ ] `GetClaimTransactionsV3` method: `GET /claim/transactions/v3` to auto-generate claim transactions
- [ ] `GetPartnerClaimTx` method: `GET /claim/partner` to get partner fee claim transactions
- [ ] `GetClaimHistory` method: `GET /claim/events` to fetch claim event history
- [ ] `GetClaimStats` method: `GET /claim/stats` to get total claimed per user
- [ ] `GetLifetimeFees` method: `GET /claim/lifetime-fees` to get total fees collected for a token
- [ ] `ResolveFeeWallet` method: `GET /fee-share/wallet` to map social/username to wallet address

## Implementation

### Step 1: Define fee types

Add to `projects/agent-bags/internal/bags/types.go`:

```go
// FeeClaimer represents a single fee share recipient.
type FeeClaimer struct {
    Wallet     string `json:"wallet"`
    ShareBps   uint16 `json:"shareBps"`   // basis points (e.g. 4000 = 40%)
    Label      string `json:"label,omitempty"`
}

// FeeShareConfig is the request body for POST /fee-share/config.
type FeeShareConfig struct {
    Mint     string       `json:"mint"`
    Claimers []FeeClaimer `json:"claimers"` // max 100 claimers
}

// FeeShareToken represents a token where the wallet is the fee admin.
type FeeShareToken struct {
    Mint     string       `json:"mint"`
    Name     string       `json:"name"`
    Symbol   string       `json:"symbol"`
    Claimers []FeeClaimer `json:"claimers"`
}

// ClaimablePosition represents a single claimable fee position.
type ClaimablePosition struct {
    Mint          string  `json:"mint"`
    PoolType      string  `json:"poolType"` // "virtual" (DBC) or "damm_v2"
    ClaimableSOL  float64 `json:"claimableSOL"`
    ClaimableUSDC float64 `json:"claimableUSDC"`
}

// ClaimTransaction is a pre-built claim transaction.
type ClaimTransaction struct {
    Transaction string `json:"transaction"` // base64 serialized tx
    Mint        string `json:"mint"`
    PoolType    string `json:"poolType"`
    EstimatedSOL  float64 `json:"estimatedSOL"`
    EstimatedUSDC float64 `json:"estimatedUSDC"`
}

// ClaimEvent represents a historical claim.
type ClaimEvent struct {
    Signature string  `json:"signature"`
    Mint      string  `json:"mint"`
    AmountSOL float64 `json:"amountSOL"`
    AmountUSDC float64 `json:"amountUSDC"`
    Timestamp string  `json:"timestamp"`
}

// ClaimStats holds aggregated claim statistics.
type ClaimStats struct {
    TotalClaimedSOL  float64 `json:"totalClaimedSOL"`
    TotalClaimedUSDC float64 `json:"totalClaimedUSDC"`
    ClaimCount       int     `json:"claimCount"`
}

// LifetimeFees holds total fee metrics for a token.
type LifetimeFees struct {
    Mint             string  `json:"mint"`
    TotalFeesSOL     float64 `json:"totalFeesSOL"`
    TotalFeesUSDC    float64 `json:"totalFeesUSDC"`
    TotalVolume      float64 `json:"totalVolume"`
    TotalTransactions int    `json:"totalTransactions"`
}

// PartnerConfig is the request for POST /fee-share/partner.
type PartnerConfig struct {
    Mint   string `json:"mint"`
    Wallet string `json:"wallet"`
}
```

### Step 2: Implement fee share configuration methods

Add to `projects/agent-bags/internal/bags/client.go`:

```go
// ConfigureFeeShare sets the fee sharing configuration for a token.
// Claimers share basis points must sum to 10000 (100%).
// Maximum 100 claimers. If >15 claimers, lookup tables are required (Bags provides public LUTs).
func (c *Client) ConfigureFeeShare(ctx context.Context, config FeeShareConfig) error {
    body, err := json.Marshal(config)
    if err != nil {
        return fmt.Errorf("marshaling fee share config: %w", err)
    }
    resp, err := c.do(ctx, http.MethodPost, "/fee-share/config", bytes.NewReader(body))
    if err != nil {
        return fmt.Errorf("configure fee share: %w", err)
    }
    resp.Body.Close()
    return nil
}

// CreatePartner creates a partner fee configuration for a wallet.
// Only one partner config per wallet is allowed.
func (c *Client) CreatePartner(ctx context.Context, config PartnerConfig) error {
    body, err := json.Marshal(config)
    if err != nil {
        return fmt.Errorf("marshaling partner config: %w", err)
    }
    resp, err := c.do(ctx, http.MethodPost, "/fee-share/partner", bytes.NewReader(body))
    if err != nil {
        return fmt.Errorf("create partner: %w", err)
    }
    resp.Body.Close()
    return nil
}

// UpdateFeeShareConfig updates the fee claimers and allocations for a token.
// Caller must be the fee share admin for the token.
func (c *Client) UpdateFeeShareConfig(ctx context.Context, config FeeShareConfig) error {
    body, err := json.Marshal(config)
    if err != nil {
        return fmt.Errorf("marshaling fee share update: %w", err)
    }
    resp, err := c.do(ctx, http.MethodPut, "/fee-share/admin/config", bytes.NewReader(body))
    if err != nil {
        return fmt.Errorf("update fee share config: %w", err)
    }
    resp.Body.Close()
    return nil
}

// ListFeeShareTokens returns tokens where the authenticated wallet is the fee admin.
func (c *Client) ListFeeShareTokens(ctx context.Context) ([]FeeShareToken, error) {
    resp, err := c.do(ctx, http.MethodGet, "/fee-share/admin/list", nil)
    if err != nil {
        return nil, fmt.Errorf("list fee share tokens: %w", err)
    }
    var tokens []FeeShareToken
    if err := decodeResponse(resp, &tokens); err != nil {
        return nil, fmt.Errorf("list fee share tokens decode: %w", err)
    }
    return tokens, nil
}

// ResolveFeeWallet maps a social handle or username to a wallet address.
func (c *Client) ResolveFeeWallet(ctx context.Context, username string) (string, error) {
    resp, err := c.do(ctx, http.MethodGet, "/fee-share/wallet?username="+username, nil)
    if err != nil {
        return "", fmt.Errorf("resolve fee wallet: %w", err)
    }
    var result struct {
        Wallet string `json:"wallet"`
    }
    if err := decodeResponse(resp, &result); err != nil {
        return "", fmt.Errorf("resolve fee wallet decode: %w", err)
    }
    return result.Wallet, nil
}
```

### Step 3: Implement fee claiming methods

```go
// GetClaimablePositions returns all claimable fee positions for the authenticated wallet.
// Includes both virtual pool (DBC bonding curve) and DAMM v2 positions.
func (c *Client) GetClaimablePositions(ctx context.Context) ([]ClaimablePosition, error) {
    resp, err := c.do(ctx, http.MethodGet, "/claim/positions", nil)
    if err != nil {
        return nil, fmt.Errorf("get claimable positions: %w", err)
    }
    var positions []ClaimablePosition
    if err := decodeResponse(resp, &positions); err != nil {
        return nil, fmt.Errorf("get claimable positions decode: %w", err)
    }
    return positions, nil
}

// GetClaimTransactionsV3 auto-generates claim transactions for all claimable positions.
// Returns pre-built transactions that need to be signed and submitted via SendTransaction.
// Pass the token mint to claim fees for a specific token, or empty string for all.
func (c *Client) GetClaimTransactionsV3(ctx context.Context, mint string) ([]ClaimTransaction, error) {
    path := "/claim/transactions/v3"
    if mint != "" {
        path += "?mint=" + mint
    }
    resp, err := c.do(ctx, http.MethodGet, path, nil)
    if err != nil {
        return nil, fmt.Errorf("get claim transactions v3: %w", err)
    }
    var txs []ClaimTransaction
    if err := decodeResponse(resp, &txs); err != nil {
        return nil, fmt.Errorf("get claim transactions v3 decode: %w", err)
    }
    return txs, nil
}

// GetPartnerClaimTx returns claim transactions for partner fee positions.
func (c *Client) GetPartnerClaimTx(ctx context.Context) ([]ClaimTransaction, error) {
    resp, err := c.do(ctx, http.MethodGet, "/claim/partner", nil)
    if err != nil {
        return nil, fmt.Errorf("get partner claim tx: %w", err)
    }
    var txs []ClaimTransaction
    if err := decodeResponse(resp, &txs); err != nil {
        return nil, fmt.Errorf("get partner claim tx decode: %w", err)
    }
    return txs, nil
}

// GetClaimHistory returns historical claim events for the authenticated wallet.
func (c *Client) GetClaimHistory(ctx context.Context) ([]ClaimEvent, error) {
    resp, err := c.do(ctx, http.MethodGet, "/claim/events", nil)
    if err != nil {
        return nil, fmt.Errorf("get claim history: %w", err)
    }
    var events []ClaimEvent
    if err := decodeResponse(resp, &events); err != nil {
        return nil, fmt.Errorf("get claim history decode: %w", err)
    }
    return events, nil
}

// GetClaimStats returns aggregated claim statistics for the authenticated wallet.
func (c *Client) GetClaimStats(ctx context.Context) (*ClaimStats, error) {
    resp, err := c.do(ctx, http.MethodGet, "/claim/stats", nil)
    if err != nil {
        return nil, fmt.Errorf("get claim stats: %w", err)
    }
    var stats ClaimStats
    if err := decodeResponse(resp, &stats); err != nil {
        return nil, fmt.Errorf("get claim stats decode: %w", err)
    }
    return &stats, nil
}

// GetLifetimeFees returns total fees collected for a token across its lifetime.
func (c *Client) GetLifetimeFees(ctx context.Context, mint string) (*LifetimeFees, error) {
    resp, err := c.do(ctx, http.MethodGet, "/claim/lifetime-fees?mint="+mint, nil)
    if err != nil {
        return nil, fmt.Errorf("get lifetime fees: %w", err)
    }
    var fees LifetimeFees
    if err := decodeResponse(resp, &fees); err != nil {
        return nil, fmt.Errorf("get lifetime fees decode: %w", err)
    }
    return &fees, nil
}
```

### Step 4: Write tests

Create `projects/agent-bags/internal/bags/fee_test.go`:

1. `TestConfigureFeeShare` — verify JSON body has correct claimers array and bps values sum to 10000
2. `TestGetClaimablePositions` — mock returns mixed pool types, verify parsing
3. `TestGetClaimTransactionsV3` — mock returns array of claim txs, verify mint filter passed as query param
4. `TestGetLifetimeFees` — mock returns fees object, verify all numeric fields parsed
5. `TestUpdateFeeShareConfig` — verify PUT method used, body correct
6. `TestConfigureFeeShareExceedsMax` — test with >100 claimers (should be validated client-side)

## Done When

- [ ] All requirements met
- [ ] Fee share configuration creates correct JSON with bps allocations
- [ ] Claim transaction retrieval returns parseable pre-signed transactions
- [ ] Lifetime fee stats are correctly deserialized
- [ ] `go test ./internal/bags/...` passes with all fee client tests green
