---
fest_type: task
fest_id: 01_auth_client.md
fest_name: auth_client
fest_parent: 01_bags_client
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.472701-06:00
fest_tracking: true
---

# Task: Bags Authentication & Base HTTP Client

## Objective

Implement the core Bags API HTTP client with Moltbook agent authentication, JWT management, and wallet access in `projects/agent-bags/internal/bags/client.go`.

## Requirements

- [ ] HTTP client struct wrapping `net/http.Client` with base URL, API key header, and JWT token
- [ ] Agent auth flow: `POST /agent/auth/init` to get challenge, post challenge to Moltbook, `POST /agent/auth/login` to receive 365-day JWT
- [ ] Dev-key management: `POST /agent/dev-keys` to create API keys, `GET /agent/dev-keys` to list them
- [ ] Wallet access: `GET /agent/wallets` to list Solana wallets, `POST /agent/wallets/export` to export private key
- [ ] Automatic `x-api-key` header injection on every request
- [ ] Rate limiting: respect 1,000 req/hour per user/IP (use a token bucket or simple counter)
- [ ] All methods accept `context.Context` as first parameter
- [ ] Structured error types wrapping HTTP status codes and Bags API error responses

## Implementation

### Step 1: Define types and client struct

Create the file `projects/agent-bags/internal/bags/client.go`:

```go
package bags

import (
    "context"
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "sync"
    "time"
)

const (
    DefaultBaseURL = "https://public-api-v2.bags.fm/api/v1"
    MaxRequestsPerHour = 1000
)

// Client is the Bags.fm API client.
type Client struct {
    baseURL    string
    apiKey     string
    jwt        string
    httpClient *http.Client

    // Rate limiting
    mu         sync.Mutex
    reqCount   int
    windowStart time.Time
}

// Config holds the configuration for creating a new Client.
type Config struct {
    BaseURL string
    APIKey  string
    JWT     string
}

// Wallet represents a Solana wallet managed by Bags.
type Wallet struct {
    Address   string `json:"address"`
    PublicKey string `json:"publicKey"`
}

// AuthChallenge is the response from /agent/auth/init.
type AuthChallenge struct {
    ChallengeID string `json:"challengeId"`
    Content     string `json:"content"`
    ExpiresAt   string `json:"expiresAt"`
}

// AuthToken is the response from /agent/auth/login.
type AuthToken struct {
    Token     string `json:"token"`
    ExpiresAt string `json:"expiresAt"`
}

// DevKey represents an API key.
type DevKey struct {
    ID        string `json:"id"`
    Key       string `json:"key"`
    Name      string `json:"name"`
    CreatedAt string `json:"createdAt"`
}

// APIError wraps Bags API error responses.
type APIError struct {
    StatusCode int
    Message    string
    Raw        string
}

func (e *APIError) Error() string {
    return fmt.Sprintf("bags api error (HTTP %d): %s", e.StatusCode, e.Message)
}
```

### Step 2: Implement the constructor and core request method

```go
// New creates a new Bags API client.
func New(cfg Config) *Client {
    baseURL := cfg.BaseURL
    if baseURL == "" {
        baseURL = DefaultBaseURL
    }
    return &Client{
        baseURL:     baseURL,
        apiKey:      cfg.APIKey,
        jwt:         cfg.JWT,
        httpClient:  &http.Client{Timeout: 30 * time.Second},
        windowStart: time.Now(),
    }
}

// SetJWT updates the JWT token (called after successful auth).
func (c *Client) SetJWT(token string) {
    c.jwt = token
}

// do executes an HTTP request with auth headers and rate limiting.
func (c *Client) do(ctx context.Context, method, path string, body io.Reader) (*http.Response, error) {
    if err := ctx.Err(); err != nil {
        return nil, err
    }
    if err := c.checkRateLimit(); err != nil {
        return nil, err
    }

    url := c.baseURL + path
    req, err := http.NewRequestWithContext(ctx, method, url, body)
    if err != nil {
        return nil, fmt.Errorf("creating request: %w", err)
    }

    req.Header.Set("Content-Type", "application/json")
    if c.apiKey != "" {
        req.Header.Set("x-api-key", c.apiKey)
    }
    if c.jwt != "" {
        req.Header.Set("Authorization", "Bearer "+c.jwt)
    }

    resp, err := c.httpClient.Do(req)
    if err != nil {
        return nil, fmt.Errorf("executing request %s %s: %w", method, path, err)
    }

    if resp.StatusCode >= 400 {
        defer resp.Body.Close()
        rawBody, _ := io.ReadAll(resp.Body)
        return nil, &APIError{
            StatusCode: resp.StatusCode,
            Message:    http.StatusText(resp.StatusCode),
            Raw:        string(rawBody),
        }
    }

    return resp, nil
}

func (c *Client) checkRateLimit() error {
    c.mu.Lock()
    defer c.mu.Unlock()

    now := time.Now()
    if now.Sub(c.windowStart) > time.Hour {
        c.reqCount = 0
        c.windowStart = now
    }
    if c.reqCount >= MaxRequestsPerHour {
        return fmt.Errorf("bags api rate limit exceeded (%d requests in current hour window)", MaxRequestsPerHour)
    }
    c.reqCount++
    return nil
}

// decodeResponse reads and decodes a JSON response body into dest.
func decodeResponse(resp *http.Response, dest any) error {
    defer resp.Body.Close()
    if err := json.NewDecoder(resp.Body).Decode(dest); err != nil {
        return fmt.Errorf("decoding response: %w", err)
    }
    return nil
}
```

### Step 3: Implement auth methods

```go
// InitAuth starts the agent authentication flow.
// Returns a challenge that must be posted to Moltbook.
func (c *Client) InitAuth(ctx context.Context) (*AuthChallenge, error) {
    resp, err := c.do(ctx, http.MethodPost, "/agent/auth/init", nil)
    if err != nil {
        return nil, fmt.Errorf("init auth: %w", err)
    }
    var challenge AuthChallenge
    if err := decodeResponse(resp, &challenge); err != nil {
        return nil, fmt.Errorf("init auth decode: %w", err)
    }
    return &challenge, nil
}

// Login completes the agent authentication flow after the challenge
// has been posted to Moltbook. Returns a 365-day JWT.
func (c *Client) Login(ctx context.Context, challengeID string) (*AuthToken, error) {
    body := fmt.Sprintf(`{"challengeId":"%s"}`, challengeID)
    resp, err := c.do(ctx, http.MethodPost, "/agent/auth/login", strings.NewReader(body))
    if err != nil {
        return nil, fmt.Errorf("login: %w", err)
    }
    var token AuthToken
    if err := decodeResponse(resp, &token); err != nil {
        return nil, fmt.Errorf("login decode: %w", err)
    }
    c.jwt = token.Token
    return &token, nil
}
```

### Step 4: Implement dev-key and wallet methods

```go
// CreateDevKey creates a new API key.
func (c *Client) CreateDevKey(ctx context.Context, name string) (*DevKey, error) {
    body := fmt.Sprintf(`{"name":"%s"}`, name)
    resp, err := c.do(ctx, http.MethodPost, "/agent/dev-keys", strings.NewReader(body))
    if err != nil {
        return nil, fmt.Errorf("create dev key: %w", err)
    }
    var key DevKey
    if err := decodeResponse(resp, &key); err != nil {
        return nil, fmt.Errorf("create dev key decode: %w", err)
    }
    return &key, nil
}

// ListDevKeys returns all API keys for the authenticated agent.
func (c *Client) ListDevKeys(ctx context.Context) ([]DevKey, error) {
    resp, err := c.do(ctx, http.MethodGet, "/agent/dev-keys", nil)
    if err != nil {
        return nil, fmt.Errorf("list dev keys: %w", err)
    }
    var keys []DevKey
    if err := decodeResponse(resp, &keys); err != nil {
        return nil, fmt.Errorf("list dev keys decode: %w", err)
    }
    return keys, nil
}

// ListWallets returns the Solana wallets associated with the authenticated agent.
func (c *Client) ListWallets(ctx context.Context) ([]Wallet, error) {
    resp, err := c.do(ctx, http.MethodGet, "/agent/wallets", nil)
    if err != nil {
        return nil, fmt.Errorf("list wallets: %w", err)
    }
    var wallets []Wallet
    if err := decodeResponse(resp, &wallets); err != nil {
        return nil, fmt.Errorf("list wallets decode: %w", err)
    }
    return wallets, nil
}

// ExportWalletKey exports the private key for the agent's Solana wallet.
// Handle with care — this is a secret.
func (c *Client) ExportWalletKey(ctx context.Context) (string, error) {
    resp, err := c.do(ctx, http.MethodPost, "/agent/wallets/export", nil)
    if err != nil {
        return "", fmt.Errorf("export wallet key: %w", err)
    }
    var result struct {
        PrivateKey string `json:"privateKey"`
    }
    if err := decodeResponse(resp, &result); err != nil {
        return "", fmt.Errorf("export wallet key decode: %w", err)
    }
    return result.PrivateKey, nil
}
```

### Step 5: Write unit tests

Create `projects/agent-bags/internal/bags/client_test.go` with table-driven tests using `httptest.NewServer` to mock Bags API responses. Test:

1. `New` constructor sets defaults correctly
2. `do` injects `x-api-key` and `Authorization` headers
3. `do` returns `*APIError` on 4xx/5xx responses
4. Rate limiter rejects after 1000 requests in a window
5. `InitAuth` parses challenge response
6. `ListWallets` parses wallet array response
7. Context cancellation stops in-flight requests

## Done When

- [ ] All requirements met
- [ ] `go build ./...` passes with no errors in `projects/agent-bags`
- [ ] `go test ./internal/bags/...` passes with all auth, wallet, dev-key, rate-limit, and error tests green
- [ ] Client correctly injects `x-api-key` header on every outbound request (verified via httptest)
- [ ] Rate limiter prevents more than 1000 requests per hour window
