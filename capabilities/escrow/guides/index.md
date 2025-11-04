---
layout: docs
title: Escrow Guides
permalink: /capabilities/escrow/guides/
---

# 📚 Escrow Implementation Guides

> Comprehensive developer guide for implementing escrow account management and milestone-based fund release.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Advanced Topics

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Secure, multi-tenant escrow accounts for conditional fund holding
- Support for fiat and crypto escrow types (FIAT, CRYPTO)
- Milestone- and time-based conditional releases
- Multi-party and agent-based escrow workflows
- Dispute resolution and full audit trails for compliance

### Technical Architecture

Simple ASCII integration diagram:

Escrow Service (REST) <---> Chain Service (crypto ops)
|
+--> Notifications/Webhooks
|
+--> Audit & Logging

### Core Data Models

Use only the schemas defined in `openapi/escrow.yaml`.

- EscrowAccount (properties used in examples):

  - id (uuid)
  - orgId (uuid)
  - escrowType (TWO_PARTY | THREE_PARTY | MULTI_PARTY | MILESTONE)
  - accountType (FIAT | CRYPTO)
  - balance (string)
  - currency (string)
  - walletId (uuid)
  - chainId (string)
  - contractAddress (string)
  - status (PENDING | ACTIVE | RELEASED | DISPUTED | CLOSED)
  - parties (array of { accountId, role })
  - createdAt (date-time)

- CreateEscrowRequest:

  - escrowType (enum)
  - currency (string)
  - parties (array of { accountId, role })

- Milestone:
  - id (uuid)
  - name (string)
  - description (string)
  - releaseAmount (string)
  - status (PENDING | COMPLETED | FAILED)
  - dueDate (date)
  - completedAt (date-time)

## 🎯 Quick Start {#quick-start}

### Prerequisites

- API access (OAuth2 or API Key) with appropriate scopes: `read:escrow`, `write:escrow`.
- `orgId` for multi-tenant requests (provided as path parameter and also via the `x-org-id` header in docs).

### 5-Minute Setup

1. Obtain API credentials (OAuth token or API key).
2. Create an escrow account (example below).
3. Deposit funds (fiat or crypto) using the escrow deposit endpoints.
4. Release funds when conditions are met.

## 🏗️ Core API Operations {#core-operations}

All paths and request/response fields below come directly from `openapi/escrow.yaml` — no extra operations or fields are added.

### Escrow Account Management

- GET /orgs/{orgId}/escrow/accounts — listEscrowAccounts

  - Parameters: `orgId` path, optional pagination (`cursor`, `limit`) and `x-org-id` header.
  - Responses: 200 with paginated `EscrowAccount` items. Errors: 400, 401, 403, 500.

- POST /orgs/{orgId}/escrow/accounts — createEscrowAccount

  - Request body: `CreateEscrowRequest` (escrowType, currency, parties)
  - Responses: 201 with `EscrowAccount`. Errors: 400, 401, 403, 500.

- GET /orgs/{orgId}/escrow/accounts/{escrowId} — getEscrowAccount
  - Path params: `escrowId` (uuid)
  - Responses: 200 with `EscrowAccount`. Errors: 400, 401, 403, 500.

### Deposits

- POST /orgs/{orgId}/escrow/accounts/{escrowId}/deposit — depositToEscrow

  - Request body (application/json): { amount (string), currency (string) }
  - Responses: 201 with updated `EscrowAccount`. Errors: 400, 401, 403, 500.

- POST /orgs/{orgId}/escrow/accounts/{escrowId}/deposit-crypto — depositCryptoToEscrow
  - Request body (application/json): { walletId (uuid), amount (string), tokenAddress (string)?, txHash (string) }
  - Responses: 201 with updated `EscrowAccount`. Errors: 400, 401, 403, 500.

### Release

- POST /orgs/{orgId}/escrow/accounts/{escrowId}/release — releaseFromEscrow

  - Request body: { amount (string), beneficiary (uuid), reason (string)? }
  - Responses: 201 with updated `EscrowAccount`. Errors: 400, 401, 403, 500.

- POST /orgs/{orgId}/escrow/accounts/{escrowId}/release-crypto — releaseCryptoFromEscrow
  - Request body: { beneficiaryWalletId (uuid), amount (string), tokenAddress (string)?, reason (string)?, txHash (string) }
  - Responses: 201 with updated `EscrowAccount`. Errors: 400, 401, 403, 500.

### Milestones

- GET /orgs/{orgId}/escrow/accounts/{escrowId}/milestones — listMilestones
  - Parameters: `orgId`, `escrowId`, pagination
  - Responses: 200 with `Milestone` items. Errors: 400, 401, 404, 500.

### Disputes

- POST /orgs/{orgId}/escrow/accounts/{escrowId}/disputes — openDispute
  - Request body: { reason (string), evidence (array[string])? }
  - Responses: 201 with `EscrowAccount`. Errors: 400, 401, 403, 409, 422, 429, 500.

## 🔐 Authentication Setup {#authentication}

The Escrow OpenAPI defines these security schemes in `components.securitySchemes`:

- `oauth2` — OAuth 2.0 with scopes `read:escrow` and `write:escrow` (used on read/write endpoints respectively).
- `apiKey` — API key header-based access allowed where shown.
- `bearerAuth` — token-based bearer authentication.

Examples below use a bearer token and the `x-org-id` header to set the org context.

## ✨ Examples (Node.js & Python)

Note: examples only use request/response fields and schemas that exist in `openapi/escrow.yaml`.

### Node.js (fetch)

```javascript
// Create an escrow account
const res = await fetch(
  "https://api.quub.exchange/v1/orgs/ORG_ID/escrow/accounts",
  {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.QUUB_TOKEN}`,
      "Content-Type": "application/json",
      "x-org-id": "ORG_ID",
    },
    body: JSON.stringify({
      escrowType: "MILESTONE",
      currency: "USDC",
      parties: [
        { accountId: "acc-depositor", role: "DEPOSITOR" },
        { accountId: "acc-beneficiary", role: "BENEFICIARY" },
      ],
    }),
  }
);
const createBody = await res.json();
console.log("Created escrow:", createBody.data.id);

// Deposit fiat
await fetch(
  `https://api.quub.exchange/v1/orgs/ORG_ID/escrow/accounts/${createBody.data.id}/deposit`,
  {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.QUUB_TOKEN}`,
      "Content-Type": "application/json",
      "x-org-id": "ORG_ID",
    },
    body: JSON.stringify({ amount: "1000.00", currency: "USD" }),
  }
);

// Release part of the funds
await fetch(
  `https://api.quub.exchange/v1/orgs/ORG_ID/escrow/accounts/${createBody.data.id}/release`,
  {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.QUUB_TOKEN}`,
      "Content-Type": "application/json",
      "x-org-id": "ORG_ID",
    },
    body: JSON.stringify({
      amount: "500.00",
      beneficiary: "acc-beneficiary",
      reason: "Completed milestone 1",
    }),
  }
);
```

### Python (requests)

```python
import os
import requests

BASE = 'https://api.quub.exchange/v1'
HEADERS = {
    'Authorization': f"Bearer {os.getenv('QUUB_TOKEN')}",
    'Content-Type': 'application/json',
    'x-org-id': 'ORG_ID'
}

# Create escrow account
resp = requests.post(
    f"{BASE}/orgs/ORG_ID/escrow/accounts",
    headers=HEADERS,
    json={
        'escrowType': 'MILESTONE',
        'currency': 'USDC',
        'parties': [
            {'accountId': 'acc-depositor', 'role': 'DEPOSITOR'},
            {'accountId': 'acc-beneficiary', 'role': 'BENEFICIARY'}
        ]
    }
)
account = resp.json()['data']

# Deposit crypto
requests.post(
    f"{BASE}/orgs/ORG_ID/escrow/accounts/{account['id']}/deposit-crypto",
    headers=HEADERS,
    json={
        'walletId': 'wallet-123',
        'amount': '1000000000000000000',
        'tokenAddress': '0xA0b86a33E6441e88C5F2712C3E9b74Ae1f8Dc9dD',
        'txHash': '0x8ba1f109551bd432803012645ac136ddd64dba72'
    }
)

# List milestones
ms = requests.get(f"{BASE}/orgs/ORG_ID/escrow/accounts/{account['id']}/milestones", headers=HEADERS).json()
for m in ms.get('data', []):
    print(m['name'], m.get('status'))
```

## ✨ Best Practices {#best-practices}

- Validate party roles and permissions before creating an escrow (`DEPOSITOR`, `BENEFICIARY`, `AGENT`).
- Use idempotency at the client side for create/deposit/release operations to avoid duplicate actions.
- For crypto flows, verify transaction hashes (`txHash`) via the Chain service before accepting deposits or releases.
- Use pagination for listing endpoints (`cursor`, `limit`).
- Implement retry/backoff for transient 5xx errors.

## 🔒 Security Guidelines {#security}

- Enforce `read:escrow` and `write:escrow` scopes for read/write endpoints as defined in the OpenAPI spec.
- Use TLS for all API calls and rotate API keys/tokens regularly.
- Limit operations by role: only `AGENT` and authorized approvers should be able to trigger releases.
- Log all release and dispute actions for audit and compliance.

## 🚀 Performance Optimization {#performance}

- Cache read-only lookups (e.g., escrow metadata) where appropriate but never cache balances.
- Batch milestone checks where the business flow requires multiple milestone statuses.
- For high-volume crypto releases, optimize gas and batch on-chain transactions via the Chain service when supported.

## 🔧 Advanced Configuration {#advanced}

- Multi-signature releases: implement the multi-sig approval flow in your application logic and only call the release endpoint once required approvals are satisfied.
- Milestone automation: trigger release calls from your CI/CD or orchestration system when external criteria are met (e.g., webhook from project management tool).

## 🔍 Troubleshooting {#troubleshooting}

- 400 Bad Request: check required fields and types (e.g., amount must be provided when depositing/releasing).
- 401/403: verify token scopes and that `x-org-id` matches the token's org.
- 404 on milestones: ensure `escrowId` is correct and the escrow exists in the org.
- 409 Conflict when opening a dispute: indicate the escrow is in a non-modifiable state; check `status`.
- 5xx: transient server issue — retry with exponential backoff and surface alerts to operations.

## 📊 Monitoring & Observability {#monitoring}

Track these key metrics (map to your observability stack):

- `escrow_accounts_created_total`
- `escrow_deposits_total` and `escrow_deposits_failed_total`
- `escrow_releases_total` and `escrow_release_failures_total`
- `escrow_disputes_opened_total`
- API latency p95/p99 for escrow endpoints

Alert examples:

- High dispute rate (> threshold in 5m)
- Repeated release failures
- Large balance mismatches between ledger and calculated funds

## 📚 Additional Resources

- OpenAPI spec: `/openapi/escrow.yaml`
- API documentation: `/capabilities/escrow/api-documentation/index.md`
- Overview: `/capabilities/escrow/overview/index.md`

---

## This guide was generated directly from `openapi/escrow.yaml`. All endpoints, request/response fields, parameters, and security schemes shown above match the OpenAPI file and no operations or schema fields were invented.

layout: docs
title: Escrow Guides
permalink: /capabilities/escrow/guides/

---

# Escrow Implementation Guides

Comprehensive guides for implementing and integrating Escrow capabilities.

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

_For API reference, see [Escrow API Documentation](../api-documentation/)_
