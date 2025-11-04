---
layout: docs
title: Market Oracles Guides
permalink: /capabilities/market-oracles/guides/
---

# 📚 Market Oracles Implementation Guides

> Comprehensive developer guide for Market Oracles: valuations, oracle attestations, price ticks, and disclosures — derived only from `openapi/market-oracles.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Provide NAV/valuation reporting for tokenized assets
- Publish cryptographically-signed oracle attestations
- Stream and query high-frequency price ticks
- Publish investor and public disclosures

### Technical Architecture

Client -> API Gateway -> Market Oracles Service -> Data Providers / Vaults -> Consumers

### Core Data Models

Defined in `openapi/market-oracles.yaml` (use these schemas exactly):

- ValuationReport: id, orgId, projectId, basis (MARKET|COST|INCOME|APPRAISAL), navTotal, navPerToken, asOfDate, attachments, signerOrgId, createdAt
- OracleAttestation: id, orgId, type (NAV|PRICE|COLLATERAL|SUPPLY|CUSTOM), referenceId, value, source, signature, timestamp
- PriceTick: id, instrumentId, price, timestamp, source
- Disclosure: id, orgId, projectId, type (RISK|UPDATE|FINANCIAL|LEGAL), contentUrl, publishedAt

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 client or org API key with scopes `read:market-oracles` / `write:market-oracles`.
- `orgId` and (where applicable) `projectId` or `instrumentId` values.

### 5-minute setup

1. Obtain an access token (OAuth2) or `X-API-KEY`.
2. Call a read endpoint to inspect available data, e.g., valuations or price ticks.

Example (curl) — list valuations:

```bash
curl -X GET "https://api.quub.exchange/v2/orgs/{orgId}/valuations" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}"
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/market-oracles.yaml`.

### Valuations

GET /orgs/{orgId}/valuations — List valuation reports (paginated). Query: `projectId`.

POST /orgs/{orgId}/valuations — Submit a valuation report. Required body fields: `projectId`, `basis`, `navTotal`, `asOfDate`.

Example (node): submit a valuation

```javascript
const resp = await axios.post(
  `${baseURL}/orgs/${orgId}/valuations`,
  {
    projectId: projectId,
    basis: "MARKET",
    navTotal: 1000000.0,
    asOfDate: "2025-11-02",
  },
  {
    headers: {
      Authorization: `Bearer ${token}`,
      "Idempotency-Key": `val_${Date.now()}`,
    },
  }
);
```

Response schema: `ValuationReport` (see spec).

### Oracle Attestations

GET /orgs/{orgId}/market-oracles/oracle — List attestations; query `type` (NAV|PRICE|...).

POST /orgs/{orgId}/market-oracles/oracle — Submit an attestation. Request body schema: `OracleAttestation`.

Notes: attestations must be cryptographically signed; include idempotency header on writes.

### Price Ticks

GET /data/price-ticks — Query by `instrumentId` (required) and optional `since` date-time. Returns `PriceTick[]`.

POST /data/price-ticks — Submit a new tick. Request body schema: `PriceTick`.

Example (curl) — query recent ticks:

```bash
curl -X GET "https://api.quub.exchange/v2/data/price-ticks?instrumentId={instrumentId}&since=2025-11-01T00:00:00Z" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Disclosures

GET /orgs/{orgId}/disclosures — List disclosures (paginated). Query: `projectId`, `type`.

POST /orgs/{orgId}/disclosures — Publish a disclosure. Required body: `projectId`, `type`, `contentUrl`.

Response schema: `Disclosure`.

## 🔐 Authentication Setup {#authentication}

- OAuth2 (scopes `read:market-oracles`, `write:market-oracles`) or `X-API-KEY` header.
- Use `X-Org-Id` header for tenant assertion where helpful.

## ✨ Best Practices {#best-practices}

- Use `Idempotency-Key` on POST endpoints to prevent duplicate submissions.
- Validate required fields client-side before sending (e.g., `instrumentId`, `projectId`).
- For price ticks, prefer streaming (WebSocket) where available; otherwise poll `GET /data/price-ticks` with `since`.

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — malformed request or missing required fields.
- 401/403: auth/permission issues — check token scopes and API key permissions.
- 429: rate limits — back off and retry with exponential backoff.

## 📊 Monitoring & Observability {#monitoring}

- Track metrics: tick_ingest_rate, attestation_success_rate, valuation_publication_latency.
- Log `Request-Id` header for traceability and audits.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/market-oracles.yaml` (source of truth)
- API docs: `/capabilities/market-oracles/api-documentation/`

---

## _This guide was generated strictly from `openapi/market-oracles.yaml` and existing capability docs; no endpoints or schema properties were invented._

layout: docs
title: Market Oracles Guides
permalink: /capabilities/market-oracles/guides/

---

# Market Oracles Implementation Guides

Comprehensive guides for implementing and integrating Market Oracles capabilities.

## 📚 Available Guides

### Getting Started

- [Quick Start Guide](./getting-started.md) - Get up and running quickly
- [Integration Guide](./integration-guide.md) - Step-by-step integration instructions

### Best Practices

- [Best Practices](./best-practices.md) - Recommended patterns and approaches
- [Security Guide](./security-guide.md) - Security implementation guidelines

### Advanced Topics

- [Troubleshooting](./troubleshooting.md) - Common issues and solutions
- [Performance Optimization](./performance-optimization.md) - Optimization strategies

### Migration & Deployment

- [Migration Guide](./migration-guide.md) - Upgrade and migration instructions
- [Deployment Guide](./deployment-guide.md) - Production deployment strategies

---

_For API reference, see [Market Oracles API Documentation](../api-documentation/)_
