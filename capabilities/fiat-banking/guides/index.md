---
layout: docs
title: Fiat Banking Guides
permalink: /capabilities/fiat-banking/guides/
---

# 📚 Fiat Banking Implementation Guides

> Comprehensive developer guide for implementing fiat banking connectors, deposits, withdrawals, settlements, and account management (derived only from OpenAPI `fiat-banking.yaml`).

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Advanced Topics

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Provide banking connectors for fiat on/off-ramps
- Manage organization-linked bank accounts and balances
- Create and track fiat deposits (wire/ACH/SEPA)
- Create and track fiat withdrawals with approval flows
- Produce settlement batches for reconciliation

### Technical Architecture

Simple ASCII integration diagram (request flow):

Quub Client -> API Gateway -> Fiat Banking Service -> Banking Connectors -> Bank

### Core Data Models

Use only properties defined in `openapi/fiat-banking.yaml`.

- BankAccount

  - id (uuid)
  - bankName (string)
  - accountNumber (string)
  - routingNumber (string)
  - iban (string, nullable)
  - swift (string, nullable)
  - accountType (enum: CHECKING | SAVINGS)
  - currency (string)
  - status (enum: ACTIVE | SUSPENDED | CLOSED)

- Deposit

  - id (uuid)
  - orgId (uuid)
  - accountId (uuid)
  - amount (number)
  - currency (string)
  - status (enum: PENDING | COMPLETED | FAILED)
  - reference (string)
  - createdAt (date-time)

- Withdrawal

  - id (uuid)
  - orgId (uuid)
  - accountId (uuid)
  - amount (number)
  - currency (string)
  - status (enum: PENDING | PROCESSING | COMPLETED | FAILED)
  - reference (string)
  - createdAt (date-time)

- Settlement
  - id (uuid)
  - orgId (uuid)
  - period (string)
  - currency (string)
  - totalCredits (number)
  - totalDebits (number)
  - netAmount (number)
  - status (enum: PENDING | CONFIRMED | FAILED)
  - settledAt (date-time, nullable)

## 🎯 Quick Start {#quick-start}

### Prerequisites

- API credentials (OAuth2 client or org-bound API key)
- Organization UUID (orgId)
- Network access to https://api.quub.exchange/v2 or sandbox

### 5-Minute Setup

1. Obtain OAuth2 client credentials or an X-API-KEY value.
2. Ensure you have an `orgId` value to scope requests.
3. Try listing accounts to discover available bank accounts.

Example curl: List accounts

```bash
curl -X GET "https://api.quub.exchange/v2/orgs/{orgId}/banking/accounts" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}"
```

## 🏗️ Core API Operations {#core-operations}

All operations and parameters below are taken directly from `openapi/fiat-banking.yaml`.

### Banking Accounts

GET /orgs/{orgId}/banking/accounts

Description: List fiat accounts linked to an organization. Supports pagination via cursor and limit parameters.

Request (curl):

```bash
curl -X GET "https://api.quub.exchange/v2/orgs/{orgId}/banking/accounts" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}"
```

Response (schema: PageResponse with data: BankAccount[]):

```json
{
  "data": [
    {
      "id": "acc_12345678-90ab-cdef-1234-567890abcdef",
      "bankName": "Chase Bank",
      "accountNumber": "****1234",
      "routingNumber": "021000021",
      "currency": "USD",
      "status": "ACTIVE"
    }
  ],
  "pagination": { "cursor": "...", "hasMore": false }
}
```

Implementation notes:

- Path parameter: `orgId` (uuid) required.
- Optional `X-Org-Id` header may be provided for tenant assertion.
- Uses security: oauth2 (scope `read:fiat-banking`) or `X-API-KEY` header.

### Deposit Operations

POST /orgs/{orgId}/banking/deposits

Description: Initiate a fiat deposit. Request body requires `accountId`, `amount` (>= 0.01), and `currency`.

Request (curl):

```bash
curl -X POST "https://api.quub.exchange/v2/orgs/{orgId}/banking/deposits" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}" \
  -H "Idempotency-Key: dep_1234567890" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "acc_12345678-90ab-cdef-1234-567890abcdef",
    "amount": 50000.00,
    "currency": "USD",
    "reference": "Monthly funding"
  }'
```

Response (201, schema: Deposit):

```json
{
  "data": {
    "id": "dep_12345678-90ab-cdef-1234-567890abcdef",
    "accountId": "acc_12345678-90ab-cdef-1234-567890abcdef",
    "amount": 50000.0,
    "currency": "USD",
    "status": "PENDING",
    "reference": "Monthly funding",
    "createdAt": "2025-11-02T10:30:00Z"
  }
}
```

Implementation notes:

- Required request body fields: `accountId` (uuid), `amount` (number, minimum 0.01), `currency` (string).
- Include `Idempotency-Key` header to prevent duplicate deposit creation (parameter defined as `Idempotency-Key`).
- Security: oauth2 with `write:fiat-banking` scope or `X-API-KEY`.

### Withdrawal Operations

POST /orgs/{orgId}/banking/withdrawals

Description: Initiate a fiat withdrawal. The request body mirrors deposit fields and requires idempotency on writes.

Request (curl):

```bash
curl -X POST "https://api.quub.exchange/v2/orgs/{orgId}/banking/withdrawals" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}" \
  -H "Idempotency-Key: wdr_1234567890" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "acc_12345678-90ab-cdef-1234-567890abcdef",
    "amount": 25000.00,
    "currency": "USD",
    "reference": "Profit distribution"
  }'
```

Response (201, schema: Withdrawal):

```json
{
  "data": {
    "id": "wdr_12345678-90ab-cdef-1234-567890abcdef",
    "accountId": "acc_12345678-90ab-cdef-1234-567890abcdef",
    "amount": 25000.0,
    "currency": "USD",
    "status": "PENDING",
    "reference": "Profit distribution",
    "createdAt": "2025-11-02T10:45:00Z"
  }
}
```

Implementation notes:

- The API may return 409 (Conflict) or 422 (ValidationError) as defined in the spec. Handle these status codes as part of your client logic.
- Writes require `write:fiat-banking` scope when using OAuth2.

### Settlement Operations

GET /orgs/{orgId}/banking/settlements

Description: List settlement batches. Response items conform to the `Settlement` schema.

Request (curl):

```bash
curl -X GET "https://api.quub.exchange/v2/orgs/{orgId}/banking/settlements" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}"
```

Response (schema: PageResponse with data: Settlement[]):

```json
{
  "data": [
    {
      "id": "stl_12345678-90ab-cdef-1234-567890abcdef",
      "orgId": "123e4567-e89b-12d3-a456-426614174000",
      "period": "2025-11-02",
      "currency": "USD",
      "totalCredits": 160000.0,
      "totalDebits": 10000.0,
      "netAmount": 150000.0,
      "status": "CONFIRMED",
      "settledAt": "2025-11-02T15:00:00Z"
    }
  ],
  "pagination": { "cursor": "...", "hasMore": false }
}
```

## 🚀 Performance Optimization {#performance}

- Cache read-only account lists where appropriate (short TTL) to reduce partner calls.
- Batch reconcile settlements offline rather than calling list endpoints in hot paths.

## 🔧 Advanced Configuration {#advanced}

- For large-volume operations, implement client-side queuing and exponential backoff for transient banking errors (502/503).

## 🔍 Troubleshooting {#troubleshooting}

- INSufficient funds -> 422 with `INSUFFICIENT_FUNDS` (as per common errors) — check available balances before requesting a withdrawal.
- DUPLICATE_REQUEST -> 409 if idempotency key collides; generate unique keys (UUIDs).

## 📊 Monitoring & Observability {#monitoring}

- Track metrics: deposit_success_rate, withdrawal_success_rate, settlement_latency, banking_partner_errors.
- Log requestId/traceId on all requests (`Request-Id` header defined in common components).

## 📚 Additional Resources

- OpenAPI spec: `/openapi/fiat-banking.yaml` (source of truth)
- API reference: `/capabilities/fiat-banking/api-documentation/`

---

## _This guide was generated to strictly reflect operations and schemas defined in `openapi/fiat-banking.yaml`._

layout: docs
title: Fiat Banking Guides
permalink: /capabilities/fiat-banking/guides/

---

# Fiat Banking Implementation Guides

Comprehensive guides for implementing and integrating Fiat Banking capabilities.

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

_For API reference, see [Fiat Banking API Documentation](../api-documentation/)_
