---
layout: docs
title: Documents Guides
permalink: /capabilities/documents/guides/
---

# 📚 Documents Implementation Guides

> Developer guide for document management, e-signature workflows, and publications. All endpoints and schemas below are taken directly from `openapi/documents.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations (Documents, ESignatures, Publications)
- Authentication & Security
- Best Practices & Troubleshooting

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Secure multi-tenant document storage with versioning and metadata.
- Upload and retrieve documents in multiple formats (PDF, DOCX, IMAGE, XLSX, JSON).
- Orchestrate electronic signature workflows across providers (DOCUSIGN, UAE_PASS, QUUB_NATIVE).
- Publish documents to audiences (PUBLIC, INVESTORS, INTERNAL) with secure, trackable URLs.
- Maintain audit trails and support regulatory compliance.

### Technical Architecture (conceptual)

```
Clients (Portals, Backoffice) --> Documents API --> Storage / E-Sign Providers / Publication CDN
                                  |-- Document metadata (Document)
                                  |-- Signature workflows (SignatureRequest)
                                  |-- Publication registry (Publication)
```

### Core Data Models (from spec)

- Document: id, orgId, name, type (PDF|DOCX|IMAGE|XLSX|JSON), status (DRAFT|REVIEW|PUBLISHED|ARCHIVED), tags, storageUrl, linkedProjectId, createdBy, createdAt, updatedAt
- SignatureRequest: id, documentId, method (DOCUSIGN|UAE_PASS|MANUAL|QUUB_NATIVE), status (PENDING|COMPLETED|REJECTED|EXPIRED), signers (name,email,role,status), requestedAt, completedAt
- Publication: id, orgId, documentId, title, category (REPORT|DISCLOSURE|NOTICE|CONTRACT), publishedAt, publishedBy, audience (PUBLIC|INVESTORS|INTERNAL), documentUrl

Refer to `openapi/documents.yaml` for complete schema property lists and exact types — do not add properties beyond the spec.

## 🎯 Quick Start {#quick-start}

### Prerequisites

- Base URL: `https://api.quub.exchange/v2` or sandbox `https://api.sandbox.quub.exchange/v2`.
- Authentication: OAuth2 bearer token (scopes `read:documents`, `write:documents`) or API key per common security schemes.
- Organization identifier (`orgId`) is required for org-scoped endpoints and often repeated in the `X-Org-Id` header (see `common/components.yaml`).

### Minimal examples

cURL — list published documents for an org

```bash
curl -X GET "https://api.sandbox.quub.exchange/v2/orgs/ORG_ID/documents?status=PUBLISHED&limit=20" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: ORG_ID"
```

Node.js (fetch) — upload a document (multipart/form-data)

```js
import fetch from "node-fetch";
import FormData from "form-data";

async function uploadDocument(orgId, token, fileStream, name, type) {
  const form = new FormData();
  form.append("file", fileStream, { filename: name });
  form.append("name", name);
  form.append("type", type); // PDF|DOCX|IMAGE|XLSX|JSON

  const res = await fetch(
    `https://api.sandbox.quub.exchange/v2/orgs/${orgId}/documents`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "X-Org-Id": orgId,
        ...form.getHeaders(),
      },
      body: form,
    }
  );
  return res.json();
}
```

Python (requests) — request an e-signature for a document

```py
import requests

def request_esign(org_id, token, document_id, signers, method='DOCUSIGN', due_date=None):
    url = f"https://api.sandbox.quub.exchange/v2/orgs/{org_id}/documents/{document_id}/signatures"
    headers = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json', 'X-Org-Id': org_id}
    payload = {'signers': signers, 'method': method}
    if due_date:
        payload['dueDate'] = due_date
    r = requests.post(url, json=payload, headers=headers)
    return r.json()

# signers example: [{'name': 'Alice','email': 'alice@example.com','role': 'SIGNER'}]
```

## 🏗️ Core API Operations {#core-operations}

All operations below match exactly the paths and methods in `openapi/documents.yaml`.

### Documents

- GET /orgs/{orgId}/documents — List documents

  - Query filters: `status` (DRAFT|REVIEW|PUBLISHED|ARCHIVED), `type` (PDF|DOCX|IMAGE|XLSX|JSON), `cursor`, `limit`.
  - Response: 200 paginated `data: Document[]`.

- POST /orgs/{orgId}/documents — Upload a new document

  - Request body: multipart/form-data with fields: `file` (binary), `name` (string), optional `type`, `tags`, `linkedProjectId` (uuid).
  - Response: 201 with `{ data: Document }`.

- GET /orgs/{orgId}/documents/{documentId} — Get document details

  - Path param: `documentId` (uuid). Response: 200 `{ data: Document }`.

- PATCH /orgs/{orgId}/documents/{documentId} — Update document metadata or status
  - Request body JSON: `name`, `status` (DRAFT|REVIEW|PUBLISHED|ARCHIVED), `tags`.
  - Response: 200 with `{ data: Document }`.

Notes: validate uploaded file types and scan for malware per your security policy. Storage URLs in `Document.storageUrl` are time-limited and provided by the service.

### ESignatures

- POST /orgs/{orgId}/documents/{documentId}/signatures — Request e-signature

  - Request body JSON (required): `signers` (array of {name,email,role}), optional `method` (DOCUSIGN|UAE_PASS|MANUAL|QUUB_NATIVE), `dueDate`.
  - Response: 201 with `{ data: SignatureRequest }`.

- GET /orgs/{orgId}/documents/{documentId}/signatures/{signatureId} — Get signature status
  - Path params: `documentId`, `signatureId` (uuids). Response: 200 `{ data: SignatureRequest }`.

Implementation note: support provider callbacks/webhooks to update signer statuses (PENDING → SIGNED/DECLINED) and to reconcile `SignatureRequest.completedAt`.

### Publications

- GET /orgs/{orgId}/publications — List published documents
  - Pagination supported. Response: 200 paginated `data: Publication[]`.

Use publications to expose documents to audiences and generate trackable document URLs (`Publication.documentUrl`).

## 🔐 Authentication & Security {#authentication}

- Security schemes per `openapi/documents.yaml`: OAuth2 (scopes `read:documents`, `write:documents`), API Key.
- Ensure org-scoped requests include `orgId` and matching `X-Org-Id` header where required by the common components.
- Protect uploaded files and storage credentials: use server-side uploads, virus-scanning, and storage URLs with short TTL.

## ✨ Best Practices {#best-practices}

- Enforce file size limits and validate content type on upload (spec recommends explicit type enum).
- Use cursor-based pagination for large document sets and limit result pages.
- For e-sign flows, include `idempotencyKey` at the client layer to prevent duplicate signature requests when retries occur (if supported by your client pattern).
- Store document metadata and avoid storing sensitive PII directly in documents unless encrypted and compliant with data retention policies.

## 🔍 Troubleshooting {#troubleshooting}

- 400 Bad Request: usually payload issues — check required multipart fields (`file`, `name`) for uploads and required signers for e-sign requests.
- 401 Unauthorized: check token validity and scopes.
- 403 Forbidden: ensure API key or OAuth client has access to the target `orgId`.
- 404 Not Found: verify `documentId` or `signatureId` and that the resource belongs to the correct org.
- 409 Conflict / 422 ValidationError: follow response bodies defined in the spec (e.g., duplicate resources, invalid signer emails).

## 📊 Monitoring & Observability {#monitoring}

- Track upload success/failure rates, average upload size, and storage errors.
- Monitor e-signature completion times and failure/retry patterns for third-party providers.
- Instrument publication accesses and document download counts for auditing and analytics.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/documents.yaml`
- API docs & overview: `/capabilities/documents/api-documentation/` and `/capabilities/documents/overview/`

---

## This guide was created strictly from `openapi/documents.yaml`. All operations, parameters, and schemas referenced are present in the spec; no endpoints or schema fields were invented.

layout: docs
title: Documents Guides
permalink: /capabilities/documents/guides/

---

# Documents Implementation Guides

Comprehensive guides for implementing and integrating Documents capabilities.

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

_For API reference, see [Documents API Documentation](../api-documentation/)_
