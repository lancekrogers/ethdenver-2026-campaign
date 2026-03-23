import React from "react";
import { Sequence, AbsoluteFill, Audio, staticFile } from "remotion";
import { S1_VaultBoundaries } from "./scenes/S1_VaultBoundaries";
import { S2_AgentIdentity } from "./scenes/S2_AgentIdentity";
import { S3_RitualCycle } from "./scenes/S3_RitualCycle";
import { S4_OnChainReceipt } from "./scenes/S4_OnChainReceipt";
import { S5_MultiChain } from "./scenes/S5_MultiChain";
import { S6_Closing } from "./scenes/S6_Closing";
import { colors } from "./data/theme";

// Scene durations adjusted to fit narration audio (30fps)
// S1: 30.9s audio → 940 frames | S2: 21.4s → 660 frames
// S3: 64.7s → 1960 frames     | S4: 28.2s → 900 frames
// S5: 22.7s → 700 frames      | S6: 18.3s → 600 frames
const S1 = { from: 0, dur: 940 };
const S2 = { from: 940, dur: 660 };
const S3 = { from: 1600, dur: 1960 };
const S4 = { from: 3560, dur: 900 };
const S5 = { from: 4460, dur: 700 };
const S6 = { from: 5160, dur: 600 };

export const ObeyDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: colors.bg }}>
      {/* Scene 1: Title + Vault Boundaries */}
      <Sequence from={S1.from} durationInFrames={S1.dur}>
        <AbsoluteFill>
          <S1_VaultBoundaries />
        </AbsoluteFill>
        <Audio src={staticFile("audio/s1_intro.wav")} />
      </Sequence>

      {/* Scene 2: Agent Identity — ERC-8004 */}
      <Sequence from={S2.from} durationInFrames={S2.dur}>
        <AbsoluteFill>
          <S2_AgentIdentity />
        </AbsoluteFill>
        <Audio src={staticFile("audio/s2_identity.wav")} />
      </Sequence>

      {/* Scene 3: Live Ritual Cycle */}
      <Sequence from={S3.from} durationInFrames={S3.dur}>
        <AbsoluteFill>
          <S3_RitualCycle />
        </AbsoluteFill>
        <Audio src={staticFile("audio/s3_festival.wav")} />
      </Sequence>

      {/* Scene 4: On-Chain Receipt */}
      <Sequence from={S4.from} durationInFrames={S4.dur}>
        <AbsoluteFill>
          <S4_OnChainReceipt />
        </AbsoluteFill>
        <Audio src={staticFile("audio/s4_receipt.wav")} />
      </Sequence>

      {/* Scene 5: Multi-Chain Architecture */}
      <Sequence from={S5.from} durationInFrames={S5.dur}>
        <AbsoluteFill>
          <S5_MultiChain />
        </AbsoluteFill>
        <Audio src={staticFile("audio/s5_chains.wav")} />
      </Sequence>

      {/* Scene 6: Closing */}
      <Sequence from={S6.from} durationInFrames={S6.dur}>
        <AbsoluteFill>
          <S6_Closing />
        </AbsoluteFill>
        <Audio src={staticFile("audio/s6_closing.wav")} />
      </Sequence>
    </AbsoluteFill>
  );
};
