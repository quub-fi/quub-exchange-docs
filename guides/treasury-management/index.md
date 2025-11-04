---
layout: docs
title: Treasury Management
permalink: /guides/treasury-management/
description: Manage liquidity, cross-chain transfers, and treasury operations
---

# Treasury Management

Manage liquidity, cross-chain transfers, and treasury operations across multiple chains.

## Liquidity Management

### Monitor Liquidity

```javascript
// Get treasury overview
const treasury = await client.treasury.getOverview();

console.log("Total AUM:", treasury.totalAUM);
console.log("By Chain:", treasury.byChain);
console.log("By Currency:", treasury.byCurrency);
```

### Rebalance Assets

```javascript
// Rebalance between chains
await client.treasury.rebalance({
  from: { chain: "ethereum", currency: "USDC" },
  to: { chain: "polygon", currency: "USDC" },
  amount: "100000",
  urgency: "high",
});
```

## Cross-Chain Transfers

```javascript
// Bridge assets
const transfer = await client.chain.bridge({
  fromChain: "ethereum",
  toChain: "arbitrum",
  currency: "USDC",
  amount: "50000",
  toAddress: "0x...",
});

// Monitor transfer
const status = await client.chain.getTransferStatus(transfer.id);
console.log("Status:", status.state);
```

---

**Next Steps:**

- [Chain Integration]({{ '/capabilities/chain/api-reference/' | relative_url }})
- [Treasury API]({{ '/capabilities/treasury/api-reference/' | relative_url }})
