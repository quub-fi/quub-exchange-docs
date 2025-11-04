---
layout: docs
title: Gateway Guides
permalink: /capabilities/gateway/guides/
---

# 📚 Gateway Implementation Guides

> Developer guide for the Gateway service. This document is derived only from OpenAPI `gateway.yaml` and covers the health and heartbeat endpoints and the HealthResponse data model.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Monitoring & Alerts

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Provide lightweight availability checks for load balancers and monitoring systems
- Expose an aggregated health view across backend services
- Support fast heartbeat checks for simple connectivity probes

### Technical Architecture

Clients -> API Gateway -> Health Aggregator -> Backend Services

### Core Data Models

Defined in `openapi/gateway.yaml`:

- HealthResponse

  - status: enum [healthy, degraded, unhealthy]
  - services: ServiceHealth[]
  - totalServices: integer
  - healthyServices: integer
  - unhealthyServices: integer
  - timestamp: date-time

- ServiceHealth
  - name: string
  - status: enum [healthy, unhealthy, unknown]
  - url: string
  - responseTime: integer (ms)
  - lastCheck: date-time

## 🎯 Quick Start {#quick-start}

### Prerequisites

- Network access to the Gateway base URL (per spec servers)
- Monitoring or client that can perform HTTP GET requests

### 2-Minute Smoke Test

Check heartbeat (no auth required):

```bash
curl -X GET "https://api.quub.com/v2/heartbeat" -H "Accept: application/json"
```

Check aggregate health:

```bash
curl -X GET "https://api.quub.com/v2/health" -H "Accept: application/json"
```

## 🏗️ Core API Operations {#core-operations}

All endpoints below are taken directly from `openapi/gateway.yaml`.

### GET /health

Summary: Aggregate health check of all registered services.

Responses declared in the spec: 200, 400, 401, 403, 429, 500.

Response schema: `HealthResponse` (see Core Data Models above).

Example response (fields shown are those defined in the schema):

```json
{
  "status": "healthy",
  "services": [
    {
      "name": "exchange",
      "status": "healthy",
      "url": "https://internal.quub.exchange",
      "responseTime": 42,
      "lastCheck": "2025-11-02T11:30:00Z"
    }
  ],
  "totalServices": 12,
  "healthyServices": 11,
  "unhealthyServices": 1,
  "timestamp": "2025-11-02T11:30:00Z"
}
```

Implementation notes (spec-derived):

- `GET /health` is unsecured in the OpenAPI spec (no security requirement on the path), so clients can poll it without authentication when allowed by local policy.
- The spec lists standard error responses (400/401/403/429/500); handle these per your client logic.

### GET /heartbeat

Summary: Lightweight heartbeat check. Returns a small payload for fast connectivity checks.

Response schema (inline in spec): `{ status: "ok", timestamp: date-time }`.

Example response:

```json
{
  "status": "ok",
  "timestamp": "2025-11-02T11:30:15Z"
}
```

Implementation notes:

- `/heartbeat` is designed for high-frequency polling and returns minimal data.
- As with `/health`, the path has no security requirement in the OpenAPI spec.

## 🔐 Authentication Setup {#authentication}

Per the OpenAPI spec, the two Gateway endpoints (`/health`, `/heartbeat`) declare no security requirements (security: []). The spec also includes references to shared security schemes (bearerAuth, oauth2, apiKey) in components, but those are not required for these two paths.

If you call other gateway-managed routes (outside the scope of this spec file), follow the security scheme defined on those specific paths.

## ✨ Best Practices {#best-practices}

- Poll `/heartbeat` for high-frequency checks; keep intervals small but avoid excessive polling that could create noise.
- Use `/health` for aggregated status in dashboards and periodic checks; avoid polling it at very high frequency since it may aggregate many backend checks.
- Respect HTTP 429 responses and implement exponential backoff when rate-limited.
- Log the `timestamp` included in the HealthResponse to align metrics and traces across systems.

## 🔍 Monitoring & Observability {#monitoring}

Suggested metrics derived from HealthResponse schema:

- gateway_health_status{status="healthy|degraded|unhealthy"}
- gateway_total_services
- gateway_healthy_services
- gateway_unhealthy_services
- gateway_service_response_time_ms{service="exchange"}

Alerting (examples):

- Alert if `gateway_health_status` == `unhealthy` for > 1 minute.
- Alert if `gateway_unhealthy_services` > 0 and not transient.

## 🔧 Troubleshooting {#troubleshooting}

- If `/heartbeat` fails with a network error, verify DNS, TLS certs, and firewall rules.
- If `/health` returns an unexpected status or missing services, inspect the `services` array and check `lastCheck` and `responseTime` values for degraded backends.

## 📚 Additional Resources

- OpenAPI spec (source of truth): `/openapi/gateway.yaml`
- API docs: `/capabilities/gateway/api-documentation/`

---

## _This guide was created strictly from `openapi/gateway.yaml` and the capability documentation; no operations or schema fields were invented._

layout: docs
title: Gateway Guides
permalink: /capabilities/gateway/guides/

---

# Gateway Implementation Guides

Comprehensive guides for implementing and integrating Gateway capabilities.

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

_For API reference, see [Gateway API Documentation](../api-documentation/)_
