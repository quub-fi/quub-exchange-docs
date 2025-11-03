---
layout: docs
permalink: /capabilities/exchange/exchange-api-documentation/
title: exchange API Documentation
service: exchange
---

{% include api-nav-banner.html %}

# Exchange API Documentation

_Based on OpenAPI specification: exchange.yaml_

## Executive Summary

**Audience:** Stakeholders

The Exchange API serves as the core trading engine for Quub Exchange, providing high-performance order matching, market management, and trade execution capabilities. It supports multi-tenant orchestration across multiple blockchain networks while maintaining regulatory compliance through integrated circuit breakers and market halts.

**Key Business Value:**

- **High-Performance Trading:** Sub-millisecond order matching with 99.99% uptime SLA
- **Multi-Asset Support:** Native support for spot markets, tokenized RWAs, and derivatives
- **Regulatory Compliance:** Built-in ATS/MTF frameworks with automated market surveillance
- **Liquidity Management:** Integrated market maker tools and continuous liquidity provision
- **Risk Management:** Real-time position monitoring and automated circuit breakers

**Strategic Importance:**

- Core revenue driver through trading fees and market data services
- Competitive advantage through superior execution quality and low latency
- Regulatory compliance foundation for global expansion
- Platform for innovative financial products and DeFi integration

## Service Overview

**Audience:** All

**Business Purpose:**

- Provide institutional-grade trading infrastructure for digital assets
- Enable fair and orderly markets through automated surveillance and circuit breakers
- Support multi-asset trading with seamless blockchain integration
- Deliver real-time market data and execution services to professional traders
- Maintain regulatory compliance through comprehensive audit trails and reporting

**Technical Architecture:**

- **Matching Engine:** High-performance order book with price-time priority matching
- **Multi-Tenant Design:** Isolated execution environments per organization
- **Blockchain Agnostic:** Support for multiple chains with atomic settlement
- **Real-Time Processing:** WebSocket streams for live market data and order updates
- **Scalable Infrastructure:** Horizontal scaling with automatic failover and load balancing
- **Security Framework:** Multi-layer authentication with API key and OAuth2 support
- **Monitoring Stack:** Comprehensive observability with distributed tracing and metrics

## API Specifications

**Audience:** Technical

**Base Configuration:**

```yaml
openapi: 3.1.0
info:
  title: Quub Exchange - ATS / Matching Engine Service
  version: 2.0.0
servers:
  - url: https://api.quub.exchange/v2
  - url: https://api.sandbox.quub.exchange/v2
```

**Authentication & Authorization:**

- **OAuth2 Scopes:** `read:exchange`, `write:exchange` for granular permissions
- **API Key Authentication:** HMAC-SHA256 signed requests for programmatic access
- **Multi-Tenant Isolation:** Organization-scoped resources with RBAC controls
- **Rate Limiting:** Tiered limits based on subscription level (100-10000 requests/minute)

## Core Endpoints

**Audience:** Technical + Project Teams

### Markets Management

**GET /orgs/{orgId}/markets**
_Business Use Case:_ Retrieve active markets for trading and market analysis
_Request Example:_

```json
GET /orgs/123e4567-e89b-12d3-a456-426614174000/markets?status=OPEN&limit=50
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

_Response Example:_

```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "orgId": "123e4567-e89b-12d3-a456-426614174000",
      "instrumentId": "789e0123-e45c-67d8-b901-234567890123",
      "quoteCcy": "USD",
      "chainId": 1,
      "priceBandPct": 0.1,
      "lotSize": 100,
      "marketType": "SPOT",
      "status": "OPEN",
      "createdAt": "2025-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "cursor": "eyJwYWdlIjoxfQ==",
    "hasMore": false
  }
}
```

_Implementation Notes:_

- Use cursor-based pagination for large market lists
- Cache market metadata for 5-minute intervals
- Filter by status to optimize query performance
- Include chainId for multi-chain routing logic

**POST /orgs/{orgId}/markets**
_Business Use Case:_ Create new trading markets for instruments
_Request Example:_

```json
POST /orgs/123e4567-e89b-12d3-a456-426614174000/markets
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "instrumentId": "789e0123-e45c-67d8-b901-234567890123",
  "quoteCcy": "USD",
  "chainId": 1,
  "priceBandPct": 0.10,
  "lotSize": 100,
  "marketType": "SPOT"
}
```

_Response Example:_

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "orgId": "123e4567-e89b-12d3-a456-426614174000",
    "instrumentId": "789e0123-e45c-67d8-b901-234567890123",
    "quoteCcy": "USD",
    "chainId": 1,
    "priceBandPct": 0.1,
    "lotSize": 100,
    "marketType": "SPOT",
    "status": "OPEN",
    "createdAt": "2025-01-15T10:30:00Z"
  }
}
```

_Implementation Notes:_

- Validate instrument exists before market creation
- Set appropriate price bands based on asset volatility
- Initialize order book and market data feeds
- Notify market participants via WebSocket streams

### Order Management

**POST /orgs/{orgId}/orders**
_Business Use Case:_ Submit orders for immediate execution or order book placement
_Request Example:_

```json
POST /orgs/123e4567-e89b-12d3-a456-426614174000/orders
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440001

{
  "accountId": "234e5678-e90c-23e4-b567-426614174001",
  "instrumentId": "789e0123-e45c-67d8-b901-234567890123",
  "side": "BUY",
  "type": "LIMIT",
  "qty": 1000,
  "px": 45000.00,
  "tif": "GTC"
}
```

_Response Example:_

```json
{
  "data": {
    "id": "345e6789-e01d-34f5-c678-426614174002",
    "orgId": "123e4567-e89b-12d3-a456-426614174000",
    "accountId": "234e5678-e90c-23e4-b567-426614174001",
    "instrumentId": "789e0123-e45c-67d8-b901-234567890123",
    "side": "BUY",
    "type": "LIMIT",
    "qty": 1000,
    "px": 45000.0,
    "tif": "GTC",
    "status": "OPEN",
    "filledQty": 0,
    "createdAt": "2025-01-15T10:30:15Z"
  }
}
```

_Implementation Notes:_

- Use idempotency keys to prevent duplicate orders
- Validate account balances and position limits pre-submission
- Support multiple order types for different trading strategies
- Implement immediate execution for market orders

**DELETE /orgs/{orgId}/orders/{orderId}**
_Business Use Case:_ Cancel open orders to prevent unwanted execution
_Request Example:_

```json
DELETE /orgs/123e4567-e89b-12d3-a456-426614174000/orders/345e6789-e01d-34f5-c678-426614174002
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

_Response Example:_

```json
{
  "data": {
    "id": "345e6789-e01d-34f5-c678-426614174002",
    "status": "CANCELLED",
    "cancelledAt": "2025-01-15T10:31:00Z"
  }
}
```

_Implementation Notes:_

- Only cancel orders in OPEN or PARTIAL status
- Maintain audit trail of cancellation reasons
- Return remaining quantity to account balance
- Notify order owner via WebSocket update

### Trade Execution

**GET /orgs/{orgId}/trades**
_Business Use Case:_ Retrieve trade history for settlement and reconciliation
_Request Example:_

```json
GET /orgs/123e4567-e89b-12d3-a456-426614174000/trades?marketId=550e8400-e29b-41d4-a716-446655440000&limit=100
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

_Response Example:_

```json
{
  "data": [
    {
      "id": "456e7890-e12e-45g6-d789-426614174003",
      "marketId": "550e8400-e29b-41d4-a716-446655440000",
      "buyOrderId": "345e6789-e01d-34f5-c678-426614174002",
      "sellOrderId": "567e8901-e23f-56h7-e890-426614174004",
      "qty": 500,
      "px": 45000.0,
      "executedAt": "2025-01-15T10:30:30Z"
    }
  ],
  "pagination": {
    "cursor": "eyJwYWdlIjoxfQ==",
    "hasMore": true
  }
}
```

_Implementation Notes:_

- Filter by time range for performance optimization
- Include both sides of trade for complete audit trail
- Support real-time trade feeds via WebSocket
- Archive historical trades for regulatory reporting

### Position Management

**GET /orgs/{orgId}/positions**
_Business Use Case:_ Monitor account positions and P/L for risk management
_Request Example:_

```json
GET /orgs/123e4567-e89b-12d3-a456-426614174000/positions?accountId=234e5678-e90c-23e4-b567-426614174001
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

_Response Example:_

```json
{
  "data": [
    {
      "accountId": "234e5678-e90c-23e4-b567-426614174001",
      "instrumentId": "789e0123-e45c-67d8-b901-234567890123",
      "qty": 1500,
      "avgPx": 44750.0,
      "realizedPnL": 1250.0,
      "unrealizedPnL": -500.0
    }
  ]
}
```

_Implementation Notes:_

- Calculate P/L in real-time using mark-to-market pricing
- Aggregate positions across multiple markets
- Support margin calculations for leveraged positions
- Update positions on each trade execution

## Security Implementation

**Audience:** Technical + Project Teams

**Multi-tenant Isolation:**

```json
{
  "orgId": "123e4567-e89b-12d3-a456-426614174000",
  "permissions": {
    "markets": ["read", "write"],
    "orders": ["read", "write"],
    "trades": ["read"],
    "positions": ["read"]
  },
  "rateLimits": {
    "requestsPerMinute": 1000,
    "burstLimit": 100
  }
}
```

**Data Protection Measures:**

- End-to-end encryption for order data in transit and at rest
- Tokenization of sensitive financial information
- Audit logging of all API interactions with tamper-proof records
- Regular security assessments and penetration testing

**Access Controls:**

- Role-based permissions with granular resource-level access
- Time-based access restrictions for sensitive operations
- Geographic restrictions based on regulatory requirements
- API key rotation with automated expiry and renewal

## Business Workflows

**Audience:** Stakeholders + Project Teams

### Primary Workflow: Order Lifecycle Management

**Business Value:** Ensures reliable trade execution with full audit trail and risk controls
**Success Metrics:** 99.99% order execution success rate, <100ms average execution latency

```mermaid
graph TD
    A[Order Submission] --> B[Validation & Risk Check]
    B --> C{Order Type}
    C --> D[LIMIT: Add to Order Book]
    C --> E[MARKET: Immediate Execution]
    D --> F[Price Match Check]
    F --> G[Trade Execution]
    E --> G
    G --> H[Position Update]
    H --> I[Settlement Queue]
    I --> J[Blockchain Confirmation]
    J --> K[Final Settlement]
```

### Secondary Workflow: Market Surveillance & Circuit Breakers

**Business Value:** Maintains market integrity and prevents extreme volatility events
**Success Metrics:** Zero regulatory violations, <0.1% trading halts due to system issues

```mermaid
graph TD
    A[Real-time Monitoring] --> B[Price Movement Analysis]
    B --> C{Threshold Check}
    C --> D[Normal: Continue Trading]
    C --> E[Warning: Increased Monitoring]
    C --> F[Critical: Circuit Breaker]
    F --> G[Market Halt Triggered]
    G --> H[Manual Review Required]
    H --> I[Resume Trading / Close Market]
```

## Integration Guide

**Audience:** Project Teams

**Development Setup:**

```bash
# Install dependencies
npm install axios crypto ws

# Set environment variables
export QUUB_API_KEY="your-api-key"
export QUUB_API_SECRET="your-api-secret"
export QUUB_BASE_URL="https://api.sandbox.quub.exchange/v2"
```

**JavaScript/Node.js Example:**

```javascript
const axios = require("axios");
const crypto = require("crypto");

class QuubExchangeClient {
  constructor(apiKey, apiSecret, baseUrl) {
    this.apiKey = apiKey;
    this.apiSecret = apiSecret;
    this.baseUrl = baseUrl;
  }

  async createOrder(orgId, orderData) {
    const timestamp = Date.now();
    const method = "POST";
    const path = `/orgs/${orgId}/orders`;
    const body = JSON.stringify(orderData);

    const signature = this.generateSignature(method, path, timestamp, body);

    const response = await axios.post(`${this.baseUrl}${path}`, orderData, {
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        "X-Timestamp": timestamp,
        "X-Signature": signature,
        "Content-Type": "application/json",
        "Idempotency-Key": crypto.randomUUID(),
      },
    });

    return response.data;
  }

  generateSignature(method, path, timestamp, body) {
    const message = `${method}${path}${timestamp}${body}`;
    return crypto
      .createHmac("sha256", this.apiSecret)
      .update(message)
      .digest("hex");
  }

  async getMarkets(orgId) {
    const response = await axios.get(`${this.baseUrl}/orgs/${orgId}/markets`, {
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
      },
    });
    return response.data;
  }
}

// Usage example
const client = new QuubExchangeClient(
  process.env.QUUB_API_KEY,
  process.env.QUUB_API_SECRET,
  process.env.QUUB_BASE_URL
);

// Create a limit order
const order = await client.createOrder("123e4567-e89b-12d3-a456-426614174000", {
  accountId: "234e5678-e90c-23e4-b567-426614174001",
  instrumentId: "789e0123-e45c-67d8-b901-234567890123",
  side: "BUY",
  type: "LIMIT",
  qty: 1000,
  px: 45000.0,
  tif: "GTC",
});

console.log("Order created:", order);
```

**Python Example:**

```python
import requests
import hmac
import hashlib
import json
import time
import uuid
from typing import Dict, Any

class QuubExchangeClient:
    def __init__(self, api_key: str, api_secret: str, base_url: str):
        self.api_key = api_key
        self.api_secret = api_secret
        self.base_url = base_url

    def _generate_signature(self, method: str, path: str, timestamp: int, body: str = "") -> str:
        message = f"{method}{path}{timestamp}{body}"
        return hmac.new(
            self.api_secret.encode(),
            message.encode(),
            hashlib.sha256
        ).hexdigest()

    def create_order(self, org_id: str, order_data: Dict[str, Any]) -> Dict[str, Any]:
        timestamp = int(time.time() * 1000)
        method = "POST"
        path = f"/orgs/{org_id}/orders"
        body = json.dumps(order_data)

        signature = self._generate_signature(method, path, timestamp, body)

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "X-Timestamp": str(timestamp),
            "X-Signature": signature,
            "Content-Type": "application/json",
            "Idempotency-Key": str(uuid.uuid4())
        }

        response = requests.post(
            f"{self.base_url}{path}",
            json=order_data,
            headers=headers
        )
        response.raise_for_status()
        return response.json()

    def get_markets(self, org_id: str) -> Dict[str, Any]:
        headers = {"Authorization": f"Bearer {self.api_key}"}
        response = requests.get(
            f"{self.base_url}/orgs/{org_id}/markets",
            headers=headers
        )
        response.raise_for_status()
        return response.json()

# Usage example
client = QuubExchangeClient(
    api_key="your-api-key",
    api_secret="your-api-secret",
    base_url="https://api.sandbox.quub.exchange/v2"
)

# Create a limit order
order = client.create_order("123e4567-e89b-12d3-a456-426614174000", {
    "accountId": "234e5678-e90c-23e4-b567-426614174001",
    "instrumentId": "789e0123-e45c-67d8-b901-234567890123",
    "side": "BUY",
    "type": "LIMIT",
    "qty": 1000,
    "px": 45000.00,
    "tif": "GTC"
})

print("Order created:", order)
```

**Testing Strategy:**

- Unit tests for order validation and matching logic
- Integration tests with testnet blockchain for settlement verification
- Load testing with 10,000+ concurrent orders per second
- Chaos engineering for high availability validation

## Error Handling

**Audience:** Technical + Project Teams

**Standard Error Response:**

```json
{
  "error": {
    "code": "INSUFFICIENT_BALANCE",
    "message": "Account balance insufficient for order quantity",
    "details": {
      "required": 4500000.0,
      "available": 2500000.0,
      "currency": "USD"
    },
    "timestamp": "2025-01-15T10:30:45Z",
    "requestId": "req_1234567890"
  }
}
```

**Error Codes Reference:**

| Code                   | HTTP Status | Description                    | Resolution                        |
| ---------------------- | ----------- | ------------------------------ | --------------------------------- |
| `INSUFFICIENT_BALANCE` | 400         | Account lacks funds for order  | Add funds or reduce order size    |
| `INVALID_ORDER_PARAMS` | 400         | Order parameters are invalid   | Check required fields and formats |
| `MARKET_HALTED`        | 409         | Market is currently halted     | Wait for market resumption        |
| `ORDER_NOT_FOUND`      | 404         | Specified order does not exist | Verify order ID and permissions   |
| `RATE_LIMIT_EXCEEDED`  | 429         | API rate limit exceeded        | Implement exponential backoff     |
| `MARKET_CLOSED`        | 409         | Market is closed for trading   | Check market hours and status     |

**Error Handling Best Practices:**

```javascript
async function submitOrder(orderData) {
  try {
    const response = await client.createOrder(orgId, orderData);
    return response.data;
  } catch (error) {
    switch (error.response?.status) {
      case 400:
        // Validation error - check order parameters
        console.error("Invalid order:", error.response.data.error);
        throw new ValidationError(error.response.data.error.message);
      case 409:
        // Market or order state conflict
        if (error.response.data.error.code === "MARKET_HALTED") {
          await waitForMarketResume();
          return submitOrder(orderData); // Retry
        }
        throw new MarketError(error.response.data.error.message);
      case 429:
        // Rate limited - exponential backoff
        const delay = Math.pow(2, retryCount) * 1000;
        await new Promise((resolve) => setTimeout(resolve, delay));
        return submitOrder(orderData);
      default:
        throw new ExchangeError("Unexpected error occurred");
    }
  }
}
```

## Implementation Checklist

**Audience:** Project Teams

### Pre-Development

- [ ] Review OpenAPI specification for complete endpoint coverage
- [ ] Set up sandbox environment access and API credentials
- [ ] Implement HMAC-SHA256 signature generation for authentication
- [ ] Design order state management and lifecycle handling
- [ ] Plan WebSocket integration for real-time market data
- [ ] Define error handling strategies and retry logic

### Development Phase

- [ ] Implement core order submission and cancellation endpoints
- [ ] Add market data retrieval and order book management
- [ ] Integrate position tracking and P/L calculations
- [ ] Implement rate limiting and idempotency handling
- [ ] Add comprehensive input validation and sanitization
- [ ] Develop WebSocket client for real-time updates
- [ ] Create trade history and execution reporting

### Testing Phase

- [ ] Unit tests for all business logic and validation rules
- [ ] Integration tests with sandbox environment
- [ ] Load testing with high-frequency order scenarios
- [ ] Failover and disaster recovery testing
- [ ] Security testing for authentication and authorization
- [ ] Performance testing for latency and throughput requirements
- [ ] Cross-browser compatibility for WebSocket connections

### Production Readiness

- [ ] Implement comprehensive logging and audit trails
- [ ] Set up monitoring and alerting for critical metrics
- [ ] Configure production API credentials and secrets management
- [ ] Deploy to staging environment for final validation
- [ ] Conduct security review and penetration testing
- [ ] Prepare runbooks for operational support
- [ ] Train operations team on monitoring and incident response

## Monitoring & Observability

**Audience:** Technical + Project Teams

**Key Metrics:**

- **Order Execution Latency:** Target <100ms average, <500ms p95
- **Matching Engine Throughput:** Target 10,000+ orders/second
- **API Availability:** Target 99.99% uptime SLA
- **Order Book Depth:** Monitor liquidity across all markets
- **Error Rate:** Target <0.1% of total API requests
- **WebSocket Connections:** Track active real-time data subscribers

**Logging Requirements:**

```json
{
  "timestamp": "2025-01-15T10:30:15.123Z",
  "level": "INFO",
  "service": "exchange-api",
  "requestId": "req_1234567890",
  "orgId": "123e4567-e89b-12d3-a456-426614174000",
  "operation": "createOrder",
  "orderId": "345e6789-e01d-34f5-c678-426614174002",
  "instrumentId": "789e0123-e45c-67d8-b901-234567890123",
  "side": "BUY",
  "quantity": 1000,
  "price": 45000.0,
  "executionTimeMs": 45,
  "status": "EXECUTED"
}
```

**Alerting Configuration:**

```yaml
alerting:
  rules:
    - name: High Latency Alert
      condition: execution_latency > 500ms for 5m
      severity: critical
      channels: [slack, pager-duty]

    - name: Low Availability Alert
      condition: uptime < 99.9% for 15m
      severity: major
      channels: [slack, email]

    - name: Circuit Breaker Triggered
      condition: market_halt_events > 0
      severity: warning
      channels: [slack]

    - name: Queue Backlog Alert
      condition: order_queue_depth > 10000
      severity: major
      channels: [slack, pager-duty]
```

## API Versioning & Evolution

**Audience:** All

**Current Version (v2.0.0):**

- Complete rewrite with improved performance and scalability
- Enhanced security with OAuth2 and API key authentication
- Multi-tenant architecture with organization isolation
- Real-time WebSocket streams for market data
- Advanced order types and time-in-force options

**Planned Enhancements (v2.1):**

- Algorithmic order types (TWAP, VWAP, Iceberg)
- Advanced risk management features
- Portfolio margin and cross-margin support
- Enhanced market data APIs with historical data
- Improved API rate limiting with burst allowances

**Breaking Changes (v3.0 - Future):**

- Migration to GraphQL API for complex queries
- Removal of deprecated order types and parameters
- Changes to authentication flow requiring token refresh
- Updated settlement processes with instant finality
- New fee structure and billing integration

## Additional Resources

**Audience:** All

**For Stakeholders:**

- [Trading Platform Overview](https://docs.quub.exchange/trading-platform)
- [Market Structure and Regulation](https://docs.quub.exchange/market-structure)
- [Performance Benchmarks](https://docs.quub.exchange/benchmarks)
- [Security and Compliance](https://docs.quub.exchange/security)

**For Technical Teams:**

- [API Reference Documentation](https://developers.quub.exchange/api-reference)
- [WebSocket Protocol Specification](https://developers.quub.exchange/websocket-protocol)
- [Order Matching Engine Architecture](https://developers.quub.exchange/matching-engine)
- [Blockchain Integration Guide](https://developers.quub.exchange/blockchain-integration)
- [Rate Limiting and Best Practices](https://developers.quub.exchange/rate-limiting)

**For Project Teams:**

- [Sandbox Environment Setup](https://developers.quub.exchange/sandbox-setup)
- [SDK Libraries and Tools](https://developers.quub.exchange/sdks)
- [Integration Testing Guide](https://developers.quub.exchange/integration-testing)
- [Deployment and Operations](https://developers.quub.exchange/operations)
- [Troubleshooting Common Issues](https://developers.quub.exchange/troubleshooting)</content>
  <parameter name="filePath">/Users/nrahal/@code_2025/products/quub/quub-exchange-docs/capabilities/exchange/exchange-api-documentation.md
