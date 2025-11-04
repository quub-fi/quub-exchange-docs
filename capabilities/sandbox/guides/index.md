---
layout: docs
title: Sandbox Guides
permalink: /capabilities/sandbox/guides/
---

# 📚 Sandbox & Test Harness Implementation Guides

> Comprehensive developer guide for the Sandbox API: create environments, generate mock data, time-travel, reset/delete environments — derived only from `openapi/sandbox.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Provide isolated test environments for developers and integrators
- Allow generating realistic mock data for integration tests
- Support simulated time manipulation for time-dependent workflows
- Offer safe reset and deletion of test environments

### Technical Architecture

Client -> Sandbox API (isolated) -> Per-environment ledger & mock data backends

### Core Data Models

Defined in `openapi/sandbox.yaml` (use these schemas exactly):

- SandboxEnvironment: id, name, status (ACTIVE|PAUSED|RESETTING|DELETED), currentTime, createdAt, updatedAt, metadata

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 token or `apiKey` with sandbox scopes (e.g., `read:sandbox`, `write:sandbox`).

### 5-minute setup

1. Point your client to the sandbox server: https://sandbox-api.quub.exchange/v1
2. Create a sandbox environment or list existing ones.

Example (curl) — create an environment:

```bash
curl -X POST "https://sandbox-api.quub.exchange/v1/sandbox/envs" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "Content-Type: application/json" \
	-d '{"name": "My Project Test Env"}'
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/sandbox.yaml`.

### List Environments

GET /sandbox/envs — List sandbox environments. Supports pagination `cursor` and `limit`.

Response: `PageResponse` + `data: SandboxEnvironment[]`.

### Create Environment

POST /sandbox/envs — Create a new sandbox environment. Optional body: `name`.

Response: `201` with `data: SandboxEnvironment`.

### Get / Delete Environment

GET /sandbox/envs/{envId} — Get environment details.

DELETE /sandbox/envs/{envId} — Delete an environment (admin scope required). Returns 204 No Content on success.

### Generate Test Data

POST /sandbox/envs/{envId}/generate-data — Populate environment with mock `dataTypes` (accounts, projects, tokens, orders) and `count`.

Response: `201` with `data: SandboxEnvironment`.

Example (Node.js) — generate sample data:

```javascript
await axios.post(
  `${baseURL}/sandbox/envs/${envId}/generate-data`,
  {
    dataTypes: ["accounts", "orders"],
    count: 50,
  },
  {
    headers: { Authorization: `Bearer ${token}` },
  }
);
```

### Time Travel

POST /sandbox/envs/{envId}/time-travel — Set sandbox time. Body (required): `timestamp` (date-time).

Response: `200` with `data: SandboxEnvironment`.

Example (curl):

```bash
curl -X POST "https://sandbox-api.quub.exchange/v1/sandbox/envs/{envId}/time-travel" \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "Content-Type: application/json" \
	-d '{"timestamp": "2025-11-01T12:00:00Z"}'
```

### Reset Environment

POST /sandbox/envs/{envId}/reset — Reset environment to a clean state. Returns `200` with `data: SandboxEnvironment`.

Responses include 409 Conflict and 422 ValidationError where applicable (see spec).

## 🔐 Authentication Setup {#authentication}

- Security schemes: `bearerAuth`, `oauth2`, `apiKey` (see `openapi/sandbox.yaml`). Use `write:sandbox` for mutating operations.

## ✨ Best Practices {#best-practices}

- Use sandbox base URL `https://sandbox-api.quub.exchange/v1` during integration tests.
- Reset environments before and after CI runs to keep tests deterministic.
- Use `generate-data` to seed realistic scenarios and test edge cases.

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — malformed request or invalid parameters.
- 401/403: auth/permission issues — verify token scopes.
- 409/422: conflicts/validation failures during reset or generate operations.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/sandbox.yaml` (source of truth)
- API docs: `/capabilities/sandbox/api-documentation/`

---

_This guide was generated strictly from `openapi/sandbox.yaml` and existing capability docs; no endpoints or schema properties were invented._

---

layout: docs
title: Sandbox Guides
permalink: /capabilities/sandbox/guides/

---

# Sandbox Implementation Guides

Comprehensive guides for implementing and integrating Sandbox capabilities.

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

_For API reference, see [Sandbox API Documentation](../api-documentation/)_
