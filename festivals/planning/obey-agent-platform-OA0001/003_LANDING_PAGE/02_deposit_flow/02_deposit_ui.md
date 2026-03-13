---
fest_type: task
fest_id: 02_deposit_ui.md
fest_name: deposit_ui
fest_parent: 02_deposit_flow
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.434442-06:00
fest_tracking: true
---

# Task: Deposit USDC Flow UI

## Objective

Build the multi-step deposit flow UI at `/agents/[id]/deposit` that lets a connected wallet user select an amount of USDC to deposit, preview the shares they will receive, confirm the transaction, and see a success confirmation with their share token receipt.

## Requirements

- [ ] Create the `/agents/[id]/deposit` page as a client component with step-based navigation (Select Amount, Review, Confirm, Success)
- [ ] Step 1 (Select Amount): Show user's USDC balance, amount input with max button, live preview of estimated shares based on current NAV/share price, creator share breakdown
- [ ] Step 2 (Review & Confirm): Show transaction summary (amount, shares received, creator share, platform fee), "Confirm Deposit" button that triggers the on-chain transaction
- [ ] Step 3 (Success): Show transaction hash (linked to Solana explorer), shares received, and navigation links to portfolio and agent profile
- [ ] Handle wallet not connected state with a prompt to connect
- [ ] Handle insufficient balance, zero amount, and transaction failure error states
- [ ] Build the Solana transaction using the MVP vault program's `deposit` instruction

## Implementation

### Step 1: Create deposit page at `src/app/agents/[id]/deposit/page.tsx`

```typescript
// src/app/agents/[id]/deposit/page.tsx
"use client";

import { use, useState } from "react";
import { useWallet } from "@solana/wallet-adapter-react";
import { ConnectWalletButton } from "@/components/wallet/ConnectWalletButton";
import { DepositAmountStep } from "@/components/deposit/DepositAmountStep";
import { DepositReviewStep } from "@/components/deposit/DepositReviewStep";
import { DepositSuccessStep } from "@/components/deposit/DepositSuccessStep";
import { useAgentProfile } from "@/hooks/useAgentProfile";
import { useAgentNAV } from "@/hooks/useAgentNAV";
import { useWalletBalance } from "@/hooks/useWalletBalance";

type DepositStep = "amount" | "review" | "success";

interface PageProps {
  params: Promise<{ id: string }>;
}

export default function DepositPage({ params }: PageProps) {
  const { id: agentId } = use(params);
  const { connected } = useWallet();
  const { profile, loading: profileLoading } = useAgentProfile(agentId);
  const { nav, loading: navLoading } = useAgentNAV(agentId, "30d");
  const { usdcBalance } = useWalletBalance();

  const [step, setStep] = useState<DepositStep>("amount");
  const [amount, setAmount] = useState<number>(0);
  const [txHash, setTxHash] = useState<string>("");
  const [sharesReceived, setSharesReceived] = useState<number>(0);

  if (!connected) {
    return (
      <main className="flex min-h-screen items-center justify-center bg-gray-950 text-gray-100">
        <div className="text-center">
          <h1 className="mb-2 text-2xl font-bold">Connect Your Wallet</h1>
          <p className="mb-6 text-gray-400">
            Connect a Solana wallet to deposit USDC into this agent.
          </p>
          <ConnectWalletButton />
        </div>
      </main>
    );
  }

  if (profileLoading || navLoading) {
    return (
      <main className="flex min-h-screen items-center justify-center bg-gray-950">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-blue-500 border-t-transparent" />
      </main>
    );
  }

  if (!profile || !nav) {
    return (
      <main className="flex min-h-screen items-center justify-center bg-gray-950 text-gray-100">
        <p className="text-red-400">Agent not found.</p>
      </main>
    );
  }

  const sharePrice = nav.currentSharePrice;
  const creatorPct = profile.creatorOwnershipPct;

  return (
    <main className="min-h-screen bg-gray-950 text-gray-100">
      <div className="mx-auto max-w-lg px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <a href={`/agents/${agentId}`} className="text-sm text-blue-400 hover:text-blue-300">
            &larr; Back to {profile.name}
          </a>
          <h1 className="mt-2 text-2xl font-bold">Deposit USDC</h1>
          <p className="text-sm text-gray-400">
            Fund {profile.name} and receive {profile.depositorStats.shareTokenSymbol} share tokens.
          </p>
        </div>

        {/* Step Indicator */}
        <div className="mb-8 flex items-center gap-2">
          {(["amount", "review", "success"] as DepositStep[]).map((s, i) => (
            <div key={s} className="flex items-center gap-2">
              <div
                className={`flex h-7 w-7 items-center justify-center rounded-full text-xs font-bold ${
                  step === s
                    ? "bg-blue-600 text-white"
                    : i < ["amount", "review", "success"].indexOf(step)
                      ? "bg-green-600 text-white"
                      : "bg-gray-800 text-gray-500"
                }`}
              >
                {i + 1}
              </div>
              {i < 2 && <div className="h-px w-8 bg-gray-700" />}
            </div>
          ))}
        </div>

        {step === "amount" && (
          <DepositAmountStep
            usdcBalance={usdcBalance}
            sharePrice={sharePrice}
            creatorPct={creatorPct}
            shareTokenSymbol={profile.depositorStats.shareTokenSymbol}
            amount={amount}
            onAmountChange={setAmount}
            onNext={() => setStep("review")}
          />
        )}

        {step === "review" && (
          <DepositReviewStep
            agentId={agentId}
            agentName={profile.name}
            amount={amount}
            sharePrice={sharePrice}
            creatorPct={creatorPct}
            shareTokenSymbol={profile.depositorStats.shareTokenSymbol}
            onBack={() => setStep("amount")}
            onSuccess={(hash, shares) => {
              setTxHash(hash);
              setSharesReceived(shares);
              setStep("success");
            }}
          />
        )}

        {step === "success" && (
          <DepositSuccessStep
            agentId={agentId}
            agentName={profile.name}
            txHash={txHash}
            sharesReceived={sharesReceived}
            shareTokenSymbol={profile.depositorStats.shareTokenSymbol}
          />
        )}
      </div>
    </main>
  );
}
```

### Step 2: Build `DepositAmountStep` at `src/components/deposit/DepositAmountStep.tsx`

```typescript
// src/components/deposit/DepositAmountStep.tsx
"use client";

import { useMemo } from "react";

interface Props {
  usdcBalance: number;
  sharePrice: number;
  creatorPct: number;
  shareTokenSymbol: string;
  amount: number;
  onAmountChange: (amount: number) => void;
  onNext: () => void;
}

export function DepositAmountStep({
  usdcBalance,
  sharePrice,
  creatorPct,
  shareTokenSymbol,
  amount,
  onAmountChange,
  onNext,
}: Props) {
  const estimatedShares = useMemo(() => {
    if (amount <= 0 || sharePrice <= 0) return 0;
    return amount / sharePrice;
  }, [amount, sharePrice]);

  const creatorShares = estimatedShares * (creatorPct / 100);
  const userShares = estimatedShares - creatorShares;
  const insufficientBalance = amount > usdcBalance;
  const canProceed = amount > 0 && !insufficientBalance;

  return (
    <div className="space-y-6">
      {/* USDC Balance */}
      <div className="rounded-lg border border-gray-800 bg-gray-900 p-4">
        <div className="flex items-center justify-between">
          <span className="text-sm text-gray-400">Your USDC Balance</span>
          <span className="font-mono text-lg font-bold text-white">
            {usdcBalance.toLocaleString("en-US", { minimumFractionDigits: 2 })} USDC
          </span>
        </div>
      </div>

      {/* Amount Input */}
      <div>
        <label className="mb-2 block text-sm font-medium text-gray-300">
          Deposit Amount (USDC)
        </label>
        <div className="relative">
          <input
            type="number"
            min={0}
            step={0.01}
            value={amount || ""}
            onChange={(e) => onAmountChange(parseFloat(e.target.value) || 0)}
            placeholder="0.00"
            className="w-full rounded-lg border border-gray-700 bg-gray-800 px-4 py-3 pr-20 text-lg font-mono text-white placeholder-gray-600 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
          />
          <button
            onClick={() => onAmountChange(usdcBalance)}
            className="absolute right-2 top-1/2 -translate-y-1/2 rounded bg-gray-700 px-3 py-1 text-xs font-medium text-gray-300 hover:bg-gray-600"
          >
            MAX
          </button>
        </div>
        {insufficientBalance && (
          <p className="mt-1 text-sm text-red-400">Insufficient USDC balance.</p>
        )}
      </div>

      {/* Share Preview */}
      {amount > 0 && (
        <div className="rounded-lg border border-gray-800 bg-gray-900 p-4 space-y-3">
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">Current Share Price</span>
            <span className="font-mono text-gray-200">${sharePrice.toFixed(4)}</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">Total Shares Minted</span>
            <span className="font-mono text-gray-200">
              ~{estimatedShares.toFixed(2)} {shareTokenSymbol}
            </span>
          </div>
          <div className="border-t border-gray-800 pt-3">
            <div className="flex justify-between text-sm">
              <span className="text-gray-400">Your Shares</span>
              <span className="font-mono text-green-400">
                ~{userShares.toFixed(2)} {shareTokenSymbol}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-400">Creator Shares ({creatorPct}%)</span>
              <span className="font-mono text-gray-500">
                ~{creatorShares.toFixed(2)} {shareTokenSymbol}
              </span>
            </div>
          </div>
        </div>
      )}

      {/* Continue Button */}
      <button
        disabled={!canProceed}
        onClick={onNext}
        className="w-full rounded-lg bg-green-600 py-3 font-semibold text-white transition-colors hover:bg-green-500 disabled:cursor-not-allowed disabled:bg-gray-700 disabled:text-gray-500"
      >
        Continue
      </button>
    </div>
  );
}
```

### Step 3: Build `DepositReviewStep` at `src/components/deposit/DepositReviewStep.tsx`

```typescript
// src/components/deposit/DepositReviewStep.tsx
"use client";

import { useState, useCallback } from "react";
import { useWallet, useConnection } from "@solana/wallet-adapter-react";
import { Transaction, PublicKey } from "@solana/web3.js";

interface Props {
  agentId: string;
  agentName: string;
  amount: number;
  sharePrice: number;
  creatorPct: number;
  shareTokenSymbol: string;
  onBack: () => void;
  onSuccess: (txHash: string, sharesReceived: number) => void;
}

const PLATFORM_FEE_PCT = 0.5; // 0.5% platform fee

export function DepositReviewStep({
  agentId,
  agentName,
  amount,
  sharePrice,
  creatorPct,
  shareTokenSymbol,
  onBack,
  onSuccess,
}: Props) {
  const { publicKey, signTransaction } = useWallet();
  const { connection } = useConnection();
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const totalShares = amount / sharePrice;
  const creatorShares = totalShares * (creatorPct / 100);
  const userShares = totalShares - creatorShares;
  const platformFee = amount * (PLATFORM_FEE_PCT / 100);
  const netDeposit = amount - platformFee;

  const handleConfirm = useCallback(async () => {
    if (!publicKey || !signTransaction) return;

    setSubmitting(true);
    setError(null);

    try {
      // 1. Request the unsigned transaction from our backend
      const res = await fetch(`/api/v1/agents/${agentId}/deposit`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          depositor: publicKey.toBase58(),
          amount: amount,
          // Amount in USDC smallest unit (6 decimals)
          amountLamports: Math.floor(amount * 1_000_000),
        }),
      });

      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.error ?? `Server error ${res.status}`);
      }

      const { transaction: txBase64, sharesOut } = await res.json();

      // 2. Deserialize and sign the transaction
      const txBuffer = Buffer.from(txBase64, "base64");
      const tx = Transaction.from(txBuffer);
      const signed = await signTransaction(tx);

      // 3. Send the signed transaction
      const signature = await connection.sendRawTransaction(signed.serialize());
      await connection.confirmTransaction(signature, "confirmed");

      onSuccess(signature, sharesOut);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Transaction failed");
    } finally {
      setSubmitting(false);
    }
  }, [publicKey, signTransaction, connection, agentId, amount, onSuccess]);

  return (
    <div className="space-y-6">
      <div className="rounded-lg border border-gray-800 bg-gray-900 p-6 space-y-4">
        <h2 className="text-lg font-semibold text-white">Review Deposit</h2>

        <div className="space-y-3">
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">Agent</span>
            <span className="text-white">{agentName}</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">Deposit Amount</span>
            <span className="font-mono text-white">{amount.toLocaleString()} USDC</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">Platform Fee ({PLATFORM_FEE_PCT}%)</span>
            <span className="font-mono text-gray-400">-{platformFee.toFixed(2)} USDC</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">Net Deposit</span>
            <span className="font-mono text-white">{netDeposit.toFixed(2)} USDC</span>
          </div>

          <div className="border-t border-gray-700 pt-3">
            <div className="flex justify-between text-sm">
              <span className="text-gray-400">You Receive</span>
              <span className="font-mono font-bold text-green-400">
                ~{userShares.toFixed(2)} {shareTokenSymbol}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-400">Creator Receives ({creatorPct}%)</span>
              <span className="font-mono text-gray-500">
                ~{creatorShares.toFixed(2)} {shareTokenSymbol}
              </span>
            </div>
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-lg border border-red-800 bg-red-900/20 p-3 text-sm text-red-400">
          {error}
        </div>
      )}

      <div className="flex gap-3">
        <button
          onClick={onBack}
          disabled={submitting}
          className="flex-1 rounded-lg border border-gray-700 py-3 font-semibold text-gray-300 transition-colors hover:border-gray-600 disabled:opacity-50"
        >
          Back
        </button>
        <button
          onClick={handleConfirm}
          disabled={submitting}
          className="flex-1 rounded-lg bg-green-600 py-3 font-semibold text-white transition-colors hover:bg-green-500 disabled:bg-green-800 disabled:text-green-300"
        >
          {submitting ? "Confirming..." : "Confirm Deposit"}
        </button>
      </div>
    </div>
  );
}
```

### Step 4: Build `DepositSuccessStep` at `src/components/deposit/DepositSuccessStep.tsx`

```typescript
// src/components/deposit/DepositSuccessStep.tsx

interface Props {
  agentId: string;
  agentName: string;
  txHash: string;
  sharesReceived: number;
  shareTokenSymbol: string;
}

const EXPLORER_URL = "https://solscan.io/tx";

export function DepositSuccessStep({
  agentId,
  agentName,
  txHash,
  sharesReceived,
  shareTokenSymbol,
}: Props) {
  return (
    <div className="space-y-6 text-center">
      <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-600/20">
        <svg className="h-8 w-8 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
        </svg>
      </div>

      <div>
        <h2 className="text-2xl font-bold text-white">Deposit Successful</h2>
        <p className="mt-1 text-gray-400">
          Your agent is now trading with your capital.
        </p>
      </div>

      <div className="rounded-lg border border-gray-800 bg-gray-900 p-4 space-y-3">
        <div className="flex justify-between text-sm">
          <span className="text-gray-400">Agent</span>
          <span className="text-white">{agentName}</span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-400">Shares Received</span>
          <span className="font-mono font-bold text-green-400">
            {sharesReceived.toFixed(2)} {shareTokenSymbol}
          </span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-400">Transaction</span>
          <a
            href={`${EXPLORER_URL}/${txHash}`}
            target="_blank"
            rel="noopener noreferrer"
            className="font-mono text-blue-400 hover:text-blue-300"
          >
            {txHash.slice(0, 8)}...{txHash.slice(-8)}
          </a>
        </div>
      </div>

      <div className="flex gap-3">
        <a
          href="/portfolio"
          className="flex-1 rounded-lg bg-blue-600 py-3 text-center font-semibold text-white transition-colors hover:bg-blue-500"
        >
          View Portfolio
        </a>
        <a
          href={`/agents/${agentId}`}
          className="flex-1 rounded-lg border border-gray-700 py-3 text-center font-semibold text-gray-300 transition-colors hover:border-gray-600"
        >
          Back to Agent
        </a>
      </div>
    </div>
  );
}
```

### Step 5: Create the backend deposit transaction endpoint at `src/app/api/v1/agents/[id]/deposit/route.ts`

```typescript
// src/app/api/v1/agents/[id]/deposit/route.ts

import { NextRequest, NextResponse } from "next/server";

const BACKEND_URL = process.env.BACKEND_API_URL ?? "http://localhost:8080";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  const { id } = await params;

  try {
    const body = await request.json();
    const { depositor, amountLamports } = body;

    if (!depositor || !amountLamports || amountLamports <= 0) {
      return NextResponse.json(
        { error: "Missing or invalid depositor address or amount" },
        { status: 400 },
      );
    }

    // Forward to Go backend which constructs the Solana transaction
    const res = await fetch(`${BACKEND_URL}/api/v1/agents/${id}/deposit`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ depositor, amountLamports }),
    });

    if (!res.ok) {
      const errBody = await res.json().catch(() => ({}));
      return NextResponse.json(
        { error: errBody.error ?? `Backend error ${res.status}` },
        { status: res.status },
      );
    }

    // Backend returns { transaction: base64, sharesOut: number }
    const data = await res.json();
    return NextResponse.json(data);
  } catch (err) {
    return NextResponse.json(
      { error: err instanceof Error ? err.message : "Internal server error" },
      { status: 500 },
    );
  }
}
```

## Done When

- [ ] All requirements met
- [ ] `/agents/[id]/deposit` page renders with step indicator and correct step content
- [ ] Disconnected wallet state shows "Connect Your Wallet" prompt with the connect button
- [ ] Step 1 shows USDC balance, amount input with MAX button, and live share preview that updates as user types
- [ ] Creator share breakdown (e.g., "Creator receives ~120 shares (12%)") is visible in the preview
- [ ] "Insufficient USDC balance" error appears when amount exceeds balance
- [ ] Step 2 shows the full transaction summary with platform fee, net deposit, user shares, and creator shares
- [ ] "Confirm Deposit" button constructs, signs, and submits the Solana transaction
- [ ] Transaction errors display in a red error banner with the error message
- [ ] Step 3 shows success checkmark, shares received, clickable transaction hash linking to Solscan, and navigation buttons
