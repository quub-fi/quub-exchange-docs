---
layout: docs
title: Working with Market Data
permalink: /guides/market-data/
description: Guide to integrating market data feeds, price oracles, and reference data
---

# Working with Market Data

Integrate market data feeds, price oracles, and reference data into your application for real-time pricing and analytics.

## Overview

This guide covers:

- Real-time price feeds via WebSocket
- Historical data and candlestick charts
- Order book depth and liquidity
- Price oracles integration
- Reference data management

## Real-Time Price Feeds

### WebSocket Connection

```javascript
import { QuubClient } from "@quub/sdk";

const client = new QuubClient({
  /* credentials */
});

// Connect to WebSocket
const ws = await client.exchange.connectWebSocket();

// Subscribe to ticker updates
ws.subscribe("market.ticker", ["BTC-USD", "ETH-USD"], (ticker) => {
  console.log(`${ticker.symbol}: $${ticker.lastPrice}`);
  console.log(`24h Change: ${ticker.priceChange24h}`);
  console.log(`24h Volume: ${ticker.volume24h}`);
});

// Subscribe to order book
ws.subscribe("market.orderbook", ["BTC-USD"], (orderbook) => {
  console.log("Best Bid:", orderbook.bids[0]);
  console.log("Best Ask:", orderbook.asks[0]);
});

// Subscribe to trades
ws.subscribe("market.trades", ["BTC-USD"], (trade) => {
  console.log(`Trade: ${trade.quantity} @ ${trade.price}`);
});
```

## Historical Data

### Candlestick Data

```javascript
// Fetch candlestick data
const candles = await client.exchange.getCandles({
  symbol: "BTC-USD",
  interval: "1h", // 1m, 5m, 15m, 1h, 4h, 1d
  startTime: Date.now() - 24 * 60 * 60 * 1000, // 24 hours ago
  endTime: Date.now(),
  limit: 100,
});

candles.forEach((candle) => {
  console.log({
    time: candle.timestamp,
    open: candle.open,
    high: candle.high,
    low: candle.low,
    close: candle.close,
    volume: candle.volume,
  });
});
```

## Price Oracles

### Get Oracle Prices

```javascript
// Get oracle-validated prices
const oraclePrice = await client.marketOracles.getPrice({
  symbol: "BTC-USD",
  sources: ["coinbase", "binance", "kraken"],
});

console.log(`Oracle Price: $${oraclePrice.price}`);
console.log(`Confidence: ${oraclePrice.confidence}%`);
console.log(`Sources: ${oraclePrice.sources.length}`);
```

## Complete Implementation

See the [Trading Integration Guide](../trading-integration/) for a complete trading application example.

---

**Next Steps:**

- [Trading Integration](../trading-integration/)
- [Custody Integration](../custody-integration/)
- [API Reference]({{ '/api-reference/' | relative_url }})
