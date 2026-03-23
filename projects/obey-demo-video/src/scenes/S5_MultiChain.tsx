import React from "react";
import { useCurrentFrame, interpolate, spring } from "remotion";
import { ChainBadge } from "../components/ChainBadge";
import { colors, fonts } from "../data/theme";

export const S5_MultiChain: React.FC = () => {
  const frame = useCurrentFrame();
  const titleOpacity = interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" });
  const counterScale = spring({ frame: frame - 120, fps: 30, config: { damping: 10 } });

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
        padding: 60,
        fontFamily: fonts.sans,
      }}
    >
      <div
        style={{
          opacity: titleOpacity,
          color: colors.textMuted,
          fontSize: 16,
          textTransform: "uppercase",
          letterSpacing: 3,
          marginBottom: 16,
        }}
      >
        Multi-Chain Architecture
      </div>

      <div
        style={{
          opacity: titleOpacity,
          color: colors.textBright,
          fontSize: 42,
          fontWeight: 800,
          marginBottom: 48,
        }}
      >
        5 Chains · 80+ Verified Transactions
      </div>

      <div style={{ display: "flex", gap: 20, flexWrap: "wrap", justifyContent: "center", maxWidth: 1200 }}>
        <ChainBadge name="Base Sepolia" color="#0052FF" txCount={20} contracts={5} delay={20} />
        <ChainBadge name="Hedera Testnet" color="#8259EF" txCount={24} delay={35} />
        <ChainBadge name="Ethereum Sepolia" color="#627EEA" txCount={2} delay={50} />
        <ChainBadge name="0G Galileo" color="#00D4AA" txCount={6} contracts={3} delay={65} />
        <ChainBadge name="Status Network" color="#4360DF" txCount={2} delay={80} />
      </div>

      <div
        style={{
          marginTop: 48,
          display: "flex",
          gap: 40,
          opacity: interpolate(frame - 100, [0, 20], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        <StatBlock label="Contracts Deployed" value="8" />
        <StatBlock label="ERC Standards" value="4626 · 8004 · 8021 · x402" />
        <StatBlock label="Agent Accounts" value="3" />
        <StatBlock label="HCS Topics" value="2" />
      </div>
    </div>
  );
};

const StatBlock: React.FC<{ label: string; value: string }> = ({ label, value }) => (
  <div style={{ textAlign: "center" }}>
    <div style={{ color: colors.textBright, fontSize: 24, fontWeight: 700, fontFamily: fonts.mono }}>{value}</div>
    <div style={{ color: colors.textMuted, fontSize: 13, marginTop: 4 }}>{label}</div>
  </div>
);
