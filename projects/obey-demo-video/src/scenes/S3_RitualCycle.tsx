import React from "react";
import { useCurrentFrame, interpolate, Sequence, spring } from "remotion";
import { TerminalWindow } from "../components/TerminalWindow";
import { DecisionCard } from "../components/DecisionCard";
import { colors, fonts } from "../data/theme";

export const S3_RitualCycle: React.FC = () => {
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
        padding: 60,
      }}
    >
      {/* Phase 1: Loop Diagram */}
      <Sequence from={0} durationInFrames={300}>
        <LoopDiagram />
      </Sequence>

      {/* Phase 2: Terminal - Ritual Execution */}
      <Sequence from={300} durationInFrames={600}>
        <div style={{ width: "100%", maxWidth: 1000 }}>
          <div
            style={{
              color: colors.blue,
              fontSize: 16,
              textTransform: "uppercase",
              letterSpacing: 3,
              marginBottom: 16,
              fontFamily: fonts.sans,
            }}
          >
            Live Ritual Execution
          </div>
          <TerminalWindow
            title="vault-agent — ritual cycle"
            lines={[
              { text: "$ fest ritual run agent-market-research-RI-AM0001 --json", delay: 0 },
              { text: '{"run_id": "RI-AM0001-0012", "dest_path": ".campaign/quests/..."}', delay: 40, color: colors.cyan },
              { text: "", delay: 60 },
              { text: "$ obey session create --festival RI-AM0001-0012 --workdir <run-path>", delay: 70 },
              { text: 'Session e7f2a1c3 bound to ritual workdir', delay: 110, color: colors.green },
              { text: "", delay: 120 },
              { text: "[discover] querying Uniswap V3 WETH/USDC pool...", delay: 130, color: colors.textMuted },
              { text: "[discover] sampling historical slot0 (30 periods)...", delay: 160, color: colors.textMuted },
              { text: "[evaluate] running CRE 8-gate risk evaluation...", delay: 190, color: colors.textMuted },
              { text: "[evaluate] gates passed: 6/8", delay: 220, color: colors.yellow },
              { text: "[decide]   deviation: +39.91% from SMA", delay: 240, color: colors.orange },
              { text: "[decide]   confidence: 0.75", delay: 255, color: colors.orange },
              { text: "[decide]   writing decision.json...", delay: 270, color: colors.textMuted },
              { text: "[result]   DECISION: GO — SELL signal", delay: 290, color: colors.green },
            ]}
            typingSpeed={3}
          />
        </div>
      </Sequence>

      {/* Phase 3: NO_GO Decision */}
      <Sequence from={900} durationInFrames={350}>
        <NoGoScene />
      </Sequence>

      {/* Phase 4: GO Decision */}
      <Sequence from={1250} durationInFrames={550}>
        <GoScene />
      </Sequence>
    </div>
  );
};

const NoGoScene: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        height: "100%",
        gap: 24,
      }}
    >
      <div
        style={{
          color: colors.textMuted,
          fontSize: 18,
          fontFamily: fonts.sans,
          textAlign: "center",
          opacity: interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        The agent decided NOT to trade. That's the point.
      </div>
      <DecisionCard
        decision="NO_GO"
        confidence={0}
        deviationPct={1.17}
        gatesPassed="6/8"
        netProfit={-0.00006}
        signal="NO_SIGNAL"
        blockingFactors={["Deviation within ±2% noise band", "No actionable signal detected"]}
      />
    </div>
  );
};

const GoScene: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        height: "100%",
        gap: 24,
      }}
    >
      <div
        style={{
          color: colors.green,
          fontSize: 18,
          fontFamily: fonts.sans,
          textAlign: "center",
          opacity: interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        Strong signal detected — executing within vault boundaries
      </div>
      <DecisionCard
        decision="GO"
        confidence={0.75}
        deviationPct={39.91}
        gatesPassed="6/8"
        netProfit={197.56}
        signal="SELL"
      />
    </div>
  );
};

const LoopDiagram: React.FC = () => {
  const frame = useCurrentFrame();
  const steps = ["DISCOVER", "PLAN", "EXECUTE", "VERIFY"];
  const stepColors = [colors.blue, colors.purple, colors.green, colors.orange];

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
          color: colors.textMuted,
          fontSize: 16,
          textTransform: "uppercase",
          letterSpacing: 3,
          marginBottom: 32,
          opacity: interpolate(frame, [0, 15], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        Festival Methodology — Autonomous Decision Loop
      </div>
      <div style={{ display: "flex", gap: 24, alignItems: "center" }}>
        {steps.map((step, i) => {
          const stepDelay = i * 15;
          const stepScale = spring({
            frame: frame - stepDelay,
            fps: 30,
            config: { damping: 12 },
          });
          const activeGlow =
            Math.floor(((frame - 60) / 30) % 4) === i && frame > 60
              ? `0 0 30px ${stepColors[i]}50`
              : "none";

          return (
            <React.Fragment key={step}>
              <div
                style={{
                  transform: `scale(${stepScale})`,
                  backgroundColor: colors.bgCard,
                  border: `2px solid ${stepColors[i]}`,
                  borderRadius: 16,
                  padding: "24px 36px",
                  textAlign: "center",
                  boxShadow: activeGlow,
                  transition: "box-shadow 0.3s",
                }}
              >
                <div style={{ color: stepColors[i], fontSize: 14, letterSpacing: 2, marginBottom: 4 }}>
                  0{i + 1}
                </div>
                <div style={{ color: colors.textBright, fontSize: 22, fontWeight: 700 }}>{step}</div>
              </div>
              {i < steps.length - 1 && (
                <div
                  style={{
                    color: colors.textMuted,
                    fontSize: 28,
                    opacity: interpolate(frame - (stepDelay + 10), [0, 10], [0, 1], {
                      extrapolateLeft: "clamp",
                      extrapolateRight: "clamp",
                    }),
                  }}
                >
                  →
                </div>
              )}
            </React.Fragment>
          );
        })}
      </div>
      <div
        style={{
          color: colors.textMuted,
          fontSize: 16,
          marginTop: 32,
          opacity: interpolate(frame, [80, 100], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        Every cycle creates a real ritual run with auditable artifacts
      </div>
    </div>
  );
};
