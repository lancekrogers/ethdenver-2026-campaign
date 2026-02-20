---
fest_type: task
fest_id: 01_setup_testnet.md
fest_name: setup_testnet
fest_parent: 06_integration
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Set Up Testnet Accounts

**Task Number:** 01 | **Sequence:** 06_integration | **Autonomy:** medium

## Objective

Set up Hedera testnet accounts for the coordinator and two worker agents. Fund accounts with testnet HBAR, configure the environment, and document the setup so other developers can reproduce it. This provides the infrastructure foundation for the E2E integration test.

## Requirements

- [ ] Create 3 Hedera testnet accounts: coordinator, agent-1, agent-2
- [ ] Fund each account with testnet HBAR via the Hedera faucet
- [ ] Create `.env.example` documenting all required environment variables
- [ ] Create `internal/integration/testnet.go` with account configuration helpers
- [ ] Verify all accounts are operational by querying their balances
- [ ] Document the account setup process for reproducibility

## Implementation

### Step 1: Create testnet accounts

Use the Hedera Portal to create testnet accounts:

1. Navigate to <https://portal.hedera.com/>
2. Create an account (or use existing developer account)
3. Generate 3 testnet accounts via the portal dashboard

For each account, you will receive:

- Account ID (e.g., `0.0.12345`)
- Private key (DER-encoded or hex)
- Public key

Label the accounts:

- **Coordinator**: The treasury account that holds payment tokens and orchestrates
- **Agent-1**: First worker agent
- **Agent-2**: Second worker agent

### Step 2: Fund accounts

Each testnet account needs HBAR to pay transaction fees. Use the Hedera testnet faucet:

1. Go to <https://portal.hedera.com/>
2. Use the faucet to send testnet HBAR to each account
3. Minimum 100 HBAR per account for development and testing

### Step 3: Create .env.example

Create `.env.example` in the agent-coordinator project root:

```env
# Hedera Testnet Configuration
# Copy this file to .env and fill in your actual testnet values.

# Network
HEDERA_NETWORK=testnet

# Coordinator Account (Treasury)
HEDERA_COORDINATOR_ACCOUNT_ID=0.0.XXXXX
HEDERA_COORDINATOR_PRIVATE_KEY=302e020100300506...

# Agent 1 Account
HEDERA_AGENT1_ACCOUNT_ID=0.0.XXXXX
HEDERA_AGENT1_PRIVATE_KEY=302e020100300506...

# Agent 2 Account
HEDERA_AGENT2_ACCOUNT_ID=0.0.XXXXX
HEDERA_AGENT2_PRIVATE_KEY=302e020100300506...

# HCS Topics (created by the integration test or set manually)
HCS_TASK_TOPIC_ID=0.0.XXXXX
HCS_STATUS_TOPIC_ID=0.0.XXXXX

# HTS Token (created by the integration test or set manually)
HTS_PAYMENT_TOKEN_ID=0.0.XXXXX

# Daemon Configuration (for daemon client)
DAEMON_ADDRESS=localhost:50051
DAEMON_TLS_ENABLED=false
```

### Step 4: Create testnet.go helper

Create `internal/integration/testnet.go` with helpers for loading testnet configuration:

```go
package integration

import (
    "fmt"
    "os"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// TestnetConfig holds all testnet account configuration.
type TestnetConfig struct {
    Network            string
    CoordinatorAccount AccountConfig
    Agent1Account      AccountConfig
    Agent2Account      AccountConfig
}

// AccountConfig holds a single Hedera account's configuration.
type AccountConfig struct {
    AccountID  hedera.AccountID
    PrivateKey hedera.PrivateKey
}

// LoadTestnetConfig loads configuration from environment variables.
func LoadTestnetConfig() (*TestnetConfig, error) {
    coordAcct, err := loadAccountConfig("HEDERA_COORDINATOR")
    if err != nil {
        return nil, fmt.Errorf("load coordinator config: %w", err)
    }

    agent1Acct, err := loadAccountConfig("HEDERA_AGENT1")
    if err != nil {
        return nil, fmt.Errorf("load agent1 config: %w", err)
    }

    agent2Acct, err := loadAccountConfig("HEDERA_AGENT2")
    if err != nil {
        return nil, fmt.Errorf("load agent2 config: %w", err)
    }

    return &TestnetConfig{
        Network:            getEnvOrDefault("HEDERA_NETWORK", "testnet"),
        CoordinatorAccount: *coordAcct,
        Agent1Account:      *agent1Acct,
        Agent2Account:      *agent2Acct,
    }, nil
}

func loadAccountConfig(prefix string) (*AccountConfig, error) {
    accountIDStr := os.Getenv(prefix + "_ACCOUNT_ID")
    if accountIDStr == "" {
        return nil, fmt.Errorf("%s_ACCOUNT_ID not set", prefix)
    }

    accountID, err := hedera.AccountIDFromString(accountIDStr)
    if err != nil {
        return nil, fmt.Errorf("parse %s_ACCOUNT_ID %q: %w", prefix, accountIDStr, err)
    }

    privateKeyStr := os.Getenv(prefix + "_PRIVATE_KEY")
    if privateKeyStr == "" {
        return nil, fmt.Errorf("%s_PRIVATE_KEY not set", prefix)
    }

    privateKey, err := hedera.PrivateKeyFromString(privateKeyStr)
    if err != nil {
        return nil, fmt.Errorf("parse %s_PRIVATE_KEY: %w", prefix, err)
    }

    return &AccountConfig{
        AccountID:  accountID,
        PrivateKey: privateKey,
    }, nil
}

func getEnvOrDefault(key, defaultVal string) string {
    val := os.Getenv(key)
    if val == "" {
        return defaultVal
    }
    return val
}

// NewClientForAccount creates a Hedera client configured for a specific account on testnet.
func NewClientForAccount(acct AccountConfig) (*hedera.Client, error) {
    client := hedera.ClientForTestnet()
    client.SetOperator(acct.AccountID, acct.PrivateKey)
    return client, nil
}
```

### Step 5: Verify accounts

Create a simple verification script or test that confirms all accounts are funded:

```go
// internal/integration/verify_accounts_test.go
//go:build integration

package integration_test

import (
    "context"
    "testing"

    "your-module/internal/integration"
    "github.com/hashgraph/hedera-sdk-go/v2"
)

func TestVerifyTestnetAccounts(t *testing.T) {
    cfg, err := integration.LoadTestnetConfig()
    if err != nil {
        t.Skipf("testnet config not available: %v", err)
    }

    accounts := []struct {
        name   string
        config integration.AccountConfig
    }{
        {"coordinator", cfg.CoordinatorAccount},
        {"agent-1", cfg.Agent1Account},
        {"agent-2", cfg.Agent2Account},
    }

    for _, acct := range accounts {
        t.Run(acct.name, func(t *testing.T) {
            client, err := integration.NewClientForAccount(acct.config)
            if err != nil {
                t.Fatalf("create client: %v", err)
            }

            balance, err := hedera.NewAccountBalanceQuery().
                SetAccountID(acct.config.AccountID).
                Execute(client)
            if err != nil {
                t.Fatalf("query balance for %s: %v", acct.config.AccountID, err)
            }

            hbarBalance := balance.Hbars.As(hedera.HbarUnits.Hbar)
            t.Logf("%s (%s): %.2f HBAR", acct.name, acct.config.AccountID, hbarBalance)

            if hbarBalance < 10 {
                t.Errorf("%s has insufficient HBAR: %.2f (need at least 10)", acct.name, hbarBalance)
            }
        })
    }
}
```

Replace `your-module` with the actual module path.

### Step 6: Add .env to .gitignore

Ensure `.env` is in `.gitignore` (never commit actual keys):

```
# In .gitignore
.env
```

## Done When

- [ ] 3 testnet accounts created (coordinator, agent-1, agent-2)
- [ ] All accounts funded with at least 100 testnet HBAR
- [ ] `.env.example` exists with all variable documentation
- [ ] `.env` is in `.gitignore`
- [ ] `internal/integration/testnet.go` provides config loading helpers
- [ ] Account verification test passes when .env is configured
- [ ] Another developer can follow the documentation to set up their own testnet accounts
