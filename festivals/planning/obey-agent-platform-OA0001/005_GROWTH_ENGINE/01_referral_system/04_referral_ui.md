---
fest_type: task
fest_id: 04_referral_ui.md
fest_name: referral_ui
fest_parent: 01_referral_system
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.530854-06:00
fest_tracking: true
---

# Task: Referral Dashboard UI

## Objective

Build the `/referrals` dashboard page in the Next.js frontend that displays the user's referral code, copy-to-clipboard link, referral stats (direct referrals, total capital referred, earnings), and a table of referred users.

## Requirements

- [ ] Page at `/referrals` accessible from the main nav
- [ ] Display user's referral code (`OBEY-XXXXXX`) with copy-to-clipboard button
- [ ] Display shareable referral link (`https://obeyplatform.xyz/ref/OBEY-XXXXXX`)
- [ ] Stats cards: Direct Referrals count, Total Capital Referred, All-Time Earnings, This Month Earnings
- [ ] Table of referred users: wallet (truncated), amount deposited, earnings generated
- [ ] Fetch data from `GET /api/referrals/code/:wallet` and `GET /api/referrals/stats/:wallet`
- [ ] Read on-chain ReferralState for `total_earned` and `referred_users`
- [ ] Responsive layout for mobile and desktop

## Implementation

### Step 1: Create the API endpoints for referral stats

Add to the platform API (Go backend):

```go
// GET /api/referrals/stats/:wallet
// Returns aggregated referral statistics for the dashboard.
type ReferralStatsResponse struct {
    Code              string           `json:"code"`
    Link              string           `json:"link"`
    DirectReferrals   int              `json:"directReferrals"`
    TotalCapital      float64          `json:"totalCapital"`       // USD
    AllTimeEarnings   float64          `json:"allTimeEarnings"`    // USD
    MonthlyEarnings   float64          `json:"monthlyEarnings"`    // USD
    ReferredUsers     []ReferredUser   `json:"referredUsers"`
}

type ReferredUser struct {
    Wallet          string  `json:"wallet"`          // truncated for display
    DepositedAmount float64 `json:"depositedAmount"` // USD
    EarningsGenerated float64 `json:"earningsGenerated"` // earned for the referrer
    RegisteredAt    string  `json:"registeredAt"`
}

func (h *Handler) GetReferralStats(w http.ResponseWriter, r *http.Request) {
    wallet := chi.URLParam(r, "wallet")

    // Get or create code
    code, _ := h.referralSvc.GetOrCreateCode(r.Context(), wallet)

    // Query referred users from DB
    rows, _ := h.db.QueryContext(r.Context(),
        `SELECT rr.user_wallet, COALESCE(SUM(d.amount), 0), rr.registered_at
         FROM referral_registrations rr
         LEFT JOIN deposits d ON d.user_wallet = rr.user_wallet
         WHERE rr.referrer_wallet = $1
         GROUP BY rr.user_wallet, rr.registered_at
         ORDER BY rr.registered_at DESC`, wallet)

    // Read on-chain total_earned from ReferralState PDA
    // ... build response
}
```

### Step 2: Create the React page component

Create `src/app/referrals/page.tsx`:

```tsx
'use client';

import { useEffect, useState } from 'react';
import { useWallet } from '@solana/wallet-adapter-react';

interface ReferralStats {
  code: string;
  link: string;
  directReferrals: number;
  totalCapital: number;
  allTimeEarnings: number;
  monthlyEarnings: number;
  referredUsers: {
    wallet: string;
    depositedAmount: number;
    earningsGenerated: number;
    registeredAt: string;
  }[];
}

export default function ReferralsPage() {
  const { publicKey } = useWallet();
  const [stats, setStats] = useState<ReferralStats | null>(null);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (!publicKey) return;
    fetch(`/api/referrals/stats/${publicKey.toBase58()}`)
      .then(r => r.json())
      .then(setStats);
  }, [publicKey]);

  const copyLink = () => {
    if (stats) {
      navigator.clipboard.writeText(stats.link);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  if (!publicKey) return <div>Connect wallet to view referrals</div>;
  if (!stats) return <div>Loading...</div>;

  return (
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Your Referrals</h1>

      {/* Referral Code Card */}
      <div className="bg-gray-800 rounded-lg p-6 mb-6">
        <div className="text-sm text-gray-400 mb-1">Your Referral Code</div>
        <div className="flex items-center gap-4">
          <span className="text-2xl font-mono font-bold">{stats.code}</span>
          <button onClick={copyLink}
            className="px-4 py-2 bg-blue-600 rounded hover:bg-blue-700">
            {copied ? 'Copied!' : 'Copy Link'}
          </button>
        </div>
        <div className="text-sm text-gray-400 mt-2">{stats.link}</div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <StatCard label="Direct Referrals" value={stats.directReferrals.toString()} />
        <StatCard label="Total Capital Referred" value={`$${stats.totalCapital.toLocaleString()}`} />
        <StatCard label="All-Time Earnings" value={`$${stats.allTimeEarnings.toFixed(2)}`} />
        <StatCard label="This Month" value={`$${stats.monthlyEarnings.toFixed(2)}`} />
      </div>

      {/* Referred Users Table */}
      <h2 className="text-xl font-semibold mb-4">Referred Users</h2>
      <table className="w-full">
        <thead>
          <tr className="text-left text-gray-400 border-b border-gray-700">
            <th className="py-2">Wallet</th>
            <th className="py-2">Deposited</th>
            <th className="py-2">Your Earnings</th>
          </tr>
        </thead>
        <tbody>
          {stats.referredUsers.map((u, i) => (
            <tr key={i} className="border-b border-gray-800">
              <td className="py-3 font-mono text-sm">{u.wallet}</td>
              <td className="py-3">${u.depositedAmount.toLocaleString()}</td>
              <td className="py-3">${u.earningsGenerated.toFixed(2)}</td>
            </tr>
          ))}
          {stats.referredUsers.length === 0 && (
            <tr><td colSpan={3} className="py-6 text-center text-gray-500">
              No referrals yet. Share your link to start earning!
            </td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

function StatCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="bg-gray-800 rounded-lg p-4">
      <div className="text-sm text-gray-400">{label}</div>
      <div className="text-xl font-bold mt-1">{value}</div>
    </div>
  );
}
```

### Step 3: Add navigation link

In the main navigation component, add a link to `/referrals` with a referral icon.

### Step 4: Handle referral link landing

Create `src/app/ref/[code]/page.tsx` that reads the referral code from the URL, stores it in localStorage, and redirects to the signup/deposit flow. When the user connects their wallet and deposits, the stored code triggers `POST /api/referrals/register`.

### Step 5: Write tests

1. Component test: `ReferralsPage` renders stats cards with correct values
2. Component test: Copy button copies link to clipboard
3. Component test: Empty state shows "No referrals yet" message
4. API test: `GET /api/referrals/stats/:wallet` returns correct aggregated data
5. Integration test: referral link landing page stores code in localStorage

## Done When

- [ ] All requirements met
- [ ] `/referrals` page displays code, link, stats, and referred users table
- [ ] Copy-to-clipboard works for the referral link
- [ ] Stats cards show real data from the API
- [ ] Referral link landing page (`/ref/:code`) captures the code for registration
- [ ] Responsive layout works on mobile
- [ ] All component and API tests pass
