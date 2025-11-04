---
layout: docs
title: Tenancy & Trust Guides
permalink: /capabilities/tenancy-trust/guides/
---

# 📚 Tenancy & Trust Implementation Guides

> Comprehensive developer guide for Tenancy & Trust: organizations, domain verification, API keys, mTLS certificates and webhooks — derived only from `openapi/tenancy-trust.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Manage tenant organizations and their trust levels (T0-T3)
- Register and manage API keys for programmatic access
- Upload and manage mTLS certificates for institutional integrations
- Configure webhooks for event-driven integrations

### Technical Architecture

Client -> API Gateway -> Tenancy & Trust Service -> Identity / PKI / Webhook Delivery

### Core Data Models

Defined in `openapi/tenancy-trust.yaml` (use these schemas exactly):

- Organization: id, name, domain, trustLevel (T0|T1|T2|T3), verified, createdAt
- ApiKey: id, name, keyPrefix, scopes[], createdAt
- MtlsCertificate: id, subjectCN, issuedBy, validFrom, validTo
- WebhookEndpoint: id, url, events[], signingSecret, createdAt

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 token with appropriate tenancy scopes or `apiKey` header.

### 5-minute setup

1. Create an organization.
2. Register API keys or upload an mTLS certificate for institutional integrations.
3. Create webhook endpoints to receive events.

Example (curl) — create an organization:

```bash
curl -X POST "https://api.quub.exchange/v1/orgs" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Quub Capital Ltd.","domain":"quub.exchange"}'
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/tenancy-trust.yaml`.

### Organizations

GET /orgs — List organizations (paginated).

POST /orgs — Create organization. Required body: `name`, `domain`.

GET /orgs/{orgId} — Get organization details.

Example (Node.js): create and fetch an organization

```javascript
const create = await axios.post(
  `${baseURL}/orgs`,
  { name: orgName, domain },
  { headers: { Authorization: `Bearer ${token}` } }
);
const orgId = create.data.data.id;
const fetch = await axios.get(`${baseURL}/orgs/${orgId}`, {
  headers: { Authorization: `Bearer ${token}` },
});
```

### Domain Verification

POST /orgs/{orgId}/verify-domain — Initiate domain verification (issues DNS TXT challenge). Response: updated `Organization`.

### API Keys

GET /orgs/{orgId}/api-keys — List API keys (paginated).

POST /orgs/{orgId}/api-keys — Create API key. Required body: `name`, `scopes`.

Example (curl) — create an API key:

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/api-keys" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Treasury Automation Key","scopes":["treasury:read"]}'
```

### mTLS Certificates

GET /orgs/{orgId}/mtls-certificates — List mTLS certificates (paginated).

POST /orgs/{orgId}/mtls-certificates — Upload mTLS certificate. Required body: `certificatePem` (PEM-formatted x509 certificate).

### Webhooks

GET /orgs/{orgId}/webhooks — List webhook endpoints (paginated).

POST /orgs/{orgId}/webhooks — Create webhook endpoint. Required body: `url`, `events`.

Example (curl) — create a webhook endpoint:

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/webhooks" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://webhooks.quub.exchange/receive","events":["trade.executed"]}'
```

## 🔐 Authentication Setup {#authentication}

- Use `bearerAuth`/`oauth2` with tenancy scopes (`read:tenancy`, `write:tenancy`) or `apiKey` per the OpenAPI securitySchemes.

## ✨ Best Practices {#best-practices}

- Use pagination for list endpoints to avoid large responses.
- Rotate API keys regularly and scope them to the minimum required permissions.
- For webhooks, validate `signingSecret` and implement retry/dedup handling.

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — missing required fields or invalid URL/PEM formats.
- 401/403: auth/permission issues — check token scopes and API key permissions.
- 409/422: conflict/validation errors when creating resources with duplicates or invalid data.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/tenancy-trust.yaml` (source of truth)
- API docs: `/capabilities/tenancy-trust/api-documentation/`

---

## _This guide was generated strictly from `openapi/tenancy-trust.yaml` and existing capability docs; no endpoints or schema properties were invented._

layout: docs
title: Tenancy Trust Guides
permalink: /capabilities/tenancy-trust/guides/

---

# Tenancy Trust Implementation Guides

Comprehensive guides for implementing and integrating Tenancy Trust capabilities.

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

_For API reference, see [Tenancy Trust API Documentation](../api-documentation/)_
