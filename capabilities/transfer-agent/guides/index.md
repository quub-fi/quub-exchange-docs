---
layout: docs
title: Transfer Agent Guides
permalink: /capabilities/transfer-agent/guides/
---

# 📚 Transfer Agent Implementation Guides

> Comprehensive developer guide for Transfer Agent services: shareholder registry, transfers, certificates, corporate actions, and reports — derived only from `openapi/transfer-agent.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Maintain authoritative shareholder registries (cap tables) for tokenized or digital securities
- Receive and process transfer requests, enforce transfer restrictions
- Issue and cancel certificates for ownership representation
- Administer corporate actions (splits, dividends, mergers)
- Produce shareholder reports and statements

### Technical Architecture

Client -> API Gateway -> Transfer Agent Service -> Registry Store / Compliance Engine -> Reporting Engine

### Core Data Models

Defined in `openapi/transfer-agent.yaml` (use these schemas exactly):

- ShareholderPosition: accountId, accountName, assetId, assetName, shares, percentOwnership, certificateNumbers, restrictions, acquisitionDate
- TransferRequest: id, orgId, assetId, fromAccountId, toAccountId, shares, status (PENDING|APPROVED|REJECTED|COMPLETED|CANCELLED), requestedAt, approvedAt, completedAt, restrictionCheck
- CreateTransferRequest: assetId, fromAccountId, toAccountId, shares, notes
- TransferRestriction: id, assetId, accountId, restrictionType (LOCK_UP|RULE_144|VESTING|REGULATORY|CONTRACTUAL), description, expiresAt, createdAt
- Certificate: id, certificateNumber, assetId, accountId, shares, status (ACTIVE|CANCELLED|VOID), issuedAt, cancelledAt
- CorporateAction: id, assetId, actionType (SPLIT|REVERSE_SPLIT|DIVIDEND|MERGER|CONSOLIDATION), recordDate, effectiveDate, ratio, status (ANNOUNCED|PENDING|EXECUTED|CANCELLED)
- ShareholderReport: assetId, asOfDate, totalShares, holders[] (ShareholderPosition)

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 token with scopes like `read:transfer-agent` or `write:transfer-agent`, or an `apiKey`.
- `orgId`, `assetId`, `accountId` values where applicable.

### 5-Minute Setup

1. Obtain an access token or `X-API-KEY` and set `X-Org-Id` header for organization-scoped calls.
2. Inspect the shareholder registry or list pending transfer requests.

Example (curl) — list pending transfer requests:

```bash
curl -G "https://api.quub.exchange/v1/orgs/{orgId}/transfer-agent/transfers" \
	--data-urlencode "status=PENDING" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}"
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/transfer-agent.yaml`.

### Shareholder Registry

GET /orgs/{orgId}/transfer-agent/registry/assets/{assetId}/holders — Get shareholder registry (cap table). Query: `asOfDate`, pagination.

GET /orgs/{orgId}/transfer-agent/registry/holders/{accountId} — Get holder positions across all assets.

Example (Node.js) — get holder positions:

```javascript
const resp = await axios.get(
  `${baseURL}/orgs/${orgId}/transfer-agent/registry/holders/${accountId}`,
  {
    headers: { Authorization: `Bearer ${token}`, "X-Org-Id": orgId },
  }
);
// resp.data.data -> ShareholderPosition[]
```

### Transfers

GET /orgs/{orgId}/transfer-agent/transfers — List transfer requests. Query filters: `status`, `assetId`, `fromAccountId`, `toAccountId`, `dateFrom`, `dateTo`.

POST /orgs/{orgId}/transfer-agent/transfers — Create transfer request. Body schema: `CreateTransferRequest`. Use `Idempotency-Key` header.

POST /orgs/{orgId}/transfer-agent/transfers/{transferId}/approve — Approve transfer request.

Example (curl) — create a transfer request (idempotent):

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/transfer-agent/transfers" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}" \
	-H "Idempotency-Key: trf_{unique}" \
	-H "Content-Type: application/json" \
	-d '{"assetId":"{assetId}","fromAccountId":"{fromAccountId}","toAccountId":"{toAccountId}","shares":"100"}'
```

### Transfer Restrictions

GET /orgs/{orgId}/transfer-agent/restrictions — List transfer restrictions. Query: `assetId`, `accountId`.

POST /orgs/{orgId}/transfer-agent/restrictions — Create transfer restriction. Body schema: `CreateRestrictionRequest`.

### Certificates

GET /orgs/{orgId}/transfer-agent/certificates — List certificates. Query: `assetId`, `status`.

POST /orgs/{orgId}/transfer-agent/certificates — Issue certificate. Body schema: `IssueCertificateRequest`.

POST /orgs/{orgId}/transfer-agent/certificates/{certificateId}/cancel — Cancel certificate (optional body: reason).

### Corporate Actions

GET /orgs/{orgId}/transfer-agent/corporate-actions — List corporate actions. Query: `assetId`, `type`.

POST /orgs/{orgId}/transfer-agent/corporate-actions — Create corporate action. Body schema: `CreateCorporateActionRequest`.

POST /orgs/{orgId}/transfer-agent/corporate-actions/{actionId}/execute — Execute corporate action.

### Reports

GET /orgs/{orgId}/transfer-agent/reports/shareholders — Generate shareholder report. Query: required `assetId` and `asOfDate`, optional `format` (PDF|CSV|JSON).

Example (Python) — request shareholder report (JSON):

```python
resp = requests.get(
		f"{base_url}/orgs/{org_id}/transfer-agent/reports/shareholders",
		params={"assetId": asset_id, "asOfDate": as_of_date, "format": "JSON"},
		headers={"Authorization": f"Bearer {token}", "X-Org-Id": org_id},
)
# resp.json()["data"] -> ShareholderReport
```

## 🔐 Authentication Setup {#authentication}

- Security schemes defined in the OpenAPI: `bearerAuth`, `oauth2` and `apiKey` (see `openapi/transfer-agent.yaml` components). Use `read:transfer-agent` for reads and `write:transfer-agent` for writes.

## ✨ Best Practices {#best-practices}

- Use `Idempotency-Key` on POST endpoints that create resources (transfers, restrictions, certificates) to avoid duplicates.
- Validate `assetId`, `accountId`, and `transferId` client-side before sending to reduce 422 errors.
- When listing large registries or transfer logs, use pagination parameters (`cursor`, `limit`).

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — malformed payload or missing required fields.
- 401/403: auth/permission issues — check token scopes and API key permissions.
- 409: Conflict — resource state conflict (e.g., duplicate transfer or restriction).
- 422: ValidationError — business validation or missing required fields in body.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/transfer-agent.yaml` (source of truth)
- API docs: `/capabilities/transfer-agent/api-documentation/`

---

_This guide was generated strictly from `openapi/transfer-agent.yaml` and existing capability docs; no endpoints or schema properties were invented._

---

layout: docs
title: Transfer Agent Guides
permalink: /capabilities/transfer-agent/guides/

---

# Transfer Agent Implementation Guides

Comprehensive guides for implementing and integrating Transfer Agent capabilities.

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

_For API reference, see [Transfer Agent API Documentation](../api-documentation/)_
