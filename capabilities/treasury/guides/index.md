---
layout: docs
title: Treasury Guides
permalink: /capabilities/treasury/guides/
---

# 📚 Treasury & Reconciliation Implementation Guides

> Comprehensive developer guide for the Treasury service: escrow accounts, payments, distributions, ledger entries, and reconciliation — derived only from `openapi/treasury.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Advanced Topics

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Manage escrow accounts and project-level balances
- Create and track payments and distribution batches
- Provide ledger entries for auditability
- Run reconciliation and upload attestations (proof files)
- Stream live reconciliation events for continuous proof-of-reserves

### Technical Architecture

Client -> API Gateway -> Treasury Service -> Escrow/Banks / Ledger / Reconciliation Engine

### Core Data Models

Defined in `openapi/treasury.yaml` (use these schemas exactly):

- EscrowAccount: id, projectId, orgId, currency, balance, holdBalance, status, bankAccount, createdAt
- Payment (domain model referenced): see `common/domain-models.yaml` for `Payment` schema used by endpoints
- Distribution: id, tokenClassId, projectId, type (DIVIDEND|INTEREST|...), totalAmount, currency, perShareAmount, recordDate, paymentDate, status
- LedgerEntry: id, type (DEBIT|CREDIT), accountRef, amount, currency, description, relatedEntityType, relatedEntityId, timestamp, orgId, accountId
- ReconciliationReport & ReconciliationStreamMessage: reconciliation details and live stream messages

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 scopes: `read:treasury` and/or `write:treasury` depending on operations, or an `apiKey` with the correct permissions.
- `orgId` and (where applicable) `projectId`, `escrowId`, or `reportId`.

### 5-minute setup

1. Obtain an access token or API key.
2. Call a read endpoint to inspect escrow accounts or payments.

Example (curl) — list escrow accounts:

```bash
curl -G "https://api.quub.exchange/v1/orgs/{orgId}/escrows" \
	--data-urlencode "projectId={projectId}" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}"
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/treasury.yaml`.

### Escrow Accounts

GET /orgs/{orgId}/escrows — List escrow accounts (supports `projectId`, pagination).

POST /orgs/{orgId}/escrows — Open escrow account. Required body fields: `currency` (ISO 3-letter) and `projectId`.

GET /orgs/{orgId}/escrows/{escrowId} — Get details for a single escrow account.

Example (Node.js) — create escrow

```javascript
const resp = await axios.post(
  `${baseURL}/orgs/${orgId}/escrows`,
  {
    currency: "USD",
    projectId: projectId,
    bankRef: "CITI-ESCROW-12345",
  },
  {
    headers: {
      Authorization: `Bearer ${token}`,
      "Idempotency-Key": idempotencyKey,
    },
  }
);
// resp.data -> EscrowAccount
```

### Payments

GET /orgs/{orgId}/payments — List payments (filters: `direction`, `status`).

POST /orgs/{orgId}/payments — Create payment. Required body fields include `direction`, `method`, `amount`, `currency`.

Response models reference the `Payment` domain model from `common/domain-models.yaml`.

### Distributions

GET /orgs/{orgId}/distributions — List distribution batches.

POST /orgs/{orgId}/distributions — Create a distribution batch. Required fields: `tokenClassId`, `period`, `net` (see spec for full properties).

### Ledger

GET /orgs/{orgId}/ledger — Query ledger entries; optional `accountId` filter. Returns `LedgerEntry[]`.

### Reconciliation

GET /orgs/{orgId}/reconciliation — List reconciliation reports (date filters available).

POST /orgs/{orgId}/reconciliation — Trigger daily reconciliation (optional `date` body).

GET /orgs/{orgId}/reconciliation/{reportId} — Retrieve a detailed reconciliation report.

POST /orgs/{orgId}/reconciliation/{reportId}/attest — Upload an attestation/proof file (multipart/form-data); `type` must be one of `bank_statement`, `onchain_proof`, or `audit_certificate`.

### Live Reconciliation Stream (WebSocket)

GET /orgs/{orgId}/reconciliation/live-status — WebSocket stream for real-time reconciliation messages (protocol: wss). Messages conform to `ReconciliationStreamMessage` schema.

Example (curl) — trigger reconciliation

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/reconciliation" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}" \
	-H "Content-Type: application/json" \
	-d '{"date":"2025-11-03"}'
```

## 🔐 Authentication Setup {#authentication}

- Security schemes in the spec: `bearerAuth`, `oauth2`, and `apiKey`. Use `read:treasury` for read operations and `write:treasury` for mutating operations.

## ✨ Best Practices {#best-practices}

- Use `Idempotency-Key` on POST endpoints (escrow creation, payments, distributions) to avoid duplicate side-effects.
- For reconciliation uploads, use `multipart/form-data` and set the `type` to a supported enum value.
- Stream live reconciliation for continuous proof-of-reserves and verify message signatures (HMAC) when using the WebSocket.

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest for malformed payloads or invalid enums.
- 401/403: check OAuth scopes and API key permissions.
- 409: conflict for duplicate resources (use idempotency keys to avoid).
- 422: validation errors for request bodies.

## 📊 Monitoring & Observability {#monitoring}

- Monitor reconciliation `status` and `hashRoot` consistency across reports.
- Track ledger query rates and payment processing latency.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/treasury.yaml` (source of truth)
- Domain models: `/openapi/common/domain-models.yaml`

---

_This guide was generated strictly from `openapi/treasury.yaml` and existing capability docs; no endpoints or schema properties were invented._

---

layout: docs
title: Treasury Guides
permalink: /capabilities/treasury/guides/

---

# Treasury Implementation Guides

Comprehensive guides for implementing and integrating Treasury capabilities.

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

_For API reference, see [Treasury API Documentation](../api-documentation/)_
