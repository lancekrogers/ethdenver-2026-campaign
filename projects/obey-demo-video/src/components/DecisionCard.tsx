import React from "react";
import { useCurrentFrame, spring, interpolate } from "remotion";
import { colors, fonts } from "../data/theme";

interface DecisionCardProps {
  decision: "GO" | "NO_GO";
  confidence: number;
  deviationPct: number;
  gatesPassed: string;
  netProfit: number;
  signal: string;
  blockingFactors?: string[];
}

export const DecisionCard: React.FC<DecisionCardProps> = ({
  decision,
  confidence,
  deviationPct,
  gatesPassed,
  netProfit,
  signal,
  blockingFactors,
}) => {
  const frame = useCurrentFrame();
  const scale = spring({ frame, fps: 30, config: { damping: 12, stiffness: 100 } });
  const isGo = decision === "GO";
  const borderColor = isGo ? colors.green : colors.red;
  const badgeColor = isGo ? colors.green : colors.red;

  return (
    <div
      style={{
        transform: `scale(${scale})`,
        backgroundColor: colors.bgCard,
        border: `2px solid ${borderColor}`,
        borderRadius: 16,
        padding: 32,
        width: 520,
        fontFamily: fonts.sans,
      }}
    >
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
        <span style={{ color: colors.textMuted, fontSize: 14, textTransform: "uppercase", letterSpacing: 2 }}>
          Ritual Decision
        </span>
        <div
          style={{
            backgroundColor: badgeColor,
            color: colors.textBright,
            padding: "6px 16px",
            borderRadius: 20,
            fontSize: 18,
            fontWeight: 700,
            fontFamily: fonts.mono,
          }}
        >
          {decision.replace("_", " ")}
        </div>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16 }}>
        <Stat label="Confidence" value={`${(confidence * 100).toFixed(0)}%`} />
        <Stat label="Signal" value={signal} color={signal === "NO_SIGNAL" ? colors.textMuted : colors.orange} />
        <Stat label="Deviation" value={`${deviationPct.toFixed(1)}%`} />
        <Stat label="CRE Gates" value={gatesPassed} />
        <Stat
          label="Net Profit Est."
          value={`$${netProfit.toFixed(2)}`}
          color={netProfit > 0 ? colors.green : colors.red}
        />
      </div>

      {blockingFactors && blockingFactors.length > 0 && (
        <div style={{ marginTop: 16, padding: "12px 16px", backgroundColor: "#1a0a0a", borderRadius: 8 }}>
          <span style={{ color: colors.red, fontSize: 12, textTransform: "uppercase", letterSpacing: 1 }}>
            Blocking Factors
          </span>
          {blockingFactors.map((f, i) => (
            <div key={i} style={{ color: colors.textMuted, fontSize: 13, marginTop: 4 }}>
              • {f}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

const Stat: React.FC<{ label: string; value: string; color?: string }> = ({
  label,
  value,
  color = colors.textBright,
}) => (
  <div>
    <div style={{ color: colors.textMuted, fontSize: 12, textTransform: "uppercase", letterSpacing: 1, marginBottom: 4 }}>
      {label}
    </div>
    <div style={{ color, fontSize: 22, fontWeight: 600, fontFamily: fonts.mono }}>{value}</div>
  </div>
);
