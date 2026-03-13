---
fest_type: task
fest_id: 02_token_client.md
fest_name: token_client
fest_parent: 01_bags_client
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.47308-06:00
fest_tracking: true
---

# Task: Token Creation & Metadata Client

## Objective

Implement Bags API methods for token creation, metadata upload, and pool queries in `projects/agent-bags/internal/bags/client.go` (extend the existing `Client`).

## Requirements

- [ ] `CreateToken` method: `POST /tokens/create` with image upload (multipart form data), name, symbol, description, social links
- [ ] `LaunchToken` method: `POST /tokens/launch` to generate the pre-signed Meteora DBC launch transaction
- [ ] `GetPoolByMint` method: `GET /pools/:mint` to fetch pool state (bonding curve or DAMM v2)
- [ ] `ListPools` method: `GET /pools` to list all Bags pools
- [ ] Request/response types for each endpoint with proper JSON tags
- [ ] Multipart form support for image upload in `CreateToken`

## Implementation

### Step 1: Define token types

Add to `projects/agent-bags/internal/bags/types.go` (create this file):

```go
package bags

// CreateTokenRequest holds parameters for token creation.
type CreateTokenRequest struct {
    Name        string `json:"name"`
    Symbol      string `json:"symbol"`
    Description string `json:"description"`
    Twitter     string `json:"twitter,omitempty"`
    Telegram    string `json:"telegram,omitempty"`
    Website     string `json:"website,omitempty"`
    ImagePath   string `json:"-"` // local file path for upload, not serialized
}

// CreateTokenResponse is returned by POST /tokens/create.
type CreateTokenResponse struct {
    Mint      string `json:"mint"`
    MetaURI   string `json:"metaUri"`
    ImageURL  string `json:"imageUrl"`
}

// LaunchTokenRequest holds parameters for launching on Meteora DBC.
type LaunchTokenRequest struct {
    Mint string `json:"mint"`
}

// LaunchTokenResponse contains the pre-signed launch transaction.
type LaunchTokenResponse struct {
    Transaction string `json:"transaction"` // base64-encoded serialized tx
    Mint        string `json:"mint"`
}

// Pool represents a Bags liquidity pool.
type Pool struct {
    Mint           string  `json:"mint"`
    Name           string  `json:"name"`
    Symbol         string  `json:"symbol"`
    PoolKey        string  `json:"poolKey"`
    PoolType       string  `json:"poolType"` // "dbc" or "damm_v2"
    Price          float64 `json:"price"`
    Volume24h      float64 `json:"volume24h"`
    Liquidity      float64 `json:"liquidity"`
    MarketCap      float64 `json:"marketCap"`
    HolderCount    int     `json:"holderCount"`
    MigrationState string  `json:"migrationState,omitempty"` // empty, "pending", "migrated"
}
```

### Step 2: Implement CreateToken with multipart upload

Add to `projects/agent-bags/internal/bags/client.go`:

```go
// CreateToken uploads token metadata and image, returning the generated mint address.
// The ImagePath field in req must point to a local image file (PNG/JPG, recommended 512x512).
func (c *Client) CreateToken(ctx context.Context, req CreateTokenRequest) (*CreateTokenResponse, error) {
    if err := ctx.Err(); err != nil {
        return nil, err
    }

    var buf bytes.Buffer
    writer := multipart.NewWriter(&buf)

    // Add image file
    if req.ImagePath != "" {
        file, err := os.Open(req.ImagePath)
        if err != nil {
            return nil, fmt.Errorf("opening image %s: %w", req.ImagePath, err)
        }
        defer file.Close()

        part, err := writer.CreateFormFile("image", filepath.Base(req.ImagePath))
        if err != nil {
            return nil, fmt.Errorf("creating form file: %w", err)
        }
        if _, err := io.Copy(part, file); err != nil {
            return nil, fmt.Errorf("copying image data: %w", err)
        }
    }

    // Add text fields
    fields := map[string]string{
        "name":        req.Name,
        "symbol":      req.Symbol,
        "description": req.Description,
    }
    if req.Twitter != "" {
        fields["twitter"] = req.Twitter
    }
    if req.Telegram != "" {
        fields["telegram"] = req.Telegram
    }
    if req.Website != "" {
        fields["website"] = req.Website
    }
    for k, v := range fields {
        if err := writer.WriteField(k, v); err != nil {
            return nil, fmt.Errorf("writing field %s: %w", k, err)
        }
    }
    writer.Close()

    // Build request manually since this is multipart, not JSON
    url := c.baseURL + "/tokens/create"
    httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, url, &buf)
    if err != nil {
        return nil, fmt.Errorf("creating token request: %w", err)
    }
    httpReq.Header.Set("Content-Type", writer.FormDataContentType())
    if c.apiKey != "" {
        httpReq.Header.Set("x-api-key", c.apiKey)
    }
    if c.jwt != "" {
        httpReq.Header.Set("Authorization", "Bearer "+c.jwt)
    }

    resp, err := c.httpClient.Do(httpReq)
    if err != nil {
        return nil, fmt.Errorf("create token request: %w", err)
    }
    if resp.StatusCode >= 400 {
        defer resp.Body.Close()
        rawBody, _ := io.ReadAll(resp.Body)
        return nil, &APIError{StatusCode: resp.StatusCode, Message: "create token failed", Raw: string(rawBody)}
    }

    var result CreateTokenResponse
    if err := decodeResponse(resp, &result); err != nil {
        return nil, fmt.Errorf("create token decode: %w", err)
    }
    return &result, nil
}
```

### Step 3: Implement LaunchToken

```go
// LaunchToken generates a pre-signed Meteora DBC launch transaction for the given mint.
// The caller must sign and submit the transaction via SendTransaction.
func (c *Client) LaunchToken(ctx context.Context, mint string) (*LaunchTokenResponse, error) {
    body := fmt.Sprintf(`{"mint":"%s"}`, mint)
    resp, err := c.do(ctx, http.MethodPost, "/tokens/launch", strings.NewReader(body))
    if err != nil {
        return nil, fmt.Errorf("launch token: %w", err)
    }
    var result LaunchTokenResponse
    if err := decodeResponse(resp, &result); err != nil {
        return nil, fmt.Errorf("launch token decode: %w", err)
    }
    return &result, nil
}
```

### Step 4: Implement pool queries

```go
// GetPoolByMint fetches the pool data for a specific token mint.
func (c *Client) GetPoolByMint(ctx context.Context, mint string) (*Pool, error) {
    resp, err := c.do(ctx, http.MethodGet, "/pools/"+mint, nil)
    if err != nil {
        return nil, fmt.Errorf("get pool by mint: %w", err)
    }
    var pool Pool
    if err := decodeResponse(resp, &pool); err != nil {
        return nil, fmt.Errorf("get pool decode: %w", err)
    }
    return &pool, nil
}

// ListPools returns all Bags pools (Meteora DBC and DAMM v2).
func (c *Client) ListPools(ctx context.Context) ([]Pool, error) {
    resp, err := c.do(ctx, http.MethodGet, "/pools", nil)
    if err != nil {
        return nil, fmt.Errorf("list pools: %w", err)
    }
    var pools []Pool
    if err := decodeResponse(resp, &pools); err != nil {
        return nil, fmt.Errorf("list pools decode: %w", err)
    }
    return pools, nil
}
```

### Step 5: Write tests

Create `projects/agent-bags/internal/bags/token_test.go` with:

1. `TestCreateToken` — mock multipart endpoint, verify image and fields are present
2. `TestLaunchToken` — mock returns base64 tx, verify parsing
3. `TestGetPoolByMint` — mock returns pool JSON, verify all fields parsed
4. `TestListPools` — mock returns array, verify count and contents
5. `TestCreateTokenMissingImage` — verify graceful handling when ImagePath is empty

## Done When

- [ ] All requirements met
- [ ] `CreateToken` successfully uploads multipart form with image + metadata fields
- [ ] `LaunchToken` returns a parseable pre-signed transaction
- [ ] `GetPoolByMint` and `ListPools` correctly deserialize pool data
- [ ] `go test ./internal/bags/...` passes with all token client tests green
