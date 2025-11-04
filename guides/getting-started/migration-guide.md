---
layout: docs
title: Migration Guide
permalink: /guides/getting-started/migration-guide/
description: Guide for migrating between Quub Exchange API versions and upgrading integrations
---

# Migration Guide

Step-by-step instructions for migrating your integration to new Quub Exchange API versions and upgrading deprecated features.

## Table of Contents

1. [Version Overview](#version-overview)
2. [Migration Path](#migration-path)
3. [Breaking Changes](#breaking-changes)
4. [Feature Deprecations](#feature-deprecations)
5. [Migration Steps](#migration-steps)
6. [Testing Your Migration](#testing-your-migration)
7. [Rollback Plan](#rollback-plan)

---

## Version Overview

### Current API Versions

| Version | Status      | Released | Support Ends |
| ------- | ----------- | -------- | ------------ |
| v2.0    | **Current** | 2024-01  | Active       |
| v1.5    | Supported   | 2023-06  | 2024-12      |
| v1.0    | Deprecated  | 2022-01  | 2024-06      |

### Version Support Policy

- **Current version**: Full support, active development
- **Supported versions**: Security updates, critical bug fixes only
- **Deprecated versions**: 6-month sunset period, emergency fixes only

---

## Migration Path

### From v1.0 to v2.0

**Timeline:**

- **2024-01**: v2.0 released
- **2024-03**: v1.0 enters sunset period
- **2024-06**: v1.0 support ends

**Major Changes:**

1. Authentication: API key format changed
2. WebSocket: New connection protocol
3. Order API: New required fields
4. Response format: Standardized error responses

### From v1.5 to v2.0

**Timeline:**

- **2024-12**: v1.5 enters sunset period
- **2025-06**: v1.5 support ends

**Major Changes:**

1. Pagination: Cursor-based instead of offset-based
2. WebSocket: Message format updated
3. Market data: Additional fields in responses

---

## Breaking Changes

### v1.0 → v2.0

#### 1. Authentication Changes

**Before (v1.0):**

```javascript
// Old API key format
const apiKey = "qk_abc123";
const apiSecret = "sk_xyz789";

const response = await fetch("https://api.quub.fi/v1/auth/token", {
  method: "POST",
  headers: {
    "X-API-Key": apiKey,
    "X-API-Secret": apiSecret,
  },
});
```

**After (v2.0):**

```javascript
// New API key format with org ID
const apiKey = "qk_live_abc123def456";
const apiSecret = "sk_live_xyz789uvw012";
const orgId = "org_abc123";

const response = await fetch("https://api.quub.fi/v2/auth/token", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    apiKey,
    apiSecret,
    orgId,
  }),
});
```

**Migration Steps:**

1. Generate new v2 API keys in dashboard
2. Update authentication code
3. Test with sandbox environment
4. Deploy to production
5. Revoke old v1 API keys

#### 2. Order Creation

**Before (v1.0):**

```javascript
const order = await quubClient.createOrder({
  symbol: "BTCUSD",
  side: "buy",
  quantity: 0.01,
  price: 45000,
});
```

**After (v2.0):**

```javascript
const order = await quubClient.createOrder({
  symbol: "BTC-USD", // Hyphen separator required
  side: "buy",
  type: "limit", // Required field
  quantity: "0.01", // String format
  price: "45000.00", // String format
  timeInForce: "GTC", // Required field
  clientOrderId: "order_123", // Optional but recommended
});
```

**Key Differences:**

- Symbol format: `BTCUSD` → `BTC-USD`
- `type` field now required
- Numeric values as strings for precision
- `timeInForce` required
- `clientOrderId` for idempotency

#### 3. Error Responses

**Before (v1.0):**

```json
{
  "error": "INSUFFICIENT_BALANCE",
  "message": "Not enough balance"
}
```

**After (v2.0):**

```json
{
  "error": {
    "code": "INSUFFICIENT_BALANCE",
    "message": "Insufficient balance to execute order",
    "details": {
      "required": "0.01 BTC",
      "available": "0.005 BTC",
      "currency": "BTC"
    },
    "timestamp": "2024-01-15T10:30:00Z",
    "requestId": "req_abc123"
  }
}
```

**Migration:**

```javascript
// Update error handling
try {
  await quubClient.createOrder(params);
} catch (error) {
  // v1.0 style
  if (error.error === "INSUFFICIENT_BALANCE") {
    // Handle error
  }

  // v2.0 style
  if (error.error?.code === "INSUFFICIENT_BALANCE") {
    console.error("Insufficient balance:");
    console.error(`  Required: ${error.error.details.required}`);
    console.error(`  Available: ${error.error.details.available}`);
  }
}
```

#### 4. WebSocket Protocol

**Before (v1.0):**

```javascript
const ws = new WebSocket("wss://ws.quub.fi/v1");

ws.on("open", () => {
  ws.send(
    JSON.stringify({
      action: "subscribe",
      channels: ["ticker"],
      symbols: ["BTCUSD"],
    })
  );
});
```

**After (v2.0):**

```javascript
const ws = new WebSocket("wss://ws.quub.fi/v2");

ws.on("open", () => {
  // Must authenticate first
  ws.send(
    JSON.stringify({
      type: "auth",
      apiKey: process.env.QUUB_API_KEY,
      timestamp: Date.now(),
    })
  );
});

ws.on("message", (data) => {
  const msg = JSON.parse(data);

  if (msg.type === "auth_success") {
    // Now subscribe
    ws.send(
      JSON.stringify({
        type: "subscribe",
        channel: "market.ticker",
        symbols: ["BTC-USD"],
      })
    );
  }
});
```

---

### v1.5 → v2.0

#### 1. Pagination Changes

**Before (v1.5):**

```javascript
// Offset-based pagination
const orders = await quubClient.getOrders({
  limit: 50,
  offset: 100, // Page 3
});
```

**After (v2.0):**

```javascript
// Cursor-based pagination
let cursor = null;
const allOrders = [];

do {
  const response = await quubClient.getOrders({
    limit: 50,
    cursor,
  });

  allOrders.push(...response.orders);
  cursor = response.nextCursor;
} while (cursor);
```

#### 2. Market Data Fields

**Before (v1.5):**

```json
{
  "symbol": "BTC-USD",
  "lastPrice": "45000.00",
  "volume": "1234.56"
}
```

**After (v2.0):**

```json
{
  "symbol": "BTC-USD",
  "lastPrice": "45000.00",
  "volume24h": "1234.56",
  "priceChange24h": "+2.5%",
  "high24h": "46000.00",
  "low24h": "44000.00",
  "vwap24h": "45250.00",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## Feature Deprecations

### Deprecated in v2.0

| Feature                      | Deprecated | Replacement                      | Removed In |
| ---------------------------- | ---------- | -------------------------------- | ---------- |
| GET `/v1/orders/all`         | v2.0       | GET `/v2/orders` with pagination | v2.5       |
| Offset pagination            | v2.0       | Cursor-based pagination          | v2.5       |
| Numeric order quantities     | v2.0       | String quantities                | v2.5       |
| Symbol format without hyphen | v2.0       | Hyphenated format (BTC-USD)      | v2.5       |

### Migration Timeline

```
2024-01  v2.0 Released
  ↓
2024-03  Deprecation warnings added
  ↓
2024-06  v1.0 support ends
  ↓
2024-09  Deprecated features show warnings
  ↓
2024-12  v1.5 enters sunset
  ↓
2025-03  Deprecated features removed (v2.5)
```

---

## Migration Steps

### Step 1: Assessment

```javascript
// Migration assessment script
import { QuubClient } from "@quub/sdk";

async function assessMigration() {
  const client = new QuubClient({
    apiKey: process.env.QUUB_API_KEY,
    apiSecret: process.env.QUUB_API_SECRET,
    version: "v1.5", // Current version
  });

  console.log("🔍 Assessing migration requirements...\n");

  // Check API usage
  const usage = await client.getApiUsage({
    startDate: "2024-01-01",
    endDate: "2024-01-31",
  });

  console.log("API Usage:");
  for (const [endpoint, count] of Object.entries(usage.endpoints)) {
    const deprecated = deprecatedEndpoints.includes(endpoint);
    console.log(
      `  ${endpoint}: ${count} calls ${deprecated ? "⚠️ DEPRECATED" : ""}`
    );
  }

  // Check for deprecated features
  const warnings = [];

  if (usage.features.offsetPagination > 0) {
    warnings.push({
      feature: "Offset-based pagination",
      usage: usage.features.offsetPagination,
      action: "Switch to cursor-based pagination",
    });
  }

  if (usage.features.numericQuantities > 0) {
    warnings.push({
      feature: "Numeric quantities",
      usage: usage.features.numericQuantities,
      action: "Use string quantities",
    });
  }

  if (warnings.length > 0) {
    console.log("\n⚠️ Migration Required:");
    warnings.forEach((w) => {
      console.log(`  - ${w.feature} (${w.usage} uses)`);
      console.log(`    Action: ${w.action}`);
    });
  } else {
    console.log("\n✅ No deprecated features detected");
  }
}
```

### Step 2: Create Migration Branch

```bash
# Create dedicated migration branch
git checkout -b migration/v2.0

# Install v2.0 SDK
npm install @quub/sdk@^2.0.0

# Update environment for testing
cp .env .env.backup
echo "QUUB_API_VERSION=v2.0" >> .env
```

### Step 3: Update Code

```javascript
// migration-helpers.js
export class MigrationHelper {
  // Convert symbol format
  static convertSymbol(symbol) {
    // BTCUSD → BTC-USD
    if (!symbol.includes("-")) {
      return symbol.replace(/^(\w{3,4})(\w{3,4})$/, "$1-$2");
    }
    return symbol;
  }

  // Convert quantity to string
  static formatQuantity(quantity) {
    return typeof quantity === "number" ? quantity.toFixed(8) : quantity;
  }

  // Adapt v1 order to v2
  static adaptOrderParams(v1Params) {
    return {
      symbol: this.convertSymbol(v1Params.symbol),
      side: v1Params.side,
      type: v1Params.type || "limit",
      quantity: this.formatQuantity(v1Params.quantity),
      price: v1Params.price ? this.formatQuantity(v1Params.price) : undefined,
      timeInForce: v1Params.timeInForce || "GTC",
      clientOrderId: v1Params.clientOrderId || `order_${Date.now()}`,
    };
  }
}

// Update existing code
import { MigrationHelper } from "./migration-helpers.js";

async function placeOrder(params) {
  // Adapt parameters for v2
  const v2Params = MigrationHelper.adaptOrderParams(params);

  return await quubClient.createOrder(v2Params);
}
```

### Step 4: Update Tests

```javascript
// tests/migration.test.js
describe("v2.0 Migration", () => {
  test("should convert symbol format", () => {
    expect(MigrationHelper.convertSymbol("BTCUSD")).toBe("BTC-USD");
    expect(MigrationHelper.convertSymbol("BTC-USD")).toBe("BTC-USD");
  });

  test("should format quantities as strings", () => {
    expect(MigrationHelper.formatQuantity(0.01)).toBe("0.01000000");
    expect(MigrationHelper.formatQuantity("0.01")).toBe("0.01");
  });

  test("should create v2 order with all required fields", async () => {
    const v1Params = {
      symbol: "BTCUSD",
      side: "buy",
      quantity: 0.01,
      price: 45000,
    };

    const v2Params = MigrationHelper.adaptOrderParams(v1Params);

    expect(v2Params).toHaveProperty("symbol", "BTC-USD");
    expect(v2Params).toHaveProperty("type");
    expect(v2Params).toHaveProperty("timeInForce");
    expect(v2Params).toHaveProperty("clientOrderId");
    expect(typeof v2Params.quantity).toBe("string");
  });
});
```

### Step 5: Gradual Rollout

```javascript
// Feature flag for gradual migration
class FeatureFlags {
  static useV2Api() {
    const rolloutPercentage = parseInt(process.env.V2_ROLLOUT_PERCENTAGE || '0');
    const random = Math.random() * 100;
    return random < rolloutPercentage;
  }
}

// Dual-version client
class DualVersionClient {
  constructor() {
    this.v1Client = new QuubClient({ version: 'v1.5', ... });
    this.v2Client = new QuubClient({ version: 'v2.0', ... });
  }

  async createOrder(params) {
    if (FeatureFlags.useV2Api()) {
      // Use v2 API
      const v2Params = MigrationHelper.adaptOrderParams(params);
      return await this.v2Client.createOrder(v2Params);
    } else {
      // Use v1 API
      return await this.v1Client.createOrder(params);
    }
  }
}
```

**Rollout Plan:**

1. Week 1: 10% traffic to v2
2. Week 2: 25% traffic to v2
3. Week 3: 50% traffic to v2
4. Week 4: 100% traffic to v2

---

## Testing Your Migration

### Integration Tests

```javascript
// tests/integration/v2-migration.test.js
describe("v2.0 Integration Tests", () => {
  let client;

  beforeAll(async () => {
    client = new QuubClient({
      apiKey: process.env.QUUB_TEST_API_KEY,
      apiSecret: process.env.QUUB_TEST_API_SECRET,
      orgId: process.env.QUUB_TEST_ORG_ID,
      environment: "sandbox",
      version: "v2.0",
    });
  });

  test("should authenticate with v2", async () => {
    const identity = await client.auth.getIdentity();
    expect(identity).toHaveProperty("orgId");
  });

  test("should create order with v2 format", async () => {
    const order = await client.exchange.createOrder({
      symbol: "BTC-USD",
      side: "buy",
      type: "limit",
      quantity: "0.001",
      price: "40000.00",
      timeInForce: "GTC",
    });

    expect(order).toHaveProperty("orderId");
    expect(order.symbol).toBe("BTC-USD");
  });

  test("should use cursor-based pagination", async () => {
    const firstPage = await client.exchange.getOrders({
      limit: 10,
    });

    expect(firstPage).toHaveProperty("orders");
    expect(firstPage).toHaveProperty("nextCursor");

    if (firstPage.nextCursor) {
      const secondPage = await client.exchange.getOrders({
        limit: 10,
        cursor: firstPage.nextCursor,
      });

      expect(secondPage.orders[0].orderId).not.toBe(
        firstPage.orders[0].orderId
      );
    }
  });
});
```

### Compatibility Testing

```javascript
// Test v1 and v2 side-by-side
async function compareVersions() {
  const v1Client = new QuubClient({ version: 'v1.5', ... });
  const v2Client = new QuubClient({ version: 'v2.0', ... });

  // Get markets from both versions
  const [v1Markets, v2Markets] = await Promise.all([
    v1Client.getMarkets(),
    v2Client.getMarkets()
  ]);

  // Compare results
  const symbolsMatch = v1Markets.every(m =>
    v2Markets.find(m2 => m2.symbol === MigrationHelper.convertSymbol(m.symbol))
  );

  console.log('Markets match:', symbolsMatch ? '✅' : '❌');
}
```

---

## Rollback Plan

### Preparation

```javascript
// Save v1 configuration
const v1Config = {
  sdk: "@quub/sdk@^1.5.0",
  apiKeys: {
    key: process.env.QUUB_V1_API_KEY,
    secret: process.env.QUUB_V1_API_SECRET,
  },
  endpoints: {
    api: "https://api.quub.fi/v1",
    ws: "wss://ws.quub.fi/v1",
  },
};

// Document in rollback.md
fs.writeFileSync(
  "rollback.md",
  `
# Rollback Instructions

## Quick Rollback

\`\`\`bash
# Revert to previous version
git revert HEAD
npm install @quub/sdk@^1.5.0
cp .env.backup .env
npm run deploy
\`\`\`

## Configuration
- API Key: ${v1Config.apiKeys.key.substring(0, 10)}...
- Endpoints: ${v1Config.endpoints.api}
`
);
```

### Rollback Execution

```bash
#!/bin/bash
# rollback.sh

echo "🔄 Rolling back to v1.5..."

# Revert code changes
git revert HEAD --no-edit

# Reinstall v1 SDK
npm install @quub/sdk@^1.5.0

# Restore environment
cp .env.backup .env

# Run tests
npm test

# Deploy
npm run deploy:production

echo "✅ Rollback complete"
```

---

## Post-Migration

### Cleanup

```bash
# Remove v1 dependencies
npm uninstall @quub/sdk@1.5.0

# Remove migration helpers
rm migration-helpers.js

# Update documentation
git commit -m "docs: update to v2.0 API"

# Revoke v1 API keys
# (Do this in Quub dashboard)
```

### Monitor

```javascript
// Post-migration monitoring
setInterval(async () => {
  const metrics = await quubClient.getMetrics();

  if (metrics.errorRate > 0.01) {
    console.error("⚠️ High error rate detected:", metrics.errorRate);
    // Alert team
  }

  if (metrics.latencyP99 > 1000) {
    console.warn("⚠️ High latency detected:", metrics.latencyP99);
  }
}, 60000);
```

---

**Need Migration Help?** Contact migrations@quub.fi | See [Migration Checklist](../migration-checklist/)
