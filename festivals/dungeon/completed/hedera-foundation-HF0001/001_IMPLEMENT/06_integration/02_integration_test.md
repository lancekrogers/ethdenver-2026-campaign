---
fest_type: task
fest_id: 02_integration_test.md
fest_name: integration_test
fest_parent: 06_integration
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Write E2E Integration Test

**Task Number:** 02 | **Sequence:** 06_integration | **Autonomy:** medium

## Objective

Write and run a comprehensive end-to-end integration test that exercises the full festival cycle on Hedera testnet: create topics and tokens, assign tasks via HCS, collect results via HCS subscription, enforce quality gates, and settle payment via HTS transfer. This test is the primary demonstration artifact for the Hedera Track 3 bounty.

## Requirements

- [ ] Create `internal/integration/e2e_test.go` with the full cycle test
- [ ] Test uses real Hedera testnet (build tag `integration`)
- [ ] Test creates HCS topics, HTS token, and runs the coordinator
- [ ] Test verifies: topic creation, message publish, message subscribe, token create, token transfer
- [ ] Test demonstrates the full plan-to-payment lifecycle
- [ ] Test cleans up created resources (delete topics if possible)
- [ ] Test has a reasonable timeout (5 minutes max)

## Implementation

### Step 1: Create e2e_test.go

Create `internal/integration/e2e_test.go` with the `integration` build tag:

```go
//go:build integration

package integration_test

import (
    "context"
    "encoding/json"
    "testing"
    "time"

    "your-module/internal/coordinator"
    "your-module/internal/hedera/hcs"
    "your-module/internal/hedera/hts"
    "your-module/internal/hedera/schedule"
    "your-module/internal/integration"
)
```

### Step 2: Implement the E2E test function

The test follows these phases:

**Phase 1: Setup**

```go
func TestE2E_FullFestivalCycle(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping E2E test in short mode")
    }

    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
    defer cancel()

    // Load testnet configuration
    cfg, err := integration.LoadTestnetConfig()
    if err != nil {
        t.Fatalf("load testnet config: %v", err)
    }

    // Create Hedera client for coordinator
    coordClient, err := integration.NewClientForAccount(cfg.CoordinatorAccount)
    if err != nil {
        t.Fatalf("create coordinator client: %v", err)
    }
```

**Phase 2: Create HCS Topics**

```go
    // Create HCS topics
    topicSvc := hcs.NewTopicService(coordClient)

    taskTopicID, err := topicSvc.CreateTopic(ctx, "festival-tasks")
    if err != nil {
        t.Fatalf("create task topic: %v", err)
    }
    t.Logf("Created task topic: %s", taskTopicID)

    statusTopicID, err := topicSvc.CreateTopic(ctx, "agent-status")
    if err != nil {
        t.Fatalf("create status topic: %v", err)
    }
    t.Logf("Created status topic: %s", statusTopicID)
```

**Phase 3: Create HTS Payment Token**

```go
    // Create HTS payment token
    tokenSvc := hts.NewTokenService(coordClient)
    tokenCfg := hts.DefaultTokenConfig()
    tokenCfg.TreasuryAccountID = cfg.CoordinatorAccount.AccountID

    paymentTokenID, err := tokenSvc.CreateFungibleToken(ctx, tokenCfg)
    if err != nil {
        t.Fatalf("create payment token: %v", err)
    }
    t.Logf("Created payment token: %s", paymentTokenID)

    // Associate token with agent accounts
    transferSvc := hts.NewTransferService(coordClient)

    // Note: Token association requires signing with the agent's key.
    // For the E2E test, create agent clients and associate from their perspective.
    agent1Client, err := integration.NewClientForAccount(cfg.Agent1Account)
    if err != nil {
        t.Fatalf("create agent1 client: %v", err)
    }
    agent1TransferSvc := hts.NewTransferService(agent1Client)
    if err := agent1TransferSvc.AssociateToken(ctx, paymentTokenID, cfg.Agent1Account.AccountID); err != nil {
        t.Fatalf("associate token with agent1: %v", err)
    }

    agent2Client, err := integration.NewClientForAccount(cfg.Agent2Account)
    if err != nil {
        t.Fatalf("create agent2 client: %v", err)
    }
    agent2TransferSvc := hts.NewTransferService(agent2Client)
    if err := agent2TransferSvc.AssociateToken(ctx, paymentTokenID, cfg.Agent2Account.AccountID); err != nil {
        t.Fatalf("associate token with agent2: %v", err)
    }
```

**Phase 4: Create Plan and Assign Tasks**

```go
    // Create a test plan
    plan := coordinator.Plan{
        FestivalID: "e2e-test",
        Sequences: []coordinator.PlanSequence{
            {
                ID: "test-sequence",
                Tasks: []coordinator.PlanTask{
                    {ID: "task-1", Name: "First Task", AssignTo: cfg.Agent1Account.AccountID.String()},
                    {ID: "task-2", Name: "Second Task", AssignTo: cfg.Agent2Account.AccountID.String()},
                },
            },
        },
    }

    // Set up publisher and assigner
    publisher := hcs.NewPublisher(coordClient, hcs.DefaultPublishConfig())
    assigner := coordinator.NewAssigner(publisher, taskTopicID, nil)

    assignedIDs, err := assigner.AssignTasks(ctx, plan)
    if err != nil {
        t.Fatalf("assign tasks: %v", err)
    }
    t.Logf("Assigned %d tasks: %v", len(assignedIDs), assignedIDs)

    if len(assignedIDs) != 2 {
        t.Fatalf("expected 2 assigned tasks, got %d", len(assignedIDs))
    }
```

**Phase 5: Verify HCS Messages (Subscribe and Check)**

```go
    // Subscribe to task topic and verify messages arrive
    subscriber := hcs.NewSubscriber(coordClient, hcs.DefaultSubscribeConfig())
    subCtx, subCancel := context.WithTimeout(ctx, 30*time.Second)
    defer subCancel()

    msgCh, errCh := subscriber.Subscribe(subCtx, taskTopicID)

    receivedCount := 0
    timeout := time.After(30 * time.Second)

    for receivedCount < 2 {
        select {
        case msg, ok := <-msgCh:
            if !ok {
                t.Fatal("message channel closed before receiving all messages")
            }
            t.Logf("Received HCS message: type=%s task=%s", msg.Type, msg.TaskID)
            receivedCount++
        case err := <-errCh:
            t.Logf("HCS subscription error: %v", err)
        case <-timeout:
            t.Fatalf("timed out waiting for HCS messages, received %d of 2", receivedCount)
        }
    }
    subCancel() // stop subscription

    t.Log("HCS message delivery verified")
```

**Phase 6: Execute Payment**

```go
    // Configure and run payment for task-1
    coordConfig := coordinator.Config{
        TaskTopicID:          taskTopicID,
        StatusTopicID:        statusTopicID,
        PaymentTokenID:       paymentTokenID,
        TreasuryAccountID:    cfg.CoordinatorAccount.AccountID,
        DefaultPaymentAmount: 100,
        MonitorPollInterval:  5 * time.Second,
        QualityGateTimeout:   30 * time.Second,
    }

    paymentMgr := coordinator.NewPayment(transferSvc, publisher, coordConfig)

    err = paymentMgr.PayForTask(ctx, "task-1", cfg.Agent1Account.AccountID.String(), 100)
    if err != nil {
        t.Fatalf("pay for task-1: %v", err)
    }
    t.Log("Payment for task-1 completed")

    // Verify payment status
    payStatus, err := paymentMgr.PaymentStatus("task-1")
    if err != nil {
        t.Fatalf("payment status: %v", err)
    }
    if payStatus != coordinator.PaymentProcessed {
        t.Fatalf("expected payment processed, got %s", payStatus)
    }

    t.Log("E2E test passed: plan -> assign -> HCS verify -> payment -> done")
}
```

### Step 3: Add heartbeat verification (optional bonus)

If time permits, add a section that starts and stops the heartbeat:

```go
    // Start heartbeat for agent-1
    schedulerSvc := schedule.NewScheduleService(agent1Client)
    hbConfig := schedule.HeartbeatConfig{
        Interval:  10 * time.Second,
        Memo:      "e2e-heartbeat",
        AgentID:   "agent-1",
        AccountID: cfg.Agent1Account.AccountID,
    }
    hb, err := schedule.NewHeartbeat(agent1Client, schedulerSvc, hbConfig)
    if err != nil {
        t.Fatalf("create heartbeat: %v", err)
    }

    hbCtx, hbCancel := context.WithTimeout(ctx, 15*time.Second)
    errCh = hb.Start(hbCtx)

    // Wait for at least one heartbeat
    time.Sleep(12 * time.Second)
    hbCancel()

    if hb.LastHeartbeat().IsZero() {
        t.Error("expected at least one successful heartbeat")
    } else {
        t.Logf("Heartbeat last fired at: %s", hb.LastHeartbeat())
    }
```

### Step 4: Run the test

```bash
# With testnet credentials in .env
source .env
go test ./internal/integration/... -v -count=1 -tags=integration -timeout=10m
```

### Step 5: Document the run

Create `internal/integration/README_E2E.md` (or a comment in the test file) documenting:

- How to set up .env
- How to run the test
- Expected output
- Troubleshooting common issues (rate limits, insufficient HBAR, token association errors)

## Done When

- [ ] `internal/integration/e2e_test.go` exists with `integration` build tag
- [ ] Test creates HCS topics and HTS token on testnet
- [ ] Test assigns tasks via HCS and verifies message delivery via subscription
- [ ] Test executes HTS payment and verifies payment status
- [ ] Test passes end-to-end within 5 minutes
- [ ] Test cleans up or documents resource creation
- [ ] Running instructions are documented
