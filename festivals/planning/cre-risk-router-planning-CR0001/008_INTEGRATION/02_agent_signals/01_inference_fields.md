---
fest_type: task
fest_id: 01_inference_fields.md
fest_name: inference fields
fest_parent: 02_agent_signals
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:46:02.403054-07:00
fest_tracking: true
---

# Task: inference fields

## Objective

Add `signal_confidence` and `risk_score` fields to `agent-inference` output so that inference results carry the data required by the CRE Risk Router's RiskRequest format (Req P1.3).

## Requirements

- [ ] `agent-inference` output struct includes `signal_confidence` (float64, 0.0-1.0) (Req P1.3)
- [ ] `agent-inference` output struct includes `risk_score` (int, 0-100) (Req P1.3)
- [ ] Fields are populated during inference with meaningful values derived from model output
- [ ] Existing consumers of inference output are not broken by the addition
- [ ] Fields are documented with expected ranges and semantics

## Implementation

1. **Locate the inference output struct** in `agent-inference`:
   - Look for the struct that represents inference results (likely in `internal/inference/types.go` or `pkg/inference/result.go`)
   - This struct is what gets passed to the coordinator after inference completes

2. **Add the new fields**:
   ```go
   type InferenceResult struct {
       // ... existing fields (Signal, MarketPair, etc.)

       // SignalConfidence is the model's confidence in the signal (0.0 to 1.0).
       // Used by CRE Risk Router Gate 1 (signal_confidence_below_threshold).
       SignalConfidence float64 `json:"signal_confidence"`

       // RiskScore is a composite risk assessment (0 to 100, lower is safer).
       // Used by CRE Risk Router Gate 2 (risk_score_exceeds_maximum).
       RiskScore int `json:"risk_score"`
   }
   ```

3. **Populate the fields during inference**:
   - `signal_confidence`: Extract from model output logits, softmax probability, or calibrated confidence score
   - `risk_score`: Derive from a combination of market volatility, position size relative to portfolio, and signal strength
   - If the model does not natively produce these values, compute them from available signals:
     ```go
     // Example derivation
     result.SignalConfidence = model.TopProbability()  // or similar
     result.RiskScore = computeRiskScore(result.Signal, marketConditions)
     ```

4. **Add the risk score computation** (if not already available):
   ```go
   func computeRiskScore(signal string, conditions MarketConditions) int {
       score := 50 // baseline
       // Adjust based on volatility
       if conditions.Volatility > 0.05 {
           score += int(conditions.Volatility * 100)
       }
       // Adjust based on signal type
       if signal == "sell" {
           score += 10 // selling in volatile markets is riskier
       }
       // Clamp to 0-100
       if score > 100 { score = 100 }
       if score < 0 { score = 0 }
       return score
   }
   ```

5. **Update JSON serialization** to ensure the fields are included in coordinator-facing output.

6. **Write tests**:
   - Test that inference results include both new fields
   - Test that `signal_confidence` is within [0.0, 1.0]
   - Test that `risk_score` is within [0, 100]
   - Test backward compatibility with existing consumers

## Done When

- [ ] All requirements met
- [ ] Both fields added to inference output struct with JSON tags
- [ ] Fields populated with meaningful values during inference
- [ ] Existing tests still pass (no regression)
- [ ] New tests verify field presence and valid ranges
