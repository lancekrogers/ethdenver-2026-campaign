---
fest_type: task
fest_id: 03_shareable_cards.md
fest_name: shareable_cards
fest_parent: 02_incentives
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.549964-06:00
fest_tracking: true
---

# Task: Shareable Performance Cards

## Objective

Build an image generation service and UI component that creates shareable monthly performance cards showing portfolio returns, best agent, total P&L, and the user's referral link -- optimized for Twitter/X, Discord, and Telegram sharing.

## Requirements

- [ ] Server-side image generation: HTML/CSS template rendered to PNG (1200x630 for Open Graph)
- [ ] Card content: portfolio return %, best agent name + return, total P&L in USD, referral link
- [ ] API endpoint: `GET /api/cards/:wallet/monthly` returns PNG image
- [ ] OG meta tags on `/portfolio/:wallet` page for automatic card preview when shared
- [ ] "Share on X" button that opens pre-filled tweet with card image and referral link
- [ ] Card branding: OBEY Agent Economy logo, dark theme, clean typography
- [ ] Caching: generated cards cached for 24h (same data, same image)

## Implementation

### Step 1: Create card data endpoint

In the Go backend:

```go
// CardData holds the values rendered into the performance card image.
type CardData struct {
    Wallet         string  `json:"wallet"`
    Period         string  `json:"period"`          // "March 2026"
    PortfolioReturn float64 `json:"portfolioReturn"` // percentage, e.g. 23.4
    BestAgentName  string  `json:"bestAgentName"`
    BestAgentReturn float64 `json:"bestAgentReturn"` // percentage
    TotalPnL       float64 `json:"totalPnL"`         // USD
    ReferralCode   string  `json:"referralCode"`
    ReferralLink   string  `json:"referralLink"`
}

// GET /api/cards/:wallet/data
func (h *Handler) GetCardData(w http.ResponseWriter, r *http.Request) {
    wallet := chi.URLParam(r, "wallet")

    // Query portfolio performance for current month
    // - Sum P&L across all funded agents
    // - Find best performing agent
    // - Calculate overall return %
    // - Get referral code

    data := CardData{
        Wallet:          truncateWallet(wallet),
        Period:          time.Now().Format("January 2006"),
        PortfolioReturn: portfolioReturn,
        BestAgentName:   bestAgent.Name,
        BestAgentReturn: bestAgent.MonthlyReturn,
        TotalPnL:        totalPnL,
        ReferralCode:    code,
        ReferralLink:    fmt.Sprintf("https://obeyplatform.xyz/ref/%s", code),
    }

    json.NewEncoder(w).Encode(data)
}
```

### Step 2: Image generation with server-side rendering

Create `internal/cards/renderer.go`:

```go
package cards

import (
    "bytes"
    "context"
    "fmt"
    "html/template"
    "sync"
    "time"
)

// Renderer generates PNG performance card images.
type Renderer struct {
    tmpl  *template.Template
    cache map[string]*CachedCard
    mu    sync.RWMutex
}

type CachedCard struct {
    PNG       []byte
    CreatedAt time.Time
}

const cacheTTL = 24 * time.Hour

// NewRenderer creates a card renderer with the HTML template.
func NewRenderer() (*Renderer, error) {
    tmpl, err := template.ParseFiles("templates/performance-card.html")
    if err != nil {
        return nil, fmt.Errorf("parsing card template: %w", err)
    }
    return &Renderer{
        tmpl:  tmpl,
        cache: make(map[string]*CachedCard),
    }, nil
}

// RenderCard generates a PNG image for the given card data.
// Uses chromedp or a headless browser to render HTML to PNG.
func (r *Renderer) RenderCard(ctx context.Context, data CardData) ([]byte, error) {
    // Check cache
    cacheKey := fmt.Sprintf("%s-%s", data.Wallet, data.Period)
    r.mu.RLock()
    if cached, ok := r.cache[cacheKey]; ok && time.Since(cached.CreatedAt) < cacheTTL {
        r.mu.RUnlock()
        return cached.PNG, nil
    }
    r.mu.RUnlock()

    // Render HTML from template
    var htmlBuf bytes.Buffer
    if err := r.tmpl.Execute(&htmlBuf, data); err != nil {
        return nil, fmt.Errorf("executing template: %w", err)
    }

    // Use chromedp to screenshot the HTML at 1200x630
    // Alternatively, use a library like go-rod or wkhtmltoimage
    png, err := screenshotHTML(ctx, htmlBuf.Bytes(), 1200, 630)
    if err != nil {
        return nil, fmt.Errorf("rendering card to PNG: %w", err)
    }

    // Cache result
    r.mu.Lock()
    r.cache[cacheKey] = &CachedCard{PNG: png, CreatedAt: time.Now()}
    r.mu.Unlock()

    return png, nil
}
```

### Step 3: HTML card template

Create `templates/performance-card.html`:

```html
<!DOCTYPE html>
<html>
<head>
<style>
  body {
    margin: 0; padding: 0;
    width: 1200px; height: 630px;
    background: linear-gradient(135deg, #0f0f23 0%, #1a1a3e 100%);
    font-family: 'Inter', sans-serif;
    color: white;
    display: flex; flex-direction: column;
    justify-content: center; padding: 60px;
    box-sizing: border-box;
  }
  .header { font-size: 24px; color: #888; margin-bottom: 20px; letter-spacing: 2px; }
  .return { font-size: 72px; font-weight: 800; margin-bottom: 16px; }
  .return.positive { color: #00ff88; }
  .return.negative { color: #ff4444; }
  .best-agent { font-size: 28px; color: #aaa; margin-bottom: 8px; }
  .best-agent span { color: #00ff88; font-weight: 600; }
  .pnl { font-size: 32px; margin-bottom: 40px; }
  .referral { font-size: 22px; color: #666; }
  .referral a { color: #4488ff; text-decoration: none; }
  .tagline { font-size: 18px; color: #555; margin-top: 16px; }
</style>
</head>
<body>
  <div class="header">OBEY AGENT ECONOMY</div>
  <div class="return {{if ge .PortfolioReturn 0.0}}positive{{else}}negative{{end}}">
    {{if ge .PortfolioReturn 0.0}}+{{end}}{{printf "%.1f" .PortfolioReturn}}% this month
  </div>
  <div class="best-agent">
    Best Agent: <span>"{{.BestAgentName}}" (+{{printf "%.1f" .BestAgentReturn}}%)</span>
  </div>
  <div class="pnl">
    Total P&amp;L: {{if ge .TotalPnL 0.0}}+{{end}}${{printf "%.0f" .TotalPnL}}
  </div>
  <div class="referral">{{.ReferralLink}}</div>
  <div class="tagline">Fund AI agents that trade for you.</div>
</body>
</html>
```

### Step 4: API endpoint returning PNG

```go
// GET /api/cards/:wallet/monthly
func (h *Handler) GetMonthlyCard(w http.ResponseWriter, r *http.Request) {
    wallet := chi.URLParam(r, "wallet")
    data := h.buildCardData(r.Context(), wallet)

    png, err := h.cardRenderer.RenderCard(r.Context(), data)
    if err != nil {
        http.Error(w, "failed to generate card", http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "image/png")
    w.Header().Set("Cache-Control", "public, max-age=86400")
    w.Write(png)
}
```

### Step 5: Share button in frontend

In the portfolio page component:

```tsx
function ShareButton({ wallet, referralCode }: { wallet: string; referralCode: string }) {
  const shareUrl = `https://obeyplatform.xyz/portfolio/${wallet}`;
  const tweetText = encodeURIComponent(
    `My AI agents made me money this month on @OBEYPlatform\n\nFund AI agents that trade prediction markets for you.\n\n${shareUrl}`
  );

  return (
    <a
      href={`https://twitter.com/intent/tweet?text=${tweetText}`}
      target="_blank"
      rel="noopener noreferrer"
      className="px-4 py-2 bg-blue-500 rounded hover:bg-blue-600"
    >
      Share on X
    </a>
  );
}
```

Add OG meta tags to portfolio page head:

```tsx
export function generateMetadata({ params }) {
  return {
    openGraph: {
      title: 'OBEY Agent Economy - Portfolio Performance',
      images: [`/api/cards/${params.wallet}/monthly`],
    },
    twitter: {
      card: 'summary_large_image',
      images: [`/api/cards/${params.wallet}/monthly`],
    },
  };
}
```

### Step 6: Write tests

1. `TestCardDataEndpoint` — verify correct monthly P&L aggregation
2. `TestCardRendering` — verify PNG output is valid image with correct dimensions
3. `TestCardCaching` — render twice, verify second call uses cache
4. `TestCardNegativeReturn` — verify negative returns display correctly
5. `TestShareButtonURL` — verify tweet intent URL is correctly formatted

## Done When

- [ ] All requirements met
- [ ] `GET /api/cards/:wallet/monthly` returns a 1200x630 PNG performance card
- [ ] Card shows portfolio return, best agent, total P&L, and referral link
- [ ] Cards are cached for 24h
- [ ] OG meta tags on portfolio page generate card preview when link is shared
- [ ] "Share on X" button opens pre-filled tweet with correct content
- [ ] Tests pass for data, rendering, caching, and share functionality
