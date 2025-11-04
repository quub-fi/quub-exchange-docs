---
layout: docs
title: Event-Driven Integration
permalink: /guides/event-driven/
description: Build reactive applications using webhooks and event streams
---

# Event-Driven Integration

Build reactive applications using Quub Exchange webhooks and event streams.

## Webhook Setup

### Register Webhooks

```javascript
// Register webhook endpoints
await client.events.createWebhook({
  url: "https://example.com/webhooks/quub",
  events: [
    "order.created",
    "order.filled",
    "order.cancelled",
    "trade.executed",
    "balance.updated",
  ],
  secret: "your-webhook-secret",
});
```

### Webhook Handler

```javascript
// webhooks/handler.js
import crypto from "crypto";
import express from "express";

const app = express();

app.post("/webhooks/quub", express.json(), (req, res) => {
  // Verify signature
  const signature = req.headers["x-quub-signature"];
  const payload = JSON.stringify(req.body);

  const expectedSignature = crypto
    .createHmac("sha256", process.env.WEBHOOK_SECRET)
    .update(payload)
    .digest("hex");

  if (signature !== expectedSignature) {
    return res.status(401).send("Invalid signature");
  }

  // Handle event
  const event = req.body;

  switch (event.type) {
    case "order.filled":
      handleOrderFilled(event.data);
      break;
    case "trade.executed":
      handleTradeExecuted(event.data);
      break;
    case "balance.updated":
      handleBalanceUpdated(event.data);
      break;
  }

  res.status(200).send("OK");
});
```

## Event Streaming

### Subscribe to Event Streams

```javascript
// Event stream consumer
const ws = await client.events.connectEventStream();

ws.subscribe("orders.*", (event) => {
  console.log("Order event:", event);
});

ws.subscribe("trades.*", (event) => {
  console.log("Trade event:", event);
});
```

---

**Next Steps:**

- [Microservices Architecture](../microservices-architecture/)
- [Testing Strategy](../testing-strategy/)
- [WebSocket Guide]({{ '/docs/websockets/' | relative_url }})
