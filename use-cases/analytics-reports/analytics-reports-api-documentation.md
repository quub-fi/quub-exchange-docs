---
layout: use-case
permalink: /use-cases/analytics-reports
---

# Analytics & Reports API Documentation

_Based on OpenAPI specification: `analytics-reports.yaml`_

## 📋 Executive Summary

> **Audience: Stakeholders**

The Analytics & Reports service provides comprehensive business intelligence and automated reporting capabilities for the Quub Exchange platform. This service enables organizations to generate real-time insights, compliance reports, and performance analytics across all trading and operational activities. Key value propositions include automated regulatory reporting, customizable business intelligence dashboards, and data-driven decision support for financial operations.

## 🎯 Service Overview

> **Audience: All**

### Business Purpose

- Automated generation of regulatory and compliance reports
- Real-time business intelligence and performance analytics
- Customizable reporting for stakeholders and management
- Data visualization and trend analysis for operational insights
- Audit trail and transaction reporting for compliance requirements

### Technical Architecture

- RESTful API with JWT-based authentication
- Multi-tenant data isolation with organization-scoped access
- Real-time data processing and report generation
- Scalable analytics engine with caching capabilities
- Integration with all platform services for comprehensive reporting

## 📊 API Specifications

> **Audience: Technical**

### Base Configuration

````yaml
servers:
  - url: https://api.quub.fi/v1/analytics
    description: Production environment
  - url: https://sandbox-api.quub.fi/v1/analytics
    description: Sandbox environment

security:
  - BearerAuth: []

# Analytics API — Authentication, Endpoints, Security & Implementation Guide

**Last updated:** November 2, 2025
**API Version:** v1 · **Document Version:** 1.0
**Audience:** Technical, Project Teams, Stakeholders

---

## 🔐 Authentication & Authorization

* **JWT access token** required with scopes:

  * `analytics:read`
  * `analytics:write` (for report generation or mutating actions)
* **Organization-scoped access** enforced via **`orgId`** validation (taken from JWT, never from request body)
* **Role-based permissions** required for sensitive financial data
* **Audit logging** on every analytics access and report generation/download

> **Important:** All endpoints reject requests where the URL/org context does not match the JWT’s `orgId`.

---


{% include api-nav-banner.html %}

## 🚀 Core Endpoints

### Reports Management

#### Generate Report

**Business Use Case:** Create automated reports for compliance, performance analysis, and business intelligence.

**Endpoint:** `POST /orgs/{orgId}/analytics/reports`
**Scopes:** `analytics:write`

**Request Example (JSON):**

```json
{
  "type": "COMPLIANCE_SUMMARY",
  "format": "PDF",
  "dateRange": {
    "from": "2025-10-01",
    "to": "2025-10-31"
  },
  "filters": {
    "markets": ["BTC-USD", "ETH-USD"],
    "includePII": false
  },
  "delivery": {
    "webhookUrl": "https://example.com/hooks/reports",
    "notifyEmail": "ops@example.com"
  }
}
````

**Response Example (202 Accepted):**

```json
{
  "reportId": "rpt_01HE0X4M5K3V9Q8",
  "status": "QUEUED",
  "estimatedReadyAt": "2025-11-02T12:02:30Z",
  "links": {
    "status": "/orgs/ORG123/analytics/reports/rpt_01HE0X4M5K3V9Q8/status"
  }
}
```

**Project Implementation Notes:**

- Validate date ranges for reasonable reporting periods (e.g., max 90 days).
- Ensure organization access to requested data.
- Implement **async** processing for large reports; return 202 + status link.
- Add **progress tracking** for long-running reports (percentage, ETA).

---

#### Get Report Status

**Business Use Case:** Track report generation progress and retrieve completed reports.

**Endpoint:** `GET /orgs/{orgId}/analytics/reports/{reportId}/status`
**Scopes:** `analytics:read`

**Response Example (200):**

```json
{
  "reportId": "rpt_01HE0X4M5K3V9Q8",
  "status": "COMPLETED",
  "progress": 100,
  "generatedAt": "2025-11-02T12:02:02Z",
  "output": {
    "format": "PDF",
    "sizeBytes": 2384012,
    "downloadUrl": "https://downloads.quub.exchange/r/...signed..."
  },
  "audit": {
    "requestedBy": "usr_9f3...",
    "requestedAt": "2025-11-02T12:00:00Z"
  }
}
```

---

### Analytics Data

#### Get Trading Metrics

**Business Use Case:** Real-time trading performance and volume analytics.

**Endpoint:** `GET /orgs/{orgId}/analytics/metrics/trading`
**Scopes:** `analytics:read`

**Query Parameters:**

- `from` / `to` (ISO dates or ISO datetimes)
- `interval` (e.g., `1m`, `5m`, `1h`, `1d`)
- `markets` (comma-separated, optional)
- `limit` (pagination, default 500)

**Response Example (200):**

```json
{
  "orgId": "ORG123",
  "interval": "1h",
  "range": { "from": "2025-11-01T00:00:00Z", "to": "2025-11-02T00:00:00Z" },
  "data": [
    {
      "timestamp": "2025-11-01T00:00:00Z",
      "market": "BTC-USD",
      "trades": 1382,
      "volume": 421.53,
      "notionalUSD": 15432962.12,
      "vwap": 36619.84
    }
  ],
  "meta": { "nextCursor": null }
}
```

---

#### Get Compliance Metrics

**Business Use Case:** Regulatory compliance monitoring and violation detection.

**Endpoint:** `GET /orgs/{orgId}/analytics/metrics/compliance`
**Scopes:** `analytics:read`

**Response Example (200):**

```json
{
  "orgId": "ORG123",
  "period": { "from": "2025-10-01", "to": "2025-10-31" },
  "kpis": {
    "kycApprovedRate": 0.992,
    "suspiciousActivityCount": 3,
    "tradeHaltIncidents": 1,
    "breachEvents": 0
  },
  "alerts": [
    {
      "id": "alrt_01",
      "type": "SAR",
      "status": "OPEN",
      "createdAt": "2025-10-15T10:11:12Z"
    }
  ]
}
```

---

### Dashboard Data

#### Get Dashboard Configuration

**Business Use Case:** Retrieve customizable dashboard configurations for business intelligence.

**Endpoint:** `GET /orgs/{orgId}/analytics/dashboard/config`
**Scopes:** `analytics:read`

**Response Example (200):**

```json
{
  "widgets": [
    {
      "id": "w_vol",
      "type": "volumeChart",
      "title": "Daily Volume",
      "params": { "interval": "1d" }
    },
    {
      "id": "w_rt",
      "type": "realtimeKPIs",
      "title": "Realtime KPIs",
      "params": {}
    }
  ],
  "layout": {
    "cols": 12,
    "items": [
      { "widgetId": "w_vol", "x": 0, "y": 0, "w": 8, "h": 4 },
      { "widgetId": "w_rt", "x": 8, "y": 0, "w": 4, "h": 4 }
    ]
  }
}
```

---

## 🔐 Security Implementation

### Multi-tenant Isolation

- **JWT `orgId`** is the single source of truth (validated against URL `orgId`).
- **RLS/tenant filters** applied at repository/DB level.
- Cross-org queries are **rejected** (403) and **audited**.

### Data Protection

- Financial data encrypted **in transit (TLS)** and **at rest (KMS)**
- **PII masked** unless requester has explicit role/scope
- Report downloads via **time-limited signed URLs**
- **Audit logging** for: access, generation, download, and admin actions

### Access Controls

- Role-based authorization (e.g., `AnalyticsViewer`, `AnalyticsAdmin`)
- Scope checks (`analytics:read`, `analytics:write`) at middleware
- Principle of least privilege; deny by default

---

## 📈 Business Workflows

### Primary Workflow — Automated Compliance Reporting

- **Value:** Automated regulatory compliance, reduced manual effort, higher accuracy
- **Success Metrics:** 100% on-time delivery · 99.9% data accuracy · zero compliance violations

### Secondary Workflow — Real-time Performance Dashboard

- **Value:** Real-time visibility into trading performance and operations
- **Success Metrics:** <100ms widget API response · 99.99% uptime · near real-time freshness

---

## 🧪 Integration Guide

### Development Setup

- Configure **JWT verification** (issuer, audience, JWKS or shared secret)
- Set **org context** from token; never accept `orgId` from request body
- Enable **audit logs** and **signed URLs** for report downloads

### Code Examples

#### JavaScript / Node.js (fetch)

```js
const token = process.env.ANALYTICS_TOKEN; // JWT with analytics:read
const orgId = process.env.ORG_ID;

const res = await fetch(
  `https://api.quub.exchange/orgs/${orgId}/analytics/metrics/trading?from=2025-11-01&to=2025-11-02&interval=1h`,
  { headers: { Authorization: `Bearer ${token}` } }
);
const data = await res.json();
console.log(data);
```

#### Python (requests)

```python
import os, requests

TOKEN = os.getenv("ANALYTICS_TOKEN")
ORG_ID = os.getenv("ORG_ID")

resp = requests.get(
    f"https://api.quub.exchange/orgs/{ORG_ID}/analytics/reports/{'rpt_01'}/status",
    headers={"Authorization": f"Bearer {TOKEN}"}
)
print(resp.json())
```

### Testing Strategy

- Unit tests for handlers and validators
- Integration tests for route→handler mapping and auth
- E2E tests for JWT, org isolation, and signed URL downloads

---

## 📊 Error Handling

### Standard Error Responses

All errors return a JSON body:

```json
{ "code": "FORBIDDEN", "message": "Insufficient permissions" }
```

### Error Codes Reference

| Code                       | HTTP Status | Description                        | Action Required              |
| -------------------------- | ----------: | ---------------------------------- | ---------------------------- |
| `UNAUTHORIZED`             |         401 | Invalid or missing JWT token       | Check authentication         |
| `FORBIDDEN`                |         403 | Insufficient analytics permissions | Verify role and scopes       |
| `INVALID_DATE_RANGE`       |         400 | Invalid or excessive date range    | Adjust date parameters       |
| `REPORT_NOT_FOUND`         |         404 | Report ID does not exist           | Verify report ID             |
| `REPORT_GENERATION_FAILED` |         500 | Report generation system error     | Retry or contact support     |
| `RATE_LIMIT_EXCEEDED`      |         429 | Too many report requests           | Implement request throttling |

**Best Practices**

- Validate inputs early, return specific `code`
- Use idempotency keys for report generation
- Include `retryAfter` header for 429s

---

## 📋 Implementation Checklist

### Pre-Development

- [ ] Analytics API access credentials obtained
- [ ] Sandbox environment access verified and tested
- [ ] Multi-tenant isolation requirements understood
- [ ] Report format specifications reviewed
- [ ] Data privacy and compliance requirements documented

### Development Phase

- [ ] JWT authentication implemented with proper scopes
- [ ] Organization ID validation implemented
- [ ] Error handling for all endpoint interactions
- [ ] Async report generation with status polling
- [ ] Report download via secure, time-limited URLs
- [ ] Logging and monitoring instrumentation added

### Testing Phase

- [ ] Unit tests for all analytics functions
- [ ] Integration tests with live sandbox data
- [ ] Multi-tenant isolation verified in tests
- [ ] Performance benchmarks met (<2s report kick-off)
- [ ] Security scan completed for data handling
- [ ] Report format validation (PDF, Excel, CSV)

### Production Readiness

- [ ] Production credentials configured securely
- [ ] Monitoring and alerting for report failures
- [ ] Dashboard integration tested and deployed
- [ ] Documentation updated with production endpoints
- [ ] Team training completed on analytics features
- [ ] Backup and disaster recovery procedures documented

---

## 📈 Monitoring & Observability

**Key Metrics**

- Report generation success rate (target: **>99%**)
- Average report generation time (target: **<30s**)
- API response time for metrics endpoints (target: **<500ms**)
- Dashboard load time (target: **<2s**)
- Data freshness lag (target: **<5min**)

**Logging Requirements**

- Auth decisions, org validations
- Request/response metadata (redact PII)
- Report lifecycle (queued, running, completed, failed)

**Alerting Configuration**

- High failure rate in generation
- Elevated latency or timeouts
- Unauthorized/forbidden spikes (potential abuse)
- Stale data freshness beyond SLO

---

## 🔄 API Versioning & Evolution

**Current Version:** `v1`

- Backward compatibility guaranteed for minor updates
- **Deprecation policy:** 6 months notice for breaking changes
- Migration support with **parallel versions** during transitions

**Planned Enhancements (v1.1)**

- Real-time streaming analytics endpoints
- Enhanced dashboard customization options
- ML-powered anomaly detection
- Advanced compliance templates

**Breaking Changes (v2.0 – Future)**

- Restructured response formats for consistency
- Mandatory **mTLS**
- Expanded multi-tenant isolation capabilities
- GraphQL endpoint alternatives

---

## 📚 Additional Resources

**For Stakeholders**

- Analytics ROI Analysis
- Competitive Feature Comparison
- Regulatory Compliance Summary

**For Technical Teams**

- OpenAPI Specification
- Postman Collection
- SDK Documentation
- Performance Benchmarks

**For Project Teams**

- Implementation Timeline
- Resource Requirements
- Risk Assessment
- Integration Testing Guide

---
