---
layout: docs
title: Building a DeFi Platform
permalink: /guides/defi-platform/
description: Build decentralized finance applications with lending, staking, and yield farming
---

# Building a DeFi Platform

Build DeFi applications with lending, staking, and yield farming using Quub Exchange.

## Lending Protocols

### Deposit/Lend

```javascript
// User deposits USDC to earn interest
const deposit = await client.exchange.createOrder({
  symbol: "USDC-LENDING",
  side: "buy",
  type: "market",
  quantity: "10000",
});

// Check interest earned
const position = await client.exchange.getPosition("USDC-LENDING");
console.log("Interest earned:", position.unrealizedPnl);
```

### Borrow

```javascript
// Borrow against collateral
const borrow = await client.exchange.createOrder({
  symbol: "USDC-BORROW",
  side: "sell",
  type: "market",
  quantity: "5000",
  collateral: {
    currency: "BTC",
    amount: "0.1",
  },
});
```

## Staking

```javascript
// Stake tokens
const stake = await client.exchange.stake({
  currency: "ETH",
  amount: "10",
  duration: "90d", // Lock for 90 days
  apr: "5.2",
});

// Check rewards
const rewards = await client.exchange.getStakingRewards(stake.id);
```

## Yield Farming

```javascript
// Provide liquidity
const liquidity = await client.exchange.addLiquidity({
  pool: "ETH-USDC",
  amountA: "10", // ETH
  amountB: "20000", // USDC
});

// Claim rewards
const farmRewards = await client.exchange.claimFarmingRewards(liquidity.poolId);
```

---

**Next Steps:**

- [Exchange API]({{ '/capabilities/exchange/api-reference/' | relative_url }})
- [Market Oracles]({{ '/capabilities/market-oracles/api-reference/' | relative_url }})
