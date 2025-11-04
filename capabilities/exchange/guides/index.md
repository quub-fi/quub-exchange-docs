---
layout: docs
title: Exchange Guides
permalink: /capabilities/exchange/guides/
---

# 📚 Exchange Implementation Guides

> Comprehensive developer guide for implementing high-performance trading, order management, and market operations.

## 🚀 Quick Navigation

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 30px 0;">

<div style="border: 2px solid #667eea; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #667eea10 0%, #764ba210 100%);">
  <h3 style="margin-top: 0; color: #667eea;">🎯 Getting Started</h3>
  <p>New to Exchange? Start here to get up and running quickly.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#overview">API Overview & Architecture</a></li>
    <li><a href="#quick-start">Quick Start Guide</a></li>
    <li><a href="#authentication">Authentication Setup</a></li>
  </ul>
</div>

<div style="border: 2px solid #10b981; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #10b98110 0%, #059669100%);">
  <h3 style="margin-top: 0; color: #10b981;">🏗️ Core Operations</h3>
  <p>Master the essential trading and market operations.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#markets">Markets Management</a></li>
    <li><a href="#orders">Order Management</a></li>
    <li><a href="#trades">Trade Execution</a></li>
    <li><a href="#positions">Position Tracking</a></li>
  </ul>
</div>

<div style="border: 2px solid #f59e0b; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #f59e0b10 0%, #d9770610 100%);">
  <h3 style="margin-top: 0; color: #f59e0b;">🔧 Advanced Topics</h3>
  <p>Deep dives into advanced features and capabilities.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#market-making">Market Making</a></li>
    <li><a href="#risk-management">Risk Management</a></li>
    <li><a href="#troubleshooting">Troubleshooting</a></li>
    <li><a href="#monitoring">Monitoring & Observability</a></li>
  </ul>
</div>

</div>

---

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

The Exchange API serves as the core trading infrastructure for Quub Exchange, providing:

- **High-Performance Order Matching:** Sub-millisecond execution with price-time priority
- **Multi-Asset Trading:** Support for SPOT, tokenized RWAs, and derivatives
- **Market Making Infrastructure:** Continuous liquidity provision and spread management
- **Risk Management:** Real-time position monitoring and circuit breakers
- **Regulatory Compliance:** ATS/MTF frameworks with comprehensive audit trails

### Technical Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Trading Client │    │  Exchange API   │    │ Matching Engine │
│                 │────│                 │────│                 │
│ • Order Entry   │    │ • Validation    │    │ • Order Book    │
│ • Portfolio     │    │ • Risk Checks   │    │ • Price Match   │
│ • Market Data   │    │ • Settlement    │    │ • Trade Exec    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                    ┌─────────────────┐
                    │  Data Pipeline  │
                    │                 │
                    │ • Real-time     │
                    │ • WebSockets    │
                    │ • Market Data   │
                    └─────────────────┘
```

### Core Data Models

**Markets:** Trading venues with configurable parameters (lot sizes, price bands, market types)
**Orders:** Trading instructions with various types (LIMIT, MARKET, STOP_LIMIT, IOC) and time-in-force options
**Trades:** Executed transactions with complete audit trail and settlement details
**Positions:** Real-time portfolio tracking with P/L calculations and risk metrics
**Market Maker Quotes:** Continuous two-sided quotes for liquidity provision

---

## 🎯 Quick Start {#quick-start}

### Prerequisites

Before you begin, ensure you have:

- ✅ Active Quub Exchange account with trading permissions
- ✅ API credentials with `read:exchange` and `write:exchange` scopes
- ✅ Development environment configured (Node.js 18+ or Python 3.9+)
- ✅ Understanding of JWT authentication and trading concepts
- ✅ Risk management policies and position limits configured

### 5-Minute Setup

#### Step 1: Install SDK

**Node.js:**

```bash
npm install @quub/exchange-sdk ws
```

**Python:**

```bash
pip install quub-exchange websocket-client
```

#### Step 2: Configure Authentication

**Node.js:**

```javascript
import { ExchangeClient } from "@quub/exchange-sdk";

const client = new ExchangeClient({
  apiKey: process.env.QUUB_API_KEY,
  orgId: process.env.QUUB_ORG_ID,
  baseUrl:
    process.env.NODE_ENV === "production"
      ? "https://api.quub.exchange/v2"
      : "https://api.sandbox.quub.exchange/v2",
});
```

**Python:**

```python
from quub.exchange import ExchangeClient
import os

client = ExchangeClient(
    api_key=os.getenv('QUUB_API_KEY'),
    org_id=os.getenv('QUUB_ORG_ID'),
    base_url='https://api.sandbox.quub.exchange/v2'
)
```

#### Step 3: Explore Available Markets

**Node.js:**

```javascript
// GET /orgs/{orgId}/markets
const response = await client.get(`/orgs/${orgId}/markets`, {
  params: {
    status: "OPEN",
    limit: 20,
  },
});

console.log("Available Markets:");
response.data.data.forEach((market) => {
  console.log(`${market.id}: ${market.quoteCcy} (${market.marketType})`);
  console.log(
    `  Lot Size: ${market.lotSize}, Price Band: ${market.priceBandPct}%`
  );
});
```

**Python:**

```python
# GET /orgs/{orgId}/markets
try:
    response = client.get(f'/orgs/{org_id}/markets', params={
        'status': 'OPEN',
        'limit': 20
    })

    markets = response.json()
    print("Available Markets:")
    for market in markets['data']:
        print(f"{market['id']}: {market['quoteCcy']} ({market['marketType']})")
        print(f"  Lot Size: {market['lotSize']}, Price Band: {market['priceBandPct']}%")

except Exception as e:
    print(f"Failed to fetch markets: {e}")
```

#### Step 4: Place Your First Order

**Node.js:**

```javascript
// POST /orgs/{orgId}/orders
const orderResponse = await client.post(`/orgs/${orgId}/orders`, {
  accountId: "acc_123456789",
  instrumentId: "inst_btc_usd_001",
  side: "BUY",
  type: "LIMIT",
  qty: 0.1,
  px: 45000.0,
  tif: "GTC",
  clientRef: "my-first-order-001",
});

console.log(
  `Order placed: ${orderResponse.data.id} (Status: ${orderResponse.data.status})`
);

// GET /orgs/{orgId}/orders/{orderId} - Monitor order status
const orderStatus = await client.get(
  `/orgs/${orgId}/orders/${orderResponse.data.id}`
);
if (orderStatus.data.status === "FILLED") {
  console.log(
    `Order filled: ${orderStatus.data.filledQty} at ${orderStatus.data.px}`
  );
}
```

**Python:**

```python
# POST /orgs/{orgId}/orders
try:
    order_response = client.post(f'/orgs/{org_id}/orders', json={
        'accountId': 'acc_123456789',
        'instrumentId': 'inst_btc_usd_001',
        'side': 'BUY',
        'type': 'LIMIT',
        'qty': 0.1,
        'px': 45000.00,
        'tif': 'GTC',
        'clientRef': 'my-first-order-001'
    })

    order = order_response.json()
    print(f"Order placed: {order['id']} (Status: {order['status']})")

    # Check if immediately filled
    if order['status'] == 'FILLED':
        print(f"Order immediately filled: {order['filledQty']} at {order['px']}")
    elif order['status'] == 'OPEN':
        print("Order is now in the order book")

except Exception as e:
    print(f"Order placement failed: {e}")
```

---

## 🏗️ Core API Operations {#core-operations}

### 1. Markets Management {#markets}

**Available Operations:**

- `GET /orgs/{orgId}/markets` - List markets (operationId: listMarkets)
- `POST /orgs/{orgId}/markets` - Create market (operationId: createMarket)
- `GET /orgs/{orgId}/markets/{marketId}` - Get market details (operationId: getMarket)
- `PATCH /orgs/{orgId}/markets/{marketId}` - Update market (operationId: updateMarket)

**List Markets**

```javascript
// GET /orgs/{orgId}/markets
const response = await client.get(`/orgs/${orgId}/markets`, {
  params: {
    status: "OPEN",
    cursor: null,
    limit: 50,
  },
});

console.log(`Found ${response.data.data.length} markets`);
response.data.data.forEach((market) => {
  console.log(`Market: ${market.id}`);
  console.log(`  Quote Currency: ${market.quoteCcy}`);
  console.log(`  Market Type: ${market.marketType}`);
  console.log(`  Lot Size: ${market.lotSize}`);
});
```

**Create Market**

```javascript
// POST /orgs/{orgId}/markets
const marketResponse = await client.post(`/orgs/${orgId}/markets`, {
  instrumentId: "inst_reit_001",
  quoteCcy: "USD",
  chainId: 1,
  priceBandPct: 0.05,
  lotSize: 100,
  marketType: "SPOT",
});

console.log(`Market created: ${marketResponse.data.id}`);
```

### 2. Order Management {#orders}

**Available Operations:**

- `GET /orgs/{orgId}/orders` - List orders (operationId: listOrders)
- `POST /orgs/{orgId}/orders` - Create order (operationId: createOrder)
- `GET /orgs/{orgId}/orders/{orderId}` - Get order details (operationId: getOrder)
- `DELETE /orgs/{orgId}/orders/{orderId}` - Cancel order (operationId: cancelOrder)

**Create Order**

```javascript
// POST /orgs/{orgId}/orders
const orderResponse = await client.post(`/orgs/${orgId}/orders`, {
  accountId: "acc_trader_001",
  instrumentId: "inst_btc_usd_001",
  side: "BUY",
  type: "LIMIT",
  qty: 1.5,
  px: 44500.0,
  tif: "GTC",
  clientRef: "trade-2025-001",
});

console.log(`Order created: ${orderResponse.data.id}`);
console.log(`Status: ${orderResponse.data.status}`);
```

**List Orders**

```javascript
// GET /orgs/{orgId}/orders
const ordersResponse = await client.get(`/orgs/${orgId}/orders`, {
  params: {
    accountId: "acc_trader_001",
    instrumentId: "inst_btc_usd_001",
    status: "OPEN",
    limit: 100,
  },
});

ordersResponse.data.data.forEach((order) => {
  console.log(`Order ${order.id}: ${order.side} ${order.qty} at ${order.px}`);
});
```

**Cancel Order**

```javascript
// DELETE /orgs/{orgId}/orders/{orderId}
await client.delete(`/orgs/${orgId}/orders/${orderId}`);
console.log(`Order ${orderId} cancelled`);
```

### 3. Trade Execution & History {#trades}

**Available Operations:**

- `GET /orgs/{orgId}/trades` - List trades (operationId: listTrades)

**List Trades**

```javascript
// GET /orgs/{orgId}/trades
const tradesResponse = await client.get(`/orgs/${orgId}/trades`, {
  params: {
    marketId: "market_btc_usd_001",
    accountId: "acc_trader_001", // Optional filter
    limit: 100,
  },
});

tradesResponse.data.data.forEach((trade) => {
  console.log(`Trade ${trade.id}:`);
  console.log(`  Quantity: ${trade.qty}`);
  console.log(`  Price: ${trade.px}`);
  console.log(`  Executed: ${trade.executedAt}`);
});
```

### 4. Position Tracking {#positions}

**Available Operations:**

- `GET /orgs/{orgId}/positions` - List positions (operationId: listPositions)

**List Positions**

```javascript
// GET /orgs/{orgId}/positions
const positionsResponse = await client.get(`/orgs/${orgId}/positions`, {
  params: {
    accountId: "acc_trader_001", // Required parameter
  },
});

console.log("Current Positions:");
positionsResponse.data.data.forEach((position) => {
  console.log(`${position.instrumentId}:`);
  console.log(`  Quantity: ${position.qty}`);
  console.log(`  Avg Price: ${position.avgPx}`);
  console.log(`  Realized P/L: ${position.realizedPnL}`);
  console.log(`  Unrealized P/L: ${position.unrealizedPnL}`);
});
```

### 5. Market Maker Quotes {#market-making}

**Available Operations:**

- `GET /orgs/{orgId}/mm-quotes` - List market maker quotes (operationId: listMMQuotes)
- `POST /orgs/{orgId}/mm-quotes` - Upsert market maker quote (operationId: upsertMMQuote)

**Upsert Market Maker Quote**

```javascript
// POST /orgs/{orgId}/mm-quotes
const quoteResponse = await client.post(`/orgs/${orgId}/mm-quotes`, {
  marketId: "market_btc_usd_001",
  bidPx: 44950.0,
  bidQty: 1000,
  askPx: 45050.0,
  askQty: 1000,
  validUntil: new Date(Date.now() + 30000).toISOString(), // 30 seconds
});

console.log(`Market maker quote updated: ${quoteResponse.data.id}`);
```

### 6. Market Halts {#risk-management}

**Available Operations:**

- `GET /orgs/{orgId}/halts` - List halts (operationId: listHalts)
- `POST /orgs/{orgId}/halts` - Create halt (operationId: createHalt)

**Create Market Halt**

```javascript
// POST /orgs/{orgId}/halts
const haltResponse = await client.post(`/orgs/${orgId}/halts`, {
  marketId: "market_btc_usd_001",
  reason: "VOLATILITY",
  triggeredBy: "AUTOMATED_SYSTEM",
});

console.log(`Market halt triggered: ${haltResponse.data.id}`);
```

qty: 1.5,
px: 44500.0,
tif: "GTC", // Good-Till-Cancelled
clientRef: "trade-2025-001",
});

````

**Place Market Order**

```javascript
// Market order for immediate execution
const marketOrder = await client.orders.create({
  accountId: "acc_trader_001",
  instrumentId: "inst_eth_usd_001",
  side: "SELL",
  type: "MARKET",
  qty: 10.0,
  tif: "IOC", // Immediate-or-Cancel
});
````

**Order Monitoring & Management**

```python
class OrderManager:
    def __init__(self, client):
        self.client = client

    async def monitor_order(self, order_id, timeout=60):
        """Monitor order until filled or cancelled"""
        start_time = time.time()

        while time.time() - start_time < timeout:
            order = await self.client.orders.get(order_id)

            if order['status'] == 'FILLED':
                return {
                    'status': 'COMPLETED',
                    'filled_qty': order['filledQty'],
                    'avg_price': order['px']
                }
            elif order['status'] == 'CANCELLED':
                return {'status': 'CANCELLED'}

            await asyncio.sleep(1)  # Check every second

        return {'status': 'TIMEOUT'}

    async def cancel_order(self, order_id):
        """Cancel an open order"""
        try:
            await self.client.orders.cancel(order_id)
            print(f"Order {order_id} cancelled successfully")
        except Exception as e:
            print(f"Failed to cancel order {order_id}: {e}")
```

### 3. Trade Execution & History {#trades}

**Business Use Case:** Monitor trade executions and analyze trading history

**Fetch Recent Trades**

```javascript
// Get trades for specific market
const trades = await client.trades.list({
  marketId: "market_btc_usd_001",
  limit: 100,
  accountId: "acc_trader_001", // Optional: filter by account
});

trades.data.forEach((trade) => {
  console.log(`Trade ${trade.id}:`);
  console.log(`  Quantity: ${trade.qty}`);
  console.log(`  Price: ${trade.px}`);
  console.log(`  Executed: ${trade.executedAt}`);
});
```

**Trade Analysis**

```python
def analyze_trading_performance(client, account_id, start_date, end_date):
    """Analyze trading performance over period"""
    trades = client.trades.list(
        account_id=account_id,
        start_date=start_date,
        end_date=end_date
    )

    total_volume = sum(trade['qty'] * trade['px'] for trade in trades['data'])
    total_trades = len(trades['data'])

    buy_trades = [t for t in trades['data'] if t['side'] == 'BUY']
    sell_trades = [t for t in trades['data'] if t['side'] == 'SELL']

    return {
        'total_volume': total_volume,
        'total_trades': total_trades,
        'buy_trades': len(buy_trades),
        'sell_trades': len(sell_trades),
        'avg_trade_size': total_volume / total_trades if total_trades > 0 else 0
    }
```

### 4. Position Tracking {#positions}

**Business Use Case:** Monitor real-time portfolio positions and P/L

**Get Account Positions**

```javascript
// Fetch all positions for an account
const positions = await client.positions.list({
  accountId: "acc_trader_001",
});

console.log("Current Positions:");
positions.data.forEach((position) => {
  console.log(`${position.instrumentId}:`);
  console.log(`  Quantity: ${position.qty}`);
  console.log(`  Avg Price: ${position.avgPx}`);
  console.log(`  Realized P/L: ${position.realizedPnL}`);
  console.log(`  Unrealized P/L: ${position.unrealizedPnL}`);
});
```

**Real-time Position Monitoring**

```python
class PositionMonitor:
    def __init__(self, client, account_id):
        self.client = client
        self.account_id = account_id
        self.risk_limits = {
            'max_position_size': 1000000,  # $1M max position
            'max_loss_threshold': -50000   # -$50K max loss
        }

    async def check_risk_limits(self):
        """Monitor positions against risk limits"""
        positions = await self.client.positions.list(
            account_id=self.account_id
        )

        alerts = []
        total_unrealized = 0

        for position in positions['data']:
            position_value = position['qty'] * position['avgPx']
            total_unrealized += position['unrealizedPnL']

            # Check position size limits
            if position_value > self.risk_limits['max_position_size']:
                alerts.append({
                    'type': 'POSITION_SIZE_EXCEEDED',
                    'instrument': position['instrumentId'],
                    'current_value': position_value,
                    'limit': self.risk_limits['max_position_size']
                })

        # Check total unrealized loss
        if total_unrealized < self.risk_limits['max_loss_threshold']:
            alerts.append({
                'type': 'LOSS_THRESHOLD_EXCEEDED',
                'unrealized_pnl': total_unrealized,
                'threshold': self.risk_limits['max_loss_threshold']
            })

        return alerts
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
