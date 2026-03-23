import React from "react";
import { useCurrentFrame, interpolate } from "remotion";
import { colors, fonts } from "../data/theme";

interface TerminalLine {
  text: string;
  delay: number;
  color?: string;
  prefix?: string;
}

interface TerminalWindowProps {
  lines: TerminalLine[];
  title?: string;
  typingSpeed?: number;
}

export const TerminalWindow: React.FC<TerminalWindowProps> = ({
  lines,
  title = "terminal",
  typingSpeed = 2,
}) => {
  const frame = useCurrentFrame();

  return (
    <div
      style={{
        backgroundColor: colors.bgTerminal,
        borderRadius: 12,
        border: `1px solid ${colors.border}`,
        overflow: "hidden",
        width: "100%",
        fontFamily: fonts.mono,
      }}
    >
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 8,
          padding: "12px 16px",
          backgroundColor: "#0f0f1e",
          borderBottom: `1px solid ${colors.border}`,
        }}
      >
        <div style={{ width: 12, height: 12, borderRadius: "50%", backgroundColor: "#ff5f57" }} />
        <div style={{ width: 12, height: 12, borderRadius: "50%", backgroundColor: "#febc2e" }} />
        <div style={{ width: 12, height: 12, borderRadius: "50%", backgroundColor: "#28c840" }} />
        <span style={{ color: colors.textMuted, fontSize: 13, marginLeft: 8 }}>{title}</span>
      </div>
      <div style={{ padding: "16px 20px", minHeight: 200 }}>
        {lines.map((line, i) => {
          const lineStart = line.delay;
          const duration = Math.max(1, line.text.length / typingSpeed);
          const charsToShow = Math.floor(
            interpolate(frame - lineStart, [0, duration], [0, line.text.length], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            })
          );

          if (frame < lineStart) return null;
          if (line.text.length === 0) return <div key={i} style={{ height: 12 }} />;

          const prefix = line.prefix ?? (line.text.startsWith("$") ? "" : "  ");
          const displayText = line.text.substring(0, charsToShow);
          const lineColor = line.color ?? (line.text.startsWith("$") ? colors.green : colors.text);

          return (
            <div key={i} style={{ marginBottom: 6, fontSize: 16, lineHeight: 1.6 }}>
              <span style={{ color: lineColor }}>
                {prefix}
                {displayText}
              </span>
              {charsToShow < line.text.length && (
                <span
                  style={{
                    color: colors.green,
                    opacity: Math.sin(frame * 0.3) > 0 ? 1 : 0,
                  }}
                >
                  █
                </span>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};
