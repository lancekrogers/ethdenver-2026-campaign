---
fest_type: task
fest_id: 01_solana_wallet_setup.md
fest_name: solana_wallet_setup
fest_parent: 04_mainnet_deployment
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.33626-06:00
fest_tracking: true
---

# Task: Solana Wallet Setup and Management

## Objective

Implement Solana wallet management for the prediction market agent, including keypair loading from environment variables, USDC balance checking, SOL balance checking (for transaction fees), and a wallet health check that verifies sufficient balances before the agent starts trading.

## Requirements

- [ ] Solana keypair loading from base58-encoded private key in env var
- [ ] USDC balance query on Solana mainnet
- [ ] SOL balance query (needed for transaction fees)
- [ ] Wallet health check: minimum SOL for fees, minimum USDC for trading
- [ ] Public key derivation from private key
- [ ] Wallet info logging on startup (public key, balances -- never log private key)
- [ ] Integration with Drift BET for deposit/trading account setup

## Implementation

### Step 1: Create Wallet Package

Create file `projects/agent-prediction/internal/wallet/wallet.go`:

```go
package wallet

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/gagliardetto/solana-go"
)

// Sentinel errors for wallet operations.
var (
	ErrInsufficientSOL  = errors.New("wallet: insufficient SOL for transaction fees")
	ErrInsufficientUSDC = errors.New("wallet: insufficient USDC for trading")
	ErrKeyLoadFailed    = errors.New("wallet: failed to load private key")
	ErrRPCFailed        = errors.New("wallet: Solana RPC call failed")
)

// Config holds wallet configuration.
type Config struct {
	// PrivateKeyBase58 is the base58-encoded Solana private key.
	PrivateKeyBase58 string

	// RPCURL is the Solana RPC endpoint.
	RPCURL string

	// USDCMint is the USDC SPL token mint address on Solana mainnet.
	// Default: EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v
	USDCMint string

	// MinSOLBalance is the minimum SOL balance to start trading (for fees).
	// Default: 0.05 SOL
	MinSOLBalance float64

	// MinUSDCBalance is the minimum USDC balance to start trading.
	// Default: 100 USDC
	MinUSDCBalance float64

	// HTTPTimeout for RPC calls.
	HTTPTimeout time.Duration
}

// Manager handles Solana wallet operations.
type Manager struct {
	cfg       Config
	account   solana.PrivateKey
	publicKey solana.PublicKey
	client    *http.Client
}

// NewManager creates a wallet manager from the given config.
func NewManager(cfg Config) (*Manager, error) {
	if cfg.RPCURL == "" {
		cfg.RPCURL = "https://api.mainnet-beta.solana.com"
	}
	if cfg.USDCMint == "" {
		cfg.USDCMint = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
	}
	if cfg.MinSOLBalance == 0 {
		cfg.MinSOLBalance = 0.05
	}
	if cfg.MinUSDCBalance == 0 {
		cfg.MinUSDCBalance = 100
	}
	if cfg.HTTPTimeout == 0 {
		cfg.HTTPTimeout = 15 * time.Second
	}

	// Load keypair from base58
	account, err := solana.PrivateKeyFromBase58(cfg.PrivateKeyBase58)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrKeyLoadFailed, err)
	}

	return &Manager{
		cfg:       cfg,
		account:   account,
		publicKey: account.PublicKey(),
		client:    &http.Client{Timeout: cfg.HTTPTimeout},
	}, nil
}

// PublicKey returns the wallet's public key.
func (m *Manager) PublicKey() solana.PublicKey {
	return m.publicKey
}

// PublicKeyString returns the base58-encoded public key.
func (m *Manager) PublicKeyString() string {
	return m.publicKey.String()
}

// PrivateKey returns the private key (use cautiously -- only for signing).
func (m *Manager) PrivateKey() solana.PrivateKey {
	return m.account
}

// SOLBalance returns the wallet's SOL balance in lamports and SOL.
func (m *Manager) SOLBalance(ctx context.Context) (lamports uint64, sol float64, err error) {
	result, err := m.rpcCall(ctx, "getBalance", []interface{}{m.publicKey.String()})
	if err != nil {
		return 0, 0, fmt.Errorf("wallet: get SOL balance: %w", err)
	}

	var resp struct {
		Value uint64 `json:"value"`
	}
	if err := json.Unmarshal(result, &resp); err != nil {
		return 0, 0, fmt.Errorf("wallet: decode SOL balance: %w", err)
	}

	return resp.Value, float64(resp.Value) / 1e9, nil
}

// USDCBalance returns the USDC token account balance.
func (m *Manager) USDCBalance(ctx context.Context) (float64, error) {
	// Find the associated token account for USDC
	params := []interface{}{
		m.publicKey.String(),
		map[string]interface{}{
			"mint": m.cfg.USDCMint,
		},
		map[string]string{
			"encoding": "jsonParsed",
		},
	}

	result, err := m.rpcCall(ctx, "getTokenAccountsByOwner", params)
	if err != nil {
		return 0, fmt.Errorf("wallet: get USDC balance: %w", err)
	}

	var resp struct {
		Value []struct {
			Account struct {
				Data struct {
					Parsed struct {
						Info struct {
							TokenAmount struct {
								UIAmount float64 `json:"uiAmount"`
							} `json:"tokenAmount"`
						} `json:"info"`
					} `json:"parsed"`
				} `json:"data"`
			} `json:"account"`
		} `json:"value"`
	}
	if err := json.Unmarshal(result, &resp); err != nil {
		return 0, fmt.Errorf("wallet: decode USDC balance: %w", err)
	}

	if len(resp.Value) == 0 {
		return 0, nil // no USDC token account
	}

	return resp.Value[0].Account.Data.Parsed.Info.TokenAmount.UIAmount, nil
}

// HealthCheck verifies the wallet has sufficient balances for trading.
func (m *Manager) HealthCheck(ctx context.Context) error {
	// Check SOL balance (needed for transaction fees)
	_, solBalance, err := m.SOLBalance(ctx)
	if err != nil {
		return fmt.Errorf("wallet health check: %w", err)
	}
	if solBalance < m.cfg.MinSOLBalance {
		return fmt.Errorf("%w: have %.4f SOL, need %.4f SOL",
			ErrInsufficientSOL, solBalance, m.cfg.MinSOLBalance)
	}

	// Check USDC balance (needed for trading)
	usdcBalance, err := m.USDCBalance(ctx)
	if err != nil {
		return fmt.Errorf("wallet health check: %w", err)
	}
	if usdcBalance < m.cfg.MinUSDCBalance {
		return fmt.Errorf("%w: have %.2f USDC, need %.2f USDC",
			ErrInsufficientUSDC, usdcBalance, m.cfg.MinUSDCBalance)
	}

	return nil
}

// Info returns a safe summary of wallet state (no private key).
type WalletInfo struct {
	PublicKey   string  `json:"public_key"`
	SOLBalance float64 `json:"sol_balance"`
	USDCBalance float64 `json:"usdc_balance"`
	Healthy    bool    `json:"healthy"`
}

// GetInfo returns wallet status information for logging.
func (m *Manager) GetInfo(ctx context.Context) (*WalletInfo, error) {
	_, solBal, solErr := m.SOLBalance(ctx)
	usdcBal, usdcErr := m.USDCBalance(ctx)

	info := &WalletInfo{
		PublicKey:   m.PublicKeyString(),
		SOLBalance:  solBal,
		USDCBalance: usdcBal,
		Healthy:     solErr == nil && usdcErr == nil,
	}

	if solErr != nil {
		return info, solErr
	}
	return info, usdcErr
}

// rpcCall performs a Solana JSON-RPC call.
func (m *Manager) rpcCall(ctx context.Context, method string, params []interface{}) (json.RawMessage, error) {
	reqBody := map[string]interface{}{
		"jsonrpc": "2.0",
		"id":      1,
		"method":  method,
		"params":  params,
	}

	data, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("wallet: marshal RPC request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, m.cfg.RPCURL,
		io.NopCloser(jsonReader(data)))
	if err != nil {
		return nil, fmt.Errorf("wallet: create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := m.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrRPCFailed, err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("wallet: read response: %w", err)
	}

	var rpcResp struct {
		Result json.RawMessage `json:"result"`
		Error  *struct {
			Code    int    `json:"code"`
			Message string `json:"message"`
		} `json:"error"`
	}
	if err := json.Unmarshal(body, &rpcResp); err != nil {
		return nil, fmt.Errorf("wallet: decode RPC response: %w", err)
	}

	if rpcResp.Error != nil {
		return nil, fmt.Errorf("%w: %d %s", ErrRPCFailed, rpcResp.Error.Code, rpcResp.Error.Message)
	}

	return rpcResp.Result, nil
}

// jsonReader wraps a byte slice as an io.Reader.
func jsonReader(data []byte) io.Reader {
	return io.NopCloser(ioReader(data))
}

type byteReader struct {
	data []byte
	pos  int
}

func ioReader(data []byte) *byteReader {
	return &byteReader{data: data}
}

func (r *byteReader) Read(p []byte) (n int, err error) {
	if r.pos >= len(r.data) {
		return 0, io.EOF
	}
	n = copy(p, r.data[r.pos:])
	r.pos += n
	return n, nil
}
```

### Step 2: Integrate Wallet into Agent Startup

In `cmd/agent/main.go`, add wallet setup before creating the agent:

```go
// After config validation, before creating adapter:
if !cfg.MockMode {
	walletMgr, err := wallet.NewManager(wallet.Config{
		PrivateKeyBase58: cfg.SolanaPrivateKey,
		RPCURL:           cfg.SolanaRPCURL,
		MinSOLBalance:    0.05,
		MinUSDCBalance:   100,
	})
	if err != nil {
		log.Error("wallet setup failed", "error", err)
		os.Exit(1)
	}

	// Derive wallet authority from private key
	cfg.WalletAuthority = walletMgr.PublicKeyString()

	// Health check
	info, err := walletMgr.GetInfo(context.Background())
	if err != nil {
		log.Warn("wallet info retrieval failed", "error", err)
	} else {
		log.Info("wallet ready",
			"public_key", info.PublicKey,
			"sol_balance", info.SOLBalance,
			"usdc_balance", info.USDCBalance)
	}

	if err := walletMgr.HealthCheck(context.Background()); err != nil {
		log.Error("wallet health check failed", "error", err)
		os.Exit(1)
	}
}
```

## Done When

- [ ] All requirements met
- [ ] `internal/wallet/wallet.go` loads Solana keypair from base58 private key
- [ ] SOL balance query works against Solana mainnet RPC
- [ ] USDC balance query works (token account lookup by mint)
- [ ] `HealthCheck()` validates minimum SOL and USDC balances
- [ ] `GetInfo()` returns wallet status without exposing private key
- [ ] Agent startup logs wallet public key and balances
- [ ] Agent refuses to start in non-mock mode with insufficient balances
- [ ] `go build ./...` compiles with `gagliardetto/solana-go` dependency
