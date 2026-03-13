---
fest_type: task
fest_id: 01_clob_client.md
fest_name: clob_client
fest_parent: 01_polymarket_adapter
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.568568-06:00
fest_tracking: true
---

# Task: Polymarket CLOB API Client

## Objective

Implement the Polymarket CLOB (Central Limit Order Book) API client in Go with EIP-712 credential creation, HMAC-SHA256 request signing, order book queries, and WebSocket subscriptions.

## Requirements

- [ ] `CLOBClient` struct wrapping HTTP client with HMAC-SHA256 request authentication
- [ ] EIP-712 signature generation for API credential creation using the agent's Polygon ECDSA key
- [ ] `CreateAPICredentials` method: derive API key, secret, and passphrase from EIP-712 signature
- [ ] `GetOrderBook` method: fetch order book for a condition token ID
- [ ] `GetMarket` method: fetch market details by condition ID
- [ ] `GetPositions` method: fetch current open positions for the authenticated user
- [ ] `GetPrice` method: fetch best bid/ask for a token
- [ ] Rate limiting: 9,000 requests per 10 seconds for reads, 3,500 per 10 seconds for orders
- [ ] WebSocket client for real-time order book updates at `wss://ws-subscriptions-clob.polymarket.com`

## Implementation

### Step 1: Define types and client struct

Create `projects/agent-inference/internal/adapters/polymarket/clob.go`:

```go
package polymarket

import (
    "context"
    "crypto/ecdsa"
    "crypto/hmac"
    "crypto/sha256"
    "encoding/base64"
    "encoding/hex"
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "strconv"
    "strings"
    "time"
)

const (
    CLOBBaseURL    = "https://clob.polymarket.com"
    CLOBWSEndpoint = "wss://ws-subscriptions-clob.polymarket.com/ws"
    ReadRateLimit  = 9000  // per 10 seconds
    OrderRateLimit = 3500  // per 10 seconds
)

// CLOBClient interfaces with the Polymarket CLOB API.
type CLOBClient struct {
    baseURL    string
    httpClient *http.Client
    creds      *APICredentials
    signer     *ecdsa.PrivateKey
}

// APICredentials are derived from EIP-712 signing.
type APICredentials struct {
    APIKey     string
    Secret     string
    Passphrase string
}

// OrderBookEntry represents a single price level.
type OrderBookEntry struct {
    Price string `json:"price"`
    Size  string `json:"size"`
}

// OrderBook for a condition token.
type OrderBook struct {
    Bids []OrderBookEntry `json:"bids"`
    Asks []OrderBookEntry `json:"asks"`
    Hash string           `json:"hash"` // for WebSocket diff updates
}

// CLOBMarket represents a Polymarket market from the CLOB API.
type CLOBMarket struct {
    ConditionID    string   `json:"condition_id"`
    Tokens         []Token  `json:"tokens"`
    MinimumOrderSize string `json:"minimum_order_size"`
    MinimumTickSize  string `json:"minimum_tick_size"`
    Active         bool     `json:"active"`
}

// Token represents a YES/NO outcome token.
type Token struct {
    TokenID  string `json:"token_id"`
    Outcome  string `json:"outcome"` // "Yes" or "No"
    Price    string `json:"price"`
    Winner   bool   `json:"winner"`
}

// Position represents an open CTF token position.
type Position struct {
    AssetID  string `json:"asset"`
    Size     string `json:"size"`
    AvgPrice string `json:"avgPrice"`
    Side     string `json:"side"` // "BUY" or "SELL"
}
```

### Step 2: Implement EIP-712 credential derivation

```go
// NewCLOBClient creates a new Polymarket CLOB client.
// The ECDSA private key is the agent's Polygon wallet key.
func NewCLOBClient(privateKey *ecdsa.PrivateKey) (*CLOBClient, error) {
    client := &CLOBClient{
        baseURL:    CLOBBaseURL,
        httpClient: &http.Client{Timeout: 30 * time.Second},
        signer:     privateKey,
    }
    return client, nil
}

// CreateAPICredentials derives CLOB API credentials using EIP-712 signing.
// This must be called once; credentials can be reused for the key's lifetime.
func (c *CLOBClient) CreateAPICredentials(ctx context.Context) (*APICredentials, error) {
    // EIP-712 domain and message type for Polymarket CLOB
    // Domain: { name: "ClobAuthDomain", version: "1", chainId: 137 }
    // Type: ClobAuth { address, timestamp, nonce, message }

    timestamp := strconv.FormatInt(time.Now().Unix(), 10)
    nonce := "0" // first-time credential creation

    // Build the EIP-712 typed data hash
    // The exact structure follows Polymarket's documentation:
    // https://docs.polymarket.com/#create-api-key
    domainSeparator := buildDomainSeparator("ClobAuthDomain", "1", 137)
    structHash := buildClobAuthHash(
        c.publicAddress(),
        timestamp,
        nonce,
        "This message creates API credentials",
    )
    digest := buildEIP712Digest(domainSeparator, structHash)

    // Sign the digest
    signature, err := signDigest(c.signer, digest)
    if err != nil {
        return nil, fmt.Errorf("signing EIP-712 digest: %w", err)
    }

    // POST to CLOB API to derive credentials
    body := fmt.Sprintf(`{
        "address": "%s",
        "timestamp": "%s",
        "nonce": "%s",
        "message": "This message creates API credentials",
        "signature": "%s"
    }`, c.publicAddress(), timestamp, nonce, hex.EncodeToString(signature))

    resp, err := c.rawPost(ctx, "/auth/derive-api-key", body)
    if err != nil {
        return nil, fmt.Errorf("deriving API credentials: %w", err)
    }

    var creds APICredentials
    if err := json.NewDecoder(resp.Body).Decode(&creds); err != nil {
        return nil, fmt.Errorf("decoding credentials: %w", err)
    }
    resp.Body.Close()

    c.creds = &creds
    return &creds, nil
}
```

### Step 3: Implement HMAC-SHA256 request signing

```go
// signRequest adds HMAC-SHA256 authentication headers to an HTTP request.
func (c *CLOBClient) signRequest(req *http.Request, body string) {
    if c.creds == nil {
        return
    }
    timestamp := strconv.FormatInt(time.Now().Unix(), 10)
    method := req.Method
    path := req.URL.Path
    if req.URL.RawQuery != "" {
        path += "?" + req.URL.RawQuery
    }

    // HMAC message: timestamp + method + path + body
    message := timestamp + method + path + body
    mac := hmac.New(sha256.New, []byte(c.creds.Secret))
    mac.Write([]byte(message))
    signature := base64.StdEncoding.EncodeToString(mac.Sum(nil))

    req.Header.Set("POLY_API_KEY", c.creds.APIKey)
    req.Header.Set("POLY_SIGNATURE", signature)
    req.Header.Set("POLY_TIMESTAMP", timestamp)
    req.Header.Set("POLY_PASSPHRASE", c.creds.Passphrase)
}

// do executes an authenticated CLOB API request.
func (c *CLOBClient) do(ctx context.Context, method, path string, body string) (*http.Response, error) {
    url := c.baseURL + path
    var bodyReader io.Reader
    if body != "" {
        bodyReader = strings.NewReader(body)
    }

    req, err := http.NewRequestWithContext(ctx, method, url, bodyReader)
    if err != nil {
        return nil, err
    }
    req.Header.Set("Content-Type", "application/json")
    c.signRequest(req, body)

    return c.httpClient.Do(req)
}
```

### Step 4: Implement query methods

```go
// GetOrderBook fetches the order book for a token ID.
func (c *CLOBClient) GetOrderBook(ctx context.Context, tokenID string) (*OrderBook, error) {
    resp, err := c.do(ctx, http.MethodGet, "/book?token_id="+tokenID, "")
    if err != nil {
        return nil, fmt.Errorf("get order book: %w", err)
    }
    defer resp.Body.Close()
    var book OrderBook
    if err := json.NewDecoder(resp.Body).Decode(&book); err != nil {
        return nil, fmt.Errorf("decode order book: %w", err)
    }
    return &book, nil
}

// GetMarket fetches market details by condition ID.
func (c *CLOBClient) GetMarket(ctx context.Context, conditionID string) (*CLOBMarket, error) {
    resp, err := c.do(ctx, http.MethodGet, "/markets/"+conditionID, "")
    if err != nil {
        return nil, fmt.Errorf("get market: %w", err)
    }
    defer resp.Body.Close()
    var market CLOBMarket
    if err := json.NewDecoder(resp.Body).Decode(&market); err != nil {
        return nil, fmt.Errorf("decode market: %w", err)
    }
    return &market, nil
}

// GetPositions fetches open positions for the authenticated user.
func (c *CLOBClient) GetPositions(ctx context.Context) ([]Position, error) {
    resp, err := c.do(ctx, http.MethodGet, "/positions", "")
    if err != nil {
        return nil, fmt.Errorf("get positions: %w", err)
    }
    defer resp.Body.Close()
    var positions []Position
    if err := json.NewDecoder(resp.Body).Decode(&positions); err != nil {
        return nil, fmt.Errorf("decode positions: %w", err)
    }
    return positions, nil
}
```

### Step 5: Write tests

Create `internal/adapters/polymarket/clob_test.go`:

1. `TestHMACSignature` — verify HMAC-SHA256 produces expected signature for known inputs
2. `TestGetOrderBook` — mock CLOB endpoint, verify bid/ask parsing
3. `TestGetMarket` — mock returns market with 2 tokens, verify condition_id and token parsing
4. `TestGetPositions` — mock returns position array
5. `TestSignRequestHeaders` — verify all 4 POLY_* headers are set correctly
6. `TestContextCancellation` — cancel context during request, verify clean abort

## Done When

- [ ] All requirements met
- [ ] EIP-712 credential derivation produces valid API key, secret, passphrase
- [ ] HMAC-SHA256 request signing adds correct headers on every request
- [ ] Order book, market, and position queries parse responses correctly
- [ ] Rate limiting constants defined for integration with rate limiter
- [ ] `go test ./internal/adapters/polymarket/...` passes
