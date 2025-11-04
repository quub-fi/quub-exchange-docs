---
layout: docs
title: Compliance Guides
permalink: /capabilities/compliance/guides/
---

# 📚 Compliance Implementation Guides

> Comprehensive developer guide for implementing KYC, investor accreditation, and token whitelist enforcement.

## 🚀 Quick Navigation

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 30px 0;">

<div style="border: 2px solid #667eea; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #667eea10 0%, #764ba210 100%);">
  <h3 style="margin-top: 0; color: #667eea;">🎯 Getting Started</h3>
  <p>New to Compliance? Start here.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#quick-start">Quick Start Guide</a></li>
    <li><a href="#overview">API Overview & Architecture</a></li>
    <li><a href="#authentication">Authentication Setup</a></li>
  </ul>
</div>

<div style="border: 2px solid #10b981; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #10b98110 0%, #059669100%);">
  <h3 style="margin-top: 0; color: #10b981;">✨ Best Practices</h3>
  <p>Patterns for reliable integrations.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#best-practices">Implementation Best Practices</a></li>
    <li><a href="#security">Security Guidelines</a></li>
    <li><a href="#performance">Performance Optimization</a></li>
  </ul>
</div>

<div style="border: 2px solid #f59e0b; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #f59e0b10 0%, #d9770610 100%);">
  <h3 style="margin-top: 0; color: #f59e0b;">🔧 Advanced Topics</h3>
  <p>Dive deeper into advanced flows.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#advanced">Advanced Configuration</a></li>
    <li><a href="#troubleshooting">Troubleshooting</a></li>
    <li><a href="#monitoring">Monitoring & Observability</a></li>
  </ul>
</div>

</div>

---

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Centralize **KYC** case creation, retrieval, and review workflows
- Manage **investor accreditation** under supported regimes (e.g., US, EU, UAE)
- Enforce **token whitelists** by wallet/account and token class
- Support **organizational segregation** via `orgId` path scoping
- Provide **audit-friendly** operations with explicit create/update semantics
- Operate across **multi-jurisdiction** compliance regimes

### Technical Architecture

### Core Data Models

> All properties shown below are taken directly from the OpenAPI schemas.

**KycCase**

- `id` (uuid), `orgId` (uuid), `accountId` (uuid)
- `type` (`PERSON` | `ENTITY`)
- `status` (`PENDING` | `APPROVED` | `REJECTED`)
- `riskScore` (float), `evidenceUrls` (uri[])
- `createdAt` (date-time), `updatedAt` (date-time)

**Accreditation**

- `id` (uuid), `orgId` (uuid), `accountId` (uuid)
- `regime` (`US_SEC_RULE501` | `EU_PROF_INVESTOR` | `UAE_FSRA` | `VARA`)
- `status` (`PENDING` | `APPROVED` | `REVOKED` | `EXPIRED`)
- `expiresAt` (date-time), `docs` (uri[])
- `createdAt` (date-time)

**WhitelistEntry**

- `id` (uuid), `orgId` (uuid)
- `tokenClassId` (uuid), `walletId` (uuid), `accountId` (uuid)
- `status` (`APPROVED` | `REVOKED`)
- `reasons` (string[])
- `createdAt` (date-time)

---

## 🎯 Quick Start {#quick-start}

### Prerequisites

- Access to **Production** `https://api.quub.exchange/v2` or **Sandbox** `https://api.sandbox.quub.exchange/v2`
- An `orgId` you are authorized to operate within
- Authentication per **OAuth2 (scoped)** and/or **API Key**, as required by each operation
- (Where referenced) required headers from `./common/components.yaml` such as `orgIdHeader` and `idempotencyKey`

### 5-Minute Setup

#### Node.js (axios)

```js
import axios from "axios";

const baseURL = "https://api.sandbox.quub.exchange/v2"; // or production
const orgId = "11111111-1111-1111-1111-111111111111";

const client = axios.create({
  baseURL,
  // Attach auth per your oauth2/apiKey setup (see Authentication section)
});

// Example: list KYC cases (no invented params)
const res = await client.get(`/orgs/${orgId}/kyc/cases`, {
  params: {
    // Optional filters per YAML:
    // accountId: "22222222-2222-2222-2222-222222222222",
    // status: "PENDING",
    // cursor: "...", // from ./common/pagination.yaml
    // limit: 20
  },
  // Include referenced headers as defined in ./common/components.yaml (orgIdHeader, etc.)
});
console.log(res.data);
```

#### Python (requests)

```python
import requests

base_url = "https://api.sandbox.quub.exchange/v2"  # or production
org_id = "11111111-1111-1111-1111-111111111111"

session = requests.Session()
# Attach auth per your oauth2/apiKey setup (see Authentication section)

r = session.get(f"{base_url}/orgs/{org_id}/kyc/cases", params={
    # 'accountId': '22222222-2222-2222-2222-222222222222',
    # 'status': 'PENDING',
    # 'cursor': '...',
    # 'limit': 20,
})
print(r.json())
```

---

## 🏗️ Core API Operations {#core-operations}

> **Important:** This section documents **only** the operations defined in the YAML. Response bodies reference schemas exactly as specified.

### KYC

#### List KYC cases — `GET /orgs/{orgId}/kyc/cases`

- **Query params (optional):** `accountId` (uuid), `status` (`PENDING`|`APPROVED`|`REJECTED`), `cursor`, `limit`
- **Security:** `oauth2` (`read:compliance`) **or** `apiKey`
- **Response 200:** JSON with pagination (from `PageResponse`) **and** `data: KycCase[]`

**Node.js**

```js
const res = await client.get(`/orgs/${orgId}/kyc/cases`, {
  params: { status: "PENDING" },
});
/*
res.data conforms to:
allOf:
  - PageResponse (via ./common/pagination.yaml)
  - { data: KycCase[] }
*/
```

**Python**

```python
resp = session.get(f"{base_url}/orgs/{org_id}/kyc/cases", params={"status": "PENDING"})
print(resp.json())
```

#### Create KYC case — `POST /orgs/{orgId}/kyc/cases`

- **Headers:** `idempotencyKey` (from `./common/components.yaml`)
- **Body (required):**
  - `accountId` (uuid) **required**
  - `type` (`PERSON`|`ENTITY`) **required**
  - `evidenceUrls` (uri[]) **optional**
- **Security:** `oauth2` (`write:compliance`) **or** `apiKey`
- **Response 201:** `{ data: KycCase }`

**Node.js**

```js
const body = {
  accountId: "22222222-2222-2222-2222-222222222222",
  type: "PERSON",
  evidenceUrls: ["https://files.example.com/kyc/doc1.pdf"],
};

const res = await client.post(`/orgs/${orgId}/kyc/cases`, body, {
  // headers: { 'Idempotency-Key': '...' } // use exact header name from common/components.yaml
});
console.log(res.data);
```

#### Retrieve KYC case — `GET /orgs/{orgId}/kyc/cases/{caseId}`

- **Path parameter:** `kycId` (uuid) _(as defined in YAML parameter; see note in Troubleshooting)_
- **Security:** `oauth2` (`read:compliance`) **or** `apiKey`
- **Response 200:** `{ data: KycCase }`

**Python**

```python
kyc_case_id = "33333333-3333-3333-3333-333333333333"
r = session.get(f"{base_url}/orgs/{org_id}/kyc/cases/{kyc_case_id}")
print(r.json())
```

#### Update KYC case — `PATCH /orgs/{orgId}/kyc/cases/{caseId}`

- **Path parameter:** `kycId` (uuid) _(see note in Troubleshooting)_
- **Body (one or more):**
  - `status` (`PENDING`|`APPROVED`|`REJECTED`)
  - `riskScore` (float 0–100)
  - `reviewer` (string)
- **Security:** `oauth2` (`write:compliance`) **or** `apiKey`
- **Response 200:** `{ data: KycCase }`

**Node.js**

```js
const kycCaseId = "33333333-3333-3333-3333-333333333333";
const res = await client.patch(`/orgs/${orgId}/kyc/cases/${kycCaseId}`, {
  status: "APPROVED",
  riskScore: 12.5,
});
console.log(res.data);
```

---

### Accreditation

#### List accreditations — `GET /orgs/{orgId}/accreditations`

- **Query params (optional):**
  - `accountId` (uuid)
  - `regime` (`US_SEC_RULE501`|`EU_PROF_INVESTOR`|`UAE_FSRA`|`VARA`)
  - `status` (`PENDING`|`APPROVED`|`REVOKED`|`EXPIRED`)
  - `cursor`, `limit`
- **Security:** `oauth2` (`read:compliance`) **or** `apiKey`
- **Response 200:** pagination + `data: Accreditation[]`

**Python**

```python
r = session.get(f"{base_url}/orgs/{org_id}/accreditations", params={
    "regime": "US_SEC_RULE501",
    "status": "APPROVED"
})
print(r.json())
```

#### Create accreditation — `POST /orgs/{orgId}/accreditations`

- **Headers:** `idempotencyKey` (from `./common/components.yaml`)
- **Body (required):**
  - `accountId` (uuid)
  - `regime` (`US_SEC_RULE501`|`EU_PROF_INVESTOR`|`UAE_FSRA`|`VARA`)
  - `expiresAt` (date-time, optional)
  - `docs` (uri[] optional)
- **Security:** `oauth2` (`write:compliance`) **or** `apiKey`
- **Response 201:** `{ data: Accreditation }`

**Node.js**

```js
const res = await client.post(
  `/orgs/${orgId}/accreditations`,
  {
    accountId: "22222222-2222-2222-2222-222222222222",
    regime: "US_SEC_RULE501",
    expiresAt: "2026-12-31T23:59:59Z",
    docs: ["https://files.example.com/accred/letter.pdf"],
  }
  // ,{ headers: { 'Idempotency-Key': '...' } }
);
console.log(res.data);
```

---

### Whitelist

#### List whitelist entries — `GET /orgs/{orgId}/whitelist`

- **Query params (optional):**
  - `tokenClassId` (uuid), `accountId` (uuid)
  - `status` (`APPROVED`|`REVOKED`)
  - `cursor`, `limit`
- **Security:** `oauth2` (`read:compliance`) **or** `apiKey`
- **Response 200:** pagination + `data: WhitelistEntry[]`

**Node.js**

```js
const res = await client.get(`/orgs/${orgId}/whitelist`, {
  params: { status: "APPROVED" },
});
console.log(res.data);
```

#### Add whitelist entry — `POST /orgs/{orgId}/whitelist`

- **Headers:** `idempotencyKey` (from `./common/components.yaml`)
- **Body (required):**
  - `tokenClassId` (uuid)
  - `walletId` (uuid)
  - `accountId` (uuid, optional)
  - `reasons` (string[] optional)
- **Security:** `oauth2` (`write:compliance`) **or** `apiKey`
- **Response 201:** `{ data: WhitelistEntry }`
- **Error:** `409 Conflict` (per YAML)

**Python**

```python
payload = {
    "tokenClassId": "44444444-4444-4444-4444-444444444444",
    "walletId": "55555555-5555-5555-5555-555555555555",
    "reasons": ["Initial allowlist"]
}
r = session.post(f"{base_url}/orgs/{org_id}/whitelist", json=payload)
print(r.status_code, r.json())
```

#### Update whitelist entry — `PATCH /orgs/{orgId}/whitelist/{entryId}`

- **Path parameter:** `id` (uuid)
- **Body:** `status` (`APPROVED`|`REVOKED`)
- **Security:** `oauth2` (`write:compliance`) **or** `apiKey`
- **Response 200:** `{ data: WhitelistEntry }`
- **Errors:** `404 NotFound`, `422 ValidationError`, `429 TooManyRequests`

**Node.js**

```js
const entryId = "66666666-6666-6666-6666-666666666666";
const res = await client.patch(`/orgs/${orgId}/whitelist/${entryId}`, {
  status: "REVOKED",
});
console.log(res.data);
```

---

## 🔐 Authentication Setup {#authentication}

> Use only the security schemes specified in the YAML:
>
> - `oauth2` (scopes used by operations: `read:compliance`, `write:compliance`)
> - `apiKey`
> - `bearerAuth` is defined in `components.securitySchemes`, but operations in this spec explicitly require `oauth2` and/or `apiKey`.

**OAuth2 (example request usage)**

```js
// Attach OAuth2 access token obtained per your configured flow.
// Scope must include either 'read:compliance' or 'write:compliance' for the target operation.
client.interceptors.request.use((cfg) => {
  cfg.headers = cfg.headers || {};
  cfg.headers.Authorization = `Bearer ${process.env.ACCESS_TOKEN}`;
  return cfg;
});
```

**API Key (example request usage)**

```js
client.interceptors.request.use((cfg) => {
  cfg.headers = cfg.headers || {};
  // Use the exact header or parameter as defined in ./common/components.yaml for apiKey
  // e.g., cfg.headers['X-API-Key'] = process.env.QUUB_API_KEY;
  return cfg;
});
```

> Also include referenced headers such as `orgIdHeader` and `idempotencyKey` exactly as defined in `./common/components.yaml`.

---

## ✨ Best Practices {#best-practices}

- **Idempotency on POSTs:** Always send the `idempotencyKey` header (see `./common/components.yaml`) for create operations.
- **Filter precisely:** Use provided query filters (`status`, `regime`, `accountId`, etc.)—do not rely on undocumented parameters.
- **Org scoping:** Use the correct `orgId` in the path for every call. If your platform uses an additional org header (`orgIdHeader`), include it as defined.
- **Schema-only payloads:** Ensure request bodies contain **only** properties defined in the YAML; avoid extra fields.

---

## 🔒 Security Guidelines {#security}

- **Scopes:** Match operation scopes (`read:compliance` for reads, `write:compliance` for mutations).
- **API Key usage:** When using `apiKey`, pass it exactly per `./common/components.yaml` (header/query as defined there).
- **Data minimization:** Only submit `evidenceUrls`, `docs`, or `reasons` necessary for the operation.
- **Access control:** Keep `orgId` and account/resource IDs scoped to your tenant processes.

---

## 🚀 Performance Optimization {#performance}

- **Pagination:** Use `cursor` and `limit` from `./common/pagination.yaml` on list endpoints to iterate large datasets.
- **Targeted queries:** Apply `status`, `regime`, and ID filters to reduce payload sizes.
- **Selective updates:** Use `PATCH` payloads with only the fields you need to change.

---

## 🔧 Advanced Configuration {#advanced}

- **Jurisdiction routing:** Use the `regime` enum for accreditations to drive jurisdiction-specific workflows downstream.
- **Whitelist governance:** Combine `tokenClassId` and `walletId` with `status` transitions (`APPROVED` ⇄ `REVOKED`) to align with token lifecycle events.
- **Risk signaling:** When updating KYC, use `riskScore` (0–100) to propagate review outcomes through your internal rules.

---

## 🔍 Troubleshooting {#troubleshooting}

- **401 Unauthorized / 403 Forbidden**

  - Verify OAuth2 token scopes (`read:compliance`/`write:compliance`)
  - Confirm `apiKey` presence and placement per `./common/components.yaml`
  - Ensure the `orgId` in the path is valid for the authenticated principal

- **400 BadRequest / 422 ValidationError**

  - Check enums: `type`, `status`, `regime` must be exact
  - Validate formats: UUIDs and `date-time` strings
  - For `riskScore`, ensure 0–100 float range

- **409 Conflict (Whitelist POST)**

  - Indicates a conflict condition as defined in the service (e.g., existing entry)

- **404 NotFound (Whitelist PATCH)**

  - The `id` path parameter must reference an existing whitelist entry

- **Parameter naming note (from YAML)**
  - `GET/PATCH /orgs/{orgId}/kyc/cases/{caseId}` declare a **path parameter named `kycId`** in the spec. Use the path shape shown here and the parameter name exactly as defined by the YAML when generating clients or server stubs.

---

## 📊 Monitoring & Observability {#monitoring}

- **Request logging:** Log method, path, and response codes for all compliance calls.
- **Audit alignment:** Retain mutation requests/responses for `POST`/`PATCH` to support audits.
- **KPIs:** Track volumes for KYC cases by `status`, accreditation by `regime/status`, and whitelist transitions.

---

## 📚 Additional Resources

- **API Documentation:** `../api-documentation/`
- **Service Overview:** `../overview/`
- **OpenAPI Specification:** `/openapi/compliance.yaml`
  _(This guide is generated strictly from the YAML and references `./common/_.yaml` for shared components.)\*
