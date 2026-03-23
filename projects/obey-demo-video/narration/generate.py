#!/usr/bin/env python3
"""Generate narration WAV files for OBEY demo video using Kokoro TTS."""

import soundfile as sf
from kokoro_onnx import Kokoro
import os
import urllib.request
from pathlib import Path

VOICE = "af_bella"
SPEED = 0.95
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
PUBLIC_DIR = os.path.join(os.path.dirname(OUTPUT_DIR), "public", "audio")

MODELS_DIR = Path.home() / ".cache" / "samantha" / "models"
MODEL_URL = "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx"
VOICES_URL = "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin"
MODEL_FILE = "kokoro-v1.0.onnx"
VOICES_FILE = "voices-v1.0.bin"

def download_if_missing(url, filename):
    path = MODELS_DIR / filename
    if path.exists():
        return path
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    print(f"  Downloading {filename}...")
    urllib.request.urlretrieve(url, str(path))
    return path

segments = {
    "s1_intro": (
        "This is OBEY Agent Economy — autonomous agent infrastructure built by Obedience Corp. "
        "The core principle is simple: agents obey their human owner. "
        "ObeyVault is an ERC-4626 vault where the human guardian sets spending boundaries "
        "enforced at the smart contract level. Max swap size, daily volume caps, token whitelists, "
        "slippage limits — the agent operates within these boundaries and cannot modify them. "
        "The guardian controls. The agent executes."
    ),
    "s2_identity": (
        "Every OBEY agent has a persistent on-chain identity using ERC-8004. "
        "Registered on Base, this identity links the agent to its operator wallet "
        "and creates a portable, verifiable track record. Other agents and protocols "
        "can query this identity before delegating tasks or trusting decisions."
    ),
    "s3_festival": (
        "Every agent decision follows the Festival Methodology — an open source planning framework "
        "built by Obedience Corp, available at fest dot build. Festival structures work into "
        "discover, plan, execute, and verify loops. The fest CLI and camp CLI are real tools "
        "that orchestrated this entire project — camp scaffolded the monorepo, and fest planned "
        "every phase of development. "
        "Here's the live campaign state. Twenty festivals total — active ritual runs, "
        "completed work archived in the dungeon, and the ritual template that spawns new cycles. "
        "Each ritual run follows a structured pipeline: ingest market data, research signals "
        "and run eight CRE risk gates, then synthesize a decision. The output is a machine-readable "
        "decision dot json with confidence scores, gate results, and trade recommendations. "
        "A no-go decision — choosing not to trade — is just as valuable as a profitable trade. "
        "It proves the agent exercises judgment, not just execution."
    ),
    "s4_receipt": (
        "When the agent does trade, every swap emits a SwapExecuted event on-chain. "
        "The reason field contains the agent's encoded rationale — committed at transaction time, "
        "not after the fact. This is a real transaction on Base Sepolia, verifiable on any block explorer. "
        "The full reasoning chain is captured in agent log dot json — phase, action, tools used, "
        "decision rationale, and the transaction hash. Complete auditability."
    ),
    "s5_chains": (
        "OBEY operates across five chains with over eighty verified transactions. "
        "Base Sepolia for vault trading, Hedera for consensus messaging, "
        "Ethereum Sepolia for CRE risk evaluation, zero-G for contract deployment, "
        "and Status Network for gasless transactions. "
        "Eight contracts deployed across four ERC standards."
    ),
    "s6_closing": (
        "The agents obey. The vault enforces. Every decision has a receipt. "
        "Built with Go, Solidity, Uniswap V3, Hedera, Chainlink CRE, "
        "and the Obey Agent Runtime. Planned and orchestrated with Festival. "
        "OBEY Agent Economy — by Obedience Corp."
    ),
}

def main():
    os.makedirs(PUBLIC_DIR, exist_ok=True)

    print("Loading Kokoro model...")
    model_path = download_if_missing(MODEL_URL, MODEL_FILE)
    voices_path = download_if_missing(VOICES_URL, VOICES_FILE)
    kokoro = Kokoro(str(model_path), str(voices_path))
    print(f"Model loaded. Voice: {VOICE}, Speed: {SPEED}")

    for name, text in segments.items():
        print(f"\nGenerating {name}...")
        samples, sample_rate = kokoro.create(text, voice=VOICE, speed=SPEED)
        out_path = os.path.join(PUBLIC_DIR, f"{name}.wav")
        sf.write(out_path, samples, sample_rate)
        duration = len(samples) / sample_rate
        print(f"  -> {out_path} ({duration:.1f}s)")

    print("\nAll narration clips generated!")

if __name__ == "__main__":
    main()
