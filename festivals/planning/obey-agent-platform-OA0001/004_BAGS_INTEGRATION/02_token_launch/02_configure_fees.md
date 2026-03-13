---
fest_type: task
fest_id: 02_configure_fees.md
fest_name: configure_fees
fest_parent: 02_token_launch
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.492933-06:00
fest_tracking: true
---

# Task: Configure OBEY Token Fee Sharing

## Objective

Implement fee share configuration for the OBEY token on Bags, splitting the 1% creator fee among four recipients: Platform Treasury (40%), Agent Performance Pool (30%), Community/Holders (20%), and Creator (10%).

## Requirements

- [ ] Configure fee sharing via `POST /fee-share/config` with 4 claimers and correct bps allocations
- [ ] Wallet addresses for each recipient loaded from environment config
- [ ] Validation: claimers bps must sum to exactly 10000 (100%)
- [ ] Validation: all wallet addresses must be valid Solana base58 pubkeys (non-empty)
- [ ] Idempotency: if fee share already configured (409 conflict), update via `PUT /fee-share/admin/config`
- [ ] Log the configured fee share breakdown for verification

## Implementation

### Step 1: Define fee share constants and allocation struct

Add to `projects/agent-bags/internal/token/token.go`:

```go
// FeeShareAllocation defines the OBEY token fee distribution.
type FeeShareAllocation struct {
    TreasuryWallet        string // 40% — operational costs, development
    PerformancePoolWallet string // 30% — rewards for top-performing agents
    CommunityWallet       string // 20% — incentivize holding (Bags dividends to top 100)
    CreatorWallet         string // 10% — founder share
}

const (
    TreasuryShareBps        = 4000 // 40%
    PerformancePoolShareBps = 3000 // 30%
    CommunityShareBps       = 2000 // 20%
    CreatorShareBps         = 1000 // 10%
)
```

### Step 2: Implement ConfigureFeeShare on Manager

```go
// ConfigureFeeShare sets up the 4-way fee split for the OBEY token.
// Must be called after CreateToken (requires mint address).
func (m *Manager) ConfigureFeeShare(ctx context.Context, alloc FeeShareAllocation) error {
    if err := ctx.Err(); err != nil {
        return err
    }
    if m.mintAddr == "" {
        return fmt.Errorf("mint address not set: call CreateToken first")
    }

    totalBps := TreasuryShareBps + PerformancePoolShareBps + CommunityShareBps + CreatorShareBps
    if totalBps != 10000 {
        return fmt.Errorf("fee share bps sum to %d, must be 10000", totalBps)
    }

    wallets := map[string]string{
        "treasury":         alloc.TreasuryWallet,
        "performance_pool": alloc.PerformancePoolWallet,
        "community":        alloc.CommunityWallet,
        "creator":          alloc.CreatorWallet,
    }
    for label, addr := range wallets {
        if addr == "" {
            return fmt.Errorf("fee share wallet for %s is empty", label)
        }
    }

    config := bags.FeeShareConfig{
        Mint: m.mintAddr,
        Claimers: []bags.FeeClaimer{
            {Wallet: alloc.TreasuryWallet, ShareBps: TreasuryShareBps, Label: "Platform Treasury"},
            {Wallet: alloc.PerformancePoolWallet, ShareBps: PerformancePoolShareBps, Label: "Agent Performance Pool"},
            {Wallet: alloc.CommunityWallet, ShareBps: CommunityShareBps, Label: "Community/Holders"},
            {Wallet: alloc.CreatorWallet, ShareBps: CreatorShareBps, Label: "Creator"},
        },
    }

    err := m.client.ConfigureFeeShare(ctx, config)
    if err != nil {
        if apiErr, ok := err.(*bags.APIError); ok && apiErr.StatusCode == 409 {
            if updateErr := m.client.UpdateFeeShareConfig(ctx, config); updateErr != nil {
                return fmt.Errorf("updating existing fee share config: %w", updateErr)
            }
            return nil
        }
        return fmt.Errorf("configuring fee share: %w", err)
    }
    return nil
}
```

### Step 3: Update environment config

Add to `.env.example`:

```
# Fee share wallets (Solana pubkeys)
PERFORMANCE_POOL_WALLET=
COMMUNITY_WALLET=
CREATOR_WALLET=
```

Load these in `cmd/agent-bags/main.go` config struct and pass to `ConfigureFeeShare` after `CreateToken` completes.

### Step 4: Wire into startup sequence

In `run()`, after token creation:

```go
alloc := token.FeeShareAllocation{
    TreasuryWallet:        cfg.TreasuryWallet,
    PerformancePoolWallet: cfg.PerformancePoolWallet,
    CommunityWallet:       cfg.CommunityWallet,
    CreatorWallet:         cfg.CreatorWallet,
}
if err := tokenMgr.ConfigureFeeShare(ctx, alloc); err != nil {
    return fmt.Errorf("configuring fee share: %w", err)
}
```

### Step 5: Write tests

In `projects/agent-bags/internal/token/token_test.go`:

1. `TestConfigureFeeShareSuccess` — mock API accepts config, verify 4 claimers with correct bps
2. `TestConfigureFeeShareNoMint` — error when mint not set
3. `TestConfigureFeeShareConflictUpdates` — mock 409 on POST, verify PUT called with same config
4. `TestConfigureFeeShareEmptyWallet` — error when any wallet address is empty string
5. `TestFeeBpsSum` — verify constants sum to exactly 10000

## Done When

- [ ] All requirements met
- [ ] Fee config sends exactly 4 claimers with bps: 4000, 3000, 2000, 1000
- [ ] 409 conflict triggers update path instead of failure
- [ ] Empty wallet addresses are rejected before API call
- [ ] `.env.example` includes PERFORMANCE_POOL_WALLET, COMMUNITY_WALLET, CREATOR_WALLET
- [ ] `go test ./internal/token/...` passes
