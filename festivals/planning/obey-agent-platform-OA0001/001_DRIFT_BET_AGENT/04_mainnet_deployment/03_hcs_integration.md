---
fest_type: task
fest_id: 03_hcs_integration.md
fest_name: hcs_integration
fest_parent: 04_mainnet_deployment
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.336764-06:00
fest_tracking: true
---

# Task: HCS Coordinator Integration

## Objective

Implement HCS (Hedera Consensus Service) integration for the prediction market agent, reusing the messaging patterns from `agent-defi/internal/hcs/`, with extended message types for prediction market reporting (NAV updates, trade execution reports, market analysis results).

## Requirements

- [ ] Port HCS handler pattern from agent-defi to agent-prediction
- [ ] Extended message types for prediction market operations (NAV update, trade executed, position resolved)
- [ ] HCS transport using Hedera SDK for production, mock transport for testing
- [ ] Prediction market P&L report format (different from DeFi P&L)
- [ ] NAV reporting with position breakdown
- [ ] Trade execution event publishing
- [ ] Health status with prediction market-specific fields
- [ ] Integration into the agent's main loop

## Implementation

### Step 1: Define Prediction Market HCS Message Types

Update file `projects/agent-prediction/internal/hcs/hcs.go`:

```go
package hcs

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"sync/atomic"
	"time"
)

// Sentinel errors for HCS operations.
var (
	ErrSubscriptionFailed = errors.New("hcs: topic subscription failed")
	ErrPublishFailed      = errors.New("hcs: message publish failed")
	ErrInvalidMessage     = errors.New("hcs: received invalid message format")
)

// MessageType identifies the kind of protocol message in an envelope.
type MessageType string

const (
	MessageTypeTaskAssignment MessageType = "task_assignment"
	MessageTypeTaskResult     MessageType = "task_result"
	MessageTypeHeartbeat      MessageType = "heartbeat"
	MessageTypePnLReport      MessageType = "pnl_report"
	MessageTypeNAVUpdate      MessageType = "nav_update"
	MessageTypeTradeExecuted  MessageType = "trade_executed"
	MessageTypePositionResolved MessageType = "position_resolved"
)

// Envelope is the standard message format, matching the coordinator protocol.
type Envelope struct {
	Type        MessageType     `json:"type"`
	Sender      string          `json:"sender"`
	Recipient   string          `json:"recipient,omitempty"`
	TaskID      string          `json:"task_id,omitempty"`
	SequenceNum uint64          `json:"sequence_num"`
	Timestamp   time.Time       `json:"timestamp"`
	Payload     json.RawMessage `json:"payload,omitempty"`
}

// Marshal serializes the envelope to JSON bytes.
func (e *Envelope) Marshal() ([]byte, error) {
	return json.Marshal(e)
}

// UnmarshalEnvelope deserializes JSON bytes into an Envelope.
func UnmarshalEnvelope(data []byte) (*Envelope, error) {
	var env Envelope
	if err := json.Unmarshal(data, &env); err != nil {
		return nil, err
	}
	return &env, nil
}

// TaskAssignment is received from the coordinator.
type TaskAssignment struct {
	TaskID   string `json:"task_id"`
	TaskType string `json:"task_type"` // "execute_cycle", "update_strategy"
	Priority int    `json:"priority"`
	Deadline time.Time `json:"deadline,omitempty"`
}

// TaskResult is published back to the coordinator.
type TaskResult struct {
	TaskID     string `json:"task_id"`
	Status     string `json:"status"` // "completed" or "failed"
	Error      string `json:"error,omitempty"`
	DurationMs int64  `json:"duration_ms,omitempty"`
}

// PnLReportMessage is the prediction market P&L report format.
type PnLReportMessage struct {
	AgentID        string    `json:"agent_id"`
	NAV            float64   `json:"nav"`
	TotalReturn    float64   `json:"total_return"`
	WinRate        float64   `json:"win_rate"`
	TradeCount     int       `json:"trade_count"`
	OpenPositions  int       `json:"open_positions"`
	ActiveStrategy string    `json:"active_strategy"`
	PeriodStart    time.Time `json:"period_start"`
	PeriodEnd      time.Time `json:"period_end"`
}

// NAVUpdate provides a detailed NAV breakdown.
type NAVUpdate struct {
	AgentID       string  `json:"agent_id"`
	NAV           float64 `json:"nav"`
	CashBalance   float64 `json:"cash_balance"`
	PositionValue float64 `json:"position_value"`
	OpenPositions int     `json:"open_positions"`
	HighWaterMark float64 `json:"high_water_mark"`
	MaxDrawdown   float64 `json:"max_drawdown"`
	Timestamp     time.Time `json:"timestamp"`
}

// TradeExecutedMessage is published when a trade is executed.
type TradeExecutedMessage struct {
	AgentID     string  `json:"agent_id"`
	MarketID    string  `json:"market_id"`
	Platform    string  `json:"platform"`
	Direction   string  `json:"direction"`
	OutcomeID   string  `json:"outcome_id"`
	Size        float64 `json:"size"`
	Edge        float64 `json:"edge"`
	TxSignature string  `json:"tx_signature"`
	Reason      string  `json:"reason"`
	Timestamp   time.Time `json:"timestamp"`
}

// PositionResolvedMessage is published when a market resolves.
type PositionResolvedMessage struct {
	AgentID    string  `json:"agent_id"`
	MarketID   string  `json:"market_id"`
	Platform   string  `json:"platform"`
	OutcomeID  string  `json:"outcome_id"`
	Won        bool    `json:"won"`
	PnL        float64 `json:"pnl"`
	Timestamp  time.Time `json:"timestamp"`
}

// HealthStatus is the prediction market agent health heartbeat.
type HealthStatus struct {
	AgentID        string  `json:"agent_id"`
	Status         string  `json:"status"` // "trading", "idle", "halted", "error"
	ActiveStrategy string  `json:"active_strategy,omitempty"`
	NAV            float64 `json:"nav"`
	UptimeSeconds  int64   `json:"uptime_seconds"`
	TradeCount     int     `json:"trade_count"`
	CycleCount     int     `json:"cycle_count"`
}

// Transport abstracts HCS topic operations.
type Transport interface {
	Publish(ctx context.Context, topicID string, data []byte) error
	Subscribe(ctx context.Context, topicID string) (<-chan []byte, <-chan error)
}

// HandlerConfig holds configuration for the HCS handler.
type HandlerConfig struct {
	Transport     Transport
	TaskTopicID   string
	ResultTopicID string
	AgentID       string
}

// Handler manages HCS subscriptions and publishing.
type Handler struct {
	cfg    HandlerConfig
	seqNum atomic.Uint64
	taskCh chan TaskAssignment
}

// NewHandler creates an HCS handler.
func NewHandler(cfg HandlerConfig) *Handler {
	return &Handler{
		cfg:    cfg,
		taskCh: make(chan TaskAssignment, 16),
	}
}

// Tasks returns a read-only channel of incoming task assignments.
func (h *Handler) Tasks() <-chan TaskAssignment {
	return h.taskCh
}

// StartSubscription begins listening for task assignments on HCS.
func (h *Handler) StartSubscription(ctx context.Context) error {
	msgCh, errCh := h.cfg.Transport.Subscribe(ctx, h.cfg.TaskTopicID)
	if msgCh == nil {
		return ErrSubscriptionFailed
	}

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case err := <-errCh:
			if err != nil {
				return fmt.Errorf("hcs: subscription error: %w", ErrSubscriptionFailed)
			}
		case data, ok := <-msgCh:
			if !ok {
				return nil
			}
			h.processMessage(ctx, data)
		}
	}
}

func (h *Handler) processMessage(ctx context.Context, data []byte) {
	env, err := UnmarshalEnvelope(data)
	if err != nil {
		return
	}
	if env.Type != MessageTypeTaskAssignment {
		return
	}
	if env.Recipient != "" && env.Recipient != h.cfg.AgentID {
		return
	}

	var task TaskAssignment
	if err := json.Unmarshal(env.Payload, &task); err != nil {
		return
	}

	select {
	case h.taskCh <- task:
	case <-ctx.Done():
	}
}

// PublishPnL sends a P&L report to the result topic.
func (h *Handler) PublishPnL(ctx context.Context, report PnLReportMessage) error {
	return h.publish(ctx, MessageTypePnLReport, report)
}

// PublishNAVUpdate sends a NAV update to the result topic.
func (h *Handler) PublishNAVUpdate(ctx context.Context, update NAVUpdate) error {
	return h.publish(ctx, MessageTypeNAVUpdate, update)
}

// PublishTradeExecuted sends a trade event to the result topic.
func (h *Handler) PublishTradeExecuted(ctx context.Context, trade TradeExecutedMessage) error {
	return h.publish(ctx, MessageTypeTradeExecuted, trade)
}

// PublishPositionResolved sends a position resolution event.
func (h *Handler) PublishPositionResolved(ctx context.Context, msg PositionResolvedMessage) error {
	return h.publish(ctx, MessageTypePositionResolved, msg)
}

// PublishHealth sends a health heartbeat.
func (h *Handler) PublishHealth(ctx context.Context, status HealthStatus) error {
	return h.publish(ctx, MessageTypeHeartbeat, status)
}

// PublishResult sends a task result back to the coordinator.
func (h *Handler) PublishResult(ctx context.Context, result TaskResult) error {
	return h.publish(ctx, MessageTypeTaskResult, result)
}

// publish wraps a payload in an Envelope and publishes it.
func (h *Handler) publish(ctx context.Context, msgType MessageType, payload interface{}) error {
	if err := ctx.Err(); err != nil {
		return fmt.Errorf("hcs: context cancelled before publish: %w", err)
	}

	payloadData, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("hcs: marshal payload: %w", err)
	}

	env := Envelope{
		Type:        msgType,
		Sender:      h.cfg.AgentID,
		SequenceNum: h.seqNum.Add(1),
		Timestamp:   time.Now(),
		Payload:     payloadData,
	}

	data, err := env.Marshal()
	if err != nil {
		return fmt.Errorf("hcs: marshal envelope: %w", err)
	}

	if err := h.cfg.Transport.Publish(ctx, h.cfg.ResultTopicID, data); err != nil {
		return fmt.Errorf("hcs: publish %s: %w", msgType, ErrPublishFailed)
	}

	return nil
}
```

### Step 2: Create Mock Transport for Testing

Create file `projects/agent-prediction/internal/hcs/transport.go`:

```go
package hcs

import (
	"context"
	"sync"
)

// MockTransport implements Transport for testing without Hedera.
type MockTransport struct {
	mu        sync.Mutex
	published []PublishedMessage
	subCh     chan []byte
	errCh     chan error
}

// PublishedMessage records a message published via the mock transport.
type PublishedMessage struct {
	TopicID string
	Data    []byte
}

// NewMockTransport creates a mock HCS transport.
func NewMockTransport() *MockTransport {
	return &MockTransport{
		subCh: make(chan []byte, 100),
		errCh: make(chan error, 1),
	}
}

// Publish records the message for later inspection.
func (t *MockTransport) Publish(ctx context.Context, topicID string, data []byte) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	t.mu.Lock()
	defer t.mu.Unlock()
	t.published = append(t.published, PublishedMessage{TopicID: topicID, Data: data})
	return nil
}

// Subscribe returns channels for receiving mock messages.
func (t *MockTransport) Subscribe(ctx context.Context, topicID string) (<-chan []byte, <-chan error) {
	return t.subCh, t.errCh
}

// SendMockMessage injects a message into the subscription channel for testing.
func (t *MockTransport) SendMockMessage(data []byte) {
	t.subCh <- data
}

// Published returns all messages published so far.
func (t *MockTransport) Published() []PublishedMessage {
	t.mu.Lock()
	defer t.mu.Unlock()
	result := make([]PublishedMessage, len(t.published))
	copy(result, t.published)
	return result
}
```

### Step 3: Create HCS Tests

Create file `projects/agent-prediction/internal/hcs/hcs_test.go`:

```go
package hcs

import (
	"context"
	"encoding/json"
	"testing"
	"time"
)

func TestPublishPnL(t *testing.T) {
	transport := NewMockTransport()
	handler := NewHandler(HandlerConfig{
		Transport:     transport,
		TaskTopicID:   "0.0.123",
		ResultTopicID: "0.0.456",
		AgentID:       "test-agent",
	})

	report := PnLReportMessage{
		AgentID:     "test-agent",
		NAV:         12340,
		TotalReturn: 0.234,
		WinRate:     0.68,
		TradeCount:  42,
	}

	err := handler.PublishPnL(context.Background(), report)
	if err != nil {
		t.Fatalf("PublishPnL() error: %v", err)
	}

	published := transport.Published()
	if len(published) != 1 {
		t.Fatalf("expected 1 published message, got %d", len(published))
	}
	if published[0].TopicID != "0.0.456" {
		t.Errorf("expected topic 0.0.456, got %s", published[0].TopicID)
	}

	// Verify envelope format
	var env Envelope
	if err := json.Unmarshal(published[0].Data, &env); err != nil {
		t.Fatalf("unmarshal envelope: %v", err)
	}
	if env.Type != MessageTypePnLReport {
		t.Errorf("expected type %s, got %s", MessageTypePnLReport, env.Type)
	}
	if env.Sender != "test-agent" {
		t.Errorf("expected sender 'test-agent', got %q", env.Sender)
	}
}

func TestPublishTradeExecuted(t *testing.T) {
	transport := NewMockTransport()
	handler := NewHandler(HandlerConfig{
		Transport:     transport,
		ResultTopicID: "0.0.456",
		AgentID:       "test-agent",
	})

	trade := TradeExecutedMessage{
		AgentID:     "test-agent",
		MarketID:    "drift_bet:0",
		Platform:    "drift_bet",
		Direction:   "buy",
		OutcomeID:   "yes",
		Size:        500,
		Edge:        0.15,
		TxSignature: "tx123",
		Reason:      "Resolution hunter edge",
		Timestamp:   time.Now(),
	}

	err := handler.PublishTradeExecuted(context.Background(), trade)
	if err != nil {
		t.Fatalf("PublishTradeExecuted() error: %v", err)
	}

	if len(transport.Published()) != 1 {
		t.Error("expected 1 published message")
	}
}

func TestTaskSubscription(t *testing.T) {
	transport := NewMockTransport()
	handler := NewHandler(HandlerConfig{
		Transport:   transport,
		TaskTopicID: "0.0.123",
		AgentID:     "test-agent",
	})

	// Send a task assignment via mock transport
	task := TaskAssignment{TaskID: "task-1", TaskType: "execute_cycle", Priority: 1}
	payload, _ := json.Marshal(task)
	env := Envelope{
		Type:      MessageTypeTaskAssignment,
		Sender:    "coordinator",
		Recipient: "test-agent",
		Payload:   payload,
		Timestamp: time.Now(),
	}
	envData, _ := json.Marshal(env)

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	// Start subscription in background
	go func() {
		time.Sleep(100 * time.Millisecond)
		transport.SendMockMessage(envData)
		time.Sleep(100 * time.Millisecond)
		cancel() // stop subscription
	}()

	go handler.StartSubscription(ctx)

	// Wait for task
	select {
	case received := <-handler.Tasks():
		if received.TaskID != "task-1" {
			t.Errorf("expected task-1, got %s", received.TaskID)
		}
	case <-ctx.Done():
		t.Error("timed out waiting for task")
	}
}

func TestSequenceNumbers(t *testing.T) {
	transport := NewMockTransport()
	handler := NewHandler(HandlerConfig{
		Transport:     transport,
		ResultTopicID: "0.0.456",
		AgentID:       "test-agent",
	})

	ctx := context.Background()

	// Publish three messages
	handler.PublishHealth(ctx, HealthStatus{AgentID: "test-agent", Status: "trading"})
	handler.PublishHealth(ctx, HealthStatus{AgentID: "test-agent", Status: "trading"})
	handler.PublishHealth(ctx, HealthStatus{AgentID: "test-agent", Status: "trading"})

	published := transport.Published()
	if len(published) != 3 {
		t.Fatalf("expected 3 messages, got %d", len(published))
	}

	// Verify sequence numbers are incrementing
	for i, msg := range published {
		var env Envelope
		json.Unmarshal(msg.Data, &env)
		if env.SequenceNum != uint64(i+1) {
			t.Errorf("message %d: expected seq %d, got %d", i, i+1, env.SequenceNum)
		}
	}
}
```

### Step 4: Integrate HCS into Agent Startup

In `cmd/agent/main.go`, add HCS handler creation when HCS is configured:

```go
// After creating other dependencies, before creating Agent:
var hcsHandler *hcs.Handler

if cfg.HCSTaskTopicID != "" && cfg.HCSResultTopicID != "" {
	// For MVP, use mock transport if no Hedera credentials
	var transport hcs.Transport
	if cfg.HCSOperatorID != "" && cfg.HCSOperatorKey != "" {
		// TODO: Create real Hedera transport using Hedera Go SDK
		// transport = hcs.NewHederaTransport(cfg.HCSOperatorID, cfg.HCSOperatorKey)
		log.Warn("Hedera transport not yet implemented, using mock")
		transport = hcs.NewMockTransport()
	} else {
		transport = hcs.NewMockTransport()
	}

	hcsHandler = hcs.NewHandler(hcs.HandlerConfig{
		Transport:     transport,
		TaskTopicID:   cfg.HCSTaskTopicID,
		ResultTopicID: cfg.HCSResultTopicID,
		AgentID:       cfg.AgentID,
	})
	log.Info("HCS handler configured", "task_topic", cfg.HCSTaskTopicID, "result_topic", cfg.HCSResultTopicID)
}

// Pass hcsHandler to agent.New() (can be nil if HCS not configured)
```

## Done When

- [ ] All requirements met
- [ ] `internal/hcs/hcs.go` defines all prediction market message types (PnL, NAV, Trade, Resolution, Health)
- [ ] HCS Handler implements Subscribe, Publish for all message types
- [ ] Envelope format matches coordinator protocol from agent-defi
- [ ] Mock transport enables testing without Hedera
- [ ] Sequence numbers increment correctly across messages
- [ ] Task subscription correctly filters by recipient
- [ ] `go test ./internal/hcs/...` passes with all test cases
- [ ] HCS integration is optional (agent runs without HCS if not configured)
- [ ] Trade execution events are published to HCS when trades execute
