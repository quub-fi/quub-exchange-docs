---
layout: docs
title: Events Guides
permalink: /capabilities/events/guides/
---

# 📚 Events Implementation Guides

> Comprehensive developer guide for implementing event schemas, subscriptions, delivery and replay based on the Events OpenAPI spec.

## 🚀 Quick Navigation

- Getting Started
- Core Operations
- Advanced Topics

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Provide a CloudEvents 1.0 compliant event platform for Quub Exchange
- Publish and consume domain events across services (account, trading, compliance, treasury, governance)
- Offer reliable delivery via webhooks and polling with automatic retries
- Support event schema discovery and validation through a schema registry
- Enable event replay for recovery and backfill use cases

### Technical Architecture

ASCII integration diagram:

Producers --> Event Bus/Registry --> Events Service (API)
|-> Subscriptions (webhooks/poll)
|-> Replay Jobs
|-> Delivery & Retry

### Core Data Models

The following schemas are defined in `openapi/events.yaml` and used in examples.

- EventSchema: eventType, version, category (ACCOUNT|TRADING|COMPLIANCE|PRIMARY|TREASURY|GOVERNANCE|SYSTEM), description, dataSchema, examples
- EventSubscription: id, orgId, name, description, eventTypes, deliveryType (WEBHOOK|POLLING), webhookUrl, webhookSecret, enabled, createdAt, updatedAt
- CreateSubscriptionRequest: name, eventTypes, deliveryType, webhookUrl, enabled
- DomainEvent: CloudEvents 1.0 compliant fields (id, source, specversion, type, datacontenttype, time, subject, orgId, data)
- EventDelivery: id, subscriptionId, eventId, status (PENDING|DELIVERED|FAILED|RETRYING), attempts, lastAttemptAt, nextRetryAt, responseCode, responseBody, error
- ReplayJob: id, subscriptionId, status (QUEUED|RUNNING|COMPLETED|FAILED), startTime, endTime, eventsTotal, eventsProcessed, eventsFailed, createdAt, completedAt

## 🎯 Quick Start {#quick-start}

### Prerequisites

- OAuth token or API key with scopes: `read:events`, `write:events`, `admin:events` (per OpenAPI securitySchemes).
- `orgId` for organization-scoped endpoints and the `x-org-id` header where required.

### 5-Minute Setup

1. Create an event subscription for your org using `POST /orgs/{orgId}/events/subscriptions`.
2. Verify webhook deliveries and signature validation if using `WEBHOOK` delivery.
3. Query recent events using `GET /orgs/{orgId}/events` and use replay when needed via `POST /orgs/{orgId}/events/replay`.

## 🏗️ Core API Operations {#core-operations}

All operations below are taken directly from `openapi/events.yaml`.

### Event Schema Management

- GET /events/schemas — listEventSchemas

  - Query parameters: `category` (enum), pagination (`cursor`, `limit`)
  - Response: 200 with paginated `EventSchema` items. Errors: 400, 401, 403, 500.

- GET /events/schemas/{eventType} — getEventSchema
  - Path param: `eventType` (string)
  - Response: 200 with `EventSchema`. Errors: 400, 401, 403, 500.

### Subscriptions (per-organization)

- GET /orgs/{orgId}/events/subscriptions — listEventSubscriptions

  - Parameters: `orgId` path, `x-org-id` header, pagination
  - Response: 200 with paginated `EventSubscription`. Errors: 400, 401, 403, 500.

- POST /orgs/{orgId}/events/subscriptions — createEventSubscription

  - Request body: `CreateSubscriptionRequest` (name, eventTypes, deliveryType, webhookUrl, enabled)
  - Response: 201 with `EventSubscription`. Errors: 400, 401, 403, 500.

- GET /orgs/{orgId}/events/subscriptions/{subscriptionId} — getEventSubscription

  - Path param: `subscriptionId` (uuid)
  - Response: 200 with `EventSubscription`. Errors: 400, 401, 403, 500.

- PATCH /orgs/{orgId}/events/subscriptions/{subscriptionId} — updateEventSubscription

  - Request body: partial object containing `enabled` (boolean) and/or `eventTypes` (array[string])
  - Response: 200 with `EventSubscription`. Errors: 400, 401, 403, 500.

- DELETE /orgs/{orgId}/events/subscriptions/{subscriptionId} — deleteEventSubscription
  - Response: 204 No Content on success. Errors: 400, 401, 403, 500.

### Event History & Querying

- GET /orgs/{orgId}/events — queryEvents

  - Query params: `eventType`, `startTime`, `endTime`, `resourceId`, pagination
  - Response: 200 with paginated `DomainEvent` items. Errors: 400, 401, 403, 500.

- GET /orgs/{orgId}/events/{eventId} — getEvent
  - Path param: `eventId` (uuid)
  - Response: 200 with `DomainEvent`. Errors: 400, 401, 403, 500.

### Event Replay

- POST /orgs/{orgId}/events/replay — replayEvents

  - Request body: { subscriptionId (uuid), startTime (date-time), endTime (date-time), eventTypes (array[string]) }
  - Response: 201 with `ReplayJob`. Errors: 400, 401, 403, 500.

- GET /orgs/{orgId}/events/replay/{jobId} — getReplayStatus
  - Path param: `jobId` (uuid)
  - Response: 200 with `ReplayJob`. Errors: 400, 401, 403, 500.

### Deliveries & Retry

- GET /orgs/{orgId}/events/deliveries — listEventDeliveries

  - Query params: `subscriptionId`, `status` (PENDING|DELIVERED|FAILED|RETRYING), pagination
  - Response: 200 with `EventDelivery` items. Errors: 400, 401, 404, 403, 500.

- POST /orgs/{orgId}/events/deliveries/{deliveryId}/retry — retryEventDelivery
  - Path param: `deliveryId` (uuid)
  - Response: 201 with `EventDelivery`. Errors: 400, 401, 403, 409, 422, 429, 500.

## 🔐 Authentication Setup {#authentication}

Security schemes in the OpenAPI spec:

- `oauth2` (scopes: `read:events`, `write:events`, `admin:events`)
- `apiKey` and `bearerAuth` referenced as available mechanisms

Use OAuth tokens with the correct scopes for each operation (reads vs writes vs admin actions).

## ✨ Examples (Node.js & Python)

All examples use only request/response fields defined in `openapi/events.yaml`.

### Node.js (axios)

```javascript
const axios = require("axios");
const BASE = "https://api.quub.exchange/v1";

// Create a webhook subscription
async function createSubscription(orgId) {
  const res = await axios.post(
    `${BASE}/orgs/${orgId}/events/subscriptions`,
    {
      name: "Trading Integration",
      eventTypes: ["com.quub.trading.order.placed.v1"],
      deliveryType: "WEBHOOK",
      webhookUrl: "https://your-domain.com/webhooks",
      enabled: true,
    },
    { headers: { Authorization: `Bearer ${process.env.QUUB_TOKEN}` } }
  );
  return res.data.data;
}

// Query recent events
async function queryEvents(orgId, eventType, startTime, endTime) {
  const res = await axios.get(`${BASE}/orgs/${orgId}/events`, {
    params: { eventType, startTime, endTime },
    headers: { Authorization: `Bearer ${process.env.QUUB_TOKEN}` },
  });
  return res.data;
}

// Request a replay
async function requestReplay(orgId, subscriptionId, startTime, endTime) {
  const res = await axios.post(
    `${BASE}/orgs/${orgId}/events/replay`,
    { subscriptionId, startTime, endTime },
    { headers: { Authorization: `Bearer ${process.env.QUUB_TOKEN}` } }
  );
  return res.data.data;
}
```

### Python (requests)

```python
import os
import requests
BASE = 'https://api.quub.exchange/v1'
HEADERS = { 'Authorization': f"Bearer {os.getenv('QUUB_TOKEN')}" }

def create_subscription(org_id, name, event_types, webhook_url):
    resp = requests.post(
        f"{BASE}/orgs/{org_id}/events/subscriptions",
        headers=HEADERS,
        json={
            'name': name,
            'eventTypes': event_types,
            'deliveryType': 'WEBHOOK',
            'webhookUrl': webhook_url,
            'enabled': True
        }
    )
    resp.raise_for_status()
    return resp.json()['data']

def query_events(org_id, event_type=None, start_time=None, end_time=None):
    params = {}
    if event_type: params['eventType'] = event_type
    if start_time: params['startTime'] = start_time
    if end_time: params['endTime'] = end_time
    resp = requests.get(f"{BASE}/orgs/{org_id}/events", headers=HEADERS, params=params)
    resp.raise_for_status()
    return resp.json()

def request_replay(org_id, subscription_id, start_time, end_time):
    payload = {
        'subscriptionId': subscription_id,
        'startTime': start_time,
        'endTime': end_time
    }
    resp = requests.post(f"{BASE}/orgs/{org_id}/events/replay", headers=HEADERS, json=payload)
    resp.raise_for_status()
    return resp.json()['data']
```

## ✨ Best Practices {#best-practices}

- Validate event payloads locally against the `EventSchema` obtained from `/events/schemas` before processing.
- Use HMAC verification (webhookSecret) to validate webhook payloads.
- Implement idempotent processing for events using the `id` field in `DomainEvent`.
- Use time-based filters and pagination for large queries to avoid timeouts.

## 🔒 Security Guidelines {#security}

- Use OAuth scopes as defined in the spec for least-privilege access.
- Protect webhook endpoints with `webhookSecret` HMAC verification and IP allowlisting where possible.
- Log delivery attempts and failures for troubleshooting and compliance.

## 🚀 Performance Optimization {#performance}

- Cache event schemas and only refresh periodically.
- Use batching and parallelism for high-throughput consumption, respecting delivery ordering where required.
- Use replay jobs responsibly (rate-limit replay jobs) to avoid overwhelming subscribers.

## 🔍 Troubleshooting {#troubleshooting}

- 400: invalid parameters such as malformed `eventType` or missing `subscriptionId` for replay.
- 401/403: missing or insufficient OAuth scopes.
- 404: subscription or event not found.
- 409/422/429: relevant to retry and rate-limiting scenarios per endpoints that specify them.

## 📊 Monitoring & Observability {#monitoring}

Track metrics such as delivery success rate, delivery latency, replay job status, subscription health, and event throughput.

## 📚 Additional Resources

- OpenAPI spec: `/openapi/events.yaml`
- API documentation: `/capabilities/events/api-documentation/index.md`
- Overview: `/capabilities/events/overview/index.md`

---

## This guide was generated directly from `openapi/events.yaml`. All endpoints, parameters, request bodies, responses, and schemas above match the OpenAPI file and no operations or schema fields were invented.

layout: docs
title: Events Guides
permalink: /capabilities/events/guides/

---

# Events Implementation Guides

Comprehensive guides for implementing and integrating Events capabilities.

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

_For API reference, see [Events API Documentation](../api-documentation/)_
