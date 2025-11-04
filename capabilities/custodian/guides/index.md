---
layout: docs
title: Custodian Guides
permalink: /capabilities/custodian/guides/
---

# 📚 Custodian Implementation Guides

> Comprehensive developer guide for implementing digital-asset custody services (accounts, balances, deposits, withdrawals, and proofs of custody).

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Advanced Topics

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Secure custody for digital assets (self-custody, qualified custody, omnibus, segregated)
- Multi-asset support: CRYPTO, SECURITIES, FIAT
- Operational automation for deposits and withdrawals with multi-signature workflows
- Regulatory and compliance support (audit trails, segregation, proof-of-custody)
- Enterprise-grade key management and HSM integration

### Technical Architecture

Simple ASCII diagram showing how clients interact with the Custodian API and custody subsystems:

```
  +-------------+       HTTPS       +-----------------+      +-------------+
  | Client App  | --------------->  | Custodian API   | ---> | Wallet / HSM |
  | (OAuth/API) |  <---------------  | (Auth, Ops)     | <--- | Signing Svc  |
  +-------------+    (Bearer/API)    +-----------------+      +-------------+
         |                    |                    |
         |                    |                    +--> Proof of custody & attestation
         |                    +--> Account mgmt
         +--> Deposits/Withdrawals
```

### Core Data Models

The following schemas are defined in `openapi/custodian.yaml` and used throughout these examples. Use these exact properties only.

- CustodyAccount

  - id (uuid)
  - orgId (uuid)
  - accountType (enum: SELF_CUSTODY | QUALIFIED_CUSTODY | OMNIBUS | SEGREGATED)
  - assetType (enum: CRYPTO | SECURITIES | FIAT)
  - status (enum: ACTIVE | SUSPENDED | CLOSED)
  - createdAt (date-time)

- CustodyBalance

  - asset (string)
  - available (string)
  - reserved (string)
  - total (string)

- CustodyTransaction

  - id (uuid)
  - accountId (uuid)
  - type (enum: DEPOSIT | WITHDRAWAL)
  - asset (string)
  - amount (string)
  - status (enum: PENDING | COMPLETED | FAILED | CANCELLED)
  - destination (string)
  - createdAt (date-time)
  - completedAt (date-time | null)

- ProofOfCustody

  - id (uuid)
  - orgId (uuid)
  - attestation (string)
  - assets (array of { asset, balance })
  - timestamp (date-time)
  - signature (string)

## 🎯 Quick Start {#quick-start}

### Prerequisites

- API credentials (OAuth 2.0 client credentials or API key) with required scopes:
  - `read:custody` — for read operations
  - `write:custody` — for create/update operations
- Organization identifier (`orgId`) — passed as path param and header where required

### 5-Minute Setup (examples)

Base URL: `https://api.quub.exchange/v1`

Use a bearer token in Authorization header for OAuth-based access.

cURL: list accounts

```bash
curl -X GET "https://api.quub.exchange/v1/orgs/ORG_ID/custody/accounts" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: ORG_ID"
```

Node.js (fetch) — create a custody account

```js
const fetch = require("node-fetch");

async function createCustodyAccount(orgId, token) {
  const res = await fetch(
    `https://api.quub.exchange/v1/orgs/${orgId}/custody/accounts`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
        "X-Org-Id": orgId,
      },
      body: JSON.stringify({
        accountType: "SEGREGATED",
        assetType: "CRYPTO",
      }),
    }
  );
  return res.json();
}
```

Python (requests) — request a withdrawal

```py
import requests

def request_withdrawal(org_id, token, account_id, asset, amount, destination):
    url = f"https://api.quub.exchange/v1/orgs/{org_id}/custody/withdrawals"
    headers = {
        'Authorization': f'Bearer {token}',
        'X-Org-Id': org_id,
        'Content-Type': 'application/json'
    }
    payload = {
        'accountId': account_id,
        'asset': asset,
        'amount': amount,
        'destination': destination
    }
    r = requests.post(url, json=payload, headers=headers)
    return r.json()
```

## 🏗️ Core API Operations {#core-operations}

All endpoints and schemas below are taken directly from `openapi/custodian.yaml`. No operations or properties are invented.

### Custody Account Management

- GET /orgs/{orgId}/custody/accounts — List custody accounts

  - Security: `oauth2` (scope `read:custody`) or `apiKey`
  - Parameters:
    - `orgId` (path) — required
    - `X-Org-Id` (header) — required (common/components param)
    - `cursor`, `limit` (pagination parameters via common/pagination.yaml)
  - Responses: 200 returns a paginated list of `CustodyAccount` objects.

Example (Node.js):

```js
// GET /orgs/{orgId}/custody/accounts
async function listAccounts(orgId, token) {
  const res = await fetch(
    `https://api.quub.exchange/v1/orgs/${orgId}/custody/accounts`,
    {
      headers: { Authorization: `Bearer ${token}`, "X-Org-Id": orgId },
    }
  );
  return res.json();
}
```

- POST /orgs/{orgId}/custody/accounts — Create custody account

  - Security: `oauth2` (scope `write:custody`) or `apiKey`
  - Request body JSON (required):
    - `accountType` (string, enum: SELF_CUSTODY | QUALIFIED_CUSTODY | OMNIBUS | SEGREGATED)
    - `assetType` (string, enum: CRYPTO | SECURITIES | FIAT)
  - Responses: 201 returns created `CustodyAccount` in `data`.

Example (cURL):

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/ORG_ID/custody/accounts" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -H "X-Org-Id: ORG_ID" \
  -d '{"accountType":"SEGREGATED","assetType":"CRYPTO"}'
```

### Balances

- GET /orgs/{orgId}/custody/balances/{accountId} — Get custody account balances

  - Security: `oauth2` (scope `read:custody`) or `apiKey`
  - Parameters:
    - `orgId` (path), `X-Org-Id` (header)
    - `accountId` (path, uuid)
    - `cursor`, `limit` (pagination)
  - Responses: 200 returns paginated `CustodyBalance` items in `data`.

Example (Python):

```py
def get_balances(org_id, token, account_id):
    url = f"https://api.quub.exchange/v1/orgs/{org_id}/custody/balances/{account_id}"
    headers = {'Authorization': f'Bearer {token}', 'X-Org-Id': org_id}
    r = requests.get(url, headers=headers)
    return r.json()
```

### Deposits

- POST /orgs/{orgId}/custody/deposits — Initiate deposit

  - Security: `oauth2` (scope `write:custody`) or `apiKey`
  - Request body JSON (required):
    - `accountId` (uuid)
    - `asset` (string)
    - `amount` (string)
  - Responses: 201 returns `CustodyTransaction` in `data` (type `DEPOSIT`).

Example (Node.js):

```js
async function initiateDeposit(orgId, token, accountId, asset, amount) {
  const res = await fetch(
    `https://api.quub.exchange/v1/orgs/${orgId}/custody/deposits`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
        "X-Org-Id": orgId,
      },
      body: JSON.stringify({ accountId, asset, amount }),
    }
  );
  return res.json();
}
```

### Withdrawals

- POST /orgs/{orgId}/custody/withdrawals — Request withdrawal

  - Security: `oauth2` (scope `write:custody`) or `apiKey`
  - Request body JSON (required):
    - `accountId` (uuid)
    - `asset` (string)
    - `amount` (string)
    - `destination` (string)
  - Responses: 201 returns `CustodyTransaction` in `data` (type `WITHDRAWAL`).

Important: responses include 409 Conflict and 422 ValidationError as defined in the common responses referenced by the spec — handle these per your client's error strategy.

Example (cURL):

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/ORG_ID/custody/withdrawals" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -H "X-Org-Id: ORG_ID" \
  -d '{"accountId":"ACCOUNT_UUID","asset":"ETH","amount":"10.0","destination":"0x..."}'
```

### Proof of Custody

- GET /orgs/{orgId}/custody/proof-of-custody — Get proof of custody attestation

  - Security: `oauth2` (scope `read:custody`) or `apiKey`
  - Parameters: `orgId` (path), `X-Org-Id` (header)
  - Responses: 200 returns `ProofOfCustody` in `data`.

Example (Python):

```py
def get_proof_of_custody(org_id, token):
    url = f"https://api.quub.exchange/v1/orgs/{org_id}/custody/proof-of-custody"
    headers = {'Authorization': f'Bearer {token}', 'X-Org-Id': org_id}
    r = requests.get(url, headers=headers)
    return r.json()
```

## 🔐 Authentication Setup {#authentication}

The Custodian API supports the security schemes referenced in the OpenAPI spec:

- OAuth 2.0 (client credentials) — use `Authorization: Bearer <token>` with `read:custody` and/or `write:custody` scopes
- API Key — use the `apiKey` scheme if configured for programmatic integrations
- bearerAuth — used by token-based examples

Always present the `X-Org-Id` header or the `orgId` path parameter as required by the endpoint.

## ✨ Best Practices {#best-practices}

- Validate request payloads against the exact schemas in `openapi/custodian.yaml`.
- Handle 4xx/5xx responses according to the spec's common responses (BadRequest, Unauthorized, Forbidden, Conflict, ValidationError).
- For high-value withdrawals, implement destination validation and multi-step approvals.
- Use pagination parameters (`cursor`, `limit`) when listing accounts or balances.

## 🔒 Security Guidelines {#security}

- Use OAuth client credentials for server-to-server integrations and rotate client secrets regularly.
- Limit scopes to `read:custody` or `write:custody` as appropriate.
- Protect API keys and tokens in secure secret stores; never embed them in client-side code.

## 🚀 Performance Optimization {#performance}

- Cache low-sensitivity responses (e.g., account metadata) where appropriate.
- Use pagination for accounts and balances to avoid large payloads.

## 🔧 Advanced Configuration {#advanced}

- Integrate on-chain confirmations for deposit flows when dealing with CRYPTO assets; the API returns transaction objects (`CustodyTransaction`) that can be correlated with blockchain events.

## 🔍 Troubleshooting {#troubleshooting}

- 401 Unauthorized: check token validity and scopes.
- 403 Forbidden: ensure the API key or OAuth client has access to the requested org.
- 404 Not Found: check `orgId` and `accountId` values are correct.
- 409 Conflict / 422 ValidationError: review payload against the schema and handle idempotency or duplicate request cases.

## 📊 Monitoring & Observability {#monitoring}

- Instrument request timings and error rates for deposit/withdrawal endpoints.
- Track the number of pending vs completed `CustodyTransaction` items.
- Monitor `ProofOfCustody` generation frequency and attestation signatures.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/custodian.yaml`
- Common components and responses: `/openapi/common/`

---

## This guide documents only operations and schemas present in `openapi/custodian.yaml` and follows the repository's YAML-fidelity constraints.

layout: docs
title: Custodian Guides
permalink: /capabilities/custodian/guides/

---

# Custodian Implementation Guides

Comprehensive guides for implementing and integrating Custodian capabilities.

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

_For API reference, see [Custodian API Documentation](../api-documentation/)_
