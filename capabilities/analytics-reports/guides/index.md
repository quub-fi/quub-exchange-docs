---
layout: docs
title: Analytics Reports Guides
permalink: /capabilities/analytics-reports/guides/
---

# 📚 Analytics Reports Implementation Guides

> Comprehensive guides for implementing and integrating Analytics Reports capabilities into your applications.

## � Quick Navigation

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 30px 0;">

<div style="border: 2px solid #667eea; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #667eea10 0%, #764ba210 100%);">
  <h3 style="margin-top: 0; color: #667eea;">🎯 Getting Started</h3>
  <p>New to Analytics Reports? Start here to get up and running quickly.</p>
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

- ✅ Active Quub Exchange account
- ✅ API credentials with `analytics:read` and `analytics:write` scopes
- ✅ Development environment configured (Node.js 18+ or Python 3.9+)
- ✅ Understanding of JWT authentication

### 5-Minute Setup

#### Step 1: Install SDK

**Node.js:**

```bash
npm install @quub/analytics-sdk
```

**Python:**

```bash
pip install quub-analytics
```

#### Step 2: Configure Authentication

**Node.js:**

```javascript
import { AnalyticsClient } from "@quub/analytics-sdk";

const client = new AnalyticsClient({
  apiKey: process.env.QUUB_API_KEY,
  orgId: process.env.QUUB_ORG_ID,
  environment: "sandbox", // or 'production'
});
```

**Python:**

```python
from quub.analytics import AnalyticsClient

client = AnalyticsClient(
    api_key=os.getenv('QUUB_API_KEY'),
    org_id=os.getenv('QUUB_ORG_ID'),
    environment='sandbox'  # or 'production'
)
```

#### Step 3: Generate Your First Report

**Node.js:**

```javascript
const report = await client.reports.create({
  type: "COMPLIANCE_SUMMARY",
  format: "PDF",
  dateRange: {
    from: "2025-10-01",
    to: "2025-10-31",
  },
});

console.log(`Report queued: ${report.reportId}`);
```

**Python:**

```python
report = client.reports.create(
    type='COMPLIANCE_SUMMARY',
    format='PDF',
    date_range={
        'from': '2025-10-01',
        'to': '2025-10-31'
    }
)

print(f"Report queued: {report.report_id}")
```

---

## 🔌 Integration Guide {#integration}

### Architecture Overview

```
┌─────────────────┐
│  Your App       │
└────────┬────────┘
         │
         ↓ HTTPS + JWT
┌─────────────────┐
│ Analytics API   │
└────────┬────────┘
         │
    ┌────┴────┐
    ↓         ↓
┌────────┐ ┌────────┐
│Reports │ │Metrics │
└────────┘ └────────┘
```

### Integration Patterns

#### 1. Report Generation Workflow

```javascript
// 1. Request report generation
const request = await client.reports.create({...});

// 2. Poll for completion
const checkStatus = async (reportId) => {
  const status = await client.reports.getStatus(reportId);

  if (status.status === 'COMPLETED') {
    return status.output.downloadUrl;
  } else if (status.status === 'FAILED') {
    throw new Error(status.error);
  }

  // Wait and retry
  await new Promise(r => setTimeout(r, 5000));
  return checkStatus(reportId);
};

const downloadUrl = await checkStatus(request.reportId);
```

#### 2. Real-time Metrics Dashboard

```javascript
// Fetch trading metrics
const metrics = await client.metrics.getTrading({
  from: "2025-11-01T00:00:00Z",
  to: "2025-11-02T00:00:00Z",
  interval: "1h",
  markets: ["BTC-USD", "ETH-USD"],
});

// Update dashboard
updateDashboard(metrics.data);
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

// Get access token
const token = await authClient.getAccessToken({
  scopes: ["analytics:read", "analytics:write"],
});

// Use with Analytics client
const analyticsClient = new AnalyticsClient({
  accessToken: token,
  orgId: process.env.QUUB_ORG_ID,
});
```

### Token Refresh Strategy

```javascript
class TokenManager {
  constructor(authClient) {
    this.authClient = authClient;
    this.token = null;
    this.expiresAt = null;
  }

  async getToken() {
    if (this.token && Date.now() < this.expiresAt - 60000) {
      return this.token;
    }

    const response = await this.authClient.getAccessToken();
    this.token = response.accessToken;
    this.expiresAt = Date.now() + response.expiresIn * 1000;

    return this.token;
  }
}
```

---

## ✨ Best Practices {#best-practices}

### 1. Error Handling

```javascript
try {
  const report = await client.reports.create({...});
} catch (error) {
  if (error.code === 'INVALID_DATE_RANGE') {
    // Handle specific error
    console.error('Invalid date range:', error.message);
  } else if (error.code === 'RATE_LIMIT_EXCEEDED') {
    // Implement backoff
    await backoff(error.retryAfter);
    // Retry request
  } else {
    // Log and alert
    logger.error('Report generation failed', error);
    alertOps(error);
  }
}
```

### 2. Rate Limiting

```javascript
import pLimit from "p-limit";

const limit = pLimit(5); // Max 5 concurrent requests

const reports = await Promise.all(
  reportConfigs.map((config) => limit(() => client.reports.create(config)))
);
```

### 3. Caching Strategy

```javascript
import NodeCache from "node-cache";

const cache = new NodeCache({ stdTTL: 300 }); // 5-minute TTL

async function getMetrics(params) {
  const cacheKey = JSON.stringify(params);
  const cached = cache.get(cacheKey);

  if (cached) return cached;

  const metrics = await client.metrics.getTrading(params);
  cache.set(cacheKey, metrics);

  return metrics;
}
```

---

## 🔒 Security Guidelines {#security}

### API Key Management

❌ **Don't:**

```javascript
// Never hardcode credentials
const client = new AnalyticsClient({
  apiKey: "sk_live_abc123...",
  orgId: "org_xyz789",
});
```

✅ **Do:**

```javascript
// Use environment variables
const client = new AnalyticsClient({
  apiKey: process.env.QUUB_API_KEY,
  orgId: process.env.QUUB_ORG_ID,
});
```

### Data Privacy

- Always set `includePII: false` unless absolutely necessary
- Use data masking for sensitive fields
- Implement proper access controls
- Log all data access for audit trails

---

## 🚀 Performance Optimization {#performance}

### 1. Batch Operations

```javascript
// Instead of multiple individual requests
for (const market of markets) {
  await client.metrics.getTrading({ markets: [market] });
}

// Batch into single request
await client.metrics.getTrading({
  markets: markets, // Multiple markets at once
});
```

### 2. Pagination

```javascript
async function* fetchAllMetrics(params) {
  let cursor = null;

  do {
    const response = await client.metrics.getTrading({
      ...params,
      cursor,
    });

    yield response.data;
    cursor = response.meta.nextCursor;
  } while (cursor);
}

// Use with async iteration
for await (const batch of fetchAllMetrics(params)) {
  processBatch(batch);
}
```

---

## 🔧 Advanced Configuration {#advanced}

### Custom Headers

```javascript
const client = new AnalyticsClient({
  apiKey: process.env.QUUB_API_KEY,
  orgId: process.env.QUUB_ORG_ID,
  headers: {
    "X-Request-ID": generateRequestId(),
    "X-App-Version": "1.0.0",
  },
});
```

### Webhook Integration

```javascript
// Configure webhooks for report completion
await client.reports.create({
  type: "COMPLIANCE_SUMMARY",
  format: "PDF",
  delivery: {
    webhookUrl: "https://your-app.com/webhooks/reports",
    webhookSecret: process.env.WEBHOOK_SECRET,
  },
});

// Verify webhook signatures
function verifyWebhookSignature(payload, signature, secret) {
  const hmac = crypto.createHmac("sha256", secret);
  const digest = hmac.update(payload).digest("hex");
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(digest));
}
```

---

## 🔍 Troubleshooting {#troubleshooting}

### Common Issues

#### Issue: 401 Unauthorized

**Cause:** Invalid or expired JWT token

**Solution:**

```javascript
// Implement token refresh
const token = await authClient.refreshToken();
analyticsClient.setAccessToken(token);
```

#### Issue: 403 Forbidden

**Cause:** Insufficient permissions or wrong orgId

**Solution:**

- Verify JWT contains correct scopes (`analytics:read`, `analytics:write`)
- Ensure `orgId` matches the organization in JWT
- Check role-based permissions

#### Issue: 429 Rate Limit Exceeded

**Cause:** Too many requests

**Solution:**

```javascript
// Implement exponential backoff
async function withRetry(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (error.code === "RATE_LIMIT_EXCEEDED" && i < maxRetries - 1) {
        const delay = Math.pow(2, i) * 1000;
        await new Promise((r) => setTimeout(r, delay));
        continue;
      }
      throw error;
    }
  }
}
```

---

## 📊 Monitoring & Observability {#monitoring}

### Logging

```javascript
import winston from "winston";

const logger = winston.createLogger({
  level: "info",
  format: winston.format.json(),
  transports: [new winston.transports.File({ filename: "analytics.log" })],
});

// Log all API calls
client.on("request", (req) => {
  logger.info("API Request", {
    method: req.method,
    url: req.url,
    requestId: req.headers["x-request-id"],
  });
});

client.on("response", (res) => {
  logger.info("API Response", {
    status: res.status,
    requestId: res.headers["x-request-id"],
    duration: res.duration,
  });
});
```

### Metrics

```javascript
import { Counter, Histogram } from "prom-client";

const requestCounter = new Counter({
  name: "analytics_requests_total",
  help: "Total number of Analytics API requests",
  labelNames: ["method", "status"],
});

const requestDuration = new Histogram({
  name: "analytics_request_duration_seconds",
  help: "Analytics API request duration",
  labelNames: ["method"],
});
```

---

## 📚 Additional Resources

- [API Reference](../analytics-reports-api-documentation/) - Complete API documentation
- [OpenAPI Specification](/openapi/analytics-reports.yaml) - Machine-readable API spec
- [Code Examples](https://github.com/quub-fi/examples) - Sample implementations
- [Support](https://support.quub.fi) - Get help from our team

---

**Need help?** Contact our support team or join our [developer community](https://community.quub.fi).
