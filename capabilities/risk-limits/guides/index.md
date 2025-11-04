---
layout: docs
title: Risk & Limits Guides
permalink: /capabilities/risk-limits/guides/
---

# 📚 Risk & Limits Implementation Guides

> Comprehensive developer guide for Risk & Limits: risk limits, pre-trade checks, and circuit breakers — derived only from `openapi/risk-limits.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Configure and retrieve organization-level quantitative risk limits
- Run pre-trade validation to prevent orders that breach limits
- Expose circuit breaker state to halt trading on extreme events

### Technical Architecture

Client -> API Gateway -> Risk Service -> Risk Engine / Limit Store

### Core Data Models

Defined in `openapi/risk-limits.yaml` (use these schemas exactly):

- RiskLimit: id, limitType (ORDER_SIZE|POSITION_SIZE|DAILY_VOLUME|NOTIONAL_VALUE), maxValue, currency, updatedAt
- CircuitBreaker: symbol, triggerType (PRICE_DROP|PRICE_SPIKE|VOLUME_SURGE), threshold, active, triggeredAt

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 token with scopes `read:risk` or `write:risk` depending on operation, or an `apiKey`.
- `orgId` for organization-scoped endpoints.

### 5-Minute Setup

1. Obtain an access token or API key.
2. Fetch current risk limits for your org.

Example (curl) — list risk limits:

```bash
curl -X GET "https://api.quub.exchange/v1/orgs/{orgId}/risk/limits" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}"
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/risk-limits.yaml`.

### Risk Limits

GET /orgs/{orgId}/risk/limits — Retrieve current risk limits for the organization.

PUT /orgs/{orgId}/risk/limits — Update risk limits. Request body: { limits: RiskLimit[] }.

Example (Node.js) — update limits

```javascript
await axios.put(
  `${baseURL}/orgs/${orgId}/risk/limits`,
  { limits: [{ limitType: "ORDER_SIZE", maxValue: 1000, currency: "USD" }] },
  { headers: { Authorization: `Bearer ${token}`, "X-Org-Id": orgId } }
);
```

Response: 200 on success; other errors per spec (400/401/403/500).

### Pre-Trade Checks

POST /orgs/{orgId}/risk/pre-trade-check — Validate an order against configured limits before execution.

Request body (required): symbol (string), side (BUY|SELL), quantity (number), price (number).

Response: { approved: boolean, reason: string|null, limitBreaches: RiskLimit[] }

Example (curl):

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/risk/pre-trade-check" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "symbol": "BTC-USD", "side": "BUY", "quantity": 5.0, "price": 45000.0 }'
```

### Circuit Breakers

GET /orgs/{orgId}/risk/circuit-breakers — Retrieve current circuit breaker status for the organization.

Response: object with `data: CircuitBreaker[]`.

Example (Python):

```python
resp = requests.get(f"{base_url}/orgs/{org_id}/risk/circuit-breakers",
                    headers={"Authorization": f"Bearer {token}", "X-Org-Id": org_id})
```

## 🔐 Authentication Setup {#authentication}

- Security schemes referenced in the spec: `bearerAuth`, `oauth2`, `apiKey`. Use `write:risk` for mutating operations and `read:risk` for read operations.

## ✨ Best Practices {#best-practices}

- Run pre-trade checks synchronously in order validation pipelines to fail-fast on breaches.
- Use small, idempotent updates to limits and validate input types on the client-side.
- Monitor circuit breaker active state and surface alerts to operations teams when `active=true`.

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — invalid request body or missing required fields.
- 401/403: auth/permission — confirm token scopes and API key permissions.
- 409: Conflict — resource state conflict; handle retries or surface appropriate error messages.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/risk-limits.yaml` (source of truth)

---

## _This guide was generated strictly from `openapi/risk-limits.yaml` and existing capability docs; no endpoints or schema properties were invented._

layout: docs
title: Risk Limits Guides
permalink: /capabilities/risk-limits/guides/

---

# Risk Limits Implementation Guides

Comprehensive guides for implementing and integrating Risk Limits capabilities.

## 📚 Available Guides

### Getting Started

- [Quick Start Guide](/docs/quickstart/) - Get up and running quickly
- [Integration Guide](/guides/getting-started/) - Step-by-step integration instructions

### Best Practices

- [Best Practices](/docs/best-practices/) - Recommended patterns and approaches
- [Security Guide](/guides/getting-started/security-guide) - Security implementation guidelines

### Advanced Topics

- [Troubleshooting](/guides/getting-started/troubleshooting) - Common issues and solutions
- [Performance Optimization](/guides/getting-started/performance-optimization) - Optimization strategies

### Migration & Deployment

- [Migration Guide](/changelog/) - Upgrade and migration instructions
- [Deployment Guide](/guides/getting-started/deployment-guide) - Production deployment strategies

---

_For API reference, see [Risk Limits API Documentation](../api-documentation/)_
