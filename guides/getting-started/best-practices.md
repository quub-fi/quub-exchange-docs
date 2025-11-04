---
layout: docs
title: Best Practices
permalink: /guides/getting-started/best-practices/
description: Best practices for building production-ready applications with Quub Exchange
---

# Best Practices

Industry-standard practices for building robust, scalable, and maintainable applications with Quub Exchange.

## Table of Contents

1. [API Design Principles](#api-design-principles)
2. [Error Handling](#error-handling)
3. [Rate Limiting](#rate-limiting)
4. [Data Management](#data-management)
5. [Security](#security)
6. [Performance](#performance)
7. [Monitoring & Logging](#monitoring--logging)

---

## API Design Principles

### 1. Idempotency

Always use idempotency keys for critical operations:

```javascript
// ✅ GOOD: Idempotent order placement
async function placeOrder(orderParams) {
  const idempotencyKey = `order-${Date.now()}-${randomUUID()}`;

  return await quubClient.exchange.createOrder({
    ...orderParams,
    idempotencyKey,
  });
}

// ❌ BAD: No idempotency protection
async function placeOrder(orderParams) {
  return await quubClient.exchange.createOrder(orderParams);
}
```

**Why it matters:** Network issues can cause duplicate requests. Idempotency keys ensure operations execute exactly once.

### 2. Pagination

Always implement pagination for list operations:

```javascript
// ✅ GOOD: Paginated fetching
async function getAllOrders() {
  const allOrders = [];
  let cursor = null;

  do {
    const response = await quubClient.exchange.getOrders({
      limit: 100,
      cursor,
    });

    allOrders.push(...response.orders);
    cursor = response.nextCursor;
  } while (cursor);

  return allOrders;
}

// ❌ BAD: Fetching all at once
async function getAllOrders() {
  return await quubClient.exchange.getOrders({ limit: 10000 });
}
```

### 3. Field Selection

Request only the fields you need:

```javascript
// ✅ GOOD: Selective fields
const markets = await quubClient.exchange.getMarkets({
  fields: ["symbol", "lastPrice", "volume24h"],
});

// ❌ BAD: Fetching everything
const markets = await quubClient.exchange.getMarkets();
```

---

## Error Handling

### Categorize Errors

```javascript
class ErrorHandler {
  static categorizeError(error) {
    // Client errors (4xx) - Don't retry
    if (error.statusCode >= 400 && error.statusCode < 500) {
      if (error.statusCode === 429) {
        return {
          type: "RATE_LIMIT",
          retry: true,
          delay: error.retryAfter || 1000,
        };
      }
      return { type: "CLIENT_ERROR", retry: false };
    }

    // Server errors (5xx) - Retry with backoff
    if (error.statusCode >= 500) {
      return { type: "SERVER_ERROR", retry: true, delay: 1000 };
    }

    // Network errors - Retry
    if (error.code === "ECONNREFUSED" || error.code === "ETIMEDOUT") {
      return { type: "NETWORK_ERROR", retry: true, delay: 2000 };
    }

    // Unknown - Don't retry
    return { type: "UNKNOWN", retry: false };
  }

  static async handleError(error, operation) {
    const category = this.categorizeError(error);

    // Log error with context
    logger.error("API Error", {
      type: category.type,
      operation,
      statusCode: error.statusCode,
      message: error.message,
      stack: error.stack,
    });

    // Alert on critical errors
    if (category.type === "SERVER_ERROR") {
      await this.sendAlert({
        severity: "high",
        message: `Quub API server error: ${error.message}`,
        operation,
      });
    }

    return category;
  }
}

// Usage
try {
  await quubClient.exchange.createOrder(params);
} catch (error) {
  const errorCategory = await ErrorHandler.handleError(error, "createOrder");

  if (errorCategory.retry) {
    await sleep(errorCategory.delay);
    // Implement retry logic
  } else {
    throw error; // Re-throw non-retryable errors
  }
}
```

### Error Response Structure

```javascript
class ApiError extends Error {
  constructor(statusCode, code, message, details = {}) {
    super(message);
    this.name = "ApiError";
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    this.timestamp = new Date().toISOString();
  }

  toJSON() {
    return {
      error: {
        code: this.code,
        message: this.message,
        details: this.details,
        timestamp: this.timestamp,
      },
    };
  }
}

// Usage
if (!order.quantity || parseFloat(order.quantity) <= 0) {
  throw new ApiError(
    400,
    "INVALID_QUANTITY",
    "Order quantity must be greater than zero",
    { provided: order.quantity, minimum: 0.00000001 }
  );
}
```

---

## Rate Limiting

### Implement Token Bucket

```javascript
class RateLimiter {
  constructor(maxTokens, refillRate) {
    this.maxTokens = maxTokens; // e.g., 100
    this.refillRate = refillRate; // tokens per second
    this.tokens = maxTokens;
    this.lastRefill = Date.now();
  }

  async acquire(tokens = 1) {
    await this.refill();

    if (this.tokens < tokens) {
      const waitTime = ((tokens - this.tokens) / this.refillRate) * 1000;
      await this.sleep(waitTime);
      await this.refill();
    }

    this.tokens -= tokens;
  }

  async refill() {
    const now = Date.now();
    const timePassed = (now - this.lastRefill) / 1000;
    const tokensToAdd = timePassed * this.refillRate;

    this.tokens = Math.min(this.maxTokens, this.tokens + tokensToAdd);
    this.lastRefill = now;
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Usage
const rateLimiter = new RateLimiter(100, 10); // 100 tokens, refill 10/sec

async function makeApiCall() {
  await rateLimiter.acquire(1);
  return await quubClient.exchange.getMarkets();
}
```

### Respect Rate Limit Headers

```javascript
class RateLimitAwareClient {
  constructor(quubClient) {
    this.client = quubClient;
    this.rateLimitRemaining = null;
    this.rateLimitReset = null;
  }

  async call(method, ...args) {
    // Check if we're close to rate limit
    if (this.rateLimitRemaining !== null && this.rateLimitRemaining < 10) {
      const waitTime = this.rateLimitReset - Date.now();
      if (waitTime > 0) {
        console.log(`⏳ Rate limit approaching, waiting ${waitTime}ms`);
        await this.sleep(waitTime);
      }
    }

    try {
      const response = await method.apply(this.client, args);

      // Update rate limit info from headers
      this.rateLimitRemaining = response.headers?.["x-ratelimit-remaining"];
      this.rateLimitReset =
        parseInt(response.headers?.["x-ratelimit-reset"]) * 1000;

      return response.data;
    } catch (error) {
      if (error.statusCode === 429) {
        const retryAfter = parseInt(error.headers?.["retry-after"]) || 60;
        console.log(`⛔ Rate limited, retrying after ${retryAfter}s`);
        await this.sleep(retryAfter * 1000);
        return this.call(method, ...args);
      }
      throw error;
    }
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
```

---

## Data Management

### Caching Strategy

```javascript
import NodeCache from 'node-cache';

class CacheManager {
  constructor() {
    this.cache = new NodeCache({
      stdTTL: 60, // Default 60 seconds
      checkperiod: 120
    });
  }

  // Cache market data (changes frequently)
  async getMarketData(symbol) {
    const cacheKey = `market:${symbol}`;
    let data = this.cache.get(cacheKey);

    if (!data) {
      data = await quubClient.exchange.getMarket(symbol);
      this.cache.set(cacheKey, data, 5); // 5 second TTL
    }

    return data;
  }

  // Cache reference data (changes rarely)
  async getAssetInfo(assetId) {
    const cacheKey = `asset:${assetId}`;
    let data = this.cache.get(cacheKey);

    if (!data) {
      data = await quubClient.pricingRefData.getAsset(assetId);
      this.cache.set(cacheKey, data, 3600); // 1 hour TTL
    }

    return data;
  }

  // Invalidate cache on updates
  invalidate(pattern) {
    const keys = this.cache.keys();
    keys.filter(k => k.startsWith(pattern)).forEach(k => this.cache.del(k));
  }
}

// Usage
const cacheManager = new CacheManager();

// Fast repeated access
const market1 = await cacheManager.getMarketData('BTC-USD'); // API call
const market2 = await cacheManager.getMarketData('BTC-USD'); // From cache

// Invalidate after order
await quubClient.exchange.createOrder({...});
cacheManager.invalidate('market:');
```

### Database Design

```sql
-- Order tracking table
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quub_order_id VARCHAR(64) UNIQUE NOT NULL,
  user_id UUID NOT NULL,
  symbol VARCHAR(20) NOT NULL,
  side VARCHAR(4) NOT NULL CHECK (side IN ('buy', 'sell')),
  type VARCHAR(10) NOT NULL,
  quantity DECIMAL(20, 8) NOT NULL,
  price DECIMAL(20, 8),
  status VARCHAR(20) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  filled_at TIMESTAMP,

  -- Indexes for common queries
  INDEX idx_user_orders (user_id, created_at DESC),
  INDEX idx_symbol_orders (symbol, created_at DESC),
  INDEX idx_status (status, created_at DESC)
);

-- Balance snapshots for reconciliation
CREATE TABLE balance_snapshots (
  id SERIAL PRIMARY KEY,
  wallet_id UUID NOT NULL,
  currency VARCHAR(10) NOT NULL,
  total_balance DECIMAL(20, 8) NOT NULL,
  available_balance DECIMAL(20, 8) NOT NULL,
  reserved_balance DECIMAL(20, 8) NOT NULL,
  snapshot_time TIMESTAMP NOT NULL DEFAULT NOW(),

  INDEX idx_wallet_snapshots (wallet_id, snapshot_time DESC)
);
```

---

## Security

### API Key Management

```javascript
// ✅ GOOD: Keys in environment variables
const quubClient = new QuubClient({
  apiKey: process.env.QUUB_API_KEY,
  apiSecret: process.env.QUUB_API_SECRET,
  orgId: process.env.QUUB_ORG_ID,
});

// ❌ BAD: Hardcoded keys
const quubClient = new QuubClient({
  apiKey: "qk_live_abc123...",
  apiSecret: "sk_live_xyz789...",
});
```

### Secure Key Storage

```javascript
// Using AWS Secrets Manager
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";

async function getQuubCredentials() {
  const client = new SecretsManagerClient({ region: "us-east-1" });

  const response = await client.send(
    new GetSecretValueCommand({ SecretId: "prod/quub/api-keys" })
  );

  return JSON.parse(response.SecretString);
}

// Usage
const credentials = await getQuubCredentials();
const quubClient = new QuubClient(credentials);
```

### Request Signing

```javascript
import crypto from "crypto";

function signRequest(method, path, body, secret) {
  const timestamp = Date.now();
  const payload = `${timestamp}${method}${path}${JSON.stringify(body)}`;

  const signature = crypto
    .createHmac("sha256", secret)
    .update(payload)
    .digest("hex");

  return {
    timestamp,
    signature,
  };
}

// Usage
const { timestamp, signature } = signRequest(
  "POST",
  "/v1/orders",
  orderData,
  apiSecret
);

await fetch("https://api.quub.fi/v1/orders", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-API-Key": apiKey,
    "X-Timestamp": timestamp,
    "X-Signature": signature,
  },
  body: JSON.stringify(orderData),
});
```

---

## Performance

### Connection Pooling

```javascript
import { Agent } from "https";

const httpsAgent = new Agent({
  keepAlive: true,
  maxSockets: 50,
  maxFreeSockets: 10,
  timeout: 60000,
  keepAliveMsecs: 30000,
});

const quubClient = new QuubClient({
  apiKey: process.env.QUUB_API_KEY,
  apiSecret: process.env.QUUB_API_SECRET,
  httpAgent: httpsAgent,
});
```

### Batch Operations

```javascript
// ✅ GOOD: Batch processing
async function processOrders(orderIds) {
  const BATCH_SIZE = 50;
  const results = [];

  for (let i = 0; i < orderIds.length; i += BATCH_SIZE) {
    const batch = orderIds.slice(i, i + BATCH_SIZE);

    const batchResults = await Promise.all(
      batch.map((id) => quubClient.exchange.getOrder(id))
    );

    results.push(...batchResults);

    // Rate limiting pause
    if (i + BATCH_SIZE < orderIds.length) {
      await sleep(100);
    }
  }

  return results;
}

// ❌ BAD: Sequential processing
async function processOrders(orderIds) {
  const results = [];
  for (const id of orderIds) {
    const order = await quubClient.exchange.getOrder(id);
    results.push(order);
  }
  return results;
}
```

### WebSocket for Real-Time Data

```javascript
// ✅ GOOD: WebSocket for frequent updates
const ws = await quubClient.exchange.connectWebSocket();

ws.subscribe("market.ticker", ["BTC-USD", "ETH-USD"], (ticker) => {
  updateUI(ticker);
});

// ❌ BAD: Polling for updates
setInterval(async () => {
  const btc = await quubClient.exchange.getMarket("BTC-USD");
  const eth = await quubClient.exchange.getMarket("ETH-USD");
  updateUI({ btc, eth });
}, 1000); // Wasteful and slow
```

---

## Monitoring & Logging

### Structured Logging

```javascript
import winston from "winston";

const logger = winston.createLogger({
  level: "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: "quub-integration" },
  transports: [
    new winston.transports.File({ filename: "error.log", level: "error" }),
    new winston.transports.File({ filename: "combined.log" }),
  ],
});

// Log API calls
logger.info("API Call", {
  method: "POST",
  endpoint: "/v1/orders",
  params: { symbol: "BTC-USD", side: "buy" },
  duration: 145,
  statusCode: 201,
});

// Log errors with context
logger.error("Order Failed", {
  error: error.message,
  errorCode: error.code,
  orderId: orderParams.id,
  userId: user.id,
  stack: error.stack,
});
```

### Metrics Collection

```javascript
import { Counter, Histogram, Gauge } from "prom-client";

const metrics = {
  apiCalls: new Counter({
    name: "quub_api_calls_total",
    help: "Total API calls",
    labelNames: ["endpoint", "method", "status"],
  }),

  apiDuration: new Histogram({
    name: "quub_api_duration_seconds",
    help: "API call duration",
    labelNames: ["endpoint", "method"],
    buckets: [0.1, 0.5, 1, 2, 5],
  }),

  activeOrders: new Gauge({
    name: "quub_active_orders",
    help: "Number of active orders",
    labelNames: ["symbol"],
  }),
};

// Record metrics
const timer = metrics.apiDuration.startTimer();
try {
  const response = await quubClient.exchange.createOrder(params);
  metrics.apiCalls.inc({
    endpoint: "/orders",
    method: "POST",
    status: "success",
  });
  return response;
} catch (error) {
  metrics.apiCalls.inc({
    endpoint: "/orders",
    method: "POST",
    status: "error",
  });
  throw error;
} finally {
  timer({ endpoint: "/orders", method: "POST" });
}
```

### Health Monitoring

```javascript
class HealthMonitor {
  async checkHealth() {
    const checks = await Promise.allSettled([
      this.checkApiConnection(),
      this.checkWebSocket(),
      this.checkDatabase(),
      this.checkCache(),
    ]);

    const results = {
      status: checks.every((c) => c.status === "fulfilled")
        ? "healthy"
        : "degraded",
      timestamp: new Date().toISOString(),
      checks: {
        api: checks[0],
        websocket: checks[1],
        database: checks[2],
        cache: checks[3],
      },
    };

    if (results.status === "degraded") {
      await this.sendAlert(results);
    }

    return results;
  }

  async checkApiConnection() {
    const start = Date.now();
    await quubClient.auth.getIdentity();
    return { status: "up", latency: Date.now() - start };
  }
}

// Run health checks every 30 seconds
setInterval(async () => {
  const health = await new HealthMonitor().checkHealth();
  logger.info("Health Check", health);
}, 30000);
```

---

## Code Quality

### TypeScript Types

```typescript
// ✅ GOOD: Strongly typed
interface OrderParams {
  symbol: string;
  side: "buy" | "sell";
  type: "market" | "limit";
  quantity: string;
  price?: string;
  timeInForce?: "GTC" | "IOC" | "FOK";
}

async function placeOrder(params: OrderParams): Promise<Order> {
  return await quubClient.exchange.createOrder(params);
}

// ❌ BAD: No type safety
async function placeOrder(params: any): Promise<any> {
  return await quubClient.exchange.createOrder(params);
}
```

### Input Validation

```javascript
import Joi from "joi";

const orderSchema = Joi.object({
  symbol: Joi.string()
    .pattern(/^[A-Z]+-[A-Z]+$/)
    .required(),
  side: Joi.string().valid("buy", "sell").required(),
  type: Joi.string().valid("market", "limit").required(),
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

async function placeOrder(params) {
  // Validate input
  const { error, value } = orderSchema.validate(params);
  if (error) {
    throw new ValidationError(error.details[0].message);
  }

  return await quubClient.exchange.createOrder(value);
}
```

---

## Next Steps

- **[Security Guide](../security-guide/)** - Advanced security practices
- **[Performance Optimization](../performance-optimization/)** - Scale your application
- **[Troubleshooting](../troubleshooting/)** - Debug common issues

---

**Questions?** Contact our support team at support@quub.fi
