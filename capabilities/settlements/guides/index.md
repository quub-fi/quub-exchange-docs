---
layout: docs
title: Settlements Guides
permalink: /capabilities/settlements/guides/
---

# 📚 Settlements & Clearing Implementation Guides

> Comprehensive developer guide for Settlement & Clearing: instructions, status, netting, batches, and failed-trade resolution — derived only from `openapi/settlements.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Manage settlement instructions for trades and transfers (DVP, DAP, RVP, FOP)
- Track settlement status and lifecycle per instruction and settlement date
- Support netting and batching workflows to optimize settlement flows
- Provide failed trade resolution APIs for operational recovery

### Technical Architecture

Clients -> API Gateway -> Settlement Service -> Clearing/Netting Engine -> Custodians

### Core Data Models

Defined in `openapi/settlements.yaml` (use these schemas exactly):

- SettlementInstruction: id, orgId, tradeId, settlementType (DVP|DAP|RVP|FOP), settlementDate, status (PENDING|MATCHED|...), deliveryAccount, receivingAccount, assetId, quantity, cashAmount, currency, counterpartyId, model, cycle, settledAt, metadata, createdAt, updatedAt
- SettlementStatusRecord: instructionId, status, timestamp, notes
- NettingResult: settlementDate, counterpartyId, assetId, grossBuy, grossSell, netPosition, netDirection (BUY|SELL|FLAT), instructionCount, batchId, netAmount, currency, instructionIds, createdAt
- SettlementBatch: id, settlementDate, batchNumber, instructionCount, status (PENDING|PROCESSING|COMPLETED|FAILED), totalAmount, currency, processedAt
- FailedTrade: id, tradeId, settlementInstructionId, failureReason, failureCode (INSUFFICIENT_ASSETS|...), status, resolutionType, failedAt, resolvedAt

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 token or `apiKey` with appropriate scopes (`read:settlements`, `write:settlements`, `admin:settlements`).
- `orgId` and relevant `tradeId` / `instructionId` values.

### 5-minute setup

1. Obtain an access token (OAuth2) or `X-API-KEY`.
2. Call `GET /orgs/{orgId}/settlements/instructions` to list instructions or `POST` to create a new instruction.

Example (curl) — list settlement instructions:

```bash
curl -G "https://api.quub.exchange/v1/orgs/{orgId}/settlements/instructions" \
	--data-urlencode "status=PENDING" \
	--data-urlencode "settlementDate={YYYY-MM-DD}" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}"
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/settlements.yaml`.

### Settlement Instructions

GET /orgs/{orgId}/settlements/instructions — List settlement instructions. Query params: `status`, `settlementDate`, `cursor`, `limit`.

POST /orgs/{orgId}/settlements/instructions — Create a settlement instruction. Request body schema: `CreateSettlementInstructionRequest` (required: `tradeId`, `settlementType`, `settlementDate`).

GET /orgs/{orgId}/settlements/instructions/{instructionId} — Get instruction details.

PUT /orgs/{orgId}/settlements/instructions/{instructionId} — Update instruction (body may include `status` (SettlementStatus), `priority`, `notes`).

DELETE /orgs/{orgId}/settlements/instructions/{instructionId} — Cancel instruction (204 No Content on success).

Example (Node.js) — create an instruction:

```javascript
const resp = await axios.post(
  `${baseURL}/orgs/${orgId}/settlements/instructions`,
  {
    tradeId: tradeId,
    settlementType: "DVP",
    settlementDate: "2025-11-05",
    deliveryAccount: "acct-delivery-123",
    receivingAccount: "acct-receive-456",
    notes: "Urgent settlement",
  },
  { headers: { Authorization: `Bearer ${token}`, "X-Org-Id": orgId } }
);
// resp.data.data -> SettlementInstruction
```

### Settlement Status & Calendar

GET /orgs/{orgId}/settlements/status — Get settlement status overview for a required `settlementDate` query parameter. Response schema: `SettlementStatusRecord`.

GET /settlements/calendar — Get settlement calendar. Query params: `startDate`, `endDate`.

Example (curl) — get settlement status for a date:

```bash
curl -G "https://api.quub.exchange/v1/orgs/{orgId}/settlements/status" \
	--data-urlencode "settlementDate=2025-11-05" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}"
```

### Netting & Batches

POST /orgs/{orgId}/settlements/netting — Calculate netting. Request body may include `settlementDate`, `counterpartyId`, `assetId`. Response: `NettingResult[]`.

GET /orgs/{orgId}/settlements/batches — List settlement batches. Query params: `cursor`, `limit`, `settlementDate`.

Example (curl) — calculate netting:

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/settlements/netting" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "Content-Type: application/json" \
	-H "X-Org-Id: {orgId}" \
	-d '{"settlementDate":"2025-11-05","counterpartyId":"{counterpartyId}","assetId":"{assetId}"}'
```

### Failed Trades

GET /orgs/{orgId}/settlements/failed-trades — List failed trades. Query params: `status`, `cursor`, `limit`.

POST /orgs/{orgId}/settlements/failed-trades/{tradeId}/resolve — Resolve a failed trade. Request body: `resolutionType` (RETRY|CANCEL|MANUAL_SETTLE), `notes`.

Example (curl) — resolve a failed trade:

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/settlements/failed-trades/{tradeId}/resolve" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "Content-Type: application/json" \
	-H "X-Org-Id: {orgId}" \
	-d '{"resolutionType":"RETRY","notes":"Retrying after custody availability"}'
```

## 🔐 Authentication Setup {#authentication}

- Security schemes: `bearerAuth`, `oauth2`, and `apiKey` (see OpenAPI components). Use the appropriate scopes: `read:settlements`, `write:settlements`, `admin:settlements`.

## ✨ Best Practices {#best-practices}

- Use settlementDate and status filters to minimize result sets.
- Use pagination (`cursor`, `limit`) for list endpoints.
- Include `X-Org-Id` for tenant-scoped operations; require appropriate scopes for admin-level actions like cancel.

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — invalid dates, missing required fields.
- 401/403: auth/permission issues — check token scopes and API key permissions.
- 409: Conflict — concurrent updates or state conflicts (e.g., resolving a failed trade that is already resolved).

## 📚 Additional Resources

- OpenAPI spec: `/openapi/settlements.yaml` (source of truth)
- API docs: `/capabilities/settlements/api-documentation/`

---

_This guide was generated strictly from `openapi/settlements.yaml` and existing capability docs; no endpoints or schema properties were invented._

---

layout: docs
title: Settlements Guides
permalink: /capabilities/settlements/guides/

---

# Settlements Implementation Guides

Comprehensive guides for implementing and integrating Settlements capabilities.

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

_For API reference, see [Settlements API Documentation](../api-documentation/)_
