import React from "react";
import { useCurrentFrame, interpolate, Sequence, AbsoluteFill } from "remotion";
import { TitleCard } from "../components/TitleCard";
import { ConstraintBar } from "../components/ConstraintBar";
import { colors, fonts } from "../data/theme";

export const S1_VaultBoundaries: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: colors.bg }}>
      <Sequence from={0} durationInFrames={240}>
        <AbsoluteFill>
          <TitleCard
            title="OBEY Agent Economy"
            subtitle="Autonomous Agent Infrastructure by Obedience Corp"
            builtWith="Obey Agent Runtime (obediencecorp.com) · Festival (fest.build)"
          />
        </AbsoluteFill>
      </Sequence>

      <Sequence from={240} durationInFrames={660}>
        <AbsoluteFill>
          <ConstraintsScene />
        </AbsoluteFill>
      </Sequence>
    </AbsoluteFill>
  );
};

const ConstraintsScene: React.FC = () => {
  const frame = useCurrentFrame();

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: 80,
      }}
    >
      <div style={{ width: "100%", maxWidth: 800 }}>
        <div
          style={{
            color: colors.blue,
            fontSize: 20,
            textTransform: "uppercase",
            letterSpacing: 3,
            marginBottom: 32,
            fontFamily: fonts.sans,
            textAlign: "center",
          }}
        >
          EVM-Enforced Vault Constraints
        </div>

        <ConstraintBar label="Max Swap Size" value="$1,000 USDC" delay={10} />
        <ConstraintBar label="Daily Volume Cap" value="$10,000" delay={20} />
        <ConstraintBar label="Max Slippage" value="100 bps" delay={30} />
        <ConstraintBar label="Token Whitelist" value="USDC · WETH" delay={40} />
        <ConstraintBar label="Risk Gates" value="8 pre-trade gates" delay={50} />

        <div
          style={{
            marginTop: 40,
            display: "flex",
            gap: 24,
            opacity: interpolate(frame - 60, [0, 20], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
          }}
        >
          <RoleCard
            role="Guardian"
            description="Sets limits, pauses vault, changes agent"
            color={colors.blue}
          />
          <RoleCard
            role="Agent"
            description="Executes swaps within boundaries — cannot modify limits"
            color={colors.purple}
          />
        </div>

        <div
          style={{
            marginTop: 32,
            color: colors.textMuted,
            fontSize: 16,
            fontFamily: fonts.mono,
            textAlign: "center",
            opacity: interpolate(frame - 80, [0, 20], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
          }}
        >
          ObeyVault: 0xbAbDd92397Cd812593e79A5b4c2a32bB4aDb06b1 (Base Sepolia)
        </div>
      </div>
    </div>
  );
};

const RoleCard: React.FC<{ role: string; description: string; color: string }> = ({
  role,
  description,
  color,
}) => (
  <div
    style={{
      flex: 1,
      padding: "24px 28px",
      backgroundColor: colors.bgCard,
      border: `1px solid ${color}40`,
      borderRadius: 12,
      fontFamily: fonts.sans,
    }}
  >
    <div style={{ color, fontSize: 22, fontWeight: 700, marginBottom: 10 }}>{role}</div>
    <div style={{ color: colors.textMuted, fontSize: 16 }}>{description}</div>
  </div>
);
