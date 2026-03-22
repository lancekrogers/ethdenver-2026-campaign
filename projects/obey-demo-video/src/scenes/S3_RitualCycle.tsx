import React from "react";
import { useCurrentFrame, interpolate, Sequence, spring, AbsoluteFill } from "remotion";
import { TerminalWindow } from "../components/TerminalWindow";
import { DecisionCard } from "../components/DecisionCard";
import { colors, fonts } from "../data/theme";

export const S3_RitualCycle: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: colors.bg }}>
      {/* Phase 1: Festival Methodology Loop */}
      <Sequence from={0} durationInFrames={250}>
        <AbsoluteFill>
          <LoopDiagram />
        </AbsoluteFill>
      </Sequence>

      {/* Phase 2: Real fest show hierarchy */}
      <Sequence from={250} durationInFrames={400}>
        <AbsoluteFill>
          <FestivalHierarchy />
        </AbsoluteFill>
      </Sequence>

      {/* Phase 3: Real ritual run hierarchy */}
      <Sequence from={650} durationInFrames={400}>
        <AbsoluteFill>
          <RitualRunHierarchy />
        </AbsoluteFill>
      </Sequence>

      {/* Phase 4: Real decision.json */}
      <Sequence from={1050} durationInFrames={400}>
        <AbsoluteFill>
          <DecisionJsonScene />
        </AbsoluteFill>
      </Sequence>

      {/* Phase 5: NO_GO Decision Card */}
      <Sequence from={1450} durationInFrames={200}>
        <AbsoluteFill>
          <NoGoScene />
        </AbsoluteFill>
      </Sequence>

      {/* Phase 6: GO Decision Card */}
      <Sequence from={1650} durationInFrames={150}>
        <AbsoluteFill>
          <GoScene />
        </AbsoluteFill>
      </Sequence>
    </AbsoluteFill>
  );
};

const FestivalHierarchy: React.FC = () => {
  // Real output from: fest show all
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
          fontFamily: fonts.sans,
          textAlign: "center",
        }}
      >
        fest show all — Live Campaign State
      </div>
      <TerminalWindow
        title="fest show all"
        typingSpeed={4}
        lines={[
          { text: "$ fest show all", delay: 0 },
          { text: "", delay: 15 },
          { text: "ALL FESTIVALS ── Total 20", delay: 20, color: colors.textBright },
          { text: "", delay: 25 },
          { text: "ACTIVE Festivals (5)", delay: 30, color: colors.green },
          { text: "  agent-market-research-RI-AM0001-0008 [100%]", delay: 40, color: colors.text },
          { text: "  agent-market-research-RI-AM0001-0009 [100%]", delay: 48, color: colors.text },
          { text: "  agent-market-research-RI-AM0001-000A [100%]", delay: 56, color: colors.text },
          { text: "  agent-market-research-RI-AM0001-000B [100%]", delay: 64, color: colors.text },
          { text: "  synthesis-fest-ritual-runtime-SF0002 [100%]", delay: 72, color: colors.text },
          { text: "", delay: 78 },
          { text: "RITUAL Festivals (1)", delay: 82, color: colors.purple },
          { text: "  agent-market-research-RI-AM0001 [template]", delay: 90, color: colors.text },
          { text: "", delay: 96 },
          { text: "DUNGEON/COMPLETED Festivals (10)", delay: 100, color: colors.textMuted },
          { text: "  obey-vault-synthesis-OV0001 [100%]", delay: 108, color: colors.textMuted },
          { text: "  cre-risk-router-planning-CR0001 [100%]", delay: 116, color: colors.textMuted },
          { text: "  dashboard-DA0001 [100%]  ...+7 more", delay: 124, color: colors.textMuted },
        ]}
      />
      <div
        style={{
          color: colors.blue,
          fontSize: 15,
          fontFamily: fonts.mono,
          marginTop: 16,
          textAlign: "center",
        }}
      >
        This monorepo was scaffolded by camp CLI · Every festival planned with fest CLI
      </div>
    </div>
  );
};

const RitualRunHierarchy: React.FC = () => {
  // Real output from: fest show --festival agent-market-research-RI-AM0001-0009
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
          color: colors.purple,
          fontSize: 20,
          textTransform: "uppercase",
          letterSpacing: 3,
          marginBottom: 24,
          fontFamily: fonts.sans,
          textAlign: "center",
        }}
      >
        Ritual Run — Real Agent Decision Pipeline
      </div>
      <TerminalWindow
        title="fest show --festival RI-AM0001-0009"
        typingSpeed={4}
        lines={[
          { text: "$ fest show --festival agent-market-research-RI-AM0001-0009", delay: 0 },
          { text: "", delay: 20 },
          { text: "agent-market-research-RI-AM0001-0009  100%", delay: 25, color: colors.green },
          { text: "├── 001_INGEST  ✓ completed", delay: 35, color: colors.green },
          { text: "│   ├── ✓ Step 1: QUERY POOL STATE", delay: 42, color: colors.text },
          { text: "│   ├── ✓ Step 2: COLLECT PRICE HISTORY", delay: 49, color: colors.text },
          { text: "│   ├── ✓ Step 3: GET VOLUME AND VOLATILITY", delay: 56, color: colors.text },
          { text: "│   ├── ✓ Step 4: QUERY VAULT STATE", delay: 63, color: colors.text },
          { text: "│   └── ✓ Step 5: VALIDATE AND PACKAGE", delay: 70, color: colors.text },
          { text: "├── 002_RESEARCH  ✓ completed", delay: 80, color: colors.green },
          { text: "│   ├── ✓ Step 1: COMPUTE MOVING AVERAGE", delay: 87, color: colors.text },
          { text: "│   ├── ✓ Step 2: CALCULATE PRICE DEVIATION", delay: 94, color: colors.text },
          { text: "│   ├── ✓ Step 3: RUN CRE RISK GATES", delay: 101, color: colors.text },
          { text: "│   ├── ✓ Step 4: SCORE OPPORTUNITY", delay: 108, color: colors.text },
          { text: "│   └── ✓ Step 5: SYNTHESIZE FINDINGS", delay: 115, color: colors.text },
          { text: "└── 003_DECIDE  ✓ completed", delay: 125, color: colors.green },
          { text: "    └── 01_synthesize_decision  ✓ 6/6 tasks", delay: 132, color: colors.text },
        ]}
      />
    </div>
  );
};

const DecisionJsonScene: React.FC = () => {
  // Real decision.json from RI-AM0001-0009
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
        padding: 60,
      }}
    >
      <div
        style={{
          color: colors.orange,
          fontSize: 20,
          textTransform: "uppercase",
          letterSpacing: 3,
          marginBottom: 24,
          fontFamily: fonts.sans,
          textAlign: "center",
          opacity: interpolate(frame, [0, 15], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        decision.json — Real Ritual Output
      </div>
      <div
        style={{
          transform: `scale(${scale})`,
          backgroundColor: colors.bgTerminal,
          border: `1px solid ${colors.border}`,
          borderRadius: 12,
          padding: 28,
          fontFamily: fonts.mono,
          fontSize: 15,
          lineHeight: 1.9,
          width: "100%",
          maxWidth: 1000,
        }}
      >
        <JsonLine frame={frame} delay={5} k="ritual_run_id" v='"agent-market-research-RI-AM0001-0009"' />
        <JsonLine frame={frame} delay={10} k="decision" v='"GO"' color={colors.green} />
        <JsonLine frame={frame} delay={15} k="confidence" v="0.75" color={colors.orange} />
        <JsonLine frame={frame} delay={20} k="rationale.price_deviation_pct" v="39.912%" color={colors.text} />
        <JsonLine frame={frame} delay={25} k="rationale.deviation_direction" v='"above_ma"' />
        <JsonLine frame={frame} delay={30} k="rationale.cre_gates_passed" v="6 / 8" />
        <JsonLine frame={frame} delay={35} k="rationale.failed_gates" v='["risk_score", "price_deviation_vs_oracle"]' color={colors.red} />
        <JsonLine frame={frame} delay={40} k="rationale.estimated_net_profit_usd" v="$197.56" color={colors.green} />
        <JsonLine frame={frame} delay={48} k="recommendation.direction" v='"SELL"' color={colors.orange} />
        <JsonLine frame={frame} delay={53} k="recommendation.suggested_size_usd" v="500" />
        <JsonLine frame={frame} delay={58} k="recommendation.urgency" v='"high"' color={colors.red} />
        <JsonLine frame={frame} delay={65} k="vault_constraints_checked" v="within_max_swap ✓  within_daily_volume ✓  token_whitelisted ✓" color={colors.green} />
        <JsonLine frame={frame} delay={72} k="guardrails.trade_allowed" v="true" color={colors.green} />
      </div>
      <div
        style={{
          color: colors.textMuted,
          fontSize: 14,
          fontFamily: fonts.mono,
          marginTop: 16,
          textAlign: "center",
          opacity: interpolate(frame - 80, [0, 15], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        festivals/active/agent-market-research-RI-AM0001-0009/003_DECIDE/.../decision.json
      </div>
    </div>
  );
};

const JsonLine: React.FC<{ frame: number; delay: number; k: string; v: string; color?: string }> = ({
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
    <span style={{ color: colors.cyan }}>{`"${k}"`}</span>
    <span style={{ color: colors.textMuted }}>: </span>
    <span style={{ color }}>{v}</span>
  </div>
);

const NoGoScene: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: 32,
      }}
    >
      <div
        style={{
          color: colors.textMuted,
          fontSize: 28,
          fontFamily: fonts.sans,
          textAlign: "center",
          opacity: interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        A NO_GO is just as valuable as a profitable trade.
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
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: 32,
      }}
    >
      <div
        style={{
          color: colors.green,
          fontSize: 28,
          fontFamily: fonts.sans,
          textAlign: "center",
          opacity: interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        GO — executing within vault boundaries
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
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: fonts.sans,
      }}
    >
      <div
        style={{
          color: colors.textMuted,
          fontSize: 20,
          textTransform: "uppercase",
          letterSpacing: 3,
          marginBottom: 48,
          opacity: interpolate(frame, [0, 15], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        Festival Methodology — fest.build
      </div>
      <div style={{ display: "flex", gap: 32, alignItems: "center" }}>
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
                  padding: "32px 48px",
                  textAlign: "center",
                  boxShadow: activeGlow,
                }}
              >
                <div style={{ color: stepColors[i], fontSize: 16, letterSpacing: 2, marginBottom: 6 }}>
                  0{i + 1}
                </div>
                <div style={{ color: colors.textBright, fontSize: 28, fontWeight: 700 }}>{step}</div>
              </div>
              {i < steps.length - 1 && (
                <div
                  style={{
                    color: colors.textMuted,
                    fontSize: 36,
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
          fontSize: 20,
          marginTop: 48,
          opacity: interpolate(frame, [80, 100], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        fest CLI and camp CLI orchestrate every cycle — from project scaffolding to agent decisions
      </div>
    </div>
  );
};
