---
layout: docs
title: Best Practices
description: Production-ready patterns and recommendations
---

# Best Practices

Build robust, secure, and performant integrations with Quub Exchange by following these best practices.

## Security

### 1. Credential Management

✅ **DO:**

- Store API keys in environment variables or secrets manager
- Use separate keys for development, staging, and production
- Rotate API keys regularly (every 90 days)
- Implement the principle of least privilege

❌ **DON'T:**

- Hardcode credentials in source code
- Commit secrets to version control
- Share API keys between environments
- Use admin keys for routine operations

### 2. Authentication

```javascript
// ✅ Good: Auto-refresh tokens
class AuthManager {
  async getToken() {
    if (this.isExpiringSoon()) {
      await this.refreshToken();
    }
    return this.accessToken;
  }
}

// ❌ Bad: Let tokens expire
const token = await login();
// Use token forever without checking expiry
```

### 3. HTTPS Only

```javascript
// ✅ Always use HTTPS
const API_BASE = "https://api.quub.exchange";

// ❌ Never use HTTP
const API_BASE = "http://api.quub.exchange"; // WRONG!
```

## Error Handling

### Retry Logic with Exponential Backoff

```javascript
async function retryWithBackoff(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;

      // Don't retry on client errors (4xx)
      if (error.response?.status >= 400 && error.response?.status < 500) {
        throw error;
      }

      // Exponential backoff: 1s, 2s, 4s
      const delay = Math.pow(2, i) * 1000;
      await sleep(delay);
    }
  }
}
```

### Graceful Degradation

```javascript
async function getMarketPrice(symbol) {
  try {
    const response = await api.get(`/pricing-refdata/v1/prices/${symbol}`);
    return response.data.price;
  } catch (error) {
    // Log error
    logger.error("Failed to fetch price", { symbol, error });

    // Return cached price if available
    const cached = cache.get(`price:${symbol}`);
    if (cached) {
      logger.warn("Using cached price", { symbol });
      return cached;
    }

    // Throw if no fallback
    throw error;
  }
}
```

## Rate Limiting

### Implement Client-Side Rate Limiting

```javascript
class RateLimiter {
  constructor(maxRequests, windowMs) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.requests = [];
  }

  async acquire() {
    const now = Date.now();

    // Remove old requests outside window
    this.requests = this.requests.filter((time) => now - time < this.windowMs);

    // Check if limit exceeded
    if (this.requests.length >= this.maxRequests) {
      const oldestRequest = this.requests[0];
      const waitTime = this.windowMs - (now - oldestRequest);
      await sleep(waitTime);
      return this.acquire();
    }

    this.requests.push(now);
  }
}

// Usage
const limiter = new RateLimiter(100, 60000); // 100 req/min

async function makeRequest(endpoint) {
  await limiter.acquire();
  return api.get(endpoint);
}
```

### Handle 429 Responses

```javascript
async function apiRequest(endpoint) {
  try {
    return await api.get(endpoint);
  } catch (error) {
    if (error.response?.status === 429) {
      const retryAfter = error.response.headers["retry-after"] || 60;
      logger.warn(`Rate limited. Retrying after ${retryAfter}s`);
      await sleep(retryAfter * 1000);
      return apiRequest(endpoint); // Retry
    }
    throw error;
  }
}
```

## Idempotency

### Use Idempotency Keys for Mutations

```javascript
async function placeOrder(orderParams) {
  const idempotencyKey = generateIdempotencyKey(orderParams);

  return api.post("/exchange/v1/orders", orderParams, {
    headers: {
      "X-Idempotency-Key": idempotencyKey,
    },
  });
}

function generateIdempotencyKey(params) {
  // Use stable hash of order params
  return crypto
    .createHash("sha256")
    .update(JSON.stringify(params))
    .digest("hex");
}
```

## Performance

### Connection Pooling

```javascript
const axios = require("axios");
const http = require("http");
const https = require("https");

const client = axios.create({
  baseURL: "https://api.quub.exchange",
  httpAgent: new http.Agent({ keepAlive: true }),
  httpsAgent: new https.Agent({ keepAlive: true }),
  timeout: 30000,
});
```

### Caching

```javascript
const NodeCache = require("node-cache");
const cache = new NodeCache({ stdTTL: 60 }); // 60s TTL

async function getMarketData(symbol) {
  const cacheKey = `market:${symbol}`;

  // Check cache first
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  // Fetch from API
  const data = await api.get(`/market-oracles/v1/prices/${symbol}`);

  // Cache for future requests
  cache.set(cacheKey, data);

  return data;
}
```

### Batch Requests

```javascript
// ❌ Bad: Multiple requests
async function getMultipleOrders(orderIds) {
  const orders = [];
  for (const id of orderIds) {
    const order = await api.get(`/exchange/v1/orders/${id}`);
    orders.push(order);
  }
  return orders;
}

// ✅ Good: Single batch request
async function getMultipleOrders(orderIds) {
  return api.get("/exchange/v1/orders", {
    params: { ids: orderIds.join(",") },
  });
}
```

## Monitoring & Observability

### Structured Logging

```javascript
const winston = require("winston");

const logger = winston.createLogger({
  format: winston.format.json(),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: "app.log" }),
  ],
});

// Log with context
logger.info("Order placed", {
  orderId: "ord_123",
  symbol: "BTC-USD",
  side: "buy",
  quantity: 0.1,
  userId: "usr_456",
});
```

### Metrics Collection

```javascript
const promClient = require("prom-client");

// Create metrics
const apiRequestDuration = new promClient.Histogram({
  name: "api_request_duration_seconds",
  help: "API request duration",
  labelNames: ["endpoint", "method", "status"],
});

const apiRequestTotal = new promClient.Counter({
  name: "api_request_total",
  help: "Total API requests",
  labelNames: ["endpoint", "method", "status"],
});

// Middleware to track metrics
async function makeRequest(endpoint, options) {
  const start = Date.now();

  try {
    const response = await api(endpoint, options);

    const duration = (Date.now() - start) / 1000;
    apiRequestDuration.observe(
      {
        endpoint,
        method: options.method,
        status: response.status,
      },
      duration
    );

    apiRequestTotal.inc({
      endpoint,
      method: options.method,
      status: response.status,
    });

    return response;
  } catch (error) {
    const status = error.response?.status || "error";
    apiRequestTotal.inc({ endpoint, method: options.method, status });
    throw error;
  }
}
```

### Health Checks

```javascript
app.get("/health", async (req, res) => {
  const health = {
    status: "healthy",
    timestamp: new Date().toISOString(),
    services: {},
  };

  try {
    // Check API connectivity
    await api.get("/health");
    health.services.quubApi = "up";
  } catch (error) {
    health.services.quubApi = "down";
    health.status = "unhealthy";
  }

  const statusCode = health.status === "healthy" ? 200 : 503;
  res.status(statusCode).json(health);
});
```

## Testing

### Unit Tests

```javascript
const { QuubClient } = require("./quub-client");
const nock = require("nock");

describe("QuubClient", () => {
  let client;

  beforeEach(() => {
    client = new QuubClient("test-key", "test-secret");
  });

  it("should place order successfully", async () => {
    nock("https://api.quub.exchange").post("/exchange/v1/orders").reply(200, {
      orderId: "ord_123",
      status: "open",
    });

    const order = await client.placeOrder({
      symbol: "BTC-USD",
      side: "buy",
      type: "limit",
      quantity: 0.1,
      price: 45000,
    });

    expect(order.orderId).toBe("ord_123");
    expect(order.status).toBe("open");
  });

  it("should handle rate limit errors", async () => {
    nock("https://api.quub.exchange")
      .post("/exchange/v1/orders")
      .reply(429, { error: "rate_limit_exceeded" });

    await expect(
      client.placeOrder({
        symbol: "BTC-USD",
        side: "buy",
      })
    ).rejects.toThrow("rate_limit_exceeded");
  });
});
```

### Integration Tests

```javascript
describe("Integration: Trading Flow", () => {
  let client;

  before(async () => {
    // Use sandbox environment
    client = new QuubClient(
      process.env.SANDBOX_API_KEY,
      process.env.SANDBOX_API_SECRET,
      { baseURL: "https://sandbox.api.quub.exchange" }
    );

    await client.login();
  });

  it("should complete full trading cycle", async () => {
    // 1. Check balance
    const balance = await client.getBalance("USD");
    expect(balance.available).toBeGreaterThan(1000);

    // 2. Place order
    const order = await client.placeOrder({
      symbol: "BTC-USD",
      side: "buy",
      type: "limit",
      quantity: 0.01,
      price: 40000,
    });
    expect(order.status).toBe("open");

    // 3. Cancel order
    await client.cancelOrder(order.orderId);

    // 4. Verify cancellation
    const updated = await client.getOrder(order.orderId);
    expect(updated.status).toBe("canceled");
  });
});
```

## Multi-Tenancy

### Always Include Tenant ID

```javascript
// ✅ Good: Explicit tenant ID
const config = {
  headers: {
    Authorization: `Bearer ${token}`,
    "X-Tenant-ID": orgId,
  },
};

// ❌ Bad: Missing tenant ID
const config = {
  headers: {
    Authorization: `Bearer ${token}`,
  },
};
```

### Validate Tenant Context

```javascript
class QuubClient {
  constructor(apiKey, apiSecret, orgId) {
    this.apiKey = apiKey;
    this.apiSecret = apiSecret;
    this.orgId = orgId;
  }

  async makeRequest(endpoint, options = {}) {
    // Always validate orgId is set
    if (!this.orgId) {
      throw new Error("Organization ID not set");
    }

    return axios({
      url: `${this.baseURL}${endpoint}`,
      ...options,
      headers: {
        Authorization: `Bearer ${this.accessToken}`,
        "X-Tenant-ID": this.orgId,
        ...options.headers,
      },
    });
  }
}
```

## WebSocket Connections

### Reconnection Logic

```javascript
class QuubWebSocket {
  constructor(url, token) {
    this.url = url;
    this.token = token;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.connect();
  }

  connect() {
    this.ws = new WebSocket(this.url);

    this.ws.onopen = () => {
      console.log("Connected");
      this.reconnectAttempts = 0;
      this.authenticate();
    };

    this.ws.onclose = () => {
      console.log("Disconnected");
      this.reconnect();
    };

    this.ws.onerror = (error) => {
      console.error("WebSocket error:", error);
    };
  }

  reconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error("Max reconnection attempts reached");
      return;
    }

    this.reconnectAttempts++;
    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);

    console.log(
      `Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`
    );
    setTimeout(() => this.connect(), delay);
  }

  authenticate() {
    this.ws.send(
      JSON.stringify({
        type: "auth",
        token: this.token,
      })
    );
  }
}
```

### Heartbeat/Ping

```javascript
class QuubWebSocket {
  startHeartbeat() {
    this.heartbeatInterval = setInterval(() => {
      if (this.ws.readyState === WebSocket.OPEN) {
        this.ws.send(JSON.stringify({ type: "ping" }));
      }
    }, 30000); // Every 30 seconds
  }

  stopHeartbeat() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
    }
  }
}
```

## Deployment

### Environment-Specific Configuration

```javascript
const config = {
  development: {
    apiUrl: "https://sandbox.api.quub.exchange",
    apiKey: process.env.DEV_API_KEY,
    logLevel: "debug",
  },
  staging: {
    apiUrl: "https://staging.api.quub.exchange",
    apiKey: process.env.STAGING_API_KEY,
    logLevel: "info",
  },
  production: {
    apiUrl: "https://api.quub.exchange",
    apiKey: process.env.PROD_API_KEY,
    logLevel: "warn",
  },
};

const env = process.env.NODE_ENV || "development";
module.exports = config[env];
```

### Circuit Breaker Pattern

```javascript
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.failureCount = 0;
    this.threshold = threshold;
    this.timeout = timeout;
    this.state = "CLOSED"; // CLOSED, OPEN, HALF_OPEN
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
    this.failureCount = 0;
    this.state = "CLOSED";
  }

  onFailure() {
    this.failureCount++;
    if (this.failureCount >= this.threshold) {
      this.state = "OPEN";
      this.nextAttempt = Date.now() + this.timeout;
    }
  }
}
```

## Related Resources

- 🔐 [Authentication Guide](../authentication/)
- 📊 [Rate Limiting](../rate-limits/)
- 🔔 [Webhooks](../webhooks/)
- 🚀 [Quick Start](../quickstart/)

## Support

Questions about best practices?

- 💬 [Community Forum](#)
- 📧 Email: support@quub.exchange
- 📚 [API Reference](../../api-reference/)
