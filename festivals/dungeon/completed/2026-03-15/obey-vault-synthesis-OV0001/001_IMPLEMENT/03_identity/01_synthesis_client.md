---
fest_type: task
fest_id: 01_synthesis_client.md
fest_name: 01_synthesis_client
fest_parent: 03_identity
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:25:32.402435-06:00
fest_updated: 2026-03-15T19:40:17.13825-06:00
fest_tracking: true
---


# Task: Synthesis API Registration Client

## Objective

Create a Go client for the Synthesis API POST /register endpoint that registers the agent with ERC-8004 identity.

## Dependencies

- None. This task has no upstream dependencies.

## Context

- Production API base URL: `https://synthesis.devfolio.co`
- The client will be used by `04_deploy_integrate/04_register_agent.md` to register the OBEY Vault Agent.
- All files are created under `projects/agent-defi/`.

## Step 1: Create the test file

Create `projects/agent-defi/internal/synthesis/register_test.go` with the following exact content:

```go
package synthesis

import (
    "context"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
)

func TestRegister_Success(t *testing.T) {
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if r.Method != http.MethodPost {
            t.Fatalf("expected POST, got %s", r.Method)
        }
        if r.URL.Path != "/register" {
            t.Fatalf("expected /register, got %s", r.URL.Path)
        }

        w.WriteHeader(http.StatusCreated)
        json.NewEncoder(w).Encode(RegisterResponse{
            ParticipantID:   "test-id",
            TeamID:          "test-team",
            Name:            "OBEY Vault Agent",
            APIKey:          "sk-synth-test123",
            RegistrationTxn: "https://basescan.org/tx/0xtest",
        })
    }))
    defer server.Close()

    client := NewClient(server.URL)
    resp, err := client.Register(context.Background(), RegisterRequest{
        Name:         "OBEY Vault Agent",
        Description:  "DeFi trading agent with on-chain vault custody",
        AgentHarness: "claude-code",
        Model:        "claude-sonnet-4-6",
        HumanInfo: HumanInfo{
            FullName:         "Lance Rogers",
            Email:            "lance@example.com",
            Background:       "Builder",
            CryptoExperience: "yes",
            AIExperience:     "yes",
            CodingComfort:    9,
            ProblemStatement: "Building autonomous DeFi agents with transparent on-chain vault management",
        },
    })
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if resp.APIKey == "" {
        t.Fatal("expected API key in response")
    }
}

func TestRegister_ContextCancellation(t *testing.T) {
    client := NewClient("http://localhost:0")
    ctx, cancel := context.WithCancel(context.Background())
    cancel()

    _, err := client.Register(ctx, RegisterRequest{})
    if err == nil {
        t.Fatal("expected error on cancelled context")
    }
}
```

## Step 2: Create the implementation file

Create `projects/agent-defi/internal/synthesis/register.go` with the following exact content:

```go
package synthesis

import (
    "bytes"
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    "time"
)

type HumanInfo struct {
    FullName         string `json:"fullName"`
    Email            string `json:"email"`
    SocialHandle     string `json:"socialHandle,omitempty"`
    Background       string `json:"background"`
    CryptoExperience string `json:"cryptoExperience"`
    AIExperience     string `json:"aiAgentExperience"`
    CodingComfort    int    `json:"codingComfort"`
    ProblemStatement string `json:"problemStatement"`
}

type RegisterRequest struct {
    Name         string    `json:"name"`
    Description  string    `json:"description"`
    AgentHarness string    `json:"agentHarness"`
    Model        string    `json:"model"`
    Image        string    `json:"image,omitempty"`
    HumanInfo    HumanInfo `json:"humanInfo"`
}

type RegisterResponse struct {
    ParticipantID   string `json:"participantId"`
    TeamID          string `json:"teamId"`
    Name            string `json:"name"`
    APIKey          string `json:"apiKey"`
    RegistrationTxn string `json:"registrationTxn"`
}

type Client struct {
    baseURL string
    http    *http.Client
}

func NewClient(baseURL string) *Client {
    return &Client{
        baseURL: baseURL,
        http:    &http.Client{Timeout: 30 * time.Second},
    }
}

func (c *Client) Register(ctx context.Context, req RegisterRequest) (*RegisterResponse, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("synthesis: context cancelled: %w", err)
    }

    body, err := json.Marshal(req)
    if err != nil {
        return nil, fmt.Errorf("synthesis: marshal request: %w", err)
    }

    httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/register", bytes.NewReader(body))
    if err != nil {
        return nil, fmt.Errorf("synthesis: create request: %w", err)
    }
    httpReq.Header.Set("Content-Type", "application/json")

    resp, err := c.http.Do(httpReq)
    if err != nil {
        return nil, fmt.Errorf("synthesis: request failed: %w", err)
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusCreated {
        return nil, fmt.Errorf("synthesis: unexpected status %d", resp.StatusCode)
    }

    var result RegisterResponse
    if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
        return nil, fmt.Errorf("synthesis: decode response: %w", err)
    }

    return &result, nil
}
```

## Step 3: Run tests

```bash
cd projects/agent-defi && go test ./internal/synthesis/... -v
```

Expected output: both `TestRegister_Success` and `TestRegister_ContextCancellation` PASS.

## Verification Checklist

- [ ] `projects/agent-defi/internal/synthesis/register.go` exists with all types and Client
- [ ] `projects/agent-defi/internal/synthesis/register_test.go` exists with both tests
- [ ] `go test ./internal/synthesis/... -v` passes all tests
- [ ] Context cancellation is checked before I/O
- [ ] `http.NewRequestWithContext` is used (not `http.NewRequest`)

## Done When

- [ ] All verification checks pass
- [ ] No lint errors in the new files