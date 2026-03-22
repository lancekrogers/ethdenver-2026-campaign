import React from "react";
import { useCurrentFrame, spring, interpolate } from "remotion";
import { colors, fonts } from "../data/theme";

interface TitleCardProps {
  title: string;
  subtitle?: string;
}

export const TitleCard: React.FC<TitleCardProps> = ({ title, subtitle }) => {
  const frame = useCurrentFrame();
  const titleOpacity = interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" });
  const titleY = spring({ frame, fps: 30, config: { damping: 15, stiffness: 80 } });
  const subtitleOpacity = interpolate(frame, [15, 35], [0, 1], { extrapolateRight: "clamp" });

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        height: "100%",
        fontFamily: fonts.sans,
      }}
    >
      <div
        style={{
          opacity: titleOpacity,
          transform: `translateY(${interpolate(titleY, [0, 1], [40, 0])}px)`,
          fontSize: 64,
          fontWeight: 800,
          color: colors.textBright,
          textAlign: "center",
          lineHeight: 1.2,
          maxWidth: 1200,
        }}
      >
        {title}
      </div>
      {subtitle && (
        <div
          style={{
            opacity: subtitleOpacity,
            fontSize: 28,
            color: colors.textMuted,
            marginTop: 20,
            textAlign: "center",
            maxWidth: 900,
          }}
        >
          {subtitle}
        </div>
      )}
    </div>
  );
};
