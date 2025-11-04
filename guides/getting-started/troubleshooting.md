---
layout: docs
title: Troubleshooting Guide
permalink: /guides/getting-started/troubleshooting/
description: Solutions to common issues when integrating with Quub Exchange
---

# Troubleshooting Guide

Comprehensive solutions to common issues, error messages, and debugging techniques for Quub Exchange integrations.

## Table of Contents

1. [Authentication Issues](#authentication-issues)
2. [API Errors](#api-errors)
3. [WebSocket Problems](#websocket-problems)
4. [Order Execution Issues](#order-execution-issues)
5. [Rate Limiting](#rate-limiting)
6. [Network & Connectivity](#network--connectivity)
7. [Data Synchronization](#data-synchronization)

---

## Authentication Issues

### Error: "Invalid API Key"

**Symptoms:**

```json
{
  "error": {
    "code": "AUTH_INVALID_KEY",
    "message": "Invalid API key"
  }
}
```

**Solutions:**

1. **Verify API Key Format**

```javascript
// Correct format
const apiKey = "qk_live_abc123..."; // Starts with qk_live_ or qk_test_

// Check key is not truncated
console.log("API Key length:", process.env.QUUB_API_KEY.length);
// Should be 64+ characters
```

2. **Check Environment**

```bash
# Verify environment variables are set
echo $QUUB_API_KEY
echo $QUUB_API_SECRET
echo $QUUB_ORG_ID

# Check .env file is loaded
node -e "require('dotenv').config(); console.log(process.env.QUUB_API_KEY)"
```

3. **Verify Key Status in Dashboard**

- Log in to Quub Dashboard
- Navigate to Settings > API Keys
- Confirm key is active and not revoked

---

### Error: "Authentication Token Expired"

**Symptoms:**

```json
{
  "error": {
    "code": "AUTH_TOKEN_EXPIRED",
    "message": "Authentication token has expired"
  }
}
```

**Solution: Implement Token Refresh**

```javascript
class TokenRefreshHandler {
  constructor(quubClient) {
    this.client = quubClient;
    this.token = null;
    this.expiresAt = null;
  }

  async getValidToken() {
    // Check if token is expired or about to expire (5-minute buffer)
    if (!this.token || Date.now() >= this.expiresAt - 300000) {
      await this.refreshToken();
    }

    return this.token;
  }

  async refreshToken() {
    try {
      const response = await this.client.auth.authenticate({
        apiKey: process.env.QUUB_API_KEY,
        apiSecret: process.env.QUUB_API_SECRET,
        orgId: process.env.QUUB_ORG_ID,
      });

      this.token = response.accessToken;
      this.expiresAt = Date.now() + response.expiresIn * 1000;

      console.log("✅ Token refreshed, expires at:", new Date(this.expiresAt));
    } catch (error) {
      console.error("❌ Token refresh failed:", error.message);
      throw error;
    }
  }
}

// Usage with automatic retry
async function makeAuthenticatedRequest(requestFn) {
  try {
    const token = await tokenHandler.getValidToken();
    return await requestFn(token);
  } catch (error) {
    if (error.code === "AUTH_TOKEN_EXPIRED") {
      // Force refresh and retry once
      await tokenHandler.refreshToken();
      const token = await tokenHandler.getValidToken();
      return await requestFn(token);
    }
    throw error;
  }
}
```

---

### Error: "Insufficient Permissions"

**Symptoms:**

```json
{
  "error": {
    "code": "AUTH_INSUFFICIENT_PERMISSIONS",
    "message": "API key does not have required scopes"
  }
}
```

**Solution: Check API Key Scopes**

```javascript
// Check current key permissions
async function verifyKeyScopes() {
  const keyInfo = await quubClient.auth.getKeyInfo();

  console.log("API Key Scopes:", keyInfo.scopes);

  const requiredScopes = ["trading:read", "trading:write", "accounts:read"];
  const missingScopes = requiredScopes.filter(
    (scope) => !keyInfo.scopes.includes(scope)
  );

  if (missingScopes.length > 0) {
    console.error("❌ Missing required scopes:", missingScopes);
    console.log("📋 Create a new API key with these scopes in the dashboard");
  }
}
```

---

## API Errors

### Error: "Invalid Request Parameters"

**Symptoms:**

```json
{
  "error": {
    "code": "INVALID_PARAMETERS",
    "message": "Invalid request parameters",
    "details": {
      "quantity": "must be a positive number"
    }
  }
}
```

**Solution: Validate Parameters**

```javascript
import Joi from "joi";

// Define validation schema
const orderSchema = Joi.object({
  symbol: Joi.string()
    .pattern(/^[A-Z]+-[A-Z]+$/)
    .required(),
  side: Joi.string().valid("buy", "sell").required(),
  type: Joi.string().valid("market", "limit", "stop").required(),
  quantity: Joi.string()
    .pattern(/^\d+\.?\d*$/)
    .required(),
  price: Joi.string()
    .pattern(/^\d+\.?\d*$/)
    .when("type", {
      is: "limit",
      then: Joi.required(),
    }),
});

// Validate before sending
async function placeOrderSafely(params) {
  // Validate
  const { error, value } = orderSchema.validate(params);

  if (error) {
    console.error("❌ Validation failed:", error.details[0].message);
    throw new Error(`Invalid parameters: ${error.details[0].message}`);
  }

  // Send request
  try {
    return await quubClient.exchange.createOrder(value);
  } catch (apiError) {
    console.error("❌ API Error:", apiError.message);
    if (apiError.details) {
      console.error("Details:", JSON.stringify(apiError.details, null, 2));
    }
    throw apiError;
  }
}
```

---

### Error: "Resource Not Found"

**Symptoms:**

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Order not found"
  }
}
```

**Debugging Steps:**

```javascript
async function debugOrderNotFound(orderId) {
  console.log("🔍 Debugging order:", orderId);

  // 1. Verify order ID format
  if (!orderId || typeof orderId !== "string") {
    console.error("❌ Invalid order ID format:", orderId);
    return;
  }

  // 2. Search in recent orders
  const recentOrders = await quubClient.exchange.getOrders({
    limit: 100,
    sortBy: "createdAt",
    sortOrder: "desc",
  });

  const found = recentOrders.find((o) => o.orderId === orderId);
  if (found) {
    console.log("✅ Order found in recent orders:", found);
    return found;
  }

  // 3. Check if order was cancelled
  const cancelledOrders = await quubClient.exchange.getOrders({
    status: "cancelled",
    limit: 100,
  });

  const cancelled = cancelledOrders.find((o) => o.orderId === orderId);
  if (cancelled) {
    console.log("ℹ️ Order was cancelled:", cancelled);
    return cancelled;
  }

  // 4. Check across all statuses
  for (const status of ["open", "filled", "cancelled", "rejected"]) {
    const orders = await quubClient.exchange.getOrders({ status, limit: 100 });
    const match = orders.find((o) => o.orderId === orderId);
    if (match) {
      console.log(`✅ Order found with status '${status}':`, match);
      return match;
    }
  }

  console.error("❌ Order not found in any status");
}
```

---

## WebSocket Problems

### Issue: WebSocket Disconnects Frequently

**Symptoms:**

- Connection drops every few minutes
- Missing market data updates
- Error: "WebSocket connection closed"

**Solution: Implement Reconnection Logic**

```javascript
class RobustWebSocketClient {
  constructor(quubClient) {
    this.client = quubClient;
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 10;
    this.reconnectDelay = 1000;
    this.subscriptions = [];
  }

  async connect() {
    try {
      this.ws = await this.client.exchange.connectWebSocket();

      this.ws.on("open", () => {
        console.log("✅ WebSocket connected");
        this.reconnectAttempts = 0;
        this.resubscribe();
      });

      this.ws.on("close", (code, reason) => {
        console.log(`⚠️ WebSocket closed: ${code} - ${reason}`);
        this.handleDisconnect();
      });

      this.ws.on("error", (error) => {
        console.error("❌ WebSocket error:", error.message);
      });

      // Heartbeat to keep connection alive
      this.startHeartbeat();
    } catch (error) {
      console.error("❌ Failed to connect:", error.message);
      this.handleDisconnect();
    }
  }

  async handleDisconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error("❌ Max reconnection attempts reached");
      return;
    }

    this.reconnectAttempts++;
    const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);

    console.log(
      `🔄 Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})...`
    );

    await this.sleep(delay);
    await this.connect();
  }

  subscribe(channel, symbols, callback) {
    this.subscriptions.push({ channel, symbols, callback });

    if (this.ws && this.ws.readyState === 1) {
      this.ws.subscribe(channel, symbols, callback);
    }
  }

  resubscribe() {
    console.log("🔄 Resubscribing to channels...");
    for (const sub of this.subscriptions) {
      this.ws.subscribe(sub.channel, sub.symbols, sub.callback);
    }
  }

  startHeartbeat() {
    this.heartbeatInterval = setInterval(() => {
      if (this.ws && this.ws.readyState === 1) {
        this.ws.ping();
      }
    }, 30000); // Ping every 30 seconds
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
```

---

### Issue: Missing Market Data Updates

**Debugging:**

```javascript
async function debugMarketData(symbol) {
  console.log("🔍 Debugging market data for", symbol);

  // 1. Check REST API endpoint
  try {
    const market = await quubClient.exchange.getMarket(symbol);
    console.log("✅ REST API working:", market.lastPrice);
  } catch (error) {
    console.error("❌ REST API failed:", error.message);
    return;
  }

  // 2. Test WebSocket connection
  const ws = await quubClient.exchange.connectWebSocket();

  let messageReceived = false;
  let messageCount = 0;

  ws.subscribe("market.ticker", [symbol], (data) => {
    messageReceived = true;
    messageCount++;
    console.log(`📊 Message ${messageCount}:`, {
      symbol: data.symbol,
      price: data.price,
      timestamp: new Date(data.timestamp).toISOString(),
    });
  });

  // Wait 10 seconds
  await new Promise((resolve) => setTimeout(resolve, 10000));

  if (!messageReceived) {
    console.error("❌ No messages received in 10 seconds");
    console.log("Possible issues:");
    console.log("  - Symbol may be inactive");
    console.log("  - WebSocket subscription failed");
    console.log("  - Firewall blocking WebSocket traffic");
  } else {
    console.log(`✅ Received ${messageCount} messages`);
  }

  ws.close();
}
```

---

## Order Execution Issues

### Issue: Orders Stuck in "Pending" Status

**Symptoms:**

- Order created but never fills
- Status remains "pending" for extended time

**Debugging:**

```javascript
async function debugPendingOrder(orderId) {
  console.log("🔍 Debugging pending order:", orderId);

  // 1. Get order details
  const order = await quubClient.exchange.getOrder(orderId);
  console.log("Order details:", {
    status: order.status,
    type: order.type,
    price: order.price,
    quantity: order.quantity,
    filled: order.filledQuantity,
  });

  // 2. Check market conditions
  const market = await quubClient.exchange.getMarket(order.symbol);
  console.log("Market conditions:", {
    lastPrice: market.lastPrice,
    bestBid: market.bestBid,
    bestAsk: market.bestAsk,
    volume24h: market.volume24h,
  });

  // 3. Analyze why order isn't filling
  if (order.type === "limit") {
    const isPriceTooFar =
      order.side === "buy"
        ? parseFloat(order.price) < parseFloat(market.bestAsk) * 0.95
        : parseFloat(order.price) > parseFloat(market.bestBid) * 1.05;

    if (isPriceTooFar) {
      console.log("⚠️ Limit price is too far from market");
      console.log(`  Your ${order.side} price: ${order.price}`);
      console.log(
        `  Market ${order.side === "buy" ? "ask" : "bid"}: ${
          order.side === "buy" ? market.bestAsk : market.bestBid
        }`
      );
    }
  }

  // 4. Check order book depth
  const orderBook = await quubClient.exchange.getOrderBook(order.symbol);
  const relevantSide = order.side === "buy" ? orderBook.asks : orderBook.bids;

  let availableLiquidity = 0;
  for (const level of relevantSide) {
    availableLiquidity += parseFloat(level.quantity);
    if (availableLiquidity >= parseFloat(order.quantity)) {
      break;
    }
  }

  if (availableLiquidity < parseFloat(order.quantity)) {
    console.log("⚠️ Insufficient liquidity in order book");
    console.log(`  Required: ${order.quantity}`);
    console.log(`  Available: ${availableLiquidity}`);
  }

  // 5. Suggest action
  console.log("\n💡 Suggestions:");
  if (order.type === "limit") {
    console.log("  - Consider adjusting limit price closer to market");
    console.log("  - Or convert to market order for immediate execution");
  }
  console.log("  - Consider splitting into smaller orders");
  console.log("  - Check if trading is halted for this market");
}
```

---

### Error: "Insufficient Balance"

**Solution:**

```javascript
async function diagnoseInsufficientBalance(orderParams) {
  console.log("🔍 Diagnosing insufficient balance...");

  // 1. Check current balance
  const currency =
    orderParams.side === "buy"
      ? orderParams.symbol.split("-")[1] // Quote currency
      : orderParams.symbol.split("-")[0]; // Base currency

  const balance = await quubClient.custodian.getBalance(currency);

  console.log(`Balance for ${currency}:`, {
    total: balance.total,
    available: balance.available,
    reserved: balance.reserved,
  });

  // 2. Calculate required amount
  const required =
    orderParams.side === "buy"
      ? parseFloat(orderParams.quantity) *
        parseFloat(
          orderParams.price || (await getMarketPrice(orderParams.symbol))
        )
      : parseFloat(orderParams.quantity);

  console.log(`Required: ${required} ${currency}`);
  console.log(`Available: ${balance.available} ${currency}`);

  // 3. Check reserved balance
  if (parseFloat(balance.reserved) > 0) {
    console.log("\n⚠️ Some balance is reserved in open orders:");
    const openOrders = await quubClient.exchange.getOrders({
      status: "open",
      symbol: orderParams.symbol,
    });

    for (const order of openOrders) {
      console.log(
        `  Order ${order.orderId}: ${order.quantity} ${order.symbol} @ ${order.price}`
      );
    }

    console.log("\n💡 Consider cancelling some orders to free up balance");
  }

  // 4. Suggest solution
  const shortfall = required - parseFloat(balance.available);
  if (shortfall > 0) {
    console.log(`\n❌ Shortfall: ${shortfall} ${currency}`);
    console.log("💡 Solutions:");
    console.log(`  - Deposit ${shortfall} ${currency}`);
    console.log(
      `  - Reduce order quantity to ${
        parseFloat(balance.available) / parseFloat(orderParams.price || 1)
      }`
    );
  }
}
```

---

## Rate Limiting

### Error: "Rate Limit Exceeded"

**Symptoms:**

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Retry after 60 seconds",
    "retryAfter": 60
  }
}
```

**Solution: Implement Rate Limit Handling**

```javascript
class RateLimitHandler {
  async callWithRateLimit(fn, retries = 3) {
    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        return await fn();
      } catch (error) {
        if (error.code === "RATE_LIMIT_EXCEEDED") {
          const retryAfter = error.retryAfter || 60;

          if (attempt < retries) {
            console.log(
              `⏳ Rate limited. Retrying after ${retryAfter}s (attempt ${
                attempt + 1
              }/${retries})`
            );
            await this.sleep(retryAfter * 1000);
            continue;
          }
        }
        throw error;
      }
    }
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Usage
const rateLimitHandler = new RateLimitHandler();

const markets = await rateLimitHandler.callWithRateLimit(() =>
  quubClient.exchange.getMarkets()
);
```

---

## Network & Connectivity

### Issue: Timeout Errors

**Solution: Configure Timeouts**

```javascript
import axios from "axios";

const quubClient = new QuubClient({
  apiKey: process.env.QUUB_API_KEY,
  apiSecret: process.env.QUUB_API_SECRET,
  timeout: 30000, // 30 seconds

  // Retry configuration
  retry: {
    attempts: 3,
    delay: 1000,
    onRetry: (attempt, error) => {
      console.log(`Retry attempt ${attempt}: ${error.message}`);
    },
  },
});

// Custom axios instance with detailed logging
const httpClient = axios.create({
  timeout: 30000,
  headers: {
    "User-Agent": "MyApp/1.0",
  },
});

httpClient.interceptors.request.use((config) => {
  config.metadata = { startTime: Date.now() };
  console.log(`→ ${config.method.toUpperCase()} ${config.url}`);
  return config;
});

httpClient.interceptors.response.use(
  (response) => {
    const duration = Date.now() - response.config.metadata.startTime;
    console.log(`← ${response.status} ${response.config.url} (${duration}ms)`);
    return response;
  },
  (error) => {
    if (error.code === "ECONNABORTED") {
      console.error("❌ Request timeout");
    } else if (error.code === "ENOTFOUND") {
      console.error("❌ DNS resolution failed");
    } else if (error.code === "ECONNREFUSED") {
      console.error("❌ Connection refused");
    }
    throw error;
  }
);
```

---

## Data Synchronization

### Issue: Balance Mismatch

**Solution: Reconciliation Tool**

```javascript
class BalanceReconciliation {
  async reconcile() {
    console.log("🔍 Starting balance reconciliation...");

    // 1. Get Quub balances
    const quubBalances = await quubClient.custodian.getBalances();

    // 2. Get internal balances
    const internalBalances = await this.getInternalBalances();

    // 3. Compare
    const discrepancies = [];

    for (const quubBal of quubBalances) {
      const internalBal = internalBalances.find(
        (b) => b.currency === quubBal.currency
      );

      if (!internalBal) {
        discrepancies.push({
          currency: quubBal.currency,
          issue: "missing_internal",
          quubBalance: quubBal.total,
        });
        continue;
      }

      const diff = Math.abs(
        parseFloat(quubBal.total) - parseFloat(internalBal.total)
      );

      if (diff > 0.00000001) {
        // Account for floating point precision
        discrepancies.push({
          currency: quubBal.currency,
          issue: "mismatch",
          quubBalance: quubBal.total,
          internalBalance: internalBal.total,
          difference: diff,
        });
      }
    }

    // 4. Report
    if (discrepancies.length === 0) {
      console.log("✅ All balances match");
    } else {
      console.error("❌ Discrepancies found:");
      console.table(discrepancies);

      // 5. Auto-fix if possible
      await this.attemptAutoFix(discrepancies);
    }

    return discrepancies;
  }

  async attemptAutoFix(discrepancies) {
    for (const disc of discrepancies) {
      if (disc.issue === "mismatch") {
        console.log(`🔧 Attempting to fix ${disc.currency}...`);

        // Fetch transaction history
        const transactions = await quubClient.custodian.getTransactions({
          currency: disc.currency,
          limit: 1000,
        });

        // Recalculate balance
        const recalculated =
          this.calculateBalanceFromTransactions(transactions);

        // Update internal DB
        await this.updateInternalBalance(disc.currency, recalculated);

        console.log(`✅ Fixed ${disc.currency} balance`);
      }
    }
  }
}
```

---

## Getting Additional Help

### Enable Debug Logging

```javascript
// Enable verbose logging
const quubClient = new QuubClient({
  apiKey: process.env.QUUB_API_KEY,
  apiSecret: process.env.QUUB_API_SECRET,
  debug: true,
  logLevel: "verbose",
});

// Custom logger
quubClient.on("request", (config) => {
  console.log("API Request:", {
    method: config.method,
    url: config.url,
    params: config.params,
  });
});

quubClient.on("response", (response) => {
  console.log("API Response:", {
    status: response.status,
    data: response.data,
  });
});

quubClient.on("error", (error) => {
  console.error("API Error:", {
    code: error.code,
    message: error.message,
    stack: error.stack,
  });
});
```

### Contact Support

When contacting support, include:

```javascript
async function generateSupportReport() {
  const report = {
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    sdkVersion: quubClient.version,
    nodeVersion: process.version,
    platform: process.platform,

    // Recent errors
    recentErrors: await this.getRecentErrors(),

    // API key info (DO NOT include the actual key)
    apiKeyInfo: {
      keyIdPrefix: process.env.QUUB_API_KEY?.substring(0, 10),
      orgId: process.env.QUUB_ORG_ID,
    },

    // System health
    healthCheck: await this.performHealthCheck(),
  };

  console.log("Support Report:", JSON.stringify(report, null, 2));
  return report;
}
```

---

**Still Having Issues?** Contact support@quub.fi with your support report
