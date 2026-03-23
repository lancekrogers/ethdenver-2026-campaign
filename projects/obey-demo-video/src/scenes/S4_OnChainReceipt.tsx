import React from "react";
import { useCurrentFrame, interpolate, Sequence, spring, AbsoluteFill } from "remotion";
import { colors, fonts } from "../data/theme";

export const S4_OnChainReceipt: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: colors.bg }}>
      <Sequence from={0} durationInFrames={450}>
        <AbsoluteFill>
          <EventScene />
        </AbsoluteFill>
      </Sequence>

      <Sequence from={450} durationInFrames={450}>
        <AbsoluteFill>
          <LogEntryScene />
        </AbsoluteFill>
      </Sequence>
    </AbsoluteFill>
  );
};

const EventScene: React.FC = () => {
  const frame = useCurrentFrame();
  const scale = spring({ frame, fps: 30, config: { damping: 12 } });

  const fields = [
    { label: "Event", value: "SwapExecuted", color: colors.green },
    { label: "tokenIn", value: "USDC", color: colors.text },
    { label: "tokenOut", value: "WETH", color: colors.text },
    { label: "amountIn", value: "1,000,000 (1 USDC)", color: colors.text },
    { label: "amountOut", value: "1,524,879,273,434,747 wei", color: colors.text },
    { label: "reason", value: "0x6533325465737453776170", color: colors.yellow },
  ];

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
        fontFamily: fonts.sans,
      }}
    >
      <div
        style={{
          color: colors.green,
          fontSize: 20,
          textTransform: "uppercase",
          letterSpacing: 3,
          marginBottom: 32,
          textAlign: "center",
          opacity: interpolate(frame, [0, 15], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        On-Chain Swap Receipt
      </div>

      <div
        style={{
          transform: `scale(${scale})`,
          backgroundColor: colors.bgCard,
          border: `1px solid ${colors.border}`,
          borderRadius: 16,
          overflow: "hidden",
          width: "100%",
          maxWidth: 900,
        }}
      >
        <div
          style={{
            padding: "16px 24px",
            backgroundColor: "#0a1a0a",
            borderBottom: `1px solid ${colors.border}`,
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <span style={{ color: colors.green, fontSize: 18, fontWeight: 600 }}>SwapExecuted Event Log</span>
          <span style={{ color: colors.textMuted, fontSize: 14, fontFamily: fonts.mono }}>
            Block 38981662 · Base Sepolia
          </span>
        </div>

        <div style={{ padding: 28 }}>
          {fields.map((field, i) => {
            const fieldOpacity = interpolate(frame - i * 8, [0, 12], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            });

            return (
              <div
                key={field.label}
                style={{
                  opacity: fieldOpacity,
                  display: "flex",
                  padding: "10px 0",
                  borderBottom: i < fields.length - 1 ? `1px solid ${colors.border}` : "none",
                }}
              >
                <span
                  style={{
                    color: colors.textMuted,
                    fontSize: 17,
                    width: 160,
                    flexShrink: 0,
                    fontFamily: fonts.mono,
                  }}
                >
                  {field.label}
                </span>
                <span
                  style={{
                    color: field.color,
                    fontSize: 17,
                    fontFamily: fonts.mono,
                    fontWeight: field.label === "reason" ? 700 : 400,
                  }}
                >
                  {field.value}
                </span>
              </div>
            );
          })}

          <div
            style={{
              marginTop: 20,
              padding: "14px 18px",
              backgroundColor: "#1a1a0a",
              borderRadius: 8,
              opacity: interpolate(frame - 60, [0, 20], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
              }),
            }}
          >
            <span style={{ color: colors.yellow, fontSize: 15 }}>
              The reason field contains the agent's encoded rationale — committed at transaction time
            </span>
          </div>
        </div>

        <div
          style={{
            padding: "14px 24px",
            borderTop: `1px solid ${colors.border}`,
            textAlign: "center",
            opacity: interpolate(frame - 80, [0, 15], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
          }}
        >
          <span style={{ color: colors.textMuted, fontSize: 13, fontFamily: fonts.mono }}>
            TX: 0xafc1c6b2e0ad1e0f0bff17aa86f2cca6ab19ce2859929e5fa066b989d2d3a9d7
          </span>
        </div>
      </div>
    </div>
  );
};

const LogEntryScene: React.FC = () => {
  const frame = useCurrentFrame();
  const scale = spring({ frame, fps: 30, config: { damping: 12 } });

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
      <div
        style={{
          color: colors.blue,
          fontSize: 20,
          textTransform: "uppercase",
          letterSpacing: 3,
          marginBottom: 24,
          textAlign: "center",
          fontFamily: fonts.sans,
          opacity: interpolate(frame, [0, 15], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        agent_log.json — Full Reasoning Chain
      </div>

      <div
        style={{
          transform: `scale(${scale})`,
          backgroundColor: colors.bgTerminal,
          border: `1px solid ${colors.border}`,
          borderRadius: 12,
          padding: 32,
          fontFamily: fonts.mono,
          fontSize: 17,
          lineHeight: 2,
          width: "100%",
          maxWidth: 900,
        }}
      >
        <Line frame={frame} delay={10} k="phase" v='"execute"' />
        <Line frame={frame} delay={15} k="action" v='"vault_swap"' />
        <Line frame={frame} delay={20} k="decision" v='"GO"' color={colors.green} />
        <Line frame={frame} delay={25} k="tools_used" v='["obey_vault_execute_swap", "uniswap_v3_pool_query"]' />
        <Line frame={frame} delay={35} k="token_in" v='"USDC"' />
        <Line frame={frame} delay={40} k="token_out" v='"WETH"' />
        <Line frame={frame} delay={45} k="amount_in" v='"1000000"' />
        <Line frame={frame} delay={50} k="amount_out" v='"1524879273434747"' />
        <Line frame={frame} delay={60} k="within_tolerance" v="true" color={colors.green} />
        <Line frame={frame} delay={65} k="chain" v='"Base Sepolia"' />
      </div>
    </div>
  );
};

const Line: React.FC<{ frame: number; delay: number; k: string; v: string; color?: string }> = ({
  frame,
  delay,
  k,
  v,
  color = colors.text,
}) => (
  <div
    style={{
      opacity: interpolate(frame - delay, [0, 8], [0, 1], {
        extrapolateLeft: "clamp",
        extrapolateRight: "clamp",
      }),
    }}
  >
    <span style={{ color: colors.purple }}>{`"${k}"`}</span>
    <span style={{ color: colors.textMuted }}>: </span>
    <span style={{ color }}>{v}</span>
  </div>
);
