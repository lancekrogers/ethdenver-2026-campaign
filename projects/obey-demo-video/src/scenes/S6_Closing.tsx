import React from "react";
import { useCurrentFrame, interpolate, spring } from "remotion";
import { colors, fonts } from "../data/theme";

export const S6_Closing: React.FC = () => {
  const frame = useCurrentFrame();
  const taglineOpacity = interpolate(frame, [0, 30], [0, 1], { extrapolateRight: "clamp" });
  const badgesOpacity = interpolate(frame, [40, 60], [0, 1], { extrapolateRight: "clamp" });
  const tracksOpacity = interpolate(frame, [90, 110], [0, 1], { extrapolateRight: "clamp" });

  const techStack = [
    "Go",
    "Solidity",
    "ERC-4626",
    "ERC-8004",
    "Uniswap V3",
    "Hedera HCS",
    "Chainlink CRE",
    "Festival Methodology",
    "Claude Opus 4.6",
    "Base L2",
  ];

  const tracks = [
    { name: "Let the Agent Cook", prize: "$8,000" },
    { name: "Agents With Receipts", prize: "$8,004" },
    { name: "Agentic Finance", prize: "$5,000" },
    { name: "Synthesis Open Track", prize: "$19,559" },
    { name: "Autonomous Trading Agent", prize: "$5,000" },
    { name: "Go Gasless", prize: "$2,000" },
  ];

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
          opacity: taglineOpacity,
          fontSize: 44,
          fontWeight: 800,
          color: colors.textBright,
          textAlign: "center",
          maxWidth: 1000,
          lineHeight: 1.3,
          marginBottom: 48,
        }}
      >
        The agent cooks.{" "}
        <span style={{ color: colors.blue }}>The vault keeps it honest.</span>
        <br />
        <span style={{ color: colors.green }}>Every receipt is on-chain.</span>
      </div>

      <div
        style={{
          opacity: badgesOpacity,
          display: "flex",
          flexWrap: "wrap",
          gap: 10,
          justifyContent: "center",
          maxWidth: 900,
          marginBottom: 40,
        }}
      >
        {techStack.map((tech, i) => {
          const badgeScale = spring({
            frame: frame - 40 - i * 3,
            fps: 30,
            config: { damping: 12 },
          });
          return (
            <div
              key={tech}
              style={{
                transform: `scale(${badgeScale})`,
                padding: "8px 16px",
                backgroundColor: colors.bgCard,
                border: `1px solid ${colors.border}`,
                borderRadius: 8,
                color: colors.text,
                fontSize: 14,
                fontFamily: fonts.mono,
              }}
            >
              {tech}
            </div>
          );
        })}
      </div>

      <div
        style={{
          opacity: tracksOpacity,
          display: "flex",
          gap: 16,
          flexWrap: "wrap",
          justifyContent: "center",
          maxWidth: 1100,
        }}
      >
        {tracks.map((track, i) => (
          <div
            key={track.name}
            style={{
              padding: "12px 20px",
              backgroundColor: colors.bgCard,
              border: `1px solid ${colors.blue}30`,
              borderRadius: 10,
              display: "flex",
              gap: 12,
              alignItems: "center",
            }}
          >
            <span style={{ color: colors.text, fontSize: 14 }}>{track.name}</span>
            <span style={{ color: colors.green, fontSize: 14, fontWeight: 700, fontFamily: fonts.mono }}>
              {track.prize}
            </span>
          </div>
        ))}
      </div>

      <div
        style={{
          marginTop: 40,
          color: colors.textMuted,
          fontSize: 14,
          fontFamily: fonts.mono,
          opacity: interpolate(frame - 130, [0, 20], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        github.com/lancekrogers/agent-defi · Built by Obedience Corp
      </div>
    </div>
  );
};
