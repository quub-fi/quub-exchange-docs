---
layout: docs
title: Identity Guides
permalink: /capabilities/identity/guides/
---

# 📚 Identity Implementation Guides

> Developer guide for Identity service: accounts, organizations, API keys, MFA, and authentication — strictly derived from `openapi/identity.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Advanced Topics

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Manage user and organization accounts
- Provide authentication (login/register) and session management
- Offer MFA lifecycle and verification
- Issue and revoke API keys with scoped permissions
- Support role-based access control and organization management

### Technical Architecture

Client -> API Gateway -> Identity Service -> Auth/Token Store -> Audit Logs

### Core Data Models

- Account (see `common/domain-models.yaml` Account schema referenced in OpenAPI)
- Org (schema `Org` in `openapi/identity.yaml` components)
- Role (schema `Role`)
- ApiKey (domain model referenced in openapi)
- MfaSetup and MfaChallenge (schemas defined in `openapi/identity.yaml`)

## 🎯 Quick Start {#quick-start}

### Prerequisites

- API base: https://api.quub.exchange/v1 (or sandbox)
- OAuth/Bearer token or API key for authenticated endpoints

### 5-Minute Setup

1. Register a user via `POST /auth/register` (public endpoint).
2. Log in via `POST /auth/login` to receive access tokens.
3. Use `GET /auth/me` to fetch current account details.

Example (curl) — register

```bash
curl -X POST "https://api.sandbox.quub.exchange/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com","password":"SecurePass123!"}'
```

## 🏗️ Core API Operations {#core-operations}

All operations below are taken directly from `openapi/identity.yaml`.

### Accounts

GET /Accounts — list accounts (supports cursor/limit, status, type, orgId query filters)

POST /Accounts — create account (required: `type`, `email`). Accepts `Idempotency-Key` header.

GET /Accounts/{accountId} — retrieve account by ID

PATCH /Accounts/{accountId} — update account fields (email, phone, status). Supports `Idempotency-Key` for writes.

Implementation notes:

- Use pagination schemas from `common/pagination.yaml` for list responses.
- Account model is defined in `common/domain-models.yaml` (referenced by the OpenAPI spec).

### Organizations

GET /Orgs — list organizations (supports `country` filter)

POST /Orgs — create organization (required: `legalName`, `country`). Uses `Idempotency-Key`.

GET /Orgs/{orgId} — retrieve organization

PATCH /Orgs/{orgId} — update organization

Notes:

- `orgId` path parameter and optional `X-Org-Id` header are used for tenant assertion as defined in common components.

### Roles

GET /Roles — list available roles (response items conform to `Role` schema).

### API Keys

GET /ApiKeys — list API keys for an account. This endpoint requires the `accountId` query parameter (see OpenAPI for parameter definition).

POST /ApiKeys — create API key. Required: `accountId`, `scopes`. The response includes `secretKey` visible once (store it)

DELETE /ApiKeys/{apiKeyId} — revoke API key (204 on success)

Notes:

- The OpenAPI explicitly documents that the full `secretKey` is returned only once.
- Validate `apiKeyId` path pattern per spec when deleting.

### Multi-Factor Authentication (MFA)

POST /Accounts/{accountId}/mfa — enable MFA. Request body requires `method` (TOTP | SMS | EMAIL) and optional `phoneNumber` for SMS.

DELETE /Accounts/{accountId}/mfa — disable MFA (requires confirmation `code`)

POST /Accounts/{accountId}/mfa/verify — verify MFA setup (request: `code`) — returns backup codes in response per spec

POST /Auth/mfa/challenge — complete MFA challenge after password login; returns tokens on success

Notes:

- TOTP secret and QR URI returned in `MfaSetup` schema when enabling TOTP.
- Backup codes are provided once when verifying setup.

### Authentication

POST /auth/login — login with `email` and `password`; returns access and refresh tokens or a `MfaChallenge` (202) if MFA required.

POST /auth/logout — logout (204)

GET /auth/me — get current authenticated user (returns `Account` schema)

POST /auth/change-password — change password (requires `currentPassword` and `newPassword`)

## 🔐 Authentication Setup {#authentication}

- Public endpoints: `POST /auth/register`, `POST /auth/login` (no auth required).
- Authenticated endpoints require Bearer token (`Authorization: Bearer <token>`) or an org/service API key as defined in common security schemes.

## ✨ Best Practices {#best-practices}

- Store API key secrets and tokens securely; the `secretKey` from `POST /ApiKeys` is shown only once.
- Enforce phone number validation when enabling SMS MFA (pattern: E.164).
- Use `Idempotency-Key` on POST endpoints where the spec includes the header.

## 🔍 Troubleshooting {#troubleshooting}

- 409 Conflict on create endpoints indicates duplicates — check existing resources first.
- 422 ValidationError contains field-level issues — present these to the user for correction.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/identity.yaml` (source of truth)
- API documentation: `/capabilities/identity/api-documentation/`

---

## _This guide strictly follows `openapi/identity.yaml` (no invented endpoints or schema properties)._

layout: docs
title: Identity Guides
permalink: /capabilities/identity/guides/

---

# Identity Implementation Guides

Comprehensive guides for implementing and integrating Identity capabilities.

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

_For API reference, see [Identity API Documentation](../api-documentation/)_
