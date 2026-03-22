import React from "react";
import { useCurrentFrame, spring, interpolate } from "remotion";
import { colors, fonts } from "../data/theme";

interface ConstraintBarProps {
  label: string;
  value: string;
  delay: number;
  icon?: string;
}

export const ConstraintBar: React.FC<ConstraintBarProps> = ({ label, value, delay, icon }) => {
  const frame = useCurrentFrame();
  const progress = spring({ frame: frame - delay, fps: 30, config: { damping: 12 } });
  const opacity = interpolate(frame - delay, [0, 10], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        opacity,
        transform: `translateX(${interpolate(progress, [0, 1], [-60, 0])}px)`,
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "16px 24px",
        backgroundColor: colors.bgCard,
        border: `1px solid ${colors.border}`,
        borderRadius: 12,
        marginBottom: 12,
        fontFamily: fonts.sans,
      }}
    >
      <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
        {icon && <span style={{ fontSize: 24 }}>{icon}</span>}
        <span style={{ color: colors.textMuted, fontSize: 18 }}>{label}</span>
      </div>
      <span style={{ color: colors.textBright, fontSize: 24, fontWeight: 700, fontFamily: fonts.mono }}>
        {value}
      </span>
    </div>
  );
};
