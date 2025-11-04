---
layout: docs
title: Integration Guide
permalink: /guides/getting-started/integration-guide/
description: Step-by-step guide to integrate Quub Exchange into your application
---

# Integration Guide

Comprehensive guide for integrating Quub Exchange services into your application. This guide covers architecture planning, implementation strategies, and production deployment.

## Table of Contents

1. [Integration Planning](#integration-planning)
2. [Architecture Patterns](#architecture-patterns)
3. [Authentication Setup](#authentication-setup)
4. [Core Services Integration](#core-services-integration)
5. [Error Handling](#error-handling)
6. [Testing Strategy](#testing-strategy)
7. [Production Deployment](#production-deployment)

---

## Integration Planning

### 1. Define Your Requirements

Before integrating, identify which Quub Exchange capabilities you need:

**Trading Platform:**

- ✅ Exchange API (order management, market data)
- ✅ Custodian API (wallet management)
- ✅ Market Oracles (price feeds)
- ✅ Risk & Limits (position management)

**Compliance Platform:**

- ✅ Identity Service (KYC/KYB)
- ✅ Compliance API (transaction monitoring)
- ✅ Documents (regulatory filings)

**Enterprise Infrastructure:**

- ✅ Treasury (liquidity management)
- ✅ Settlements (clearing & settlement)
- ✅ Analytics & Reports (business intelligence)

### 2. Choose Your Integration Approach

#### Option A: SDK Integration (Recommended)

**Pros:**

- Type-safe interfaces
- Automatic retries and error handling
- WebSocket management
- Built-in rate limiting

**Best for:** Most applications

```bash
npm install @quub/sdk
# or
pip install quub-sdk
```

#### Option B: Direct REST API

**Pros:**

- Maximum flexibility
- Language agnostic
- No dependencies

**Best for:** Custom implementations, non-Node.js/Python environments

#### Option C: GraphQL API

**Pros:**

- Query exactly what you need
- Single endpoint
- Strongly typed schema

**Best for:** Complex data requirements, mobile apps

---

## Architecture Patterns

### Pattern 1: Microservices Architecture

```
┌─────────────────┐
│   Your App      │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼──┐  ┌──▼───┐  ┌────────┐
│Trade │  │User  │  │Reports │
│Service│  │Service│  │Service │
└───┬──┘  └──┬───┘  └───┬────┘
    │        │          │
    └────────┼──────────┘
             │
      ┌──────▼────────┐
      │  Quub Exchange│
      └───────────────┘
```

**Implementation:**

```javascript
// services/trading-service.js
import { QuubClient } from '@quub/sdk';

export class TradingService {
  constructor() {
    this.client = new QuubClient({
      apiKey: process.env.QUUB_API_KEY,
      apiSecret: process.env.QUUB_API_SECRET,
      orgId: process.env.QUUB_ORG_ID
    });
  }

  async placeOrder(params) {
    return await this.client.exchange.createOrder(params);
  }

  async getPortfolio() {
    return await this.client.custodian.getBalances();
  }
}

// services/user-service.js
export class UserService {
  constructor() {
    this.client = new QuubClient({...});
  }

  async verifyUser(userId) {
    return await this.client.identity.verifyIdentity(userId);
  }
}
```

### Pattern 2: Event-Driven Architecture

```
┌─────────────┐       ┌──────────────┐
│  Your App   │──────▶│ Event Queue  │
└─────────────┘       │  (RabbitMQ)  │
                      └──────┬───────┘
                             │
                      ┌──────▼───────┐
                      │ Event Handler│
                      └──────┬───────┘
                             │
                      ┌──────▼────────┐
                      │ Quub Exchange │
                      └───────────────┘
```

**Implementation:**

```javascript
import { QuubClient } from '@quub/sdk';
import { EventEmitter } from 'events';

class TradingEventHandler extends EventEmitter {
  constructor() {
    super();
    this.client = new QuubClient({...});
    this.setupListeners();
  }

  setupListeners() {
    this.on('order:create', this.handleOrderCreate.bind(this));
    this.on('order:cancel', this.handleOrderCancel.bind(this));
    this.on('balance:check', this.handleBalanceCheck.bind(this));
  }

  async handleOrderCreate(orderData) {
    try {
      const order = await this.client.exchange.createOrder(orderData);
      this.emit('order:created', order);
    } catch (error) {
      this.emit('order:failed', error);
    }
  }
}

// Usage
const handler = new TradingEventHandler();
handler.emit('order:create', {
  symbol: 'BTC-USD',
  side: 'buy',
  type: 'market',
  quantity: '0.01'
});
```

### Pattern 3: Gateway/BFF Pattern

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│ Web App  │  │Mobile App│  │ Desktop  │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │             │
     └──────────┬──┴─────────────┘
                │
         ┌──────▼──────┐
         │   API GW    │
         │    (BFF)    │
         └──────┬──────┘
                │
         ┌──────▼────────┐
         │ Quub Exchange │
         └───────────────┘
```

**Implementation:**

```javascript
// api-gateway/routes/trading.js
import express from 'express';
import { QuubClient } from '@quub/sdk';

const router = express.Router();
const quub = new QuubClient({...});

// Simplified endpoint for mobile
router.post('/quick-buy', async (req, res) => {
  const { symbol, amount } = req.body;

  try {
    // Get current price
    const market = await quub.exchange.getMarket(symbol);

    // Calculate quantity
    const quantity = (amount / market.price).toFixed(8);

    // Place order
    const order = await quub.exchange.createOrder({
      symbol,
      side: 'buy',
      type: 'market',
      quantity
    });

    res.json({
      success: true,
      orderId: order.orderId,
      executedPrice: order.executedPrice,
      quantity: order.executedQuantity
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
```

---

## Authentication Setup

### JWT Token Management

```javascript
class QuubAuthManager {
  constructor(apiKey, apiSecret, orgId) {
    this.apiKey = apiKey;
    this.apiSecret = apiSecret;
    this.orgId = orgId;
    this.token = null;
    this.expiresAt = null;
  }

  async getToken() {
    // Return cached token if still valid
    if (this.token && Date.now() < this.expiresAt - 60000) {
      return this.token;
    }

    // Request new token
    const response = await fetch("https://api.quub.fi/v1/auth/token", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        apiKey: this.apiKey,
        apiSecret: this.apiSecret,
        orgId: this.orgId,
      }),
    });

    const data = await response.json();
    this.token = data.accessToken;
    this.expiresAt = Date.now() + data.expiresIn * 1000;

    return this.token;
  }

  async refreshToken() {
    this.token = null;
    return await this.getToken();
  }
}

// Usage
const authManager = new QuubAuthManager(
  process.env.QUUB_API_KEY,
  process.env.QUUB_API_SECRET,
  process.env.QUUB_ORG_ID
);

const token = await authManager.getToken();
```

### API Key Rotation

```javascript
class ApiKeyRotation {
  constructor() {
    this.primaryKey = process.env.QUUB_API_KEY_PRIMARY;
    this.secondaryKey = process.env.QUUB_API_KEY_SECONDARY;
    this.currentKey = 'primary';
  }

  async rotateKeys() {
    console.log('🔄 Starting API key rotation...');

    // Switch to secondary key
    this.currentKey = 'secondary';

    // Verify secondary key works
    const testClient = new QuubClient({
      apiKey: this.secondaryKey,
      ...
    });

    await testClient.auth.getIdentity();
    console.log('✅ Secondary key verified');

    // Revoke primary key
    await this.revokePrimaryKey();

    // Generate new primary key
    const newPrimaryKey = await this.generateNewKey();

    // Update environment/secret manager
    await this.updateKeyInSecretManager(newPrimaryKey);

    console.log('✅ Key rotation complete');
  }
}
```

---

## Core Services Integration

### Exchange Integration

```javascript
class ExchangeIntegration {
  constructor(quubClient) {
    this.client = quubClient;
  }

  // Market data streaming
  async subscribeToMarketData(symbols) {
    const ws = await this.client.exchange.connectWebSocket();

    ws.subscribe("market.ticker", symbols, (data) => {
      this.handleTickerUpdate(data);
    });

    ws.subscribe("market.orderbook", symbols, (data) => {
      this.handleOrderBookUpdate(data);
    });

    return ws;
  }

  // Order management
  async placeOrderWithChecks(orderParams) {
    // 1. Pre-flight checks
    await this.checkBalance(orderParams);
    await this.checkRiskLimits(orderParams);

    // 2. Place order
    const order = await this.client.exchange.createOrder(orderParams);

    // 3. Monitor execution
    return await this.monitorOrderExecution(order.orderId);
  }

  async checkBalance(orderParams) {
    const balance = await this.client.custodian.getBalance(
      orderParams.side === "buy"
        ? orderParams.quoteCurrency
        : orderParams.baseCurrency
    );

    const required =
      orderParams.side === "buy"
        ? parseFloat(orderParams.quantity) * parseFloat(orderParams.price)
        : parseFloat(orderParams.quantity);

    if (parseFloat(balance.available) < required) {
      throw new Error("Insufficient balance");
    }
  }
}
```

### Custodian Integration

```javascript
class CustodianIntegration {
  constructor(quubClient) {
    this.client = quubClient;
  }

  // Multi-sig wallet setup
  async createMultiSigWallet(params) {
    const wallet = await this.client.custodian.createWallet({
      name: params.name,
      type: "multi_sig",
      requiredSignatures: params.requiredSigs,
      signers: params.signerPublicKeys,
      currency: params.currency,
    });

    return wallet;
  }

  // Withdrawal workflow
  async initiateWithdrawal(params) {
    // 1. Create withdrawal request
    const withdrawal = await this.client.custodian.createWithdrawal({
      walletId: params.walletId,
      toAddress: params.destinationAddress,
      amount: params.amount,
      currency: params.currency,
    });

    // 2. Get approval workflow
    const approvers = await this.getRequiredApprovers(withdrawal.id);

    // 3. Notify approvers
    await this.notifyApprovers(approvers, withdrawal);

    return withdrawal;
  }

  // Balance reconciliation
  async reconcileBalances() {
    const quubBalances = await this.client.custodian.getBalances();
    const internalBalances = await this.getInternalBalances();

    const discrepancies = [];

    for (const quubBal of quubBalances) {
      const internalBal = internalBalances.find(
        (b) => b.currency === quubBal.currency
      );

      if (!internalBal || internalBal.total !== quubBal.total) {
        discrepancies.push({
          currency: quubBal.currency,
          quubBalance: quubBal.total,
          internalBalance: internalBal?.total || "0",
          difference:
            parseFloat(quubBal.total) - parseFloat(internalBal?.total || "0"),
        });
      }
    }

    if (discrepancies.length > 0) {
      await this.alertFinanceTeam(discrepancies);
    }

    return discrepancies;
  }
}
```

---

## Error Handling

### Retry Strategy

```javascript
class RetryHandler {
  async executeWithRetry(fn, options = {}) {
    const {
      maxRetries = 3,
      initialDelay = 1000,
      maxDelay = 10000,
      backoffMultiplier = 2,
      retryableErrors = [429, 500, 502, 503, 504],
    } = options;

    let lastError;
    let delay = initialDelay;

    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;

        // Don't retry on client errors (except rate limits)
        if (error.statusCode && !retryableErrors.includes(error.statusCode)) {
          throw error;
        }

        if (attempt < maxRetries) {
          console.log(
            `Retry attempt ${attempt + 1}/${maxRetries} after ${delay}ms`
          );
          await this.sleep(delay);
          delay = Math.min(delay * backoffMultiplier, maxDelay);
        }
      }
    }

    throw lastError;
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Usage
const retryHandler = new RetryHandler();

const order = await retryHandler.executeWithRetry(
  () => quubClient.exchange.createOrder(orderParams),
  { maxRetries: 3 }
);
```

### Circuit Breaker

```javascript
class CircuitBreaker {
  constructor(options = {}) {
    this.failureThreshold = options.failureThreshold || 5;
    this.resetTimeout = options.resetTimeout || 60000;
    this.state = "CLOSED";
    this.failures = 0;
    this.nextAttempt = Date.now();
  }

  async execute(fn) {
    if (this.state === "OPEN") {
      if (Date.now() < this.nextAttempt) {
        throw new Error("Circuit breaker is OPEN");
      }
      this.state = "HALF_OPEN";
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failures = 0;
    this.state = "CLOSED";
  }

  onFailure() {
    this.failures++;
    if (this.failures >= this.failureThreshold) {
      this.state = "OPEN";
      this.nextAttempt = Date.now() + this.resetTimeout;
      console.error("🔴 Circuit breaker OPEN");
    }
  }
}
```

---

## Testing Strategy

### Unit Testing

```javascript
// tests/trading.test.js
import { jest } from '@jest/globals';
import { TradingService } from '../services/trading-service.js';

describe('TradingService', () => {
  let tradingService;
  let mockQuubClient;

  beforeEach(() => {
    mockQuubClient = {
      exchange: {
        createOrder: jest.fn(),
        getMarket: jest.fn()
      }
    };

    tradingService = new TradingService();
    tradingService.client = mockQuubClient;
  });

  test('should place market order successfully', async () => {
    mockQuubClient.exchange.createOrder.mockResolvedValue({
      orderId: 'order_123',
      status: 'filled',
      executedPrice: '45000.00'
    });

    const result = await tradingService.placeOrder({
      symbol: 'BTC-USD',
      side: 'buy',
      type: 'market',
      quantity: '0.01'
    });

    expect(result.orderId).toBe('order_123');
    expect(mockQuubClient.exchange.createOrder).toHaveBeenCalledTimes(1);
  });

  test('should handle insufficient balance error', async () => {
    mockQuubClient.exchange.createOrder.mockRejectedValue(
      new Error('INSUFFICIENT_BALANCE')
    );

    await expect(
      tradingService.placeOrder({...})
    ).rejects.toThrow('INSUFFICIENT_BALANCE');
  });
});
```

### Integration Testing

```javascript
// tests/integration/exchange.integration.test.js
import { QuubClient } from "@quub/sdk";

describe("Exchange Integration", () => {
  let client;

  beforeAll(() => {
    client = new QuubClient({
      apiKey: process.env.TEST_API_KEY,
      apiSecret: process.env.TEST_API_SECRET,
      orgId: process.env.TEST_ORG_ID,
      environment: "sandbox",
    });
  });

  test("should fetch market data", async () => {
    const markets = await client.exchange.getMarkets();

    expect(Array.isArray(markets)).toBe(true);
    expect(markets.length).toBeGreaterThan(0);
    expect(markets[0]).toHaveProperty("symbol");
    expect(markets[0]).toHaveProperty("lastPrice");
  });

  test("should place and cancel order", async () => {
    // Place order
    const order = await client.exchange.createOrder({
      symbol: "BTC-USD",
      side: "buy",
      type: "limit",
      quantity: "0.001",
      price: "1000.00", // Far below market
      timeInForce: "GTC",
    });

    expect(order.orderId).toBeDefined();
    expect(order.status).toBe("open");

    // Cancel order
    const cancelled = await client.exchange.cancelOrder(order.orderId);
    expect(cancelled.status).toBe("cancelled");
  });
});
```

---

## Production Deployment

### Environment Configuration

```yaml
# config/production.yml
quub:
  environment: production
  api:
    base_url: https://api.quub.fi
    timeout: 30000
    retry:
      max_attempts: 3
      initial_delay: 1000
  websocket:
    url: wss://ws.quub.fi
    reconnect: true
    heartbeat_interval: 30000
  security:
    api_key_rotation_days: 90
    require_mfa: true
    ip_whitelist:
      - 203.0.113.0/24
      - 198.51.100.0/24
```

### Health Checks

```javascript
// health-check.js
export class HealthCheck {
  constructor(quubClient) {
    this.client = quubClient;
  }

  async check() {
    const results = {
      status: "healthy",
      timestamp: new Date().toISOString(),
      checks: {},
    };

    // Auth check
    try {
      await this.client.auth.getIdentity();
      results.checks.auth = { status: "up" };
    } catch (error) {
      results.checks.auth = { status: "down", error: error.message };
      results.status = "unhealthy";
    }

    // Exchange API check
    try {
      await this.client.exchange.getMarkets();
      results.checks.exchange = { status: "up" };
    } catch (error) {
      results.checks.exchange = { status: "down", error: error.message };
      results.status = "degraded";
    }

    // WebSocket check
    try {
      const ws = await this.client.exchange.connectWebSocket();
      ws.close();
      results.checks.websocket = { status: "up" };
    } catch (error) {
      results.checks.websocket = { status: "down", error: error.message };
    }

    return results;
  }
}
```

### Monitoring

```javascript
// monitoring.js
import { Counter, Histogram } from "prom-client";

export class QuubMetrics {
  constructor() {
    this.apiCalls = new Counter({
      name: "quub_api_calls_total",
      help: "Total Quub API calls",
      labelNames: ["method", "endpoint", "status"],
    });

    this.apiLatency = new Histogram({
      name: "quub_api_latency_seconds",
      help: "Quub API latency",
      labelNames: ["method", "endpoint"],
    });

    this.orderCount = new Counter({
      name: "quub_orders_total",
      help: "Total orders placed",
      labelNames: ["symbol", "side", "type", "status"],
    });
  }

  recordApiCall(method, endpoint, status, duration) {
    this.apiCalls.inc({ method, endpoint, status });
    this.apiLatency.observe({ method, endpoint }, duration / 1000);
  }

  recordOrder(symbol, side, type, status) {
    this.orderCount.inc({ symbol, side, type, status });
  }
}
```

---

## Next Steps

- **[Best Practices](../best-practices/)** - Coding standards and patterns
- **[Security Guide](../security-guide/)** - Secure your integration
- **[Performance Optimization](../performance-optimization/)** - Optimize for scale
- **[API Reference]({{ '/capabilities/' | relative_url }})** - Complete API docs

---

**Need Help?** Contact our integration team at integrations@quub.fi
