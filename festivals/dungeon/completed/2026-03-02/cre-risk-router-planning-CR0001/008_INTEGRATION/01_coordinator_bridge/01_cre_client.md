---
fest_type: task
fest_id: 01_cre_client.md
fest_name: cre client
fest_parent: 01_coordinator_bridge
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:45:49.00872-07:00
fest_updated: 2026-03-02T01:21:34.76052-07:00
fest_tracking: true
---


# Task: cre client

## Objective

Create an HTTP client package in `agent-coordinator` that sends RiskRequest payloads to the CRE Risk Router HTTP trigger and parses the RiskDecision response (Req P1.1).

## Requirements

- [ ] New package `pkg/creclient/` in `agent-coordinator` with `EvaluateRisk(ctx, req) (RiskDecision, error)` (Req P1.1)
- [ ] Client sends HTTP POST to the CRE Risk Router endpoint with JSON-encoded RiskRequest
- [ ] Client parses the JSON RiskDecision response including all fields (approved, deny_reason, constrained_position_usd, etc.)
- [ ] Client handles HTTP errors, timeouts, and malformed responses gracefully
- [ ] CRE endpoint URL is configurable via environment variable or config

## Implementation

1. **Create the package directory**:
   ```bash
   mkdir -p projects/agent-coordinator/pkg/creclient
   ```

2. **Define types** in `pkg/creclient/types.go`:
   ```go
   package creclient

   // RiskRequest matches the CRE Risk Router input format
   type RiskRequest struct {
       AgentID              string  `json:"agent_id"`
       TaskID               string  `json:"task_id"`
       Signal               string  `json:"signal"`               // "buy", "sell", "hold"
       SignalConfidence      float64 `json:"signal_confidence"`     // 0.0 - 1.0
       RiskScore            int     `json:"risk_score"`            // 0 - 100
       MarketPair           string  `json:"market_pair"`           // e.g., "ETH/USD"
       RequestedPositionUSD float64 `json:"requested_position_usd"`
       Timestamp            int64   `json:"timestamp"`             // Unix epoch seconds
   }

   // RiskDecision matches the CRE Risk Router output format
   type RiskDecision struct {
       RunID                string  `json:"run_id"`
       Approved             bool    `json:"approved"`
       DenyReason           string  `json:"deny_reason,omitempty"`
       ConstrainedPositionUSD float64 `json:"constrained_position_usd"`
       GateResults          []GateResult `json:"gate_results"`
       TxHash               string  `json:"tx_hash,omitempty"`
       DecisionHash         string  `json:"decision_hash"`
   }

   // GateResult represents the evaluation result of a single risk gate
   type GateResult struct {
       Gate    string `json:"gate"`
       Passed  bool   `json:"passed"`
       Reason  string `json:"reason,omitempty"`
   }
   ```

3. **Create the client** in `pkg/creclient/client.go`:
   ```go
   package creclient

   import (
       "bytes"
       "context"
       "encoding/json"
       "fmt"
       "net/http"
       "time"
   )

   type Client struct {
       endpoint   string
       httpClient *http.Client
   }

   func New(endpoint string, timeout time.Duration) *Client {
       return &Client{
           endpoint: endpoint,
           httpClient: &http.Client{Timeout: timeout},
       }
   }

   func (c *Client) EvaluateRisk(ctx context.Context, req RiskRequest) (RiskDecision, error) {
       body, err := json.Marshal(req)
       if err != nil {
           return RiskDecision{}, fmt.Errorf("marshal risk request: %w", err)
       }

       httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.endpoint, bytes.NewReader(body))
       if err != nil {
           return RiskDecision{}, fmt.Errorf("create HTTP request: %w", err)
       }
       httpReq.Header.Set("Content-Type", "application/json")

       resp, err := c.httpClient.Do(httpReq)
       if err != nil {
           return RiskDecision{}, fmt.Errorf("send risk request: %w", err)
       }
       defer resp.Body.Close()

       if resp.StatusCode != http.StatusOK {
           return RiskDecision{}, fmt.Errorf("CRE returned status %d", resp.StatusCode)
       }

       var decision RiskDecision
       if err := json.NewDecoder(resp.Body).Decode(&decision); err != nil {
           return RiskDecision{}, fmt.Errorf("decode risk decision: %w", err)
       }

       return decision, nil
   }
   ```

4. **Add configuration** support:
   - Read `CRE_RISK_ROUTER_URL` from environment or coordinator config
   - Default to `http://localhost:8080/evaluate-risk` for local development
   - Default timeout: 10 seconds

5. **Write unit tests** in `pkg/creclient/client_test.go`:
   - Test successful request/response round-trip with httptest server
   - Test HTTP error handling (500, 400, timeout)
   - Test malformed JSON response handling
   - Test context cancellation

## Done When

- [ ] All requirements met
- [ ] `pkg/creclient/` package exists with types, client, and tests
- [ ] Client correctly serializes RiskRequest and deserializes RiskDecision
- [ ] Error handling covers network failures, HTTP errors, and bad responses
- [ ] Tests pass with `go test ./pkg/creclient/...`