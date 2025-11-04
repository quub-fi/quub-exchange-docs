---
layout: docs
title: Exchange Guides
permalink: /capabilities/exchange/guides/
---

# 📚 Exchange Implementation Guides

> Comprehensive guides for implementing and integrating Exchange capabilities into your trading applications.

## 🚀 Quick Navigation

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 30px 0;">

<div style="border: 2px solid #667eea; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #667eea10 0%, #764ba210 100%);">
  <h3 style="margin-top: 0; color: #667eea;">🎯 Getting Started</h3>
  <p>New to Exchange? Start here to get up and running quickly.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#quick-start">Quick Start Guide</a></li>
    <li><a href="#integration">Integration Guide</a></li>
    <li><a href="#authentication">Authentication Setup</a></li>
  </ul>
</div>

<div style="border: 2px solid #10b981; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #10b98110 0%, #059669100%);">
  <h3 style="margin-top: 0; color: #10b981;">✨ Best Practices</h3>
  <p>Learn recommended patterns and industry best practices.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#best-practices">Implementation Best Practices</a></li>
    <li><a href="#security">Security Guidelines</a></li>
    <li><a href="#performance">Performance Optimization</a></li>
  </ul>
</div>

<div style="border: 2px solid #f59e0b; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #f59e0b10 0%, #d9770610 100%);">
  <h3 style="margin-top: 0; color: #f59e0b;">🔧 Advanced Topics</h3>
  <p>Deep dives into advanced features and capabilities.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#advanced">Advanced Configuration</a></li>
    <li><a href="#troubleshooting">Troubleshooting</a></li>
    <li><a href="#monitoring">Monitoring & Observability</a></li>
  </ul>
</div>

</div>

---

## 🎯 Quick Start {#quick-start}

### Prerequisites

Before you begin, ensure you have:

- ✅ Active Quub Exchange account with trading permissions
- ✅ API credentials with `read:exchange` and `write:exchange` scopes
- ✅ Development environment configured (Node.js 18+ or Python 3.9+)
- ✅ Understanding of JWT authentication and trading concepts

### 5-Minute Setup

#### Step 1: Install SDK

**Node.js:**

```bash
npm install @quub/exchange-sdk
```

**Python:**

```bash
pip install quub-exchange
```

#### Step 2: Configure Authentication

**Node.js:**

```javascript
import { ExchangeClient } from "@quub/exchange-sdk";

const client = new ExchangeClient({
  apiKey: process.env.QUUB_API_KEY,
  orgId: process.env.QUUB_ORG_ID,
  environment: "sandbox", // or 'production'
});
```

**Python:**

```python
from quub.exchange import ExchangeClient

client = ExchangeClient(
    api_key=os.getenv('QUUB_API_KEY'),
    org_id=os.getenv('QUUB_ORG_ID'),
    environment='sandbox'  # or 'production'
)
```

#### Step 3: Create Your First Market

**Node.js:**

```javascript
const market = await client.markets.create({
  instrumentId: "inst_btc_usd_001",
  quoteCcy: "USD",
  chainId: 1,
  lotSize: 100,
  marketType: "SPOT",
});

console.log(`Market created: ${market.id}`);
```

**Python:**

```python
market = client.markets.create(
    instrument_id='inst_btc_usd_001',
    quote_ccy='USD',
    chain_id=1,
    lot_size=100,
    market_type='SPOT'
)

print(f"Market created: {market.id}")
```

#### Step 4: Place Your First Order

**Node.js:**

```javascript
const order = await client.orders.create({
  accountId: "acc_123456789",
  instrumentId: "inst_btc_usd_001",
  side: "BUY",
  type: "LIMIT",
  qty: 0.1,
  px: 45000.0,
  tif: "GTC",
});

console.log(`Order placed: ${order.id}`);
```

**Python:**

```python
order = client.orders.create(
    account_id='acc_123456789',
    instrument_id='inst_btc_usd_001',
    side='BUY',
    type='LIMIT',
    qty=0.1,
    px=45000.00,
    tif='GTC'
)

print(f"Order placed: {order.id}")
```

---

## 🔌 Integration Guide {#integration}

### Architecture Overview

```
┌─────────────────┐
│  Your Trading   │
│     App         │
└────────┬────────┘
         │
         ↓ HTTPS + JWT
┌─────────────────┐
│ Exchange API    │
└────────┬────────┘
         │
    ┌────┴─────┬─────────┬─────────┐
    ↓          ↓         ↓         ↓
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Markets │ │Orders  │ │Trades  │ │Halts   │
└────────┘ └────────┘ └────────┘ └────────┘
```

### Integration Patterns

#### 1. Market Management Workflow

```javascript
// 1. Create a new market
const market = await client.markets.create({
  instrumentId: "inst_eth_usd_001",
  quoteCcy: "USD",
  chainId: 1,
  priceBandPct: 0.05, // 5% price collar
  lotSize: 10,
  marketType: "SPOT",
});

// 2. Monitor market status
const checkMarketStatus = async (marketId) => {
  const marketDetails = await client.markets.get(marketId);
  console.log(`Market ${marketId} status: ${marketDetails.status}`);
  return marketDetails;
};

// 3. Update market parameters if needed
if (market.status === "ACTIVE") {
  await client.markets.update(market.id, {
    priceBandPct: 0.03, // Tighten price collar to 3%
  });
}
```

#### 2. Order Management System

```javascript
// Place order with error handling
const placeOrder = async (orderParams) => {
  try {
    const order = await client.orders.create(orderParams);

    // Monitor order status
    const orderStatus = await client.orders.get(order.id);

    if (orderStatus.status === "OPEN") {
      console.log("Order is active in the order book");
    } else if (orderStatus.status === "FILLED") {
      console.log(
        `Order filled: ${orderStatus.filledQty} at ${orderStatus.px}`
      );
    }

    return order;
  } catch (error) {
    if (error.code === "INSUFFICIENT_BALANCE") {
      console.error("Not enough balance to place order");
    } else if (error.code === "MARKET_HALTED") {
      console.error("Market is currently halted");
    }
    throw error;
  }
};
```

#### 3. Real-time Trade Monitoring

```javascript
// Fetch recent trades
const getTrades = async (marketId, accountId = null) => {
  const trades = await client.trades.list({
    marketId: marketId,
    accountId: accountId, // Optional: filter by account
    limit: 50,
  });

  return trades.data.map((trade) => ({
    id: trade.id,
    quantity: trade.qty,
    price: trade.px,
    timestamp: trade.executedAt,
  }));
};

// Calculate position metrics
const calculatePositions = async (accountId) => {
  const positions = await client.positions.list({ accountId });

  return positions.data.map((position) => ({
    instrument: position.instrumentId,
    quantity: position.qty,
    averagePrice: position.avgPx,
    realizedPnL: position.realizedPnL,
    unrealizedPnL: position.unrealizedPnL,
  }));
};
```

---

## 🔐 Authentication Setup {#authentication}

### JWT Token Management

```javascript
import { AuthClient } from "@quub/auth-sdk";

const authClient = new AuthClient({
  clientId: process.env.QUUB_CLIENT_ID,
  clientSecret: process.env.QUUB_CLIENT_SECRET,
});

// Get access token with exchange scopes
const token = await authClient.getAccessToken({
  scopes: ["read:exchange", "write:exchange", "admin:exchange"],
});

// Use with Exchange client
const exchangeClient = new ExchangeClient({
  accessToken: token,
  orgId: process.env.QUUB_ORG_ID,
});
```

### Token Refresh Strategy

```javascript
class ExchangeTokenManager {
  constructor(authClient) {
    this.authClient = authClient;
    this.token = null;
    this.expiresAt = null;
  }

  async getToken() {
    if (this.token && Date.now() < this.expiresAt - 60000) {
      return this.token;
    }

    const response = await this.authClient.getAccessToken({
      scopes: ["read:exchange", "write:exchange"],
    });

    this.token = response.accessToken;
    this.expiresAt = Date.now() + response.expiresIn * 1000;

    return this.token;
  }
}
```

---

## ✨ Best Practices {#best-practices}

### 1. Order Management Best Practices

```javascript
// Use idempotency keys for critical operations
const placeOrderSafely = async (orderParams) => {
  const idempotencyKey = `order-${Date.now()}-${Math.random()}`;

  try {
    const order = await client.orders.create(orderParams, {
      headers: {
        "Idempotency-Key": idempotencyKey,
      },
    });

    return order;
  } catch (error) {
    if (error.code === "DUPLICATE_REQUEST") {
      // Handle duplicate gracefully
      console.log("Order already placed with this idempotency key");
    }
    throw error;
  }
};
```

### 2. Error Handling

```javascript
const handleExchangeError = (error) => {
  switch (error.code) {
    case "INVALID_ORDER_PARAMS":
      console.error("Order parameters are invalid:", error.message);
      break;
    case "MARKET_CLOSED":
      console.error("Market is currently closed for trading");
      break;
    case "INSUFFICIENT_BALANCE":
      console.error("Account has insufficient balance");
      break;
    case "PRICE_OUT_OF_BAND":
      console.error("Order price is outside the allowed price band");
      break;
    case "RATE_LIMIT_EXCEEDED":
      console.error("Rate limit exceeded, implement backoff");
      break;
    default:
      console.error("Unexpected error:", error);
  }
};
```

### 3. Rate Limiting and Batching

```javascript
import pLimit from "p-limit";

const limit = pLimit(10); // Max 10 concurrent requests

// Batch order placement
const placeBatchOrders = async (orders) => {
  const results = await Promise.allSettled(
    orders.map((order) => limit(() => client.orders.create(order)))
  );

  const successful = results
    .filter((result) => result.status === "fulfilled")
    .map((result) => result.value);

  const failed = results
    .filter((result) => result.status === "rejected")
    .map((result) => result.reason);

  return { successful, failed };
};
```

---

## 🔒 Security Guidelines {#security}

### API Key Management

❌ **Don't:**

```javascript
// Never hardcode credentials
const client = new ExchangeClient({
  apiKey: "sk_live_abc123...",
  orgId: "org_xyz789",
});
```

✅ **Do:**

```javascript
// Use environment variables
const client = new ExchangeClient({
  apiKey: process.env.QUUB_API_KEY,
  orgId: process.env.QUUB_ORG_ID,
  environment: process.env.NODE_ENV === "production" ? "production" : "sandbox",
});
```

### Order Validation

```javascript
// Validate orders before submission
const validateOrder = (order) => {
  const errors = [];

  if (!order.accountId || !order.instrumentId) {
    errors.push("Missing required account or instrument ID");
  }

  if (order.type === "LIMIT" && !order.px) {
    errors.push("Limit orders require a price");
  }

  if (order.qty <= 0) {
    errors.push("Quantity must be positive");
  }

  if (!["BUY", "SELL"].includes(order.side)) {
    errors.push("Invalid order side");
  }

  return errors;
};

// Use validation in order placement
const placeValidatedOrder = async (orderParams) => {
  const validationErrors = validateOrder(orderParams);

  if (validationErrors.length > 0) {
    throw new Error(`Order validation failed: ${validationErrors.join(", ")}`);
  }

  return await client.orders.create(orderParams);
};
```

### Audit Logging

```javascript
// Log all trading activities for compliance
const auditLogger = winston.createLogger({
  level: "info",
  format: winston.format.json(),
  transports: [new winston.transports.File({ filename: "exchange-audit.log" })],
});

const auditTradeAction = (action, params, result) => {
  auditLogger.info("Trading Action", {
    action,
    params,
    result: result ? "success" : "failure",
    timestamp: new Date().toISOString(),
    userId: getCurrentUserId(),
    orgId: process.env.QUUB_ORG_ID,
  });
};
```

---

## 🚀 Performance Optimization {#performance}

### 1. Connection Pooling

```javascript
// Configure HTTP client with connection pooling
const client = new ExchangeClient({
  apiKey: process.env.QUUB_API_KEY,
  orgId: process.env.QUUB_ORG_ID,
  httpOptions: {
    maxSockets: 20,
    keepAlive: true,
    timeout: 30000,
  },
});
```

### 2. Efficient Data Fetching

```javascript
// Use pagination for large datasets
async function* fetchAllOrders(accountId) {
  let cursor = null;

  do {
    const response = await client.orders.list({
      accountId,
      cursor,
      limit: 100, // Optimize batch size
    });

    yield response.data;
    cursor = response.meta.nextCursor;
  } while (cursor);
}

// Process in batches
for await (const orderBatch of fetchAllOrders("acc_123")) {
  await processOrderBatch(orderBatch);
}
```

### 3. Caching Strategy

```javascript
import NodeCache from "node-cache";

const cache = new NodeCache({ stdTTL: 60 }); // 1-minute TTL

// Cache market data
const getCachedMarket = async (marketId) => {
  const cacheKey = `market:${marketId}`;
  const cached = cache.get(cacheKey);

  if (cached) return cached;

  const market = await client.markets.get(marketId);
  cache.set(cacheKey, market);

  return market;
};
```

---

## 🔧 Advanced Configuration {#advanced}

### Market Maker Integration

```javascript
// Continuous market maker quote updates
class MarketMaker {
  constructor(client, marketId) {
    this.client = client;
    this.marketId = marketId;
    this.isRunning = false;
  }

  async start() {
    this.isRunning = true;

    while (this.isRunning) {
      try {
        // Calculate fair value and spreads
        const fairValue = await this.calculateFairValue();
        const spread = this.calculateSpread();

        // Update quotes
        await this.client.mmQuotes.upsert({
          marketId: this.marketId,
          bidPx: fairValue - spread / 2,
          bidQty: 1000,
          askPx: fairValue + spread / 2,
          askQty: 1000,
          validUntil: new Date(Date.now() + 30000), // 30 seconds
        });

        // Wait before next update
        await new Promise((resolve) => setTimeout(resolve, 5000));
      } catch (error) {
        console.error("Market maker error:", error);
        await new Promise((resolve) => setTimeout(resolve, 10000));
      }
    }
  }

  stop() {
    this.isRunning = false;
  }

  async calculateFairValue() {
    // Implement your fair value calculation
    return 45000; // Example BTC price
  }

  calculateSpread() {
    // Dynamic spread based on volatility and inventory
    return 10; // $10 spread
  }
}
```

### Circuit Breaker Implementation

```javascript
// Implement trading halts and circuit breakers
const monitorMarketVolatility = async (marketId) => {
  const trades = await client.trades.list({
    marketId,
    limit: 100,
  });

  // Calculate price volatility
  const prices = trades.data.map((trade) => trade.px);
  const volatility = calculateVolatility(prices);

  // Trigger halt if volatility exceeds threshold
  if (volatility > 0.1) {
    // 10% volatility threshold
    await client.halts.create({
      marketId,
      reason: "VOLATILITY",
      triggeredBy: "AUTOMATED_SYSTEM",
    });

    console.log(`Market ${marketId} halted due to high volatility`);
  }
};
```

---

## 🔍 Troubleshooting {#troubleshooting}

### Common Issues

#### Issue: 401 Unauthorized

**Cause:** Invalid or expired JWT token

**Solution:**

```javascript
// Check token validity and refresh
const validateToken = async () => {
  try {
    await client.markets.list({ limit: 1 });
  } catch (error) {
    if (error.status === 401) {
      const newToken = await authClient.refreshToken();
      client.setAccessToken(newToken);
    }
  }
};
```

#### Issue: 403 Forbidden - Insufficient Trading Permissions

**Cause:** JWT token lacks required scopes

**Solution:**

```javascript
// Verify required scopes are present
const requiredScopes = ["read:exchange", "write:exchange"];
const tokenScopes = decodeJWT(token).scopes;

const missingScopes = requiredScopes.filter(
  (scope) => !tokenScopes.includes(scope)
);

if (missingScopes.length > 0) {
  throw new Error(`Missing required scopes: ${missingScopes.join(", ")}`);
}
```

#### Issue: 422 Validation Error - Invalid Order

**Cause:** Order parameters don't meet market requirements

**Solution:**

```javascript
// Pre-validate order against market constraints
const validateOrderAgainstMarket = async (orderParams) => {
  const market = await client.markets.get(orderParams.marketId);

  // Check lot size compliance
  if (orderParams.qty % market.lotSize !== 0) {
    throw new Error(`Quantity must be multiple of lot size ${market.lotSize}`);
  }

  // Check price band for limit orders
  if (orderParams.type === "LIMIT" && market.priceBandPct) {
    const lastTrade = await getLastTradePrice(market.id);
    const maxPrice = lastTrade * (1 + market.priceBandPct);
    const minPrice = lastTrade * (1 - market.priceBandPct);

    if (orderParams.px > maxPrice || orderParams.px < minPrice) {
      throw new Error(
        `Price ${orderParams.px} outside allowed band [${minPrice}, ${maxPrice}]`
      );
    }
  }
};
```

#### Issue: 429 Rate Limit Exceeded

**Cause:** Too many requests to the API

**Solution:**

```javascript
// Implement exponential backoff with jitter
const withRetry = async (fn, maxRetries = 3) => {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (error.status === 429 && attempt < maxRetries - 1) {
        const baseDelay = Math.pow(2, attempt) * 1000;
        const jitter = Math.random() * 1000;
        await new Promise((resolve) => setTimeout(resolve, baseDelay + jitter));
        continue;
      }
      throw error;
    }
  }
};
```

---

## 📊 Monitoring & Observability {#monitoring}

### Performance Metrics

```javascript
import { Counter, Histogram, Gauge } from "prom-client";

// Order metrics
const orderCounter = new Counter({
  name: "exchange_orders_total",
  help: "Total number of orders placed",
  labelNames: ["status", "side", "type"],
});

const orderDuration = new Histogram({
  name: "exchange_order_duration_seconds",
  help: "Order placement duration",
  labelNames: ["type"],
});

const activeOrders = new Gauge({
  name: "exchange_active_orders",
  help: "Number of active orders",
  labelNames: ["market_id"],
});

// Trade metrics
const tradeVolume = new Counter({
  name: "exchange_trade_volume_total",
  help: "Total trading volume",
  labelNames: ["market_id", "quote_currency"],
});
```

### Health Check System

```javascript
// Comprehensive health checks
const performHealthCheck = async () => {
  const checks = {
    api_connectivity: false,
    market_data: false,
    order_placement: false,
    websocket_connection: false,
  };

  try {
    // Test API connectivity
    const markets = await client.markets.list({ limit: 1 });
    checks.api_connectivity = true;

    // Test market data retrieval
    if (markets.data.length > 0) {
      const market = await client.markets.get(markets.data[0].id);
      checks.market_data = !!market.id;
    }

    // Test order validation (dry run)
    try {
      validateOrder({
        accountId: "test",
        instrumentId: "test",
        side: "BUY",
        type: "LIMIT",
        qty: 1,
        px: 100,
        tif: "GTC",
      });
      checks.order_placement = true;
    } catch (e) {
      // Expected validation error means validation is working
      checks.order_placement = true;
    }
  } catch (error) {
    console.error("Health check failed:", error);
  }

  return checks;
};
```

### Alerting Configuration

```javascript
// Set up alerts for critical events
const alertThresholds = {
  orderLatency: 1000, // ms
  errorRate: 0.05, // 5%
  activeOrderLimit: 1000,
};

const checkAlerts = async () => {
  // Check order latency
  const avgLatency = await getAverageOrderLatency();
  if (avgLatency > alertThresholds.orderLatency) {
    await sendAlert("HIGH_ORDER_LATENCY", {
      current: avgLatency,
      threshold: alertThresholds.orderLatency,
    });
  }

  // Check error rate
  const errorRate = await getErrorRate();
  if (errorRate > alertThresholds.errorRate) {
    await sendAlert("HIGH_ERROR_RATE", {
      current: errorRate,
      threshold: alertThresholds.errorRate,
    });
  }
};
```

### Logging Configuration

```javascript
import winston from "winston";

const logger = winston.createLogger({
  level: "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({
      filename: "exchange-error.log",
      level: "error",
    }),
    new winston.transports.File({ filename: "exchange-combined.log" }),
  ],
});

// Log all API interactions
client.on("request", (req) => {
  logger.info("Exchange API Request", {
    method: req.method,
    url: req.url,
    requestId: req.headers["x-request-id"],
    orgId: req.headers["x-org-id"],
  });
});

client.on("response", (res) => {
  const logLevel = res.status >= 400 ? "error" : "info";
  logger.log(logLevel, "Exchange API Response", {
    status: res.status,
    requestId: res.headers["x-request-id"],
    duration: res.duration,
  });
});
```

---

## 📚 Additional Resources

- [API Reference](../api-documentation/) - Complete Exchange API documentation
- [OpenAPI Specification](/openapi/exchange.yaml) - Machine-readable API spec
- [Trading Best Practices](/guides/trading-integration/) - Advanced trading strategies
- [Market Making Guide](/guides/market-making/) - Liquidity provision strategies
- [Risk Management](/guides/risk-management/) - Position and risk controls
- [Code Examples](https://github.com/quub-fi/examples) - Sample implementations
- [Support](https://support.quub.fi) - Get help from our team

---

**Need help?** Contact our support team or join our [developer community](https://community.quub.fi).
