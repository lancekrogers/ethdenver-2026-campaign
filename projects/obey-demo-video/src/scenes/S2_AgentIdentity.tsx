import React from "react";
import { useCurrentFrame, interpolate, spring } from "remotion";
import { colors, fonts } from "../data/theme";

export const S2_AgentIdentity: React.FC = () => {
  const frame = useCurrentFrame();
  const badgeScale = spring({ frame, fps: 30, config: { damping: 10, stiffness: 80 } });
  const detailsOpacity = interpolate(frame, [30, 50], [0, 1], { extrapolateRight: "clamp" });
  const txOpacity = interpolate(frame, [60, 80], [0, 1], { extrapolateRight: "clamp" });

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        backgroundColor: colors.bg,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: 80,
        fontFamily: fonts.sans,
      }}
    >
      <div
        style={{
          transform: `scale(${badgeScale})`,
          backgroundColor: colors.bgCard,
          border: `2px solid ${colors.purple}`,
          borderRadius: 24,
          padding: "48px 64px",
          textAlign: "center",
          boxShadow: `0 0 60px ${colors.purple}20`,
        }}
      >
        <div
          style={{
            color: colors.purple,
            fontSize: 16,
            textTransform: "uppercase",
            letterSpacing: 3,
            marginBottom: 16,
          }}
        >
          ERC-8004 Agent Identity
        </div>
        <div
          style={{
            color: colors.textBright,
            fontSize: 48,
            fontWeight: 800,
            marginBottom: 24,
          }}
        >
          OBEY Vault Agent
        </div>

        <div style={{ opacity: detailsOpacity }}>
          <div style={{ marginBottom: 20 }}>
            <div style={{ color: colors.textMuted, fontSize: 13, marginBottom: 6 }}>Identity Contract</div>
            <div style={{ color: colors.cyan, fontSize: 16, fontFamily: fonts.mono }}>
              0x0C97820abBdD2562645DaE92D35eD581266CCe70
            </div>
          </div>

          <div style={{ marginBottom: 20 }}>
            <div style={{ color: colors.textMuted, fontSize: 13, marginBottom: 6 }}>Operator Wallet</div>
            <div style={{ color: colors.blue, fontSize: 16, fontFamily: fonts.mono }}>
              0xC71d8A19422C649fe9bdCbF3ffA536326c82b58b
            </div>
          </div>
        </div>

        <div style={{ opacity: txOpacity }}>
          <div style={{ color: colors.textMuted, fontSize: 13, marginBottom: 6 }}>Registration TX</div>
          <div style={{ color: colors.green, fontSize: 14, fontFamily: fonts.mono }}>
            0x9b31bd785dd7b12649d9d12379546c268aea1da6...
          </div>
          <div style={{ color: colors.textMuted, fontSize: 13, marginTop: 12 }}>
            Portable · Verifiable · On-Chain · Base Sepolia
          </div>
        </div>
      </div>
    </div>
  );
};
