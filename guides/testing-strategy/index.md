---
layout: docs
title: Testing Your Integration
permalink: /guides/testing-strategy/
description: Comprehensive testing strategies including unit, integration, and E2E tests
---

# Testing Your Integration

Comprehensive testing strategies for Quub Exchange integrations.

## Unit Testing

### Mock Quub Client

```javascript
// __mocks__/@quub/sdk.js
export class QuubClient {
  exchange = {
    createOrder: jest.fn(),
    getMarket: jest.fn(),
    getOrders: jest.fn(),
  };

  custodian = {
    getBalance: jest.fn(),
    getBalances: jest.fn(),
  };
}
```

### Test Example

```javascript
// __tests__/order-service.test.js
import { OrderService } from "../services/order-service";
import { QuubClient } from "@quub/sdk";

jest.mock("@quub/sdk");

describe("OrderService", () => {
  let orderService;
  let mockClient;

  beforeEach(() => {
    mockClient = new QuubClient();
    orderService = new OrderService(mockClient);
  });

  test("should place order successfully", async () => {
    mockClient.exchange.createOrder.mockResolvedValue({
      orderId: "order_123",
      status: "open",
    });

    const order = await orderService.placeOrder({
      symbol: "BTC-USD",
      side: "buy",
      type: "limit",
      quantity: "0.01",
      price: "45000",
    });

    expect(order.orderId).toBe("order_123");
    expect(mockClient.exchange.createOrder).toHaveBeenCalledTimes(1);
  });
});
```

## Integration Testing

### Sandbox Environment

```javascript
// tests/integration/exchange.test.js
import { QuubClient } from "@quub/sdk";

describe("Exchange Integration", () => {
  let client;

  beforeAll(() => {
    client = new QuubClient({
      apiKey: process.env.SANDBOX_API_KEY,
      apiSecret: process.env.SANDBOX_API_SECRET,
      environment: "sandbox",
    });
  });

  test("should fetch markets", async () => {
    const markets = await client.exchange.getMarkets();
    expect(Array.isArray(markets)).toBe(true);
    expect(markets.length).toBeGreaterThan(0);
  });

  test("should place and cancel order", async () => {
    const order = await client.exchange.createOrder({
      symbol: "BTC-USD",
      side: "buy",
      type: "limit",
      quantity: "0.001",
      price: "1000",
      timeInForce: "GTC",
    });

    expect(order.orderId).toBeDefined();

    const cancelled = await client.exchange.cancelOrder(order.orderId);
    expect(cancelled.status).toBe("cancelled");
  });
});
```

## E2E Testing

### Full Flow Test

```javascript
// tests/e2e/trading-flow.test.js
describe('Complete Trading Flow', () => {
  test('should complete full trading cycle', async () => {
    // 1. Check balance
    const balance = await client.custodian.getBalance('USD');
    expect(parseFloat(balance.available)).toBeGreaterThan(100);

    // 2. Place order
    const order = await client.exchange.createOrder({...});
    expect(order.status).toBe('open');

    // 3. Monitor until filled
    await waitForOrderFill(order.orderId);

    // 4. Verify position
    const position = await client.exchange.getPosition('BTC-USD');
    expect(parseFloat(position.quantity)).toBeGreaterThan(0);

    // 5. Close position
    const closeOrder = await client.exchange.createOrder({
      symbol: 'BTC-USD',
      side: 'sell',
      type: 'market',
      quantity: position.quantity
    });

    expect(closeOrder.status).toBe('filled');
  });
});
```

---

**Next Steps:**

- [Production Deployment](../production-deployment/)
- [Monitoring Guide]({{ '/guides/getting-started/deployment-guide/' | relative_url }})
- [Best Practices]({{ '/guides/getting-started/best-practices/' | relative_url }})
