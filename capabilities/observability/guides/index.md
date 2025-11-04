---
layout: docs
title: Observability Guides
permalink: /capabilities/observability/guides/
---

---

layout: docs
title: Observability Guides
permalink: /capabilities/observability/guides/

---

# 📚 Observability Implementation Guides

> Comprehensive developer guide for Observability: audit logs, system logs, and metrics — derived only from `openapi/observability.yaml`.

## � Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Provide immutable, tamper-evident audit logs for compliance and forensics
- Expose system logs for operational debugging and SRE workflows
- Surface aggregated telemetry and usage metrics for organizations
- Offer paginated and filterable query endpoints for observability data

### Technical Architecture

Client -> API Gateway -> Observability Service -> Storage / Metrics Backends

### Core Data Models

Defined in `openapi/observability.yaml` (use these schemas exactly):

- AuditLogEntry: id, timestamp, orgId, accountId, eventType, action, resourceType, resourceId, changes, ipAddress, userAgent, hashChain
- SystemLogEntry: timestamp, level (DEBUG|INFO|WARN|ERROR), service, message, traceId, metadata
- MetricsResponse: collectedAt, metrics[] { name, value, unit }

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 token with scope `read:observability` or an `apiKey`.
- `orgId` for organization-scoped endpoints.

### 5-Minute Setup

1. Obtain an access token (OAuth2) or `X-API-KEY`.
2. Call a read endpoint to inspect available logs or metrics.

Example (curl) — query audit logs:

```bash
curl -G "https://api.quub.exchange/v1/orgs/{orgId}/audit-logs" \
	--data-urlencode "startTime={startTime}" \
	--data-urlencode "endTime={endTime}" \
	--data-urlencode "eventType={eventType}" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "X-Org-Id: {orgId}"
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/observability.yaml`.

### Audit Logs

GET /orgs/{orgId}/audit-logs — Query audit logs. Query parameters: `startTime`, `endTime`, `eventType`, `limit`, `cursor`.

Response: object with `data: AuditLogEntry[]`.

Example (Node.js): query audit logs

```javascript
const resp = await axios.get(`${baseURL}/orgs/${orgId}/audit-logs`, {
  params: { startTime, endTime, eventType },
  headers: { Authorization: `Bearer ${token}`, "X-Org-Id": orgId },
});
// resp.data.data -> AuditLogEntry[]
```

### System Logs

GET /admin/system-logs — Query system logs. Query parameters: `level` (DEBUG|INFO|WARN|ERROR), `service`, `limit`.

Response: object with `data: SystemLogEntry[]`.

Example (curl):

```bash
curl -G "https://api.quub.exchange/v1/admin/system-logs" \
	--data-urlencode "level=ERROR" \
	--data-urlencode "service=exchange-core" \
	-H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Metrics

GET /orgs/{orgId}/metrics — Retrieve organization metrics. Query parameter: `range` (e.g., `24h`, `7d`).

Response: object with `data: MetricsResponse`.

Example (Python): get metrics

```python
resp = requests.get(
		f"{base_url}/orgs/{org_id}/metrics",
		params={"range": "24h"},
		headers={"Authorization": f"Bearer {token}", "X-Org-Id": org_id},
)
# resp.json()["data"] -> MetricsResponse
```

## 🔐 Authentication Setup {#authentication}

- Security schemes defined in the OpenAPI: `bearerAuth` (OAuth2), `oauth2`, and `apiKey` (see components). Use the `read:observability` scope for read operations.

## ✨ Best Practices {#best-practices}

- Use time-bounded queries (`startTime`/`endTime`) and pagination (`cursor`) when reading audit logs.
- Preserve `X-Org-Id` header for tenant-scoped requests for auditability.
- For system logs, filter by `service` and `level` to reduce payload size.

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — malformed filter or invalid timestamp format.
- 401/403: auth/permission issues — verify token scopes and API key permissions.
- 429: rate limits — back off and retry using exponential backoff.

## 📊 Monitoring & Observability {#monitoring}

- Emit request tracing headers (e.g., `traceId`) when ingesting logs to correlate traces.
- Monitor `metrics.collectedAt` and track metric collection latency.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/observability.yaml` (source of truth)
- API docs: `/capabilities/observability/api-documentation/`

---

_This guide was generated strictly from `openapi/observability.yaml` and existing capability docs; no endpoints or schema properties were invented._
