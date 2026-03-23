import React from "react";
import { Sequence, AbsoluteFill } from "remotion";
import { S1_VaultBoundaries } from "./scenes/S1_VaultBoundaries";
import { S2_AgentIdentity } from "./scenes/S2_AgentIdentity";
import { S3_RitualCycle } from "./scenes/S3_RitualCycle";
import { S4_OnChainReceipt } from "./scenes/S4_OnChainReceipt";
import { S5_MultiChain } from "./scenes/S5_MultiChain";
import { S6_Closing } from "./scenes/S6_Closing";
import { colors } from "./data/theme";

export const ObeyDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: colors.bg }}>
      {/* Scene 1: Title + Vault Boundaries (0:00–0:30) */}
      <Sequence from={0} durationInFrames={900}>
        <AbsoluteFill>
          <S1_VaultBoundaries />
        </AbsoluteFill>
      </Sequence>

      {/* Scene 2: Agent Identity — ERC-8004 (0:30–0:50) */}
      <Sequence from={900} durationInFrames={600}>
        <AbsoluteFill>
          <S2_AgentIdentity />
        </AbsoluteFill>
      </Sequence>

      {/* Scene 3: Live Ritual Cycle (0:50–1:50) */}
      <Sequence from={1500} durationInFrames={1800}>
        <AbsoluteFill>
          <S3_RitualCycle />
        </AbsoluteFill>
      </Sequence>

      {/* Scene 4: On-Chain Receipt (1:50–2:20) */}
      <Sequence from={3300} durationInFrames={900}>
        <AbsoluteFill>
          <S4_OnChainReceipt />
        </AbsoluteFill>
      </Sequence>

      {/* Scene 5: Multi-Chain Architecture (2:20–2:40) */}
      <Sequence from={4200} durationInFrames={600}>
        <AbsoluteFill>
          <S5_MultiChain />
        </AbsoluteFill>
      </Sequence>

      {/* Scene 6: Closing (2:40–3:00) */}
      <Sequence from={4800} durationInFrames={600}>
        <AbsoluteFill>
          <S6_Closing />
        </AbsoluteFill>
      </Sequence>
    </AbsoluteFill>
  );
};
