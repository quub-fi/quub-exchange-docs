---
layout: docs
title: Governance Guides
permalink: /capabilities/governance/guides/
---

# 📚 Governance Implementation Guides

> Comprehensive developer guide for implementing governance workflows — corporate actions, voting sessions, ballots, conversion events, and buyback windows — derived only from OpenAPI `governance.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Advanced Topics

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Manage corporate actions (dividends, splits, mergers, etc.)
- Create and orchestrate voting sessions and collect ballots
- Execute conversion events and buyback windows
- Provide auditable workflows for on-chain/off-chain corporate actions
- Support multi-tenant, organization-scoped governance operations

### Technical Architecture

Quub Client -> API Gateway -> Governance Service -> Identity & Compliance -> Ledger/Settlement

### Core Data Models

The following models are defined in `openapi/governance.yaml` and must be used as the single source of truth.

- CorporateAction

  - id (uuid), type (enum per primitives), tokenClassId, targetTokenClassId, status, recordDate, effectiveDate, expiryDate (nullable), details (object)

- VotingSession

  - id (uuid), corporateActionId (uuid), question (string), options (string[]), quorumPct (number), startAt (date-time), endAt (date-time), status (enum), createdAt, updatedAt

- Ballot

  - id (uuid), votingSessionId (uuid), accountId, choice (FOR|AGAINST|ABSTAIN), shares (number), weight (number), votedAt, createdAt

- ConversionEvent

  - id (uuid), fromTokenClassId, toTokenClassId, ratio (number), accountId, sharesConverted, convertedAt

- BuybackWindow
  - id (uuid), tokenClassId, status, price (number), maxShares (integer), sharesRepurchased (integer), startAt, endAt, terms

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 credentials with scopes `read:governance` and/or `write:governance`, or an org-scoped `X-API-Key`.
- Organization UUID (`orgId`) to scope API calls.

### 5-Minute Setup

1. Obtain access token or API key.
2. Use the `orgId` path parameter for all organization-scoped calls: `/orgs/{orgId}/...`.
3. Start by listing corporate actions to understand current governance state.

Example (curl) — list corporate actions:

```bash
curl -X GET "https://api.quub.exchange/v1/orgs/{orgId}/corporate-actions" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}"
```

Response: PageResponse with data: `CorporateAction[]` (see OpenAPI schema for full properties).

## 🏗️ Core API Operations {#core-operations}

All below operations, parameters, request bodies and responses are taken directly from `openapi/governance.yaml`.

### Corporate Actions

GET /orgs/{orgId}/corporate-actions

List corporate actions. Supports pagination and filtering by `type` and `tokenClassId`.

POST /orgs/{orgId}/corporate-actions

Create a corporate action. Request body required fields: `type`, `targetTokenClassId`.

Request (curl):

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/corporate-actions" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}" \
	-H "Idempotency-Key: ca_{UUID}" \
	-H "Content-Type: application/json" \
	-d '{
		"type": "DIVIDEND",
		"targetTokenClassId": "tc_abcdef123456",
		"recordDate": "2025-12-01",
		"effectiveDate": "2025-12-15",
		"params": { "dividendAmount": 0.05, "currency": "USD" }
	}'
```

Response (201): object with `data` property containing `CorporateAction`.

Notes:

- The operation accepts `Idempotency-Key` header (defined in common components) to prevent duplicate creations.
- HTTP 409 (Conflict) and 422 (ValidationError) are possible per spec; handle accordingly.

### Corporate Action Details

GET /orgs/{orgId}/corporate-actions/{caId}

Retrieve a single corporate action by `caId`.

PATCH /orgs/{orgId}/corporate-actions/{caId}

Update an action (partial). Request body may include `effectiveDate` and `params` per spec. Use `Idempotency-Key` header for writes.

### Voting Sessions

GET /orgs/{orgId}/voting-sessions

List voting sessions. Supports query `ca_id` to filter by corporate action.

POST /orgs/{orgId}/voting-sessions

Create a voting session. Required fields: `caId`, `question`, `options`, `quorumPct`, `endAt`.

Request (curl):

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/voting-sessions" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}" \
	-H "Idempotency-Key: vs_{UUID}" \
	-H "Content-Type: application/json" \
	-d '{
		"caId": "ca_1234567890",
		"question": "Approve 2:1 stock split?",
		"options": ["FOR","AGAINST","ABSTAIN"],
		"quorumPct": 50,
		"endAt": "2025-12-15T23:59:59Z"
	}'
```

Response (201): object with `data` containing `VotingSession`.

### Ballots

POST /orgs/{orgId}/voting-sessions/{sessionId}/ballots

Cast a ballot in a voting session. Required body fields: `accountId`, `choice` (enum: FOR, AGAINST, ABSTAIN).

Request (curl):

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/voting-sessions/{sessionId}/ballots" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}" \
	-H "Idempotency-Key: ballot_{UUID}" \
	-H "Content-Type: application/json" \
	-d '{
		"accountId": "acct_abc123",
		"choice": "FOR",
		"shares": 100
	}'
```

GET /orgs/{orgId}/voting-sessions/{sessionId}/ballots

List ballots for a session (paginated). Response items conform to `Ballot` schema.

### Conversion Events

GET /orgs/{orgId}/conversion-events

List conversion events (paginated).

POST /orgs/{orgId}/conversion-events

Execute a conversion event. Required fields: `fromTokenClassId`, `toTokenClassId`, `ratio`.

Request (curl):

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/conversion-events" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}" \
	-H "Idempotency-Key: conv_{UUID}" \
	-H "Content-Type: application/json" \
	-d '{
		"fromTokenClassId": "tc_from",
		"toTokenClassId": "tc_to",
		"ratio": 1.5
	}'
```

Response (201): object with `data` containing `ConversionEvent`.

### Buyback Windows

GET /orgs/{orgId}/buyback-windows

List buyback windows (paginated). Filterable by `tokenClassId` per spec.

POST /orgs/{orgId}/buyback-windows

Create a buyback window. Required fields per spec: `tokenClassId`, `startAt`, `endAt`, `capPct`, `bandPct`.

Request (curl):

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/buyback-windows" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}" \
	-H "Idempotency-Key: buyback_{UUID}" \
	-H "Content-Type: application/json" \
	-d '{
		"tokenClassId": "tc_abcdef123456",
		"startAt": "2025-12-01T00:00:00Z",
		"endAt": "2025-12-15T23:59:59Z",
		"capPct": 5,
		"bandPct": 1
	}'
```

Response (201): object with `data` containing `BuybackWindow`.

## 🔐 Authentication Setup {#authentication}

Supported security schemes (from `openapi/governance.yaml`):

- OAuth2 (authorization code / client credentials) with scopes `read:governance`, `write:governance`.
- API Key: header `X-API-Key` for service-to-service calls.

Example headers:

```
Authorization: Bearer <ACCESS_TOKEN>
X-API-Key: <your-service-api-key>
X-Org-Id: {orgId}  # optional tenant assertion header
Idempotency-Key: <uuid>  # for POST/PATCH writes where supported
```

## ✨ Best Practices {#best-practices}

- Use `Idempotency-Key` for all POST/PATCH operations that accept it to avoid duplicate side effects.
- Validate required fields locally before calling write endpoints (e.g., `quorumPct`, `endAt`, `ratio`).
- Implement exponential backoff for 429/5xx responses.
- Enforce role-based checks client-side to avoid unnecessary API calls that will be denied (403).

## 🔒 Security Guidelines {#security}

- Store tokens and API keys securely. Use short-lived tokens where possible.
- Log `Request-Id` (returned in responses) for tracing and audits.
- Ensure audit logging is enabled for all governance actions.

## 🚀 Performance Optimization {#performance}

- Cache read-only lists (corporate actions, buyback windows) with a short TTL to reduce load.
- For high-volume ballot ingestion, batch processing and asynchronous submission to the API gateway is recommended.

## 🔍 Troubleshooting {#troubleshooting}

- 422 ValidationError: return includes field-level details — reflect these in UI validation messages.
- 409 Conflict: resource state conflict (e.g., duplicate create); check current resource state and idempotency key.

## 📊 Monitoring & Observability {#monitoring}

- Track metrics: corporate_action_create_failures, voting_session_latency, ballot_submission_rate, conversion_event_errors.
- Capture `Request-Id`, `orgId`, and operation names in logs for correlation.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/governance.yaml` (source of truth)
- API documentation: `/capabilities/governance/api-documentation/`

---

_This guide was generated strictly from `openapi/governance.yaml` and existing capability docs; no endpoints or schema properties were invented._

---

layout: docs
title: Governance Guides
permalink: /capabilities/governance/guides/

---

# Governance Implementation Guides

Comprehensive guides for implementing and integrating Governance capabilities.

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

_For API reference, see [Governance API Documentation](../api-documentation/)_
