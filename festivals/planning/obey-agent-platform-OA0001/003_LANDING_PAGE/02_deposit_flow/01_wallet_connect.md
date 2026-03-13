---
fest_type: task
fest_id: 01_wallet_connect.md
fest_name: wallet_connect
fest_parent: 02_deposit_flow
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.434132-06:00
fest_tracking: true
---

# Task: Solana Wallet Connection Integration

## Objective

Integrate Solana wallet adapters (Phantom, Solflare, Backpack) into the Next.js dashboard using `@solana/wallet-adapter-react`, providing a wallet context provider, connect/disconnect buttons, and a reusable hook for accessing the connected wallet throughout the app.

## Requirements

- [ ] Install `@solana/wallet-adapter-base`, `@solana/wallet-adapter-react`, `@solana/wallet-adapter-react-ui`, `@solana/wallet-adapter-wallets`, and `@solana/web3.js` packages
- [ ] Create a `SolanaWalletProvider` that wraps the app with `ConnectionProvider` and `WalletProvider` configured for Solana mainnet-beta
- [ ] Register Phantom, Solflare, and Backpack wallet adapters
- [ ] Build a `ConnectWalletButton` component that shows "Connect Wallet" when disconnected and shows truncated address + disconnect option when connected
- [ ] Create a `useWallet` convenience re-export hook that exposes `publicKey`, `connected`, `connect`, `disconnect`, and `signTransaction`
- [ ] Wrap the root layout with the `SolanaWalletProvider`
- [ ] Store the selected wallet in localStorage for auto-reconnect on page reload

## Implementation

### Step 1: Install dependencies

```bash
npm install @solana/wallet-adapter-base @solana/wallet-adapter-react \
  @solana/wallet-adapter-react-ui @solana/wallet-adapter-wallets @solana/web3.js
```

### Step 2: Create `SolanaWalletProvider` at `src/components/providers/SolanaWalletProvider.tsx`

```typescript
// src/components/providers/SolanaWalletProvider.tsx
"use client";

import { useMemo, type ReactNode } from "react";
import {
  ConnectionProvider,
  WalletProvider,
} from "@solana/wallet-adapter-react";
import { WalletModalProvider } from "@solana/wallet-adapter-react-ui";
import {
  PhantomWalletAdapter,
  SolflareWalletAdapter,
  BackpackWalletAdapter,
} from "@solana/wallet-adapter-wallets";
import { clusterApiUrl } from "@solana/web3.js";

// Import the default wallet adapter styles
import "@solana/wallet-adapter-react-ui/styles.css";

const SOLANA_RPC_URL = process.env.NEXT_PUBLIC_SOLANA_RPC_URL ?? clusterApiUrl("mainnet-beta");

interface Props {
  children: ReactNode;
}

export function SolanaWalletProvider({ children }: Props) {
  const wallets = useMemo(
    () => [
      new PhantomWalletAdapter(),
      new SolflareWalletAdapter(),
      new BackpackWalletAdapter(),
    ],
    [],
  );

  return (
    <ConnectionProvider endpoint={SOLANA_RPC_URL}>
      <WalletProvider wallets={wallets} autoConnect>
        <WalletModalProvider>
          {children}
        </WalletModalProvider>
      </WalletProvider>
    </ConnectionProvider>
  );
}
```

### Step 3: Build `ConnectWalletButton` at `src/components/wallet/ConnectWalletButton.tsx`

```typescript
// src/components/wallet/ConnectWalletButton.tsx
"use client";

import { useWallet } from "@solana/wallet-adapter-react";
import { useWalletModal } from "@solana/wallet-adapter-react-ui";
import { useCallback, useState, useRef, useEffect } from "react";

function truncateAddress(address: string): string {
  return `${address.slice(0, 4)}...${address.slice(-4)}`;
}

export function ConnectWalletButton() {
  const { publicKey, disconnect, connected, wallet } = useWallet();
  const { setVisible } = useWalletModal();
  const [showMenu, setShowMenu] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  const handleConnect = useCallback(() => {
    setVisible(true);
  }, [setVisible]);

  const handleDisconnect = useCallback(async () => {
    await disconnect();
    setShowMenu(false);
  }, [disconnect]);

  const handleCopyAddress = useCallback(() => {
    if (publicKey) {
      navigator.clipboard.writeText(publicKey.toBase58());
      setShowMenu(false);
    }
  }, [publicKey]);

  // Close menu on outside click
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setShowMenu(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  if (!connected || !publicKey) {
    return (
      <button
        onClick={handleConnect}
        className="rounded-lg bg-purple-600 px-5 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-purple-500"
      >
        Connect Wallet
      </button>
    );
  }

  return (
    <div className="relative" ref={menuRef}>
      <button
        onClick={() => setShowMenu((v) => !v)}
        className="flex items-center gap-2 rounded-lg border border-gray-700 bg-gray-800 px-4 py-2.5 text-sm text-white transition-colors hover:border-gray-600"
      >
        {wallet?.adapter.icon && (
          <img src={wallet.adapter.icon} alt="" className="h-4 w-4" />
        )}
        <span className="font-mono">{truncateAddress(publicKey.toBase58())}</span>
      </button>

      {showMenu && (
        <div className="absolute right-0 top-full z-50 mt-2 w-48 rounded-lg border border-gray-700 bg-gray-800 py-1 shadow-xl">
          <button
            onClick={handleCopyAddress}
            className="w-full px-4 py-2 text-left text-sm text-gray-300 hover:bg-gray-700"
          >
            Copy Address
          </button>
          <button
            onClick={handleDisconnect}
            className="w-full px-4 py-2 text-left text-sm text-red-400 hover:bg-gray-700"
          >
            Disconnect
          </button>
        </div>
      )}
    </div>
  );
}
```

### Step 4: Update root layout at `src/app/layout.tsx`

Wrap the existing layout body content with `SolanaWalletProvider`:

```typescript
// src/app/layout.tsx

import type { Metadata } from "next";
import type { ReactNode } from "react";
import { SolanaWalletProvider } from "@/components/providers/SolanaWalletProvider";
import "./globals.css";

export const metadata: Metadata = {
  title: "OBEY Agent Economy",
  description: "Fund AI agents that trade prediction markets",
};

export default function RootLayout({
  children,
}: {
  children: ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-gray-950 text-gray-100 antialiased">
        <SolanaWalletProvider>
          {children}
        </SolanaWalletProvider>
      </body>
    </html>
  );
}
```

### Step 5: Add environment variable

Add to `.env.local`:

```
NEXT_PUBLIC_SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
```

For production, replace with a dedicated RPC provider (Helius, QuickNode, Triton, etc.) to avoid rate limits.

### Step 6: Create `useWalletBalance` hook at `src/hooks/useWalletBalance.ts`

This hook fetches the connected wallet's USDC token balance, which is needed for the deposit flow.

```typescript
// src/hooks/useWalletBalance.ts
"use client";

import { useState, useEffect } from "react";
import { useConnection, useWallet } from "@solana/wallet-adapter-react";
import { PublicKey } from "@solana/web3.js";

// USDC mint on Solana mainnet
const USDC_MINT = new PublicKey("EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v");

export function useWalletBalance() {
  const { connection } = useConnection();
  const { publicKey, connected } = useWallet();
  const [solBalance, setSolBalance] = useState<number>(0);
  const [usdcBalance, setUsdcBalance] = useState<number>(0);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!connected || !publicKey) {
      setSolBalance(0);
      setUsdcBalance(0);
      return;
    }

    let cancelled = false;
    setLoading(true);

    async function fetchBalances() {
      try {
        // Fetch SOL balance
        const lamports = await connection.getBalance(publicKey!);
        if (!cancelled) setSolBalance(lamports / 1e9);

        // Fetch USDC balance via getTokenAccountsByOwner
        const tokenAccounts = await connection.getParsedTokenAccountsByOwner(
          publicKey!,
          { mint: USDC_MINT },
        );

        if (!cancelled) {
          const usdcAccount = tokenAccounts.value[0];
          const amount = usdcAccount
            ? (usdcAccount.account.data.parsed.info.tokenAmount.uiAmount as number)
            : 0;
          setUsdcBalance(amount);
        }
      } catch {
        // Silently fail — balances will show as 0
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    fetchBalances();
    return () => { cancelled = true; };
  }, [connected, publicKey, connection]);

  return { solBalance, usdcBalance, loading };
}
```

## Done When

- [ ] All requirements met
- [ ] `npm install` completes with all Solana wallet adapter packages installed
- [ ] `SolanaWalletProvider` wraps the app in root `layout.tsx`
- [ ] Clicking "Connect Wallet" opens the wallet selection modal showing Phantom, Solflare, and Backpack
- [ ] After connecting, the button shows the wallet icon + truncated address (e.g., `AbCd...xYzW`)
- [ ] Clicking the connected wallet button shows a dropdown with "Copy Address" and "Disconnect" options
- [ ] Refreshing the page auto-reconnects to the previously selected wallet (via `autoConnect`)
- [ ] `useWalletBalance` returns the correct SOL and USDC balances for the connected wallet
- [ ] Disconnecting resets all wallet state and balances to defaults
