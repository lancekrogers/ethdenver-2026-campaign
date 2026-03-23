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
    "Obey Agent Runtime",
    "fest CLI (fest.build)",
    "camp CLI",
    "Claude Opus 4.6",
    "Base L2",
  ];

  const tracks = [
    "Let the Agent Cook",
    "Agents With Receipts",
    "Agentic Finance",
    "Synthesis Open Track",
    "Autonomous Trading Agent",
    "Go Gasless",
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
        The agents obey.{" "}
        <span style={{ color: colors.blue }}>The vault enforces.</span>
        <br />
        <span style={{ color: colors.green }}>Every decision has a receipt.</span>
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
            key={track}
            style={{
              padding: "12px 20px",
              backgroundColor: colors.bgCard,
              border: `1px solid ${colors.blue}30`,
              borderRadius: 10,
              display: "flex",
              alignItems: "center",
            }}
          >
            <span style={{ color: colors.text, fontSize: 14 }}>{track}</span>
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
        obediencecorp.com · fest.build · github.com/lancekrogers/Obey-Agent-Economy
      </div>
    </div>
  );
};
