import React from "react";
import { useCurrentFrame, interpolate, Sequence } from "remotion";
import { TitleCard } from "../components/TitleCard";
import { ConstraintBar } from "../components/ConstraintBar";
import { colors, fonts } from "../data/theme";

export const S1_VaultBoundaries: React.FC = () => {
  const frame = useCurrentFrame();

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
      }}
    >
      <Sequence from={0} durationInFrames={240}>
        <TitleCard
          title="OBEY Vault Agent"
          subtitle="Autonomous Trading with Human Boundaries"
        />
      </Sequence>

      <Sequence from={240} durationInFrames={660}>
        <div style={{ width: "100%", maxWidth: 900 }}>
          <div
            style={{
              color: colors.blue,
              fontSize: 16,
              textTransform: "uppercase",
              letterSpacing: 3,
              marginBottom: 24,
              fontFamily: fonts.sans,
              opacity: interpolate(frame - 240, [0, 15], [0, 1], { extrapolateRight: "clamp" }),
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
              marginTop: 32,
              display: "flex",
              gap: 24,
              opacity: interpolate(frame - 300, [0, 20], [0, 1], {
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
              marginTop: 24,
              color: colors.textMuted,
              fontSize: 14,
              fontFamily: fonts.mono,
              opacity: interpolate(frame - 340, [0, 20], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
              }),
            }}
          >
            ObeyVault: 0xbAbDd92397Cd812593e79A5b4c2a32bB4aDb06b1 (Base Sepolia)
          </div>
        </div>
      </Sequence>
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
      padding: "20px 24px",
      backgroundColor: colors.bgCard,
      border: `1px solid ${color}40`,
      borderRadius: 12,
      fontFamily: fonts.sans,
    }}
  >
    <div style={{ color, fontSize: 20, fontWeight: 700, marginBottom: 8 }}>{role}</div>
    <div style={{ color: colors.textMuted, fontSize: 14 }}>{description}</div>
  </div>
);
