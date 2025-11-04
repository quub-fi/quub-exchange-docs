---
layout: docs
title: Fees & Billing Guides
permalink: /capabilities/fees-billing/guides/
---

# 📚 Fees & Billing Implementation Guides

> Comprehensive developer guide for implementing fee schedules, invoices, and rebate operations (derived strictly from the OpenAPI spec).

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Manage organization fee schedules and rates for trading, deposits, withdrawals, network and service fees
- Provide invoice history, retrieval and reconciliation for organization billing
- Support rebate programs and credits for organizations
- Enable programmatic queries for billing automation and financial reporting

### Technical Architecture

Fee engine -> Billing service -> Invoice store -> Notification/Accounting systems

### Core Data Models

All models below are copied from `openapi/fees-billing.yaml` and used in examples.

- FeeSchedule

  - id (uuid)
  - orgId (uuid)
  - feeType (TRADING|WITHDRAWAL|DEPOSIT|NETWORK|SERVICE)
  - rate (number)
  - currency (string)
  - effectiveDate (date)
  - createdAt (date-time)

- Invoice

  - id (uuid)
  - orgId (uuid)
  - amount (number)
  - currency (string)
  - status (DRAFT|ISSUED|PAID|OVERDUE|CANCELLED)
  - issueDate (date)
  - dueDate (date)
  - items (array of InvoiceItem)
  - paidAt (date-time)
  - createdAt (date-time)

- InvoiceItem

  - description (string)
  - amount (number)
  - currency (string)

- Rebate
  - id (uuid)
  - orgId (uuid)
  - description (string)
  - amount (number)
  - currency (string)
  - status (PENDING|APPROVED|CREDITED|REJECTED)
  - effectiveDate (date)
  - createdAt (date-time)

## 🎯 Quick Start {#quick-start}

### Prerequisites

- API access (OAuth2 scopes `read:fees`, `write:fees` or API key)
- `orgId` to scope organization data (also provided via `x-org-id` header per docs)

### 5-Minute Setup

1. Retrieve fee schedules for pricing calculations via `GET /orgs/{orgId}/fees/schedules`.
2. Query invoices for billing automation via `GET /orgs/{orgId}/billing/invoices`.
3. Retrieve rebates with `GET /orgs/{orgId}/billing/rebates` to apply credits.

## 🏗️ Core API Operations {#core-operations}

The following operations are present in `openapi/fees-billing.yaml` — no additional endpoints are introduced.

### Fee Schedules

- GET /orgs/{orgId}/fees/schedules — listFeeSchedules
  - Query parameters: `type` (TRADING|WITHDRAWAL|DEPOSIT|NETWORK|SERVICE), pagination (`cursor`, `limit`)
  - Success: 200 with paginated `FeeSchedule` items. Error responses: 400, 401, 403, 500.

### Invoices

- GET /orgs/{orgId}/billing/invoices — listInvoices

  - Query parameters: `status` (DRAFT|ISSUED|PAID|OVERDUE|CANCELLED), `fromDate`, `toDate`, pagination
  - Success: 200 with paginated `Invoice` items. Error responses: 400, 401, 403, 500.

- GET /orgs/{orgId}/billing/invoices/{invoiceId} — getInvoice
  - Path param: `invoiceId` (uuid)
  - Success: 200 with `Invoice` in `data`. Error responses: 400, 401, 403, 500.

### Rebates

- GET /orgs/{orgId}/billing/rebates — listRebates
  - Query parameters: `status` (PENDING|APPROVED|CREDITED|REJECTED), pagination
  - Success: 200 with paginated `Rebate` items. Error responses: 400, 401, 403, 404, 429, 500.

## 🔐 Authentication Setup {#authentication}

Security schemes defined in the spec:

- `oauth2` with scopes `read:fees`, `write:fees`
- `apiKey` and `bearerAuth` referenced as available mechanisms

Use OAuth tokens with the proper scope for read or write operations.

## ✨ Examples (Node.js & Python)

All examples use only fields and endpoints that exist in `openapi/fees-billing.yaml`.

### Node.js (axios)

```javascript
const axios = require("axios");
const BASE = "https://api.quub.exchange/v1";

async function getFeeSchedules(orgId, type) {
  const res = await axios.get(`${BASE}/orgs/${orgId}/fees/schedules`, {
    params: type ? { type } : {},
    headers: { Authorization: `Bearer ${process.env.QUUB_TOKEN}` },
  });
  return res.data; // contains paginated FeeSchedule items
}

async function listInvoices(orgId, status) {
  const res = await axios.get(`${BASE}/orgs/${orgId}/billing/invoices`, {
    params: status ? { status } : {},
    headers: { Authorization: `Bearer ${process.env.QUUB_TOKEN}` },
  });
  return res.data; // paginated Invoice items
}

async function getInvoice(orgId, invoiceId) {
  const res = await axios.get(
    `${BASE}/orgs/${orgId}/billing/invoices/${invoiceId}`,
    {
      headers: { Authorization: `Bearer ${process.env.QUUB_TOKEN}` },
    }
  );
  return res.data.data; // Invoice object
}
```

### Python (requests)

```python
import os
import requests

BASE = 'https://api.quub.exchange/v1'
HEADERS = { 'Authorization': f"Bearer {os.getenv('QUUB_TOKEN')}" }

def get_fee_schedules(org_id, fee_type=None):
    params = {'type': fee_type} if fee_type else {}
    resp = requests.get(f"{BASE}/orgs/{org_id}/fees/schedules", headers=HEADERS, params=params)
    resp.raise_for_status()
    return resp.json()

def list_invoices(org_id, status=None, from_date=None, to_date=None):
    params = {}
    if status: params['status'] = status
    if from_date: params['fromDate'] = from_date
    if to_date: params['toDate'] = to_date
    resp = requests.get(f"{BASE}/orgs/{org_id}/billing/invoices", headers=HEADERS, params=params)
    resp.raise_for_status()
    return resp.json()

def get_invoice(org_id, invoice_id):
    resp = requests.get(f"{BASE}/orgs/{org_id}/billing/invoices/{invoice_id}", headers=HEADERS)
    resp.raise_for_status()
    return resp.json()['data']
```

## ✨ Best Practices {#best-practices}

- Cache fee schedules but revalidate on `effectiveDate` changes to ensure correct rate application.
- Use invoice `status` filters and date ranges to paginate and retrieve relevant billing periods.
- Implement retry/backoff for 429 rate-limit responses and transient 5xx errors.
- Verify rebate `status` before applying credits to avoid double-crediting.

## 🔍 Troubleshooting {#troubleshooting}

- 400: check query parameter formats (dates expected as `YYYY-MM-DD`).
- 401/403: ensure token scopes include `read:fees` for read operations.
- 404: invoice or rebate not found — verify `invoiceId` and `orgId`.
- 429: back off and retry per rate limit guidance.

## 📊 Monitoring & Observability {#monitoring}

- Track metrics: `fee_schedules_fetched_total`, `invoices_fetched_total`, `rebates_fetched_total`, `billing_errors_total`, invoice generation latency.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/fees-billing.yaml`
- API documentation: `/capabilities/fees-billing/api-documentation/index.md`
- Overview: `/capabilities/fees-billing/overview/index.md` (if present)

---

## This guide was generated directly from `openapi/fees-billing.yaml`. All endpoints, request/response fields, parameters and schemas used here are present in the OpenAPI file and nothing was invented.

layout: docs
title: Fees Billing Guides
permalink: /capabilities/fees-billing/guides/

---

# Fees Billing Implementation Guides

Comprehensive guides for implementing and integrating Fees Billing capabilities.

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

_For API reference, see [Fees Billing API Documentation](../api-documentation/)_
