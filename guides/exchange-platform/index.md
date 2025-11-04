---
layout: docs
title: Building a Cryptocurrency Exchange
permalink: /guides/exchange-platform/
description: Build a complete cryptocurrency exchange with order books and matching engine
---

# Building a Cryptocurrency Exchange

Build a complete cryptocurrency exchange platform powered by Quub Exchange.

## Exchange Architecture

```
┌──────────────┐
│  Web/Mobile  │
└──────┬───────┘
       │
┌──────▼───────┐
│ Order Engine │ ← Quub Exchange API
└──────┬───────┘
       │
┌──────▼───────┐
│   Custody    │ ← Quub Custodian API
└──────────────┘
```

## Order Book Integration

```javascript
// Get order book
const orderBook = await client.exchange.getOrderBook("BTC-USD", {
  depth: 50,
});

// Display order book in UI
renderOrderBook(orderBook.bids, orderBook.asks);

// Subscribe to updates
ws.subscribe("market.orderbook", ["BTC-USD"], (book) => {
  updateOrderBook(book);
});
```

## User Accounts

```javascript
// Create user account
const account = await client.identity.createAccount({
  email: "user@example.com",
  kycLevel: "tier2",
});

// Get user balances
const balances = await client.custodian.getBalances(account.id);
```

## Fee Structure

```javascript
// Configure fee tiers
await client.feesBilling.setFeeTiers([
  { volume: 0, makerFee: "0.1%", takerFee: "0.2%" },
  { volume: 1000000, makerFee: "0.08%", takerFee: "0.15%" },
  { volume: 10000000, makerFee: "0.05%", takerFee: "0.1%" },
]);
```

---

**Next Steps:**

- [Trading Integration](../trading-integration/)
- [Custody Integration](../custody-integration/)
- [Exchange API]({{ '/capabilities/exchange/api-reference/' | relative_url }})
