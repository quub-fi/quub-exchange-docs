---
layout: docs
title: Pricing & Reference Data Guides
permalink: /capabilities/pricing-refdata/guides/
---

# 📚 Pricing & Reference Data Implementation Guides

> Comprehensive developer guide for Pricing & Reference Data — symbols, indices, and FX rates — derived only from `openapi/pricing-refdata.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Provide canonical symbol/reference metadata for trading and matching
- Expose FX rates (real-time and historical) used in pricing and settlements
- Publish indices and composite reference data for market feeds

### Technical Architecture

Clients -> API Gateway -> Pricing/Refdata Service -> Data Providers / Index Engines

### Core Data Models

Defined in `openapi/pricing-refdata.yaml` (use these schemas exactly):

- Symbol: symbol, name, baseAsset, quoteAsset, assetClass, tradingHours, tickSize, precision, status (ACTIVE|INACTIVE), createdAt
- FxRate: baseCurrency, quoteCurrency, rate, timestamp, source
- Index: id, name

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 token with scope `read:pricing` or an `apiKey`.

### 5-Minute Setup

1. Obtain a token (OAuth2) or `X-API-KEY`.
2. Call a read endpoint such as `GET /refdata/symbols`.

Example (curl) — list symbols:

```bash
curl -G "https://api.quub.exchange/v1/refdata/symbols" \
  --data-urlencode "assetClass=CRYPTO" \
  --data-urlencode "baseAsset=BTC" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/pricing-refdata.yaml`.

### Symbols

GET /refdata/symbols — List symbols. Query params: `assetClass`, `baseAsset`, `quoteAsset`, `cursor`, `limit`.

GET /refdata/symbols/{symbol} — Get symbol details. Path param: `symbol`.

Response: `Symbol` schema.

Example (Node.js) — get symbol details:

```javascript
const resp = await axios.get(
  `${baseURL}/refdata/symbols/${encodeURIComponent(symbol)}`,
  {
    headers: { Authorization: `Bearer ${token}` },
  }
);
// resp.data.data -> Symbol
```

### FX Rates

GET /refdata/fx-rates — Retrieve FX rates. Query params: `base`, `quote`, `since`, `cursor`, `limit`.

Response: paginated list of `FxRate`.

Example (curl) — get recent USD/EUR rates:

```bash
curl -G "https://api.quub.exchange/v1/refdata/fx-rates" \
  --data-urlencode "base=USD" \
  --data-urlencode "quote=EUR" \
  --data-urlencode "since={since}" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Indices

GET /refdata/indices — List indices. Query params: `type`, `cursor`, `limit`.

Response: paginated list of `Index`.

## 🔐 Authentication Setup {#authentication}

- Security schemes defined in the OpenAPI: `bearerAuth` (OAuth2), `oauth2`, and `apiKey` (see components). Use `read:pricing` scope for these read-only endpoints.

## ✨ Best Practices {#best-practices}

- Use pagination (`cursor`/`limit`) for large symbol lists.
- Filter by `assetClass` or `baseAsset` to reduce payloads.
- For FX rates historical retrieval use `since` with ISO date-time.

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — invalid query parameters.
- 401/403: auth/permission issues — verify token scopes and API key permissions.
- 429: rate limits — implement exponential backoff.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/pricing-refdata.yaml` (source of truth)
- API docs: `/capabilities/pricing-refdata/api-documentation/`

---

## _This guide was generated strictly from `openapi/pricing-refdata.yaml` and existing capability docs; no endpoints or schema properties were invented._

layout: docs
title: Pricing Refdata Guides
permalink: /capabilities/pricing-refdata/guides/

---

# Pricing Refdata Implementation Guides

Comprehensive guides for implementing and integrating Pricing Refdata capabilities.

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

_For API reference, see [Pricing Refdata API Documentation](../api-documentation/)_
