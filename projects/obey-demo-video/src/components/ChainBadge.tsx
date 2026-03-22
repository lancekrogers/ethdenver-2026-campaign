import React from "react";
import { useCurrentFrame, spring, interpolate } from "remotion";
import { colors, fonts } from "../data/theme";

interface ChainBadgeProps {
  name: string;
  color: string;
  txCount: number;
  contracts?: number;
  delay: number;
}

export const ChainBadge: React.FC<ChainBadgeProps> = ({ name, color, txCount, contracts, delay }) => {
  const frame = useCurrentFrame();
  const scale = spring({ frame: frame - delay, fps: 30, config: { damping: 12 } });
  const opacity = interpolate(frame - delay, [0, 8], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        opacity,
        transform: `scale(${scale})`,
        backgroundColor: colors.bgCard,
        border: `2px solid ${color}`,
        borderRadius: 16,
        padding: "20px 28px",
        textAlign: "center",
        fontFamily: fonts.sans,
        minWidth: 200,
      }}
    >
      <div
        style={{
          width: 16,
          height: 16,
          borderRadius: "50%",
          backgroundColor: color,
          margin: "0 auto 12px",
          boxShadow: `0 0 20px ${color}40`,
        }}
      />
      <div style={{ color: colors.textBright, fontSize: 18, fontWeight: 600, marginBottom: 8 }}>{name}</div>
      <div style={{ color: colors.textMuted, fontSize: 14 }}>
        {txCount}+ txs{contracts ? ` · ${contracts} contracts` : ""}
      </div>
    </div>
  );
};
