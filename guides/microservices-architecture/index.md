---
layout: docs
title: Microservices Architecture
permalink: /guides/microservices-architecture/
description: Design patterns for building scalable applications with Quub Exchange APIs
---

# Microservices Architecture

Design patterns for building scalable, maintainable applications with Quub Exchange APIs.

## Architecture Overview

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Trading   │  │   Custody   │  │  Compliance │
│  Service    │  │  Service    │  │   Service   │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                 │
       └────────────────┼─────────────────┘
                        │
                 ┌──────▼────────┐
                 │  API Gateway  │
                 └───────────────┘
                        │
                 ┌──────▼────────┐
                 │ Quub Exchange │
                 └───────────────┘
```

## Service Patterns

### API Gateway Pattern

```javascript
// gateway/index.js
import express from "express";
import { createProxyMiddleware } from "http-proxy-middleware";

const app = express();

// Route to trading service
app.use(
  "/api/trading",
  createProxyMiddleware({
    target: "http://trading-service:3001",
    changeOrigin: true,
  })
);

// Route to custody service
app.use(
  "/api/custody",
  createProxyMiddleware({
    target: "http://custody-service:3002",
    changeOrigin: true,
  })
);

app.listen(3000);
```

### Service Mesh

```javascript
// services/trading-service.js
export class TradingService {
  constructor() {
    this.quubClient = new QuubClient({...});
  }

  async placeOrder(orderParams) {
    // Validate
    await this.validate(orderParams);

    // Place order via Quub
    const order = await this.quubClient.exchange.createOrder(orderParams);

    // Publish event
    await this.eventBus.publish('order.created', order);

    return order;
  }
}
```

## Event-Driven Communication

```javascript
// Event bus with RabbitMQ
import amqp from "amqplib";

export class EventBus {
  async publish(event, data) {
    const connection = await amqp.connect(process.env.RABBITMQ_URL);
    const channel = await connection.createChannel();

    await channel.assertExchange("quub-events", "topic", { durable: true });
    channel.publish("quub-events", event, Buffer.from(JSON.stringify(data)));
  }

  async subscribe(event, handler) {
    const connection = await amqp.connect(process.env.RABBITMQ_URL);
    const channel = await connection.createChannel();

    await channel.assertExchange("quub-events", "topic", { durable: true });
    const q = await channel.assertQueue("", { exclusive: true });

    await channel.bindQueue(q.queue, "quub-events", event);
    channel.consume(q.queue, (msg) => {
      handler(JSON.parse(msg.content.toString()));
    });
  }
}
```

---

**Next Steps:**

- [Event-Driven Integration](../event-driven/)
- [Production Deployment](../production-deployment/)
- [Best Practices]({{ '/guides/getting-started/best-practices/' | relative_url }})
