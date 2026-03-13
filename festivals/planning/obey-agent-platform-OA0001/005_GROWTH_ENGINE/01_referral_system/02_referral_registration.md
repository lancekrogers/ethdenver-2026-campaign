---
fest_type: task
fest_id: 02_referral_registration.md
fest_name: referral_registration
fest_parent: 01_referral_system
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.530363-06:00
fest_tracking: true
---

# Task: Referral Code Generation & Registration API

## Objective

Implement the off-chain referral code system that generates unique referral codes for every wallet, maps codes to wallet addresses, and handles referral registration when new users sign up with a code.

## Requirements

- [ ] Referral code format: `OBEY-XXXXXX` where X is alphanumeric (6 chars, case-insensitive)
- [ ] Every wallet automatically gets a referral code on first interaction
- [ ] Referral code -> wallet address mapping stored in PostgreSQL
- [ ] Registration endpoint: accept referral code, validate, trigger on-chain `initialize_referral`
- [ ] Referral link format: `https://obeyplatform.xyz/ref/OBEY-XXXXXX`
- [ ] REST API endpoints: `POST /api/referrals/register`, `GET /api/referrals/code/:wallet`
- [ ] Rate limiting on registration to prevent spam

## Implementation

### Step 1: Database schema

Create migration for the referral table:

```sql
CREATE TABLE referral_codes (
    id          BIGSERIAL PRIMARY KEY,
    wallet      TEXT NOT NULL UNIQUE,
    code        TEXT NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_referral_codes_code ON referral_codes(code);
CREATE INDEX idx_referral_codes_wallet ON referral_codes(wallet);

CREATE TABLE referral_registrations (
    id              BIGSERIAL PRIMARY KEY,
    user_wallet     TEXT NOT NULL UNIQUE,
    referrer_wallet TEXT NOT NULL,
    referral_code   TEXT NOT NULL,
    tx_signature    TEXT,           -- on-chain init_referral tx
    registered_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Step 2: Implement referral code generation

In the platform API service (Go):

```go
package referral

import (
    "context"
    "crypto/rand"
    "database/sql"
    "fmt"
    "strings"
)

const codeAlphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // no 0/O/1/I to avoid confusion
const codeLength = 6
const codePrefix = "OBEY-"

// Service manages referral codes and registrations.
type Service struct {
    db     *sql.DB
    solana SolanaClient // interface to submit on-chain txs
}

// GetOrCreateCode returns the referral code for a wallet.
// Creates a new code if one doesn't exist.
func (s *Service) GetOrCreateCode(ctx context.Context, wallet string) (string, error) {
    // Check existing
    var code string
    err := s.db.QueryRowContext(ctx,
        "SELECT code FROM referral_codes WHERE wallet = $1", wallet,
    ).Scan(&code)
    if err == nil {
        return code, nil
    }

    // Generate unique code
    for attempts := 0; attempts < 10; attempts++ {
        code = generateCode()
        _, err = s.db.ExecContext(ctx,
            "INSERT INTO referral_codes (wallet, code) VALUES ($1, $2) ON CONFLICT DO NOTHING",
            wallet, code,
        )
        if err == nil {
            return code, nil
        }
    }
    return "", fmt.Errorf("failed to generate unique referral code after 10 attempts")
}

func generateCode() string {
    b := make([]byte, codeLength)
    rand.Read(b)
    var code strings.Builder
    code.WriteString(codePrefix)
    for _, v := range b {
        code.WriteByte(codeAlphabet[int(v)%len(codeAlphabet)])
    }
    return code.String()
}
```

### Step 3: Implement registration endpoint

```go
// RegisterReferral links a new user to their referrer on-chain.
func (s *Service) RegisterReferral(ctx context.Context, userWallet, referralCode string) error {
    // Look up referrer wallet from code
    var referrerWallet string
    err := s.db.QueryRowContext(ctx,
        "SELECT wallet FROM referral_codes WHERE code = $1",
        strings.ToUpper(referralCode),
    ).Scan(&referrerWallet)
    if err != nil {
        return fmt.Errorf("invalid referral code: %s", referralCode)
    }

    // Prevent self-referral
    if userWallet == referrerWallet {
        return fmt.Errorf("cannot use your own referral code")
    }

    // Check if already registered
    var exists bool
    s.db.QueryRowContext(ctx,
        "SELECT EXISTS(SELECT 1 FROM referral_registrations WHERE user_wallet = $1)",
        userWallet,
    ).Scan(&exists)
    if exists {
        return fmt.Errorf("wallet already has a referrer")
    }

    // Submit on-chain initialize_referral instruction
    txSig, err := s.solana.InitializeReferral(ctx, userWallet, referrerWallet)
    if err != nil {
        return fmt.Errorf("on-chain referral init failed: %w", err)
    }

    // Record in database
    _, err = s.db.ExecContext(ctx,
        "INSERT INTO referral_registrations (user_wallet, referrer_wallet, referral_code, tx_signature) VALUES ($1, $2, $3, $4)",
        userWallet, referrerWallet, strings.ToUpper(referralCode), txSig,
    )
    if err != nil {
        return fmt.Errorf("recording referral registration: %w", err)
    }

    return nil
}
```

### Step 4: REST API handlers

```go
// Handler for POST /api/referrals/register
// Body: {"wallet": "...", "referralCode": "OBEY-XXXXXX"}
func (h *Handler) RegisterReferral(w http.ResponseWriter, r *http.Request) {
    var req struct {
        Wallet       string `json:"wallet"`
        ReferralCode string `json:"referralCode"`
    }
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "invalid request body", http.StatusBadRequest)
        return
    }
    if err := h.referralSvc.RegisterReferral(r.Context(), req.Wallet, req.ReferralCode); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(map[string]string{"status": "registered"})
}

// Handler for GET /api/referrals/code/:wallet
func (h *Handler) GetReferralCode(w http.ResponseWriter, r *http.Request) {
    wallet := chi.URLParam(r, "wallet")
    code, err := h.referralSvc.GetOrCreateCode(r.Context(), wallet)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    json.NewEncoder(w).Encode(map[string]string{
        "code": code,
        "link": fmt.Sprintf("https://obeyplatform.xyz/ref/%s", code),
    })
}
```

### Step 5: Write tests

1. `TestGetOrCreateCode` — first call creates, second call returns same code
2. `TestCodeFormat` — verify code matches `OBEY-[A-Z0-9]{6}` pattern
3. `TestRegisterReferral` — valid code, verify DB entry and on-chain tx called
4. `TestRegisterSelfReferral` — error when user uses own code
5. `TestRegisterDuplicate` — error when wallet already has a referrer
6. `TestInvalidCode` — error for nonexistent referral code

## Done When

- [ ] All requirements met
- [ ] Every wallet gets a unique `OBEY-XXXXXX` referral code
- [ ] Registration validates code, prevents self-referral, triggers on-chain tx
- [ ] Database stores code mappings and registration history with tx signatures
- [ ] REST endpoints work for code lookup and registration
- [ ] Tests pass for all referral registration scenarios
