---
layout: docs
title: Primary Market Guides
permalink: /capabilities/primary-market/guides/
---

# 📚 Primary Market Implementation Guides

> Comprehensive developer guide for Primary Market: projects, token classes, offerings, and subscriptions — derived only from `openapi/primary-market.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Create and manage projects for tokenized asset issuance
- Define token classes and tokenization parameters
- Publish offerings and manage subscriptions
- Coordinate milestone certification and escrow release

### Technical Architecture

Client -> API Gateway -> Primary Market Service -> Project / Token registries

### Core Data Models

Defined in `openapi/primary-market.yaml` (use these schemas exactly):

- Project (see `common/domain-models.yaml`): id, name, type, currency, spvId, metadata
- TokenClass: id, standard, rights, transferRestricted, decimals, chainId, contractAddr
- PageResponse / PageMeta: pagination envelope used in list endpoints

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 token with `read:primary-market` or `write:primary-market` scopes, or an `apiKey`.
- `orgId` for organization-scoped endpoints.

### 5-Minute Setup

1. Obtain an access token (OAuth2) or `X-API-KEY`.
2. List existing projects and token classes to inspect current configuration.

Example (curl) — list projects:

```bash
curl -G "https://api.quub.exchange/v1/orgs/{orgId}/projects" \
  --data-urlencode "type={type}" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}"
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/primary-market.yaml`.

### Projects

GET /orgs/{orgId}/projects — List projects (supports `type`, `spvId`, pagination).

POST /orgs/{orgId}/projects — Create project. Required body fields: `name`, `type`, `currency`.

Example (Node.js) — create a project

```javascript
const resp = await axios.post(
  `${baseURL}/orgs/${orgId}/projects`,
  {
    name: "Green Real Estate Fund",
    type: "REAL_ESTATE", // must match ProjectType enum in spec
    currency: "USD",
  },
  {
    headers: {
      Authorization: `Bearer ${token}`,
      "Idempotency-Key": `proj_${Date.now()}`,
    },
  }
);
// resp.data.data -> Project
```

GET /orgs/{orgId}/projects/{projectId} — Get project details.

PATCH /orgs/{orgId}/projects/{projectId} — Update project (partial fields allowed; idempotency header available).

### Token Classes

GET /orgs/{orgId}/token-classes — List token classes (supports `chainId`, `rights`, pagination).

POST /orgs/{orgId}/token-classes — Create token class. Required body fields: `standard`, `rights`, `transferRestricted`, `decimals`, `chainId`.

Example (curl) — create token class

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/token-classes" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "standard": "ERC20",
    "rights": "NONE",
    "transferRestricted": true,
    "decimals": 18,
    "chainId": 1,
    "contractAddr": "0x0123456789abcdef0123456789abcdef01234567"
  }'
```

GET /orgs/{orgId}/token-classes/{tokenClassId} — Get token class details.

PATCH /orgs/{orgId}/token-classes/{tokenClassId} — Update token class.

## 🔐 Authentication Setup {#authentication}

- Use OAuth2 scopes `read:primary-market` / `write:primary-market` or `apiKey` as defined in the OpenAPI spec.

## ✨ Best Practices {#best-practices}

- Use `Idempotency-Key` on write endpoints (project and token class creation) to avoid duplicates.
- Validate `contractAddr` format client-side (it must match the hex pattern defined in the schema).
- Prefer pagination for list endpoints (`cursor`, `limit`).

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — missing required fields or invalid enum values.
- 401/403: auth/permission issues — check token scopes and `X-Org-Id` header.
- 409: Conflict — resource already exists (e.g., duplicate project id).

## 📚 Additional Resources

- OpenAPI spec: `/openapi/primary-market.yaml` (source of truth)
- Common domain models: `/openapi/common/domain-models.yaml`

---

## _This guide was generated strictly from `openapi/primary-market.yaml` and existing capability docs; no endpoints or schema properties were invented._

layout: docs
title: Primary Market Guides
permalink: /capabilities/primary-market/guides/

---

# Primary Market Implementation Guides

Comprehensive guides for implementing and integrating Primary Market capabilities.

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

_For API reference, see [Primary Market API Documentation](../api-documentation/)_
