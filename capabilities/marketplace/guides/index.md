---
layout: docs
title: Marketplace Guides
permalink: /capabilities/marketplace/guides/
---

# 📚 Marketplace Implementation Guides

> Comprehensive developer guide for Marketplace: RFQ, OTC negotiations, and auction capabilities — derived only from `openapi/marketplace.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Enable alternative trading mechanisms for private securities (RFQ, OTC, auctions — per spec).
- Provide institutional liquidity for large block trades and illiquid assets.
- Support negotiated pricing and auction-based price discovery.
- Enforce multi-tenant controls and role-based permissions for trading.

### Technical Architecture

Client -> API Gateway -> Marketplace Service -> Matching / Negotiation Engine -> Settlement

### Core Data Models

Defined in `openapi/marketplace.yaml` (use these schemas exactly):

- RFQ: id, orgId, assetId, quantity, side (BUY|SELL), minPrice, maxPrice, status (OPEN|QUOTED|ACCEPTED|EXPIRED|CANCELLED), createdAt, expiresAt
- RFQQuote: id, rfqId, quoterOrgId, price, quantity, status (PENDING|ACCEPTED|REJECTED|EXPIRED), createdAt, expiresAt
- OTCNegotiation: id, orgId, assetId, counterpartyOrgId, side (BUY|SELL), quantity, proposedPrice, agreedPrice, status (INITIATED|NEGOTIATING|AGREED|CANCELLED), createdAt, updatedAt
- Auction: id, orgId, assetId, quantity, auctionType (ENGLISH|DUTCH), startPrice, currentPrice, reservePrice, status (SCHEDULED|ACTIVE|COMPLETED|CANCELLED), startAt, endAt, createdAt
- AuctionBid: id, auctionId, bidderOrgId, bidPrice, quantity, status (ACTIVE|OUTBID|WINNING|WON|LOST), createdAt

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 client or API key with scopes `read:marketplace` / `write:marketplace` (per spec securitySchemes).
- `orgId` value for tenant-scoped operations.

### 5-Minute Setup

1. Obtain an access token or API key.
2. Call a read endpoint to inspect RFQs or auctions.

Example (curl) — list RFQs:

```bash
curl -X GET "https://api.quub.exchange/v1/orgs/{orgId}/marketplace/rfqs" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}"
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/marketplace.yaml`.

### RFQ (Request for Quote)

GET /orgs/{orgId}/marketplace/rfqs — List RFQs (query: requesterId, assetId, status, pagination).

POST /orgs/{orgId}/marketplace/rfqs — Create RFQ. Required body fields: `assetId`, `quantity`, `side` (BUY|SELL). Optional: `minPrice`, `maxPrice`, `expiresAt`.

Example (Node.js) — create an RFQ (uses only fields from the spec):

```javascript
const axios = require("axios");

async function createRfq(baseURL, orgId, token) {
  const resp = await axios.post(
    `${baseURL}/orgs/${orgId}/marketplace/rfqs`,
    {
      assetId: "123e4567-e89b-12d3-a456-426614174000",
      quantity: "1000000",
      side: "BUY",
      minPrice: "25.00",
      maxPrice: "30.00",
      expiresAt: "2025-11-15T16:00:00Z",
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
        "X-Org-Id": orgId,
        "Idempotency-Key": `rfq_${Date.now()}`,
      },
    }
  );

  return resp.data.data; // RFQ (per OpenAPI schema)
}
```

Response schema: `RFQ` (see spec).

GET /orgs/{orgId}/marketplace/rfqs/{rfqId} — Retrieve RFQ details (path param `rfqId`).

POST /orgs/{orgId}/marketplace/rfqs/{rfqId}/quotes — Submit quote for RFQ. Request body fields: `price`, `quantity`, optional `expiresAt`.

Example (Python) — submit a quote for an RFQ:

```python
import requests

def submit_quote(base_url, org_id, token, rfq_id):
    url = f"{base_url}/orgs/{org_id}/marketplace/rfqs/{rfq_id}/quotes"
    headers = {
        "Authorization": f"Bearer {token}",
        "X-Org-Id": org_id,
        "Content-Type": "application/json"
    }
    body = {
        "price": "27.50",
        "quantity": "1000000",
        "expiresAt": "2025-11-15T18:00:00Z"
    }

    resp = requests.post(url, json=body, headers=headers)
    resp.raise_for_status()
    return resp.json()["data"]  # RFQQuote per spec
```

### OTC Negotiations

GET /orgs/{orgId}/marketplace/otc/negotiations — List OTC negotiations (paginated).

POST /orgs/{orgId}/marketplace/otc/negotiations — Create OTC negotiation. Required: `assetId`, `counterpartyOrgId`, `side`, `quantity`. Optional: `proposedPrice`.

GET /orgs/{orgId}/marketplace/otc/{negotiationId} — Retrieve negotiation.

PATCH /orgs/{orgId}/marketplace/otc/{negotiationId} — Update negotiation (fields: `proposedPrice`, `status` with enum values from spec).

### Auctions

GET /orgs/{orgId}/marketplace/auctions — List auctions (paginated).

POST /orgs/{orgId}/marketplace/auctions — Create auction. Required: `assetId`, `quantity`, `auctionType` (ENGLISH|DUTCH), `startPrice`. Optional: `reservePrice`, `startAt`, `endAt`.

GET /orgs/{orgId}/marketplace/auctions/{auctionId} — Get auction details.

POST /orgs/{orgId}/marketplace/auctions/{auctionId}/bids — Place bid on auction. Request body: `bidPrice`, `quantity`.

Example (Node.js) — place a bid on an auction:

```javascript
const axios = require("axios");

async function placeBid(baseURL, orgId, token, auctionId) {
  const resp = await axios.post(
    `${baseURL}/orgs/${orgId}/marketplace/auctions/${auctionId}/bids`,
    {
      bidPrice: "21.00",
      quantity: "100000",
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
        "X-Org-Id": orgId,
      },
    }
  );

  return resp.data.data; // AuctionBid per spec
}
```

## 🔐 Authentication Setup {#authentication}

- Security schemes referenced in the spec: `oauth2` (scopes `read:marketplace`, `write:marketplace`), `apiKey`, and bearer token (via common components).
- Use `X-Org-Id` header for tenant assertion where applicable.

## ✨ Best Practices {#best-practices}

- Use `Idempotency-Key` for POST operations (RFQ, auctions, quotes) to avoid duplicate submissions.
- Validate required fields client-side (`assetId`, `quantity`, `side`, `auctionType`, etc.).
- Use pagination parameters for list endpoints to avoid large responses.

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — malformed payload or missing required fields.
- 401/403: authorization/permission — verify token scopes and API key.
- 404: NotFound — referenced resource (e.g., auctionId) not found.
- 409/422: conflict/validation — handle per endpoint responses (bids can return 409/422 as defined in spec).

## 📊 Monitoring & Observability {#monitoring}

- Track metrics: rfq_creation_rate, rfq_fill_rate, auction_participation, bid_failure_rate.
- Log `Request-Id` for traceability across negotiation workflows.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/marketplace.yaml` (source of truth)
- API docs and overview in `/capabilities/marketplace/`

---

## _This guide was generated strictly from `openapi/marketplace.yaml`; no endpoints or schema properties were invented._

layout: docs
title: Marketplace Guides
permalink: /capabilities/marketplace/guides/

---

# Marketplace Implementation Guides

Comprehensive guides for implementing and integrating Marketplace capabilities.

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

_For API reference, see [Marketplace API Documentation](../api-documentation/)_
