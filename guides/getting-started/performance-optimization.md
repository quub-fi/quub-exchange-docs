---
layout: docs
title: Performance Optimization
permalink: /guides/getting-started/performance-optimization/
description: Optimize your Quub Exchange integration for maximum performance and scalability
---

# Performance Optimization

Strategies and techniques to optimize your Quub Exchange integration for speed, scalability, and efficiency.

## Table of Contents

1. [API Performance](#api-performance)
2. [Caching Strategies](#caching-strategies)
3. [Database Optimization](#database-optimization)
4. [WebSocket Optimization](#websocket-optimization)
5. [Load Testing](#load-testing)
6. [Monitoring & Profiling](#monitoring--profiling)
7. [Scalability Patterns](#scalability-patterns)

---

## API Performance

### Connection Pooling

```javascript
import { Agent as HttpsAgent } from "https";
import { Agent as HttpAgent } from "http";

// Configure connection pooling
const httpsAgent = new HttpsAgent({
  keepAlive: true,
  keepAliveMsecs: 30000,
  maxSockets: 50, // Max concurrent connections
  maxFreeSockets: 10, // Keep 10 idle connections
  timeout: 60000, // 60 second timeout
  scheduling: "lifo", // Last In First Out for better cache locality
});

const quubClient = new QuubClient({
  apiKey: process.env.QUUB_API_KEY,
  apiSecret: process.env.QUUB_API_SECRET,
  httpAgent: httpsAgent,
});

// Monitor connection usage
setInterval(() => {
  console.log("Connection Pool Stats:", {
    sockets: Object.keys(httpsAgent.sockets).length,
    freeSockets: Object.keys(httpsAgent.freeSockets).length,
    requests: Object.keys(httpsAgent.requests).length,
  });
}, 60000);
```

### Request Batching

```javascript
class BatchRequestManager {
  constructor(quubClient, options = {}) {
    this.client = quubClient;
    this.batchSize = options.batchSize || 50;
    this.batchDelay = options.batchDelay || 100; // ms
    this.queue = [];
    this.processing = false;
  }

  async getOrder(orderId) {
    return new Promise((resolve, reject) => {
      this.queue.push({ orderId, resolve, reject });

      if (!this.processing) {
        setTimeout(() => this.processBatch(), this.batchDelay);
        this.processing = true;
      }
    });
  }

  async processBatch() {
    if (this.queue.length === 0) {
      this.processing = false;
      return;
    }

    const batch = this.queue.splice(0, this.batchSize);
    const orderIds = batch.map((item) => item.orderId);

    try {
      // Fetch all orders in one request
      const orders = await this.client.exchange.getOrders({
        orderIds: orderIds.join(","),
      });

      // Resolve each promise
      batch.forEach((item) => {
        const order = orders.find((o) => o.orderId === item.orderId);
        if (order) {
          item.resolve(order);
        } else {
          item.reject(new Error(`Order ${item.orderId} not found`));
        }
      });
    } catch (error) {
      // Reject all promises in batch
      batch.forEach((item) => item.reject(error));
    }

    // Process next batch
    if (this.queue.length > 0) {
      setTimeout(() => this.processBatch(), this.batchDelay);
    } else {
      this.processing = false;
    }
  }
}

// Usage
const batchManager = new BatchRequestManager(quubClient);

// These will be batched into a single request
const [order1, order2, order3] = await Promise.all([
  batchManager.getOrder("order_1"),
  batchManager.getOrder("order_2"),
  batchManager.getOrder("order_3"),
]);
```

### Parallel Requests

```javascript
// ✅ GOOD: Parallel independent requests
async function loadDashboard() {
  const start = Date.now();

  const [markets, balances, openOrders, recentTrades] = await Promise.all([
    quubClient.exchange.getMarkets(),
    quubClient.custodian.getBalances(),
    quubClient.exchange.getOrders({ status: "open" }),
    quubClient.exchange.getTrades({ limit: 10 }),
  ]);

  console.log(`✅ Dashboard loaded in ${Date.now() - start}ms`);

  return { markets, balances, openOrders, recentTrades };
}

// ❌ BAD: Sequential requests
async function loadDashboardSlow() {
  const start = Date.now();

  const markets = await quubClient.exchange.getMarkets();
  const balances = await quubClient.custodian.getBalances();
  const openOrders = await quubClient.exchange.getOrders({ status: "open" });
  const recentTrades = await quubClient.exchange.getTrades({ limit: 10 });

  console.log(`⏱️ Dashboard loaded in ${Date.now() - start}ms`);

  return { markets, balances, openOrders, recentTrades };
}

// Benchmark: Parallel is typically 4-5x faster
```

### Request Compression

```javascript
import compression from "compression";
import axios from "axios";

// Enable request/response compression
const httpClient = axios.create({
  headers: {
    "Accept-Encoding": "gzip, deflate, br",
  },
  decompress: true,
});

// For Express API
app.use(
  compression({
    level: 6, // Compression level (0-9)
    threshold: 1024, // Only compress responses > 1KB
    filter: (req, res) => {
      if (req.headers["x-no-compression"]) {
        return false;
      }
      return compression.filter(req, res);
    },
  })
);
```

---

## Caching Strategies

### Multi-Layer Caching

```javascript
import NodeCache from "node-cache";
import Redis from "ioredis";

class MultiLayerCache {
  constructor() {
    // L1: In-memory cache (fast, limited size)
    this.l1Cache = new NodeCache({
      stdTTL: 60,
      maxKeys: 1000,
    });

    // L2: Redis cache (shared, larger capacity)
    this.l2Cache = new Redis({
      host: process.env.REDIS_HOST,
      port: process.env.REDIS_PORT,
      maxRetriesPerRequest: 3,
    });
  }

  async get(key) {
    // Try L1 cache first
    let value = this.l1Cache.get(key);
    if (value) {
      console.log("✅ L1 cache hit:", key);
      return value;
    }

    // Try L2 cache
    const cached = await this.l2Cache.get(key);
    if (cached) {
      console.log("✅ L2 cache hit:", key);
      value = JSON.parse(cached);

      // Populate L1 cache
      this.l1Cache.set(key, value);
      return value;
    }

    console.log("❌ Cache miss:", key);
    return null;
  }

  async set(key, value, ttl = 60) {
    // Set in both caches
    this.l1Cache.set(key, value, ttl);
    await this.l2Cache.setex(key, ttl, JSON.stringify(value));
  }

  async invalidate(pattern) {
    // Invalidate L1
    const keys = this.l1Cache.keys();
    keys
      .filter((k) => k.startsWith(pattern))
      .forEach((k) => this.l1Cache.del(k));

    // Invalidate L2
    const l2Keys = await this.l2Cache.keys(`${pattern}*`);
    if (l2Keys.length > 0) {
      await this.l2Cache.del(...l2Keys);
    }
  }
}

// Usage
const cache = new MultiLayerCache();

async function getMarketData(symbol) {
  const cacheKey = `market:${symbol}`;

  let data = await cache.get(cacheKey);
  if (!data) {
    data = await quubClient.exchange.getMarket(symbol);
    await cache.set(cacheKey, data, 5); // 5 second TTL
  }

  return data;
}
```

### Smart Cache Invalidation

```javascript
class SmartCacheManager {
  constructor(cache) {
    this.cache = cache;
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Invalidate on order events
    quubClient.on("order.created", (order) => {
      this.invalidateOrderCache(order);
    });

    quubClient.on("order.filled", (order) => {
      this.invalidateOrderCache(order);
      this.invalidateBalanceCache(order.userId);
      this.invalidateMarketCache(order.symbol);
    });

    quubClient.on("order.cancelled", (order) => {
      this.invalidateOrderCache(order);
    });
  }

  invalidateOrderCache(order) {
    this.cache.invalidate(`orders:${order.userId}`);
    this.cache.invalidate(`order:${order.orderId}`);
  }

  invalidateBalanceCache(userId) {
    this.cache.invalidate(`balance:${userId}`);
  }

  invalidateMarketCache(symbol) {
    this.cache.invalidate(`market:${symbol}`);
  }
}
```

### Cache-Aside Pattern

```javascript
class CacheAsideRepository {
  constructor(quubClient, cache) {
    this.client = quubClient;
    this.cache = cache;
  }

  async getMarket(symbol) {
    const cacheKey = `market:${symbol}`;

    // Try cache
    let market = await this.cache.get(cacheKey);
    if (market) return market;

    // Cache miss - fetch from API
    market = await this.client.exchange.getMarket(symbol);

    // Store in cache
    await this.cache.set(cacheKey, market, 5);

    return market;
  }

  async getMarkets() {
    const cacheKey = "markets:all";

    let markets = await this.cache.get(cacheKey);
    if (markets) return markets;

    markets = await this.client.exchange.getMarkets();
    await this.cache.set(cacheKey, markets, 30);

    return markets;
  }
}
```

---

## Database Optimization

### Indexing Strategy

```sql
-- Orders table indexes
CREATE INDEX idx_orders_user_created ON orders(user_id, created_at DESC);
CREATE INDEX idx_orders_symbol_created ON orders(symbol, created_at DESC);
CREATE INDEX idx_orders_status_created ON orders(status, created_at DESC);
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Composite index for common query
CREATE INDEX idx_orders_user_symbol_status
  ON orders(user_id, symbol, status, created_at DESC);

-- Partial index for active orders only
CREATE INDEX idx_orders_active
  ON orders(user_id, created_at DESC)
  WHERE status IN ('open', 'pending');

-- Transactions table
CREATE INDEX idx_transactions_user_time ON transactions(user_id, created_at DESC);
CREATE INDEX idx_transactions_type_time ON transactions(type, created_at DESC);
CREATE INDEX idx_transactions_wallet ON transactions(wallet_id, created_at DESC);
```

### Query Optimization

```javascript
// ✅ GOOD: Efficient pagination
async function getRecentOrders(userId, page = 1, limit = 50) {
  const offset = (page - 1) * limit;

  const orders = await db.query(
    `
    SELECT id, symbol, side, type, quantity, price, status, created_at
    FROM orders
    WHERE user_id = $1
      AND status IN ('open', 'filled')
    ORDER BY created_at DESC
    LIMIT $2 OFFSET $3
  `,
    [userId, limit, offset]
  );

  return orders.rows;
}

// ❌ BAD: Loading all orders into memory
async function getRecentOrdersSlow(userId) {
  const orders = await db.query(
    `
    SELECT * FROM orders WHERE user_id = $1 ORDER BY created_at DESC
  `,
    [userId]
  );

  return orders.rows.slice(0, 50);
}

// ✅ GOOD: Cursor-based pagination (better for large datasets)
async function getOrdersCursor(userId, cursor = null, limit = 50) {
  const query = cursor
    ? `SELECT * FROM orders
       WHERE user_id = $1 AND created_at < $2
       ORDER BY created_at DESC LIMIT $3`
    : `SELECT * FROM orders
       WHERE user_id = $1
       ORDER BY created_at DESC LIMIT $2`;

  const params = cursor ? [userId, cursor, limit] : [userId, limit];
  const result = await db.query(query, params);

  return {
    orders: result.rows,
    nextCursor:
      result.rows.length > 0
        ? result.rows[result.rows.length - 1].created_at
        : null,
  };
}
```

### Connection Pooling

```javascript
import { Pool } from "pg";

// Configure PostgreSQL connection pool
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,

  // Pool configuration
  max: 20, // Maximum connections
  min: 5, // Minimum connections
  idleTimeoutMillis: 30000, // Close idle connections after 30s
  connectionTimeoutMillis: 2000,

  // Performance
  statement_timeout: 30000, // Query timeout
  query_timeout: 30000,

  // Monitoring
  log: (msg) => console.log("DB Pool:", msg),
});

// Monitor pool health
setInterval(() => {
  console.log("Pool Status:", {
    total: pool.totalCount,
    idle: pool.idleCount,
    waiting: pool.waitingCount,
  });
}, 60000);

// Graceful shutdown
process.on("SIGTERM", async () => {
  await pool.end();
  console.log("Database pool closed");
});
```

---

## WebSocket Optimization

### Message Batching

```javascript
class OptimizedWebSocketClient {
  constructor(quubClient) {
    this.client = quubClient;
    this.messageBuffer = [];
    this.batchSize = 100;
    this.batchInterval = 100; // ms

    this.startBatching();
  }

  async connect() {
    this.ws = await this.client.exchange.connectWebSocket();

    this.ws.subscribe("market.ticker", ["BTC-USD", "ETH-USD"], (message) => {
      this.bufferMessage(message);
    });
  }

  bufferMessage(message) {
    this.messageBuffer.push(message);

    if (this.messageBuffer.length >= this.batchSize) {
      this.processBatch();
    }
  }

  startBatching() {
    setInterval(() => {
      if (this.messageBuffer.length > 0) {
        this.processBatch();
      }
    }, this.batchInterval);
  }

  processBatch() {
    const batch = this.messageBuffer.splice(0, this.batchSize);

    // Process messages in bulk
    this.handleMessages(batch);
  }

  handleMessages(messages) {
    // Aggregate updates
    const latestPrices = new Map();

    for (const msg of messages) {
      latestPrices.set(msg.symbol, msg.price);
    }

    // Update UI once with all changes
    this.updateUI(Array.from(latestPrices.entries()));
  }
}
```

### Selective Subscriptions

```javascript
// ✅ GOOD: Subscribe only to needed data
const ws = await quubClient.exchange.connectWebSocket();

// Only subscribe to specific symbols
ws.subscribe("market.ticker", ["BTC-USD", "ETH-USD"], handleTicker);

// Only subscribe to top of book (not full order book)
ws.subscribe("market.topOfBook", ["BTC-USD"], handleTopOfBook);

// ❌ BAD: Subscribe to everything
ws.subscribe("market.ticker", ["*"], handleTicker); // All symbols!
ws.subscribe("market.orderbook", ["BTC-USD"], handleOrderBook); // Full book!
```

---

## Load Testing

### API Load Testing

```javascript
import autocannon from "autocannon";

async function loadTestApi() {
  const token = await getAuthToken();

  const result = await autocannon({
    url: "https://api.quub.fi/v1/markets",
    connections: 100, // Concurrent connections
    duration: 30, // Test duration in seconds
    pipelining: 10, // Requests per connection

    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },

    requests: [
      {
        method: "GET",
        path: "/v1/markets",
      },
      {
        method: "GET",
        path: "/v1/markets/BTC-USD",
      },
      {
        method: "POST",
        path: "/v1/orders",
        body: JSON.stringify({
          symbol: "BTC-USD",
          side: "buy",
          type: "limit",
          quantity: "0.001",
          price: "40000",
        }),
      },
    ],
  });

  console.log("Load Test Results:");
  console.log(`  Requests: ${result.requests.total}`);
  console.log(`  Duration: ${result.duration}s`);
  console.log(`  RPS: ${result.requests.average}`);
  console.log(`  Latency p50: ${result.latency.p50}ms`);
  console.log(`  Latency p99: ${result.latency.p99}ms`);
  console.log(`  Errors: ${result.errors}`);
}
```

### Stress Testing

```javascript
import { check, sleep } from "k6";
import http from "k6/http";

export const options = {
  stages: [
    { duration: "2m", target: 100 }, // Ramp up to 100 users
    { duration: "5m", target: 100 }, // Stay at 100 users
    { duration: "2m", target: 200 }, // Ramp up to 200 users
    { duration: "5m", target: 200 }, // Stay at 200 users
    { duration: "2m", target: 0 }, // Ramp down
  ],
  thresholds: {
    http_req_duration: ["p(95)<500"], // 95% requests < 500ms
    http_req_failed: ["rate<0.01"], // Error rate < 1%
  },
};

export default function () {
  const token = getAuthToken();

  // Get markets
  let res = http.get("https://api.quub.fi/v1/markets", {
    headers: { Authorization: `Bearer ${token}` },
  });
  check(res, { "markets status 200": (r) => r.status === 200 });

  sleep(1);

  // Get specific market
  res = http.get("https://api.quub.fi/v1/markets/BTC-USD", {
    headers: { Authorization: `Bearer ${token}` },
  });
  check(res, { "market status 200": (r) => r.status === 200 });

  sleep(1);
}
```

---

## Monitoring & Profiling

### Performance Metrics

```javascript
import { Histogram, Counter } from "prom-client";

class PerformanceMonitor {
  constructor() {
    this.apiLatency = new Histogram({
      name: "api_request_duration_seconds",
      help: "API request duration",
      labelNames: ["method", "endpoint", "status"],
      buckets: [0.1, 0.5, 1, 2, 5, 10],
    });

    this.cacheHitRate = new Counter({
      name: "cache_requests_total",
      help: "Cache requests",
      labelNames: ["result"], // hit, miss
    });

    this.dbQueryDuration = new Histogram({
      name: "db_query_duration_seconds",
      help: "Database query duration",
      labelNames: ["query_type"],
      buckets: [0.01, 0.05, 0.1, 0.5, 1, 2],
    });
  }

  recordApiCall(method, endpoint, status, duration) {
    this.apiLatency.observe({ method, endpoint, status }, duration / 1000);
  }

  recordCacheHit() {
    this.cacheHitRate.inc({ result: "hit" });
  }

  recordCacheMiss() {
    this.cacheHitRate.inc({ result: "miss" });
  }
}

// Usage
const monitor = new PerformanceMonitor();

async function monitoredApiCall() {
  const start = Date.now();

  try {
    const result = await quubClient.exchange.getMarkets();
    const duration = Date.now() - start;

    monitor.recordApiCall("GET", "/markets", 200, duration);

    return result;
  } catch (error) {
    const duration = Date.now() - start;
    monitor.recordApiCall("GET", "/markets", error.statusCode || 500, duration);
    throw error;
  }
}
```

---

## Scalability Patterns

### Horizontal Scaling

```javascript
// Using cluster module for multi-process
import cluster from "cluster";
import os from "os";

if (cluster.isMaster) {
  const numCPUs = os.cpus().length;

  console.log(`Master ${process.pid} starting ${numCPUs} workers...`);

  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on("exit", (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died, spawning new worker...`);
    cluster.fork();
  });
} else {
  // Worker process
  const app = createApp();
  app.listen(3000, () => {
    console.log(`Worker ${process.pid} started`);
  });
}
```

### Message Queue for Async Processing

```javascript
import Bull from "bull";

// Create job queue
const orderQueue = new Bull("orders", {
  redis: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
  },
});

// Process orders asynchronously
orderQueue.process(10, async (job) => {
  // 10 concurrent processors
  const { orderParams } = job.data;

  try {
    const order = await quubClient.exchange.createOrder(orderParams);
    return { success: true, orderId: order.orderId };
  } catch (error) {
    throw error; // Will retry automatically
  }
});

// Add order to queue
async function placeOrderAsync(orderParams) {
  const job = await orderQueue.add(
    { orderParams },
    {
      attempts: 3,
      backoff: {
        type: "exponential",
        delay: 2000,
      },
    }
  );

  return job.id;
}
```

---

**Next Steps:**

- **[Load Testing Guide](../load-testing/)** - Comprehensive load testing strategies
- **[Monitoring Guide](../monitoring/)** - Set up comprehensive monitoring

---

**Performance Issues?** Contact performance@quub.fi
