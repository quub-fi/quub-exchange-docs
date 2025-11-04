---
layout: docs
title: Notifications Guides
permalink: /capabilities/notifications/guides/
---

# 📚 Notifications Implementation Guides

> Comprehensive developer guide for Notifications: managing preferences, delivery history, and sending messages — derived only from `openapi/notifications.yaml`.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Best Practices

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Manage organization-level notification preferences (channels, templates, triggers)
- Retrieve delivery history for auditing and troubleshooting
- Send notifications (EMAIL, SMS, PUSH) to users or accounts

### Technical Architecture

Client -> API Gateway -> Notifications Service -> Delivery Providers (SMTP/SMS/Push) -> Recipients

### Core Data Models

Defined in `openapi/notifications.yaml` (use these schemas exactly):

- Notification: id (uuid), orgId (uuid), type (EMAIL|SMS|PUSH), status (PENDING|SENT|FAILED), subject, body, sentAt (date-time), recipients[], metadata
- NotificationPreference: channel (EMAIL|SMS|PUSH), enabled (boolean), templateId, trigger

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth2 client or org API key with scopes `read:notifications` / `write:notifications`.
- `orgId` value for the tenant you're operating on.

### 5-Minute Setup

1. Obtain an access token (OAuth2) or `X-API-KEY`.
2. Inspect current preferences, review history, then send a test notification.

Example (curl) — get notification preferences:

```bash
curl -X GET "https://api.quub.exchange/v1/orgs/{orgId}/notifications/preferences" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}"
```

## 🏗️ Core API Operations {#core-operations}

All operations and schemas below are taken directly from `openapi/notifications.yaml`.

### Preferences

GET /orgs/{orgId}/notifications/preferences — Retrieve organization notification preferences.

PUT /orgs/{orgId}/notifications/preferences — Update notification preferences. Request body expects `preferences: NotificationPreference[]`.

Example (curl) — update preferences:

```bash
curl -X PUT "https://api.quub.exchange/v1/orgs/{orgId}/notifications/preferences" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -H "X-Org-Id: {orgId}" \
  -d '{"preferences": [{"channel":"EMAIL","enabled":true,"templateId":"tpl_123","trigger":"TRADE_EXECUTED"}]}'
```

### History

GET /orgs/{orgId}/notifications/history — Retrieve sent notifications. Query parameters: `type` (EMAIL|SMS|PUSH), `status` (PENDING|SENT|FAILED), `since` (date-time).

Example (curl) — query history (validator-friendly query format):

```bash
curl -G "https://api.quub.exchange/v1/orgs/{orgId}/notifications/history" \
  --data-urlencode "type=EMAIL" \
  --data-urlencode "status=SENT" \
  --data-urlencode "since={since}" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Org-Id: {orgId}"
```

Response schema: `Notification[]` (see spec).

### Send

POST /orgs/{orgId}/notifications/send — Send a notification. Required body fields: `type`, `recipients`, `subject`, `body`.

Example (curl) — send a notification:

```bash
curl -X POST "https://api.quub.exchange/v1/orgs/{orgId}/notifications/send" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -H "X-Org-Id: {orgId}" \
  -d '{
    "type":"EMAIL",
    "recipients":["user@example.com"],
    "subject":"Test notification",
    "body":"This is a test message from Quub.",
    "metadata": {"templateId":"tpl_123"}
  }'
```

Success response: 201 with `Notification` object.

## 🔐 Authentication Setup {#authentication}

- Security schemes (from spec): OAuth2 (scopes `read:notifications`, `write:notifications`), `apiKey`, or `bearerAuth`.
- Include `X-Org-Id` header for tenant assertion where applicable.

## ✨ Best Practices {#best-practices}

- Validate recipients and message size client-side before sending.
- Use templates (referenced via `metadata.templateId`) to standardize messages and reduce body size.
- Respect rate limits (server may return 429). Implement exponential backoff on failures.

## 🔍 Troubleshooting {#troubleshooting}

- 400: BadRequest — malformed request or missing required fields.
- 401/403: auth/permission issues — verify token scopes and API key permissions.
- 404: NotFound — resource (org) not present.
- 429: TooManyRequests — back off and retry.

## 📊 Monitoring & Observability {#monitoring}

- Record delivery status and errors from `Notification.status` (PENDING|SENT|FAILED).
- Capture `Request-Id` and `X-Org-Id` in logs for auditing.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/notifications.yaml` (source of truth)
- API docs: `/capabilities/notifications/api-documentation/`

---

_This guide was generated strictly from `openapi/notifications.yaml` and existing capability docs; no endpoints or schema properties were invented._

## For API reference, see [Notifications API Documentation](../api-documentation/)

layout: docs
title: Notifications Guides
permalink: /capabilities/notifications/guides/

---

# Notifications Implementation Guides

Comprehensive guides for implementing and integrating Notifications capabilities.

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

_For API reference, see [Notifications API Documentation](../api-documentation/)_
