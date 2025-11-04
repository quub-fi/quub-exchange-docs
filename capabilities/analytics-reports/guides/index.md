---
layout: docs
title: Analytics Reports Guides
permalink: /capabilities/analytics-reports/guides/
---

# 📚 Analytics & Reports Implementation Guides

> Comprehensive developer guide for implementing business intelligence, compliance reporting, and data analytics capabilities.

## 🚀 Quick Navigation

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

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

The Analytics & Reports API serves as the comprehensive business intelligence backbone for Quub Exchange, providing:

- **Automated Compliance Reporting:** Generate regulatory-compliant reports for various jurisdictions
- **Real-time Business Intelligence:** Live dashboards with KPIs and performance metrics
- **Financial Analytics:** Investment performance, ROI analysis, and distribution tracking
- **Multi-format Data Export:** PDF, CSV, JSON, and XML output formats
- **Audit Trail Management:** Complete transaction and activity reporting

### Technical Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client App    │    │  Analytics API  │    │  Data Sources   │
│                 │────│                 │────│                 │
│ • Dashboards    │    │ • Report Engine │    │ • Trading Data  │
│ • Reports UI    │    │ • Analytics     │    │ • User Data     │
│ • Export Tools  │    │ • Compliance    │    │ • Market Data   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                    ┌─────────────────┐
                    │  Data Pipeline  │
                    │                 │
                    │ • ETL Process   │
                    │ • Aggregation   │
                    │ • Caching       │
                    └─────────────────┘
```

### Core Data Models

**Statements:** Account and distribution statements for specific periods
**Tax Reports:** Annual tax filings with jurisdiction-specific formatting
**Regulatory Reports:** Compliance disclosures (AML, KYC, AUDIT, COMPLIANCE)
**Analytics Dashboard:** Real-time KPIs and performance metrics

---

## 🎯 Quick Start {#quick-start}

### Prerequisites

Before you begin, ensure you have:

- ✅ Active Quub Exchange account with analytics permissions
- ✅ API credentials with `analytics:read` scope (and `analytics:write` for report generation)
- ✅ Development environment configured (Node.js 18+ or Python 3.9+)
- ✅ Understanding of JWT authentication and financial data handling

### 5-Minute Setup

#### Step 1: Install SDK

**Node.js:**

```bash
npm install @quub/analytics-sdk axios
```

**Python:**

```bash
pip install quub-analytics requests
```

#### Step 2: Configure Authentication

**Node.js:**

```javascript
import { AnalyticsClient } from "@quub/analytics-sdk";

const client = new AnalyticsClient({
  apiKey: process.env.QUUB_API_KEY,
  orgId: process.env.QUUB_ORG_ID,
  baseUrl:
    process.env.NODE_ENV === "production"
      ? "https://api.quub.exchange/v2"
      : "https://sandbox.quub.exchange/v2",
});
```

**Python:**

```python
from quub.analytics import AnalyticsClient
import os

client = AnalyticsClient(
    api_key=os.getenv('QUUB_API_KEY'),
    org_id=os.getenv('QUUB_ORG_ID'),
    base_url='https://sandbox.quub.exchange/v2'  # or production URL
)
```

#### Step 3: Fetch Your First Analytics Dashboard

**Node.js:**

```javascript
// GET /orgs/{orgId}/analytics/dashboard
const dashboard = await client.get(
  `/orgs/${client.orgId}/analytics/dashboard`,
  {
    params: {
      period: "MONTHLY",
      startDate: "2025-01-01",
      endDate: "2025-01-31",
    },
  }
);

console.log("Dashboard Data:", {
  totalInvested: dashboard.data.totalInvested,
  activeInvestors: dashboard.data.activeInvestors,
  roiYTD: dashboard.data.roiYTD,
});
```

**Python:**

```python
# GET /orgs/{orgId}/analytics/dashboard
response = client.get(f'/orgs/{client.org_id}/analytics/dashboard', params={
    'period': 'MONTHLY',
    'startDate': '2025-01-01',
    'endDate': '2025-01-31'
})

dashboard = response.json()
print(f"Total Invested: ${dashboard['totalInvested']:,.2f}")
print(f"Active Investors: {dashboard['activeInvestors']}")
print(f"ROI YTD: {dashboard['roiYTD']}%")
```

#### Step 4: Retrieve Statements

**Node.js:**

```javascript
// GET /orgs/{orgId}/reports/statements
const statements = await client.get(
  `/orgs/${client.orgId}/reports/statements`,
  {
    params: {
      limit: 10,
      cursor: null, // Start from beginning
    },
  }
);

// Access statement details
statements.data.data.forEach((statement) => {
  console.log(`Statement ID: ${statement.id}`);
  console.log(`Period: ${statement.period}`);
  console.log(`Format: ${statement.format}`);
  console.log(`Download URI: ${statement.uri}`);
});
```

**Python:**

```python
# GET /orgs/{orgId}/reports/statements
response = client.get(f'/orgs/{client.org_id}/reports/statements', params={
    'limit': 10
})

statements = response.json()
for statement in statements['data']:
    print(f"Statement ID: {statement['id']}")
    print(f"Period: {statement['period']}")
    print(f"Format: {statement['format']}")
    print(f"Download URI: {statement['uri']}")
```

```python
statements = client.reports.get_statements(
    limit=10,
    period='2025-Q1'
)

# Download a specific statement
if statements['data']:
    statement = statements['data'][0]
    if statement['uri']:
        report_data = client.reports.download(statement['uri'])
        print(f"Downloaded {statement['format']} statement for {statement['period']}")
```

---

## 🔌 Core API Operations {#core-operations}

### 1. Statements Management

**Business Use Case:** Generate and retrieve account statements for specific periods

**List Statements**

```javascript
// Get all statements for Q1 2025
const statements = await client.reports.getStatements({
  cursor: null, // Start from beginning
  limit: 50, // Max 50 results
});

console.log(`Found ${statements.data.length} statements`);
statements.data.forEach((statement) => {
  console.log(
    `${statement.period}: ${statement.format} (${statement.generatedAt})`
  );
});
```

**Implementation Notes:**

- Use cursor-based pagination for large result sets
- Statements are generated automatically for each period
- Multiple formats available: PDF (human-readable), CSV (data analysis), JSON (API consumption)
- URI field provides direct download link when report is ready

### 2. Tax Reports Generation

**Business Use Case:** Generate jurisdiction-specific tax reports for compliance

**Generate Tax Report**

```javascript
// Generate US tax report for 2024
const taxReport = await client.reports.getTaxReport({
  year: 2024,
  locale: "en", // Localization: en, ar, fr
});

if (taxReport.uri) {
  console.log(
    `Tax report ready: ${taxReport.format} for ${taxReport.jurisdiction}`
  );
  // Download the report
  const reportBuffer = await client.reports.download(taxReport.uri);
} else {
  console.log("Tax report is being generated...");
}
```

**Python Implementation:**

```python
# Generate tax report with error handling
try:
    tax_report = client.reports.get_tax_report(
        year=2024,
        locale='en'
    )

    if tax_report['uri']:
        print(f"Tax report ready for {tax_report['jurisdiction']}")
        # Process the report
        report_data = client.reports.download(tax_report['uri'])
    else:
        print("Report generation in progress")

except Exception as e:
    print(f"Tax report generation failed: {e}")
```

**Implementation Notes:**

- Tax reports support multiple jurisdictions (US, EU, etc.)
- Available formats: PDF (filing), XML (electronic submission), JSON (data processing)
- Localization affects date formats, currency symbols, and regulatory text
- Reports include realized gains/losses, trading volume, and fee summaries

### 3. Regulatory Reports Access

**Business Use Case:** Access compliance reports for audit and regulatory requirements

**List Regulatory Reports**

```javascript
// Get all compliance reports by category
const regulatoryReports = await client.reports.getRegulatoryReports({
  category: "AML", // Filter by: AML, KYC, AUDIT, COMPLIANCE
  limit: 25,
});

regulatoryReports.data.forEach((report) => {
  console.log(`${report.title} (${report.category}) - ${report.issuedAt}`);
});
```

**Compliance Report Categories:**

- **AML:** Anti-Money Laundering reports and suspicious activity
- **KYC:** Know Your Customer verification and updates
- **AUDIT:** Financial audits and reconciliation reports
- **COMPLIANCE:** General regulatory compliance documentation

### 4. Real-time Analytics Dashboard

**Business Use Case:** Build live dashboards with KPIs and performance metrics

**Get Dashboard Data**

```javascript
// Fetch comprehensive dashboard for current quarter
const dashboard = await client.analytics.getDashboard({
  period: "QUARTERLY",
  startDate: "2025-01-01",
  endDate: "2025-03-31",
});

// Display key metrics
const metrics = {
  totalInvested: dashboard.totalInvested,
  activeInvestors: dashboard.activeInvestors,
  distributionsYTD: dashboard.distributionsYTD,
  roiYTD: dashboard.roiYTD,
  projectsByStatus: dashboard.projectsByStatus,
};

console.log("Dashboard Metrics:", metrics);
```

**Advanced Dashboard Implementation**

```python
class AnalyticsDashboard:
    def __init__(self, client, org_id):
        self.client = client
        self.org_id = org_id

    async def get_performance_metrics(self, period='MONTHLY'):
        """Fetch and calculate performance metrics"""
        dashboard = await self.client.analytics.get_dashboard(
            period=period,
            start_date=self.get_period_start(period),
            end_date=self.get_period_end(period)
        )

        return {
            'total_invested': dashboard['totalInvested'],
            'active_investors': dashboard['activeInvestors'],
            'roi_ytd': dashboard['roiYTD'],
            'distributions_ytd': dashboard['distributionsYTD'],
            'project_breakdown': dashboard['projectsByStatus']
        }

    def calculate_growth_rate(self, current, previous):
        """Calculate period-over-period growth"""
        if previous == 0:
            return 0
        return ((current - previous) / previous) * 100
```

**Dashboard Period Options:**

- **DAILY:** Day-by-day analytics for operational monitoring
- **WEEKLY:** Week-over-week trends and patterns
- **MONTHLY:** Monthly performance and investor reporting
- **QUARTERLY:** Quarterly business reviews and board reporting
- **YEARLY:** Annual performance and strategic planning

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

- [API Reference](../api-documentation/) - Complete API documentation
- [OpenAPI Specification](/openapi/analytics-reports.yaml) - Machine-readable API spec
- [Code Examples](https://github.com/quub-fi/examples) - Sample implementations
- [Support](https://support.quub.fi) - Get help from our team

---

**Need help?** Contact our support team or join our [developer community](https://community.quub.fi).
