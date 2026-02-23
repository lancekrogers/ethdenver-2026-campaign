---
fest_type: task
fest_id: 01_implement_session_auth.md
fest_name: implement session auth
fest_parent: 03_zerog_compute_payment
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.777583-07:00
fest_updated: 2026-02-23T13:46:54.744991-07:00
fest_tracking: true
---


# Task: Implement 0G Compute Session Auth

## Objective

Implement the session-based Bearer token authentication required by 0G Compute providers so the inference agent can actually run paid inference against real 0G providers on Galileo testnet.

## Requirements

- [ ] The broker in `projects/agent-inference/internal/zerog/compute/broker.go` constructs a signed Bearer token in the format `app-sk-<base64(rawMessage:signature)>` before submitting inference requests
- [ ] The broker handles 401 responses from providers by refreshing the session token and retrying once

## Implementation

### Step 1: Understand the 0G auth protocol

0G Compute providers require a Bearer token constructed from an ECDSA signature. The format is:

1. Create a raw message (typically a timestamp or nonce)
2. Sign it with the same private key used for the 0G chain (`ZG_CHAIN_PRIVATE_KEY`)
3. Base64-encode `rawMessage:signature`
4. Set header: `Authorization: Bearer app-sk-<base64_result>`

### Step 2: Add session token construction

In `projects/agent-inference/internal/zerog/compute/broker.go`, add a method:

```go
func (b *Broker) buildAuthToken(ctx context.Context) (string, error) {
    // Create message: current unix timestamp as string
    msg := fmt.Sprintf("%d", time.Now().Unix())
    msgHash := crypto.Keccak256Hash([]byte(msg))

    // Sign with the chain private key (already loaded in broker)
    sig, err := crypto.Sign(msgHash.Bytes(), b.privateKey)
    if err != nil {
        return "", fmt.Errorf("sign auth message: %w", err)
    }

    // Encode as base64(message:signature)
    payload := fmt.Sprintf("%s:%s", msg, hexutil.Encode(sig))
    token := "app-sk-" + base64.StdEncoding.EncodeToString([]byte(payload))
    return token, nil
}
```

### Step 3: Wire into SubmitJob

In the `SubmitJob` method, before the HTTP POST to the provider, add:

```go
token, err := b.buildAuthToken(ctx)
if err != nil {
    return "", fmt.Errorf("build auth token: %w", err)
}
req.Header.Set("Authorization", "Bearer "+token)
```

### Step 4: Add retry on 401

If the provider returns 401, rebuild the token and retry once. Wrap the HTTP call in a simple retry:

```go
resp, err := b.httpClient.Do(req)
if resp.StatusCode == http.StatusUnauthorized {
    token, _ = b.buildAuthToken(ctx)
    req.Header.Set("Authorization", "Bearer "+token)
    resp, err = b.httpClient.Do(req)
}
```

### Step 5: Ensure private key is available

Verify the broker has access to `*ecdsa.PrivateKey` — it should already be loaded via `ethutil.LoadKey` from `ZG_CHAIN_PRIVATE_KEY`. If not, add it as a field.

## Done When

- [ ] All requirements met
- [ ] Broker sends Authorization header with signed Bearer token on every inference request; 401 responses trigger one retry with a fresh token