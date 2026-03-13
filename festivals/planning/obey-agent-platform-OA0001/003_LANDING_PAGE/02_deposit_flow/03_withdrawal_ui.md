---
fest_type: task
fest_id: 03_withdrawal_ui.md
fest_name: withdrawal_ui
fest_parent: 02_deposit_flow
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.43468-06:00
fest_tracking: true
---

# Task: Withdrawal (Share Burn) Flow UI

## Objective

Build the withdrawal flow at `/agents/[id]/withdraw` that lets users burn their share tokens to receive proportional USDC back, including a pending withdrawal state with countdown timer when the agent has a withdrawal delay configured.

## Requirements

- [ ] Create the `/agents/[id]/withdraw` page with step-based flow (Select Shares, Review, Pending/Execute, Complete)
- [ ] Step 1 (Select Shares): Show user's current share balance, current NAV per share, input for number of shares to burn, estimated withdrawal value in USDC
- [ ] Step 2 (Review): Summary showing shares to burn, estimated USDC value, withdrawal delay notice if applicable, "Request Withdrawal" button
- [ ] Step 3 (Pending): If agent has a withdrawal delay, show a countdown timer to when the withdrawal becomes executable, with a "Cancel Withdrawal" option
- [ ] Step 4 (Execute/Complete): "Execute Withdrawal" button once the delay has passed, then success state showing USDC received and transaction hash
- [ ] Handle zero share balance, wallet not connected, and transaction failure states
- [ ] Create hooks to fetch user's share token balance and pending withdrawal status

## Implementation

### Step 1: Create `useShareBalance` hook at `src/hooks/useShareBalance.ts`

```typescript
// src/hooks/useShareBalance.ts
"use client";

import { useState, useEffect } from "react";
import { useConnection, useWallet } from "@solana/wallet-adapter-react";
import { PublicKey } from "@solana/web3.js";

export function useShareBalance(shareTokenMint: string | undefined) {
  const { connection } = useConnection();
  const { publicKey, connected } = useWallet();
  const [balance, setBalance] = useState<number>(0);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!connected || !publicKey || !shareTokenMint) {
      setBalance(0);
      return;
    }

    let cancelled = false;
    setLoading(true);

    async function fetchBalance() {
      try {
        const mint = new PublicKey(shareTokenMint!);
        const tokenAccounts = await connection.getParsedTokenAccountsByOwner(
          publicKey!,
          { mint },
        );

        if (!cancelled) {
          const account = tokenAccounts.value[0];
          const amount = account
            ? (account.account.data.parsed.info.tokenAmount.uiAmount as number)
            : 0;
          setBalance(amount);
        }
      } catch {
        if (!cancelled) setBalance(0);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    fetchBalance();
    return () => { cancelled = true; };
  }, [connected, publicKey, connection, shareTokenMint]);

  return { balance, loading };
}
```

### Step 2: Create pending withdrawal types and hook at `src/hooks/usePendingWithdrawal.ts`

```typescript
// src/hooks/usePendingWithdrawal.ts
"use client";

import { useState, useEffect } from "react";
import { useWallet } from "@solana/wallet-adapter-react";

export interface PendingWithdrawal {
  id: string;
  shares: number;
  estimatedValue: number;
  requestedAt: string;      // ISO timestamp
  executableAt: string;     // ISO timestamp
  status: "pending" | "executable" | "cancelled" | "executed";
}

export function usePendingWithdrawal(agentId: string) {
  const { publicKey, connected } = useWallet();
  const [pending, setPending] = useState<PendingWithdrawal | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!connected || !publicKey) {
      setPending(null);
      return;
    }

    let cancelled = false;
    setLoading(true);

    fetch(
      `/api/v1/agents/${agentId}/withdrawals?wallet=${publicKey.toBase58()}&status=pending`,
    )
      .then((res) => (res.ok ? res.json() : null))
      .then((data) => {
        if (!cancelled) {
          setPending(data?.withdrawal ?? null);
          setLoading(false);
        }
      })
      .catch(() => {
        if (!cancelled) setLoading(false);
      });

    return () => { cancelled = true; };
  }, [connected, publicKey, agentId]);

  return { pending, loading, refresh: () => setPending(null) };
}
```

### Step 3: Create withdraw page at `src/app/agents/[id]/withdraw/page.tsx`

```typescript
// src/app/agents/[id]/withdraw/page.tsx
"use client";

import { use, useState, useCallback } from "react";
import { useWallet, useConnection } from "@solana/wallet-adapter-react";
import { Transaction } from "@solana/web3.js";
import { ConnectWalletButton } from "@/components/wallet/ConnectWalletButton";
import { useAgentProfile } from "@/hooks/useAgentProfile";
import { useAgentNAV } from "@/hooks/useAgentNAV";
import { useShareBalance } from "@/hooks/useShareBalance";
import { usePendingWithdrawal } from "@/hooks/usePendingWithdrawal";
import { WithdrawAmountStep } from "@/components/withdraw/WithdrawAmountStep";
import { WithdrawReviewStep } from "@/components/withdraw/WithdrawReviewStep";
import { WithdrawPendingStep } from "@/components/withdraw/WithdrawPendingStep";
import { WithdrawSuccessStep } from "@/components/withdraw/WithdrawSuccessStep";

type WithdrawStep = "amount" | "review" | "pending" | "success";

interface PageProps {
  params: Promise<{ id: string }>;
}

export default function WithdrawPage({ params }: PageProps) {
  const { id: agentId } = use(params);
  const { connected, publicKey, signTransaction } = useWallet();
  const { connection } = useConnection();
  const { profile, loading: profileLoading } = useAgentProfile(agentId);
  const { nav } = useAgentNAV(agentId, "30d");
  const { balance: shareBalance } = useShareBalance(
    profile?.depositorStats.shareTokenSymbol, // In real implementation, this would be the mint address
  );
  const { pending } = usePendingWithdrawal(agentId);

  const [step, setStep] = useState<WithdrawStep>(pending ? "pending" : "amount");
  const [sharesToBurn, setSharesToBurn] = useState<number>(0);
  const [txHash, setTxHash] = useState<string>("");
  const [usdcReceived, setUsdcReceived] = useState<number>(0);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const sharePrice = nav?.currentSharePrice ?? 0;
  const withdrawalDelayHours = profile?.riskParams.withdrawalDelayHours ?? 0;

  const handleRequestWithdrawal = useCallback(async () => {
    if (!publicKey || !signTransaction) return;
    setSubmitting(true);
    setError(null);

    try {
      const res = await fetch(`/api/v1/agents/${agentId}/withdraw`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          wallet: publicKey.toBase58(),
          shares: sharesToBurn,
        }),
      });

      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.error ?? `Server error ${res.status}`);
      }

      const { transaction: txBase64 } = await res.json();
      const txBuffer = Buffer.from(txBase64, "base64");
      const tx = Transaction.from(txBuffer);
      const signed = await signTransaction(tx);
      const signature = await connection.sendRawTransaction(signed.serialize());
      await connection.confirmTransaction(signature, "confirmed");

      if (withdrawalDelayHours > 0) {
        setStep("pending");
      } else {
        setTxHash(signature);
        setUsdcReceived(sharesToBurn * sharePrice);
        setStep("success");
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Withdrawal failed");
    } finally {
      setSubmitting(false);
    }
  }, [publicKey, signTransaction, connection, agentId, sharesToBurn, sharePrice, withdrawalDelayHours]);

  const handleExecuteWithdrawal = useCallback(async () => {
    if (!publicKey || !signTransaction || !pending) return;
    setSubmitting(true);
    setError(null);

    try {
      const res = await fetch(`/api/v1/agents/${agentId}/withdraw/execute`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          wallet: publicKey.toBase58(),
          withdrawalId: pending.id,
        }),
      });

      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.error ?? `Server error ${res.status}`);
      }

      const { transaction: txBase64, usdcAmount } = await res.json();
      const txBuffer = Buffer.from(txBase64, "base64");
      const tx = Transaction.from(txBuffer);
      const signed = await signTransaction(tx);
      const signature = await connection.sendRawTransaction(signed.serialize());
      await connection.confirmTransaction(signature, "confirmed");

      setTxHash(signature);
      setUsdcReceived(usdcAmount);
      setStep("success");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Execution failed");
    } finally {
      setSubmitting(false);
    }
  }, [publicKey, signTransaction, connection, agentId, pending]);

  if (!connected) {
    return (
      <main className="flex min-h-screen items-center justify-center bg-gray-950 text-gray-100">
        <div className="text-center">
          <h1 className="mb-2 text-2xl font-bold">Connect Your Wallet</h1>
          <p className="mb-6 text-gray-400">Connect your wallet to withdraw.</p>
          <ConnectWalletButton />
        </div>
      </main>
    );
  }

  if (profileLoading || !profile) {
    return (
      <main className="flex min-h-screen items-center justify-center bg-gray-950">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-blue-500 border-t-transparent" />
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-gray-950 text-gray-100">
      <div className="mx-auto max-w-lg px-4 py-8">
        <div className="mb-8">
          <a href={`/agents/${agentId}`} className="text-sm text-blue-400 hover:text-blue-300">
            &larr; Back to {profile.name}
          </a>
          <h1 className="mt-2 text-2xl font-bold">Withdraw</h1>
          <p className="text-sm text-gray-400">
            Burn your {profile.depositorStats.shareTokenSymbol} shares to receive USDC.
          </p>
        </div>

        {error && (
          <div className="mb-4 rounded-lg border border-red-800 bg-red-900/20 p-3 text-sm text-red-400">
            {error}
          </div>
        )}

        {step === "amount" && (
          <WithdrawAmountStep
            shareBalance={shareBalance}
            sharePrice={sharePrice}
            shareTokenSymbol={profile.depositorStats.shareTokenSymbol}
            sharesToBurn={sharesToBurn}
            onSharesChange={setSharesToBurn}
            onNext={() => setStep("review")}
          />
        )}

        {step === "review" && (
          <WithdrawReviewStep
            sharesToBurn={sharesToBurn}
            sharePrice={sharePrice}
            shareTokenSymbol={profile.depositorStats.shareTokenSymbol}
            withdrawalDelayHours={withdrawalDelayHours}
            submitting={submitting}
            onBack={() => setStep("amount")}
            onConfirm={handleRequestWithdrawal}
          />
        )}

        {step === "pending" && pending && (
          <WithdrawPendingStep
            pending={pending}
            shareTokenSymbol={profile.depositorStats.shareTokenSymbol}
            submitting={submitting}
            onExecute={handleExecuteWithdrawal}
            onCancel={() => setStep("amount")}
          />
        )}

        {step === "success" && (
          <WithdrawSuccessStep
            agentId={agentId}
            usdcReceived={usdcReceived}
            txHash={txHash}
          />
        )}
      </div>
    </main>
  );
}
```

### Step 4: Build `WithdrawAmountStep` at `src/components/withdraw/WithdrawAmountStep.tsx`

```typescript
// src/components/withdraw/WithdrawAmountStep.tsx
"use client";

interface Props {
  shareBalance: number;
  sharePrice: number;
  shareTokenSymbol: string;
  sharesToBurn: number;
  onSharesChange: (shares: number) => void;
  onNext: () => void;
}

export function WithdrawAmountStep({
  shareBalance,
  sharePrice,
  shareTokenSymbol,
  sharesToBurn,
  onSharesChange,
  onNext,
}: Props) {
  const estimatedValue = sharesToBurn * sharePrice;
  const exceedsBalance = sharesToBurn > shareBalance;
  const canProceed = sharesToBurn > 0 && !exceedsBalance;

  return (
    <div className="space-y-6">
      <div className="rounded-lg border border-gray-800 bg-gray-900 p-4 space-y-2">
        <div className="flex justify-between text-sm">
          <span className="text-gray-400">Your Share Balance</span>
          <span className="font-mono font-bold text-white">
            {shareBalance.toLocaleString()} {shareTokenSymbol}
          </span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-400">NAV Per Share</span>
          <span className="font-mono text-gray-300">${sharePrice.toFixed(4)}</span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-400">Total Value</span>
          <span className="font-mono text-white">
            ${(shareBalance * sharePrice).toLocaleString("en-US", { minimumFractionDigits: 2 })}
          </span>
        </div>
      </div>

      <div>
        <label className="mb-2 block text-sm font-medium text-gray-300">
          Shares to Burn
        </label>
        <div className="relative">
          <input
            type="number"
            min={0}
            step={0.01}
            value={sharesToBurn || ""}
            onChange={(e) => onSharesChange(parseFloat(e.target.value) || 0)}
            placeholder="0.00"
            className="w-full rounded-lg border border-gray-700 bg-gray-800 px-4 py-3 pr-20 text-lg font-mono text-white placeholder-gray-600 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
          />
          <button
            onClick={() => onSharesChange(shareBalance)}
            className="absolute right-2 top-1/2 -translate-y-1/2 rounded bg-gray-700 px-3 py-1 text-xs font-medium text-gray-300 hover:bg-gray-600"
          >
            MAX
          </button>
        </div>
        {exceedsBalance && (
          <p className="mt-1 text-sm text-red-400">Exceeds your share balance.</p>
        )}
      </div>

      {sharesToBurn > 0 && (
        <div className="rounded-lg border border-gray-800 bg-gray-900 p-4">
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">Estimated Withdrawal Value</span>
            <span className="font-mono font-bold text-green-400">
              ${estimatedValue.toLocaleString("en-US", { minimumFractionDigits: 2 })} USDC
            </span>
          </div>
          <p className="mt-2 text-xs text-gray-500">
            You will receive proportional underlying assets based on current NAV.
          </p>
        </div>
      )}

      <button
        disabled={!canProceed}
        onClick={onNext}
        className="w-full rounded-lg bg-red-600 py-3 font-semibold text-white transition-colors hover:bg-red-500 disabled:cursor-not-allowed disabled:bg-gray-700 disabled:text-gray-500"
      >
        Continue
      </button>
    </div>
  );
}
```

### Step 5: Build `WithdrawReviewStep` at `src/components/withdraw/WithdrawReviewStep.tsx`

```typescript
// src/components/withdraw/WithdrawReviewStep.tsx
"use client";

interface Props {
  sharesToBurn: number;
  sharePrice: number;
  shareTokenSymbol: string;
  withdrawalDelayHours: number;
  submitting: boolean;
  onBack: () => void;
  onConfirm: () => void;
}

export function WithdrawReviewStep({
  sharesToBurn,
  sharePrice,
  shareTokenSymbol,
  withdrawalDelayHours,
  submitting,
  onBack,
  onConfirm,
}: Props) {
  const estimatedValue = sharesToBurn * sharePrice;

  return (
    <div className="space-y-6">
      <div className="rounded-lg border border-gray-800 bg-gray-900 p-6 space-y-4">
        <h2 className="text-lg font-semibold text-white">Review Withdrawal</h2>

        <div className="space-y-3">
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">Shares to Burn</span>
            <span className="font-mono text-white">
              {sharesToBurn.toLocaleString()} {shareTokenSymbol}
            </span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">Estimated Value</span>
            <span className="font-mono font-bold text-green-400">
              ${estimatedValue.toLocaleString("en-US", { minimumFractionDigits: 2 })} USDC
            </span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">You Will Receive</span>
            <span className="text-gray-200">Proportional underlying assets</span>
          </div>
        </div>

        {withdrawalDelayHours > 0 && (
          <div className="rounded-md border border-yellow-700/50 bg-yellow-900/20 p-3">
            <p className="text-sm text-yellow-400">
              This agent has a {withdrawalDelayHours}-hour withdrawal delay.
              After requesting, you must wait before executing the withdrawal.
            </p>
          </div>
        )}
      </div>

      <div className="flex gap-3">
        <button
          onClick={onBack}
          disabled={submitting}
          className="flex-1 rounded-lg border border-gray-700 py-3 font-semibold text-gray-300 transition-colors hover:border-gray-600 disabled:opacity-50"
        >
          Back
        </button>
        <button
          onClick={onConfirm}
          disabled={submitting}
          className="flex-1 rounded-lg bg-red-600 py-3 font-semibold text-white transition-colors hover:bg-red-500 disabled:bg-red-800 disabled:text-red-300"
        >
          {submitting ? "Requesting..." : "Request Withdrawal"}
        </button>
      </div>
    </div>
  );
}
```

### Step 6: Build `WithdrawPendingStep` at `src/components/withdraw/WithdrawPendingStep.tsx`

```typescript
// src/components/withdraw/WithdrawPendingStep.tsx
"use client";

import { useState, useEffect } from "react";
import type { PendingWithdrawal } from "@/hooks/usePendingWithdrawal";

interface Props {
  pending: PendingWithdrawal;
  shareTokenSymbol: string;
  submitting: boolean;
  onExecute: () => void;
  onCancel: () => void;
}

function formatCountdown(ms: number): string {
  if (ms <= 0) return "Ready";
  const hours = Math.floor(ms / 3_600_000);
  const minutes = Math.floor((ms % 3_600_000) / 60_000);
  const seconds = Math.floor((ms % 60_000) / 1_000);
  return `${hours}h ${minutes}m ${seconds}s`;
}

export function WithdrawPendingStep({
  pending,
  shareTokenSymbol,
  submitting,
  onExecute,
  onCancel,
}: Props) {
  const [now, setNow] = useState(Date.now());

  useEffect(() => {
    const interval = setInterval(() => setNow(Date.now()), 1_000);
    return () => clearInterval(interval);
  }, []);

  const executableAt = new Date(pending.executableAt).getTime();
  const remaining = executableAt - now;
  const isReady = remaining <= 0;

  return (
    <div className="space-y-6">
      <div className="rounded-lg border border-gray-800 bg-gray-900 p-6 text-center space-y-4">
        <h2 className="text-lg font-semibold text-white">Withdrawal Pending</h2>

        <div className="text-4xl font-mono font-bold text-white">
          {formatCountdown(remaining)}
        </div>

        <p className="text-sm text-gray-400">
          {isReady
            ? "Your withdrawal is ready to execute."
            : `Executable after: ${new Date(pending.executableAt).toLocaleString()}`}
        </p>

        <div className="space-y-2 text-sm">
          <div className="flex justify-between">
            <span className="text-gray-400">Shares to Burn</span>
            <span className="font-mono text-white">
              {pending.shares.toLocaleString()} {shareTokenSymbol}
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-400">Estimated Value</span>
            <span className="font-mono text-green-400">
              ${pending.estimatedValue.toLocaleString("en-US", { minimumFractionDigits: 2 })}
            </span>
          </div>
        </div>
      </div>

      <div className="flex gap-3">
        <button
          onClick={onCancel}
          disabled={submitting}
          className="flex-1 rounded-lg border border-gray-700 py-3 font-semibold text-gray-300 transition-colors hover:border-gray-600 disabled:opacity-50"
        >
          Cancel Withdrawal
        </button>
        <button
          onClick={onExecute}
          disabled={!isReady || submitting}
          className="flex-1 rounded-lg bg-green-600 py-3 font-semibold text-white transition-colors hover:bg-green-500 disabled:cursor-not-allowed disabled:bg-gray-700 disabled:text-gray-500"
        >
          {submitting ? "Executing..." : isReady ? "Execute Withdrawal" : "Waiting..."}
        </button>
      </div>
    </div>
  );
}
```

### Step 7: Build `WithdrawSuccessStep` at `src/components/withdraw/WithdrawSuccessStep.tsx`

```typescript
// src/components/withdraw/WithdrawSuccessStep.tsx

interface Props {
  agentId: string;
  usdcReceived: number;
  txHash: string;
}

const EXPLORER_URL = "https://solscan.io/tx";

export function WithdrawSuccessStep({ agentId, usdcReceived, txHash }: Props) {
  return (
    <div className="space-y-6 text-center">
      <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-600/20">
        <svg className="h-8 w-8 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
        </svg>
      </div>

      <div>
        <h2 className="text-2xl font-bold text-white">Withdrawal Complete</h2>
        <p className="mt-1 text-gray-400">Assets transferred to your wallet.</p>
      </div>

      <div className="rounded-lg border border-gray-800 bg-gray-900 p-4 space-y-3">
        <div className="flex justify-between text-sm">
          <span className="text-gray-400">USDC Received</span>
          <span className="font-mono font-bold text-green-400">
            ${usdcReceived.toLocaleString("en-US", { minimumFractionDigits: 2 })}
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

## Done When

- [ ] All requirements met
- [ ] `/agents/[id]/withdraw` page renders with step-based flow
- [ ] Step 1 shows share balance, NAV per share, total value, and shares-to-burn input with MAX button
- [ ] Estimated withdrawal value updates live as user changes the shares input
- [ ] "Exceeds your share balance" error appears when input exceeds balance
- [ ] Step 2 shows review summary with withdrawal delay warning when applicable
- [ ] "Request Withdrawal" signs and submits the on-chain transaction
- [ ] Step 3 (Pending) shows a live countdown timer that ticks every second, with "Execute Withdrawal" disabled until the delay has passed
- [ ] "Cancel Withdrawal" returns user to Step 1
- [ ] Step 4 (Success) shows USDC received, clickable transaction hash linking to Solscan, and portfolio/agent navigation
- [ ] Wallet not connected state shows a connect prompt
