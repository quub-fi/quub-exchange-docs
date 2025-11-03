---
layout: docs
title: marketplace API Documentation
service: marketplace
permalink: /use-cases/marketplace/marketplace-api-documentation
---

{% include api-nav-banner.html %}

# Marketplace API Documentation

_Based on OpenAPI specification: marketplace.yaml_

## Executive Summary

**Audience:** Stakeholders

The Marketplace API enables alternative trading mechanisms for private securities, providing institutional-grade liquidity solutions beyond traditional exchange trading. This service supports sophisticated trading models including Request for Quote (RFQ), Over-the-Counter (OTC) negotiations, various auction formats, and anonymous dark pool trading.

**Key Business Value:**

- **Liquidity Access**: Connects institutional investors with alternative trading venues for large block trades and illiquid securities
- **Price Discovery**: Enables negotiated pricing and auction mechanisms for fair value determination
- **Regulatory Compliance**: Supports pre-IPO secondary trading and private market transactions
- **Risk Management**: Provides controlled trading environments with appropriate counterparty verification

**Strategic Importance:**

- Enables trading of securities not suitable for public exchanges
- Supports institutional investment strategies requiring discretion
- Facilitates price discovery in private markets
- Provides regulatory-compliant trading infrastructure

## Service Overview

**Audience:** All

**Business Purpose:**

- Enable alternative trading mechanisms for private securities and large block trades
- Provide institutional-grade liquidity solutions beyond traditional exchange trading
- Support sophisticated trading models (RFQ, OTC, auctions, dark pools)
- Facilitate price discovery and negotiated pricing for illiquid assets
- Ensure regulatory compliance for private market transactions

**Technical Architecture:**

- Multi-tenant architecture supporting isolated trading environments
- Real-time matching engine for RFQ and auction mechanisms
- Anonymous trading capabilities for dark pool functionality
- Integration with compliance and risk management systems
- High-throughput messaging for real-time price updates
- Secure API gateway with rate limiting and authentication

## API Specifications

**Audience:** Technical

**Base Configuration:**

```yaml
openapi: 3.1.0
info:
  title: Quub Exchange - Marketplace API
  version: 2.0.0
servers:
  - url: https://api.quub.exchange/v1
```

**Authentication & Authorization:**

- OAuth 2.0 with scopes: `read:marketplace`, `write:marketplace`
- API key authentication for programmatic access
- Multi-tenant isolation with organization-based access control
- Role-based permissions for different trading operations

## Core Endpoints

**Audience:** Technical + Project Teams

### RFQ (Request for Quote) Endpoints

**GET /orgs/{orgId}/marketplace/rfqs**

- **Business Use Case**: Retrieve list of active RFQs for price discovery and trading opportunities
- **Request Example**:

```json
GET /orgs/123e4567-e89b-12d3-a456-426614174000/marketplace/rfqs?status=OPEN&limit=50
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

- **Response Example**:

```json
{
  "data": [
    {
      "id": "rfq-123",
      "assetId": "asset-456",
      "quantity": "1000000",
      "side": "BUY",
      "minPrice": "25.00",
      "maxPrice": "30.00",
      "expiresAt": "2025-11-02T16:00:00Z",
      "status": "OPEN"
    }
  ],
  "pagination": {
    "cursor": "eyJwYWdlIjoxfQ==",
    "hasMore": true
  }
}
```

- **Implementation Notes**:
  - Use cursor-based pagination for large result sets
  - Filter by status to optimize performance
  - Cache frequently accessed RFQs locally

**POST /orgs/{orgId}/marketplace/rfqs**

- **Business Use Case**: Create new RFQ to request quotes from multiple counterparties
- **Request Example**:

```json
POST /orgs/123e4567-e89b-12d3-a456-426614174000/marketplace/rfqs
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "assetId": "asset-456",
  "quantity": "1000000",
  "side": "BUY",
  "minPrice": "25.00",
  "maxPrice": "30.00",
  "expiresAt": "2025-11-02T16:00:00Z"
}
```

- **Response Example**:

```json
{
  "data": {
    "id": "rfq-123",
    "assetId": "asset-456",
    "quantity": "1000000",
    "side": "BUY",
    "status": "OPEN",
    "createdAt": "2025-11-02T10:30:00Z"
  }
}
```

- **Implementation Notes**:
  - Use idempotency keys for reliable creation
  - Validate asset permissions before creation
  - Monitor expiration times for timely cleanup

### Auction Endpoints

**POST /orgs/{orgId}/marketplace/auctions**

- **Business Use Case**: Initiate auction for price discovery and competitive bidding
- **Request Example**:

```json
POST /orgs/123e4567-e89b-12d3-a456-426614174000/marketplace/auctions
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "assetId": "asset-456",
  "quantity": "500000",
  "auctionType": "ENGLISH",
  "startingPrice": "20.00",
  "reservePrice": "25.00",
  "durationMinutes": 30
}
```

- **Response Example**:

```json
{
  "data": {
    "id": "auction-789",
    "assetId": "asset-456",
    "auctionType": "ENGLISH",
    "status": "ACTIVE",
    "currentPrice": "20.00",
    "endsAt": "2025-11-02T11:00:00Z"
  }
}
```

- **Implementation Notes**:
  - Support multiple auction types (English, Dutch, etc.)
  - Real-time price updates via WebSocket
  - Automatic auction conclusion and settlement

### Dark Pool Endpoints

**POST /orgs/{orgId}/marketplace/dark-pool/orders**

- **Business Use Case**: Submit anonymous orders to dark pool for discreet large trades
- **Request Example**:

```json
POST /orgs/123e4567-e89b-12d3-a456-426614174000/marketplace/dark-pool/orders
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "assetId": "asset-456",
  "quantity": "2000000",
  "side": "SELL",
  "price": "28.50",
  "minimumFill": "500000"
}
```

- **Response Example**:

```json
{
  "data": {
    "id": "dp-order-101",
    "assetId": "asset-456",
    "status": "PENDING",
    "remainingQuantity": "2000000"
  }
}
```

- **Implementation Notes**:
  - Complete anonymity maintained throughout process
  - Minimum fill quantities prevent partial execution
  - Real-time matching without price/time priority

## Security Implementation

**Audience:** Technical + Project Teams

**Multi-tenant Isolation:**

```yaml
# Organization-based access control
securitySchemes:
  oauth2:
    type: oauth2
    flows:
      clientCredentials:
        tokenUrl: /auth/token
        scopes:
          read:marketplace: Read marketplace data
          write:marketplace: Create/modify marketplace orders
```

**Data Protection Measures:**

- End-to-end encryption for sensitive trading data
- Audit logging for all trading activities
- Compliance with SEC Regulation SCI requirements
- Multi-signature validation for large trades

**Access Controls:**

```json
{
  "permissions": {
    "rfq": {
      "create": ["TRADER", "DEALER"],
      "quote": ["MARKET_MAKER", "DEALER"],
      "view": ["TRADER", "COMPLIANCE"]
    },
    "auctions": {
      "create": ["AUCTIONEER"],
      "bid": ["TRADER", "INVESTOR"],
      "view": ["TRADER", "ANALYST"]
    }
  }
}
```

## Business Workflows

**Audience:** Stakeholders + Project Teams

### Primary Workflow - RFQ Trading Process

```mermaid
graph TD
    A[Trader Creates RFQ] --> B[RFQ Published to Market]
    B --> C[Market Makers Receive Notification]
    C --> D[Market Makers Submit Quotes]
    D --> E[Trader Reviews Quotes]
    E --> F{Trader Accepts Quote?}
    F -->|Yes| G[Trade Executed]
    F -->|No| H[RFQ Expires or Cancelled]
    G --> I[Settlement Process]
    I --> J[Trade Completed]
```

**Business Value:**

- Enables negotiated pricing for large block trades
- Provides access to multiple liquidity providers simultaneously
- Reduces market impact through discreet trading
- Supports complex trading strategies

**Success Metrics:**

- RFQ fill rate > 85%
- Average time to quote < 5 minutes
- Trading volume through RFQ > $500M monthly

### Secondary Workflow - Auction Process

```mermaid
graph TD
    A[Seller Initiates Auction] --> B[Auction Announced]
    B --> C[Bidders Register Interest]
    C --> D[Auction Starts]
    D --> E[Bidders Submit Bids]
    E --> F{Auction Type}
    F -->|English| G[Price Increases]
    F -->|Dutch| H[Price Decreases]
    G --> I[Winning Bid Determined]
    H --> I
    I --> J[Auction Concludes]
    J --> K[Winner Notified]
    K --> L[Settlement Process]
```

**Business Value:**

- Provides transparent price discovery mechanism
- Enables competitive bidding for fair valuation
- Supports various auction formats for different use cases
- Attracts diverse pool of potential counterparties

**Success Metrics:**

- Auction participation rate > 70%
- Price improvement vs. reference price > 2%
- Successful completion rate > 95%

## Integration Guide

**Audience:** Project Teams

**Development Setup:**

```bash
# Install dependencies
npm install @quub/exchange-sdk axios ws

# Configure environment
export QUUB_API_KEY=your-api-key
export QUUB_BASE_URL=https://api.quub.exchange/v1
```

**Code Examples:**

**JavaScript/Node.js - Create RFQ:**

```javascript
const { MarketplaceAPI } = require("@quub/exchange-sdk");

const marketplace = new MarketplaceAPI({
  apiKey: process.env.QUUB_API_KEY,
  baseURL: process.env.QUUB_BASE_URL,
});

async function createRFQ() {
  try {
    const rfq = await marketplace.createRFQ({
      orgId: "123e4567-e89b-12d3-a456-426614174000",
      assetId: "asset-456",
      quantity: "1000000",
      side: "BUY",
      minPrice: "25.00",
      maxPrice: "30.00",
      expiresAt: "2025-11-02T16:00:00Z",
    });

    console.log("RFQ created:", rfq.id);
    return rfq;
  } catch (error) {
    console.error("Error creating RFQ:", error);
    throw error;
  }
}
```

**Python - Monitor Auction:**

```python
import asyncio
import websockets
import json
from quub_exchange import MarketplaceAPI

api = MarketplaceAPI(
    api_key=os.getenv('QUUB_API_KEY'),
    base_url=os.getenv('QUUB_BASE_URL')
)

async def monitor_auction(auction_id):
    uri = f"wss://api.quub.exchange/v1/ws/marketplace/auctions/{auction_id}"

    async with websockets.connect(uri) as websocket:
        while True:
            try:
                message = await websocket.recv()
                data = json.loads(message)

                if data['type'] == 'price_update':
                    print(f"New price: ${data['price']} at {data['timestamp']}")
                elif data['type'] == 'auction_ended':
                    print(f"Auction ended. Winner: {data['winnerId']}")
                    break

            except websockets.exceptions.ConnectionClosed:
                print("Connection closed")
                break

# Usage
asyncio.run(monitor_auction('auction-789'))
```

**Testing Strategy:**

- Unit tests for API client methods
- Integration tests with sandbox environment
- Load testing for high-frequency trading scenarios
- End-to-end tests for complete trading workflows

## Error Handling

**Audience:** Technical + Project Teams

**Standard Error Response:**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid RFQ parameters",
    "details": {
      "field": "quantity",
      "issue": "Must be positive number"
    },
    "requestId": "req-12345",
    "timestamp": "2025-11-02T10:30:00Z"
  }
}
```

**Error Codes Reference:**

| Code                       | Description                | HTTP Status | Retryable |
| -------------------------- | -------------------------- | ----------- | --------- |
| `VALIDATION_ERROR`         | Invalid request parameters | 400         | No        |
| `INSUFFICIENT_PERMISSIONS` | Access denied              | 403         | No        |
| `AUCTION_NOT_FOUND`        | Auction doesn't exist      | 404         | No        |
| `AUCTION_EXPIRED`          | Auction has ended          | 410         | No        |
| `RATE_LIMIT_EXCEEDED`      | Too many requests          | 429         | Yes       |
| `SERVICE_UNAVAILABLE`      | Temporary service issue    | 503         | Yes       |

**Error Handling Best Practices:**

```javascript
async function createRFQWithRetry(params, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const rfq = await marketplace.createRFQ(params);
      return rfq;
    } catch (error) {
      if (error.code === "RATE_LIMIT_EXCEEDED" && attempt < maxRetries) {
        // Exponential backoff
        await new Promise((resolve) =>
          setTimeout(resolve, Math.pow(2, attempt) * 1000)
        );
        continue;
      }

      if (error.code === "VALIDATION_ERROR") {
        // Log and rethrow validation errors
        console.error("Validation failed:", error.details);
        throw error;
      }

      // Don't retry other errors
      throw error;
    }
  }
}
```

## Implementation Checklist

**Audience:** Project Teams

**Pre-Development:**

- [ ] Review trading model requirements (RFQ, OTC, auctions, dark pool)
- [ ] Assess integration points with existing trading systems
- [ ] Evaluate real-time connectivity requirements
- [ ] Plan for high-throughput messaging architecture
- [ ] Design multi-tenant isolation strategy
- [ ] Define monitoring and alerting requirements

**Development Phase:**

- [ ] Implement OAuth 2.0 authentication flow
- [ ] Build RFQ creation and management endpoints
- [ ] Develop auction engine with real-time bidding
- [ ] Create dark pool anonymous matching logic
- [ ] Implement WebSocket connections for real-time updates
- [ ] Add comprehensive input validation and sanitization
- [ ] Integrate with compliance and risk management systems

**Testing Phase:**

- [ ] Unit tests for all API endpoints (100% coverage)
- [ ] Integration tests with sandbox environment
- [ ] Load testing for concurrent trading scenarios
- [ ] Security testing for access control and data protection
- [ ] End-to-end testing for complete trading workflows
- [ ] Performance testing for high-frequency operations
- [ ] Failover and disaster recovery testing

**Production Readiness:**

- [ ] Configure production API credentials and endpoints
- [ ] Set up monitoring dashboards and alerting
- [ ] Implement rate limiting and throttling
- [ ] Configure backup and disaster recovery procedures
- [ ] Establish incident response procedures
- [ ] Train operations team on monitoring and troubleshooting
- [ ] Perform final security audit and penetration testing

## Monitoring & Observability

**Audience:** Technical + Project Teams

**Key Metrics:**

- **Trading Volume**: Total value traded through marketplace ($)
- **RFQ Success Rate**: Percentage of RFQs that result in trades (>85%)
- **Auction Participation**: Average number of bidders per auction (>5)
- **API Response Time**: P95 response time for all endpoints (<200ms)
- **WebSocket Connections**: Active real-time connections for price updates
- **Error Rate**: Percentage of failed API requests (<1%)

**Logging Requirements:**

```json
{
  "timestamp": "2025-11-02T10:30:00Z",
  "level": "INFO",
  "service": "marketplace",
  "operation": "rfq_created",
  "orgId": "123e4567-e89b-12d3-a456-426614174000",
  "rfqId": "rfq-123",
  "assetId": "asset-456",
  "quantity": "1000000",
  "side": "BUY",
  "requestId": "req-abc123"
}
```

**Alerting Configuration:**

```yaml
alerts:
  - name: High Error Rate
    condition: error_rate > 0.05
    severity: critical
    channels: [slack, email, pager]

  - name: RFQ Expiration Warning
    condition: rfq_expiring_soon > 10
    severity: warning
    channels: [slack]

  - name: Auction Without Bids
    condition: auction_no_bids > 0
    severity: info
    channels: [slack]
```

## API Versioning & Evolution

**Audience:** All

**Current Version (v1.0):**

- RFQ trading with quote management
- Basic auction functionality (English auctions)
- OTC negotiation support
- Dark pool anonymous trading

**Planned Enhancements (v1.1):**

- Advanced auction types (Dutch, Vickrey-Clarke-Groves)
- Cross-market liquidity aggregation
- AI-powered price prediction
- Enhanced compliance reporting

**Breaking Changes (v2.0 - Future):**

- Unified trading protocol across all mechanisms
- Real-time settlement integration
- Advanced risk management features
- Multi-asset portfolio trading

## Additional Resources

**Audience:** All

**For Stakeholders:**

- [Trading Models Overview](https://docs.quub.exchange/trading-models)
- [Marketplace Business Case](https://docs.quub.exchange/marketplace-business-case)
- [Regulatory Compliance Guide](https://docs.quub.exchange/regulatory-compliance)
- [Success Metrics Dashboard](https://dashboard.quub.exchange/marketplace)

**For Technical Teams:**

- [API Reference Documentation](https://developers.quub.exchange/marketplace)
- [WebSocket Protocol Specification](https://developers.quub.exchange/websockets)
- [Rate Limiting Guide](https://developers.quub.exchange/rate-limiting)
- [SDK Libraries](https://github.com/quub-fi/exchange-sdks)
- [Postman Collection](https://github.com/quub-fi/postman-collections)

**For Project Teams:**

- [Integration Patterns](https://developers.quub.exchange/integration-patterns)
- [Testing Environments](https://developers.quub.exchange/testing)
- [Deployment Playbook](https://ops.quub.exchange/marketplace-deployment)
- [Troubleshooting Guide](https://support.quub.exchange/marketplace-troubleshooting)
- [Security Best Practices](https://security.quub.exchange/marketplace)
