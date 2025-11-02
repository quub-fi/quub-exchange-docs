# Market Oracles API Documentation

_Based on OpenAPI specification: market-oracles.yaml_

## Executive Summary

**Audience:** Stakeholders

The Market Oracles service provides institutional-grade valuation services, oracle attestations, and price transparency for Real World Asset (RWA) markets. It enables asset transparency, audit traceability, and verified data feeds that support regulatory compliance and investor confidence in tokenized assets.

**Key capabilities:**

- Net Asset Value (NAV) calculations and reporting
- Oracle attestations for verified market data
- Real-time price tick feeds for tradable instruments
- Public disclosures and investor transparency reports
- Multi-source data validation and cross-verification

**Strategic importance:**

- Ensures market integrity through verified pricing data
- Supports regulatory compliance with transparent valuation processes
- Enables institutional adoption through audit-ready documentation
- Provides competitive advantage through reliable oracle services

## Service Overview

**Audience:** All

**Business Purpose:**

- Provide verified valuation data for tokenized real-world assets
- Enable transparent pricing through oracle attestations and price feeds
- Support regulatory compliance with comprehensive audit trails
- Facilitate institutional investment through reliable market data
- Ensure market integrity through multi-source data validation

**Technical Architecture:**

- RESTful API with comprehensive OpenAPI specification
- Multi-tenant architecture supporting organization-level data isolation
- Event-driven architecture for real-time price updates
- Cryptographic signing for oracle attestation integrity
- Integration with external data sources and valuation providers
- High-availability deployment with regional redundancy

## API Specifications

**Audience:** Technical

**Base Configuration:**

```yaml
openapi: 3.1.0
info:
  title: Quub Exchange - Market Oracles Service
  version: 2.0.0
servers:
  - url: https://api.quub.exchange/v2
  - url: https://api.sandbox.quub.exchange/v2
```

**Authentication & Authorization:**

- OAuth 2.0 with scopes: `read:market-oracles`, `write:market-oracles`
- API key authentication for programmatic access
- Organization-level access control with role-based permissions
- Multi-tenant data isolation ensuring data privacy

## Core Endpoints

**Audience:** Technical + Project Teams

### Valuations

**GET /orgs/{orgId}/valuations**
_Business Use Case:_ Retrieve historical valuation reports for compliance and audit purposes
_Request Example:_

```javascript
GET /orgs/123e4567-e89b-12d3-a456-426614174000/valuations?projectId=456e7890-e89b-12d3-a456-426614174001
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

_Response Example:_

```json
{
  "data": [
    {
      "id": "789e0123-e89b-12d3-a456-426614174002",
      "projectId": "456e7890-e89b-12d3-a456-426614174001",
      "basis": "MARKET",
      "navTotal": 1000000.0,
      "navPerToken": 100.0,
      "asOfDate": "2025-11-02",
      "status": "PUBLISHED",
      "createdAt": "2025-11-02T10:00:00Z"
    }
  ],
  "pagination": {
    "cursor": "eyJpZCI6Ijc4OWUwMTIzLWU4OWItMTJkMy1hNDU2LTQyNjYxNDE3NDAwMiJ9",
    "hasMore": false
  }
}
```

_Implementation Notes:_

- Supports filtering by project ID and date ranges
- Includes pagination for large result sets
- Data is cached for performance optimization
- Audit trail maintained for all valuation access

**POST /orgs/{orgId}/valuations**
_Business Use Case:_ Submit new valuation reports from authorized valuation providers
_Request Example:_

```json
{
  "projectId": "456e7890-e89b-12d3-a456-426614174001",
  "basis": "MARKET",
  "navTotal": 1000000.0,
  "navPerToken": 100.0,
  "asOfDate": "2025-11-02",
  "attachments": [
    "https://storage.quub.exchange/valuations/nav-report-2025-11-02.pdf"
  ],
  "signerOrgId": "123e4567-e89b-12d3-a456-426614174000"
}
```

_Implementation Notes:_

- Requires cryptographic signing for data integrity
- Supports multiple valuation methodologies
- Automatic validation against historical data
- Triggers notification events for stakeholders

### Oracle Attestations

**GET /orgs/{orgId}/market-oracles/oracle**
_Business Use Case:_ Retrieve verified oracle data for trading and compliance systems
_Request Example:_

```javascript
GET /orgs/123e4567-e89b-12d3-a456-426614174000/market-oracles/oracle?type=NAV
```

_Response Example:_

```json
{
  "data": [
    {
      "id": "321e6547-e89b-12d3-a456-426614174003",
      "type": "NAV",
      "value": 100.0,
      "timestamp": "2025-11-02T10:00:00Z",
      "signature": "0x1a2b3c4d...",
      "oracleId": "oracle-001",
      "confidence": 0.95
    }
  ]
}
```

_Implementation Notes:_

- Cryptographically signed attestations ensure data integrity
- Multiple oracle sources provide redundancy
- Confidence scores indicate data reliability
- Real-time updates via WebSocket connections

**POST /orgs/{orgId}/market-oracles/oracle**
_Business Use Case:_ Submit new oracle attestations from authorized data providers
_Request Example:_

```json
{
  "type": "PRICE",
  "value": 105.5,
  "instrumentId": "789e0123-e89b-12d3-a456-426614174004",
  "timestamp": "2025-11-02T10:00:00Z",
  "metadata": {
    "source": "primary-market",
    "methodology": "VWAP"
  }
}
```

_Implementation Notes:_

- Requires authorized oracle provider credentials
- Automatic cross-validation with multiple data sources
- Consensus mechanisms for conflicting data points
- Audit logging for regulatory compliance

### Price Ticks

**GET /data/price-ticks**
_Business Use Case:_ Access real-time and historical price data for trading applications
_Request Example:_

```javascript
GET /data/price-ticks?instrumentId=789e0123-e89b-12d3-a456-426614174004&since=2025-11-01T00:00:00Z
```

_Response Example:_

```json
{
  "data": [
    {
      "instrumentId": "789e0123-e89b-12d3-a456-426614174004",
      "price": 105.5,
      "volume": 1000,
      "timestamp": "2025-11-02T10:00:00Z",
      "source": "primary-market"
    }
  ]
}
```

_Implementation Notes:_

- High-frequency data with sub-second timestamps
- Supports both polling and streaming access patterns
- Historical data retention for backtesting
- Rate limiting based on subscription tiers

## Security Implementation

**Audience:** Technical + Project Teams

**Multi-tenant Isolation:**

```yaml
# Organization-level data segregation
components:
  securitySchemes:
    oauth2:
      flows:
        clientCredentials:
          scopes:
            read:market-oracles: Read oracle data
            write:market-oracles: Submit oracle data
```

**Data Protection measures:**

- End-to-end encryption for sensitive valuation data
- Cryptographic signing of all oracle attestations
- Audit trails for all data access and modifications
- Regular security assessments and penetration testing

**Access Controls:**

- Role-based permissions for different user types
- API rate limiting to prevent abuse
- Geographic restrictions for data residency compliance
- Multi-factor authentication for administrative access

## Business Workflows

**Audience:** Stakeholders + Project Teams

**Primary Workflow** — NAV Valuation Process

```mermaid
graph TD
    A[Asset Valuation Request] --> B[Data Collection]
    B --> C[Valuation Methodology Selection]
    C --> D[NAV Calculation]
    D --> E[Cross-verification]
    E --> F[Oracle Attestation]
    F --> G[Publication to Market]
    G --> H[Investor Notifications]

    I[Regulatory Reporting] --> J[Audit Trail Generation]
    J --> K[Compliance Verification]
```

_Business Value:_ Ensures transparent, auditable valuation processes that build investor confidence and support regulatory compliance.

_Success Metrics:_

- Valuation accuracy: >99.5%
- Processing time: <24 hours
- Audit compliance rate: 100%

**Secondary Workflow** — Price Oracle Updates

```mermaid
graph TD
    A[Market Data Sources] --> B[Data Ingestion]
    B --> C[Validation & Cleaning]
    C --> D[Consensus Algorithm]
    D --> E[Oracle Attestation]
    E --> F[Distribution to Consumers]
    F --> G[Trading Applications]
    F --> H[Risk Management Systems]
    F --> I[Reporting Systems]
```

_Business Value:_ Provides reliable, real-time price data that enables efficient trading and risk management across the platform.

_Success Metrics:_

- Data freshness: <100ms latency
- Uptime: >99.9%
- Consumer adoption: 95% of trading volume

## Integration Guide

**Audience:** Project Teams

**Development Setup:**

```bash
# Clone repository
git clone https://github.com/quub-fi/quub-exchange-docs.git
cd quub-exchange-docs

# Install dependencies
npm install

# Start local development server
npm run dev
```

**Code Examples:**

_JavaScript/Node.js:_

```javascript
const axios = require("axios");

class MarketOraclesClient {
  constructor(apiKey, baseUrl = "https://api.quub.exchange/v2") {
    this.client = axios.create({
      baseURL: baseUrl,
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
    });
  }

  async getValuations(orgId, projectId) {
    try {
      const response = await this.client.get(`/orgs/${orgId}/valuations`, {
        params: { projectId },
      });
      return response.data;
    } catch (error) {
      console.error("Error fetching valuations:", error.response.data);
      throw error;
    }
  }

  async submitOracleAttestation(orgId, attestation) {
    try {
      const response = await this.client.post(
        `/orgs/${orgId}/market-oracles/oracle`,
        attestation,
        {
          headers: {
            "Idempotency-Key": generateIdempotencyKey(),
          },
        }
      );
      return response.data;
    } catch (error) {
      console.error("Error submitting attestation:", error.response.data);
      throw error;
    }
  }
}

// Usage
const client = new MarketOraclesClient(process.env.QUUB_API_KEY);
const valuations = await client.getValuations(orgId, projectId);
```

_Python:_

```python
import requests
from typing import Dict, List, Optional
import uuid

class MarketOraclesClient:
    def __init__(self, api_key: str, base_url: str = "https://api.quub.exchange/v2"):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json'
        })

    def get_valuations(self, org_id: str, project_id: Optional[str] = None) -> Dict:
        """Retrieve valuation reports for an organization."""
        params = {}
        if project_id:
            params['projectId'] = project_id

        response = self.session.get(f'/orgs/{org_id}/valuations', params=params)
        response.raise_for_status()
        return response.json()

    def submit_oracle_attestation(self, org_id: str, attestation: Dict) -> Dict:
        """Submit a new oracle attestation."""
        headers = {'Idempotency-Key': str(uuid.uuid4())}
        response = self.session.post(
            f'/orgs/{org_id}/market-oracles/oracle',
            json=attestation,
            headers=headers
        )
        response.raise_for_status()
        return response.json()

    def get_price_ticks(self, instrument_id: str, since: Optional[str] = None) -> Dict:
        """Retrieve price ticks for an instrument."""
        params = {'instrumentId': instrument_id}
        if since:
            params['since'] = since

        response = self.session.get('/data/price-ticks', params=params)
        response.raise_for_status()
        return response.json()

# Usage
client = MarketOraclesClient(api_key=os.getenv('QUUB_API_KEY'))
valuations = client.get_valuations(org_id='123e4567-e89b-12d3-a456-426614174000')
```

**Testing Strategy:**

```bash
# Unit tests
npm test

# Integration tests
npm run test:integration

# Load testing
npm run test:load
```

## Error Handling

**Audience:** Technical + Project Teams

**Standard Error Response:**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid valuation data provided",
    "details": {
      "field": "navTotal",
      "issue": "Must be positive number"
    },
    "requestId": "req_1234567890",
    "timestamp": "2025-11-02T10:00:00Z"
  }
}
```

**Error Codes Reference:**

| Code               | Description              | HTTP Status | Resolution                               |
| ------------------ | ------------------------ | ----------- | ---------------------------------------- |
| `VALIDATION_ERROR` | Invalid request data     | 400         | Check request format and required fields |
| `UNAUTHORIZED`     | Authentication failed    | 401         | Verify API credentials                   |
| `FORBIDDEN`        | Insufficient permissions | 403         | Check user roles and scopes              |
| `NOT_FOUND`        | Resource not found       | 404         | Verify resource IDs                      |
| `CONFLICT`         | Resource conflict        | 409         | Check for duplicate submissions          |
| `RATE_LIMITED`     | Too many requests        | 429         | Implement exponential backoff            |
| `INTERNAL_ERROR`   | Server error             | 500         | Retry with exponential backoff           |

**Error Handling Best Practices:**

```javascript
async function handleApiCall(apiCall) {
  const maxRetries = 3;
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      return await apiCall();
    } catch (error) {
      attempt++;

      if (error.response?.status === 429) {
        // Rate limited - exponential backoff
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise((resolve) => setTimeout(resolve, delay));
        continue;
      }

      if (error.response?.status >= 500 && attempt < maxRetries) {
        // Server error - retry
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise((resolve) => setTimeout(resolve, delay));
        continue;
      }

      // Non-retryable error or max retries reached
      throw error;
    }
  }
}
```

## Implementation Checklist

**Audience:** Project Teams

**Pre-Development:**

- [ ] Review API specifications and understand data models
- [ ] Set up development environment with proper credentials
- [ ] Implement authentication and authorization mechanisms
- [ ] Design data validation and error handling strategies
- [ ] Plan for rate limiting and caching requirements
- [ ] Establish monitoring and alerting thresholds

**Development Phase:**

- [ ] Implement core valuation retrieval functionality
- [ ] Add oracle attestation submission capabilities
- [ ] Integrate price tick streaming or polling
- [ ] Implement proper error handling and retry logic
- [ ] Add comprehensive logging and audit trails
- [ ] Ensure multi-tenant data isolation
- [ ] Implement idempotency for critical operations

**Testing Phase:**

- [ ] Unit tests for all API client methods (100% coverage)
- [ ] Integration tests with sandbox environment
- [ ] Load testing for high-volume scenarios
- [ ] Security testing for authentication and authorization
- [ ] Performance testing for latency requirements
- [ ] Cross-browser testing for web integrations

**Production Readiness:**

- [ ] Environment configuration management
- [ ] API key rotation and credential management
- [ ] Monitoring dashboard setup and alerts
- [ ] Documentation review and updates
- [ ] Security audit and penetration testing
- [ ] Performance optimization and caching
- [ ] Backup and disaster recovery procedures

## Monitoring & Observability

**Audience:** Technical + Project Teams

**Key Metrics:**

- **API Response Time:** Target <200ms for 95th percentile
- **Data Freshness:** Oracle updates within 100ms of source
- **Uptime:** 99.9% availability with <4 hours monthly downtime
- **Error Rate:** <0.1% of total API calls
- **Throughput:** Support 10,000+ valuations per hour
- **Data Accuracy:** 99.99% accuracy in oracle attestations

**Logging Requirements:**

```json
{
  "timestamp": "2025-11-02T10:00:00Z",
  "level": "INFO",
  "service": "market-oracles",
  "operation": "submit_valuation",
  "orgId": "123e4567-e89b-12d3-a456-426614174000",
  "requestId": "req_1234567890",
  "userId": "user_987654321",
  "metadata": {
    "projectId": "456e7890-e89b-12d3-a456-426614174001",
    "valuationType": "MARKET",
    "navTotal": 1000000.0
  },
  "duration": 150,
  "status": "SUCCESS"
}
```

**Alerting Configuration:**

```yaml
alerts:
  - name: High Error Rate
    condition: error_rate > 0.1
    severity: critical
    channels: [slack, email, pager]

  - name: Data Staleness
    condition: data_age > 300000 # 5 minutes
    severity: warning
    channels: [slack]

  - name: API Latency Degradation
    condition: p95_response_time > 500
    severity: warning
    channels: [slack, email]
```

## API Versioning & Evolution

**Audience:** All

**Current Version:** v2.0.0

- Complete rewrite with improved performance and reliability
- Enhanced security with multi-tenant isolation
- Expanded oracle types and attestation methods
- Real-time price tick streaming capabilities

**Planned Enhancements (v2.1):**

- Machine learning-based anomaly detection
- Enhanced cross-validation algorithms
- Blockchain-based oracle attestations
- Advanced analytics and reporting features

**Breaking Changes (v3.0 - Future):**

- Migration to GraphQL API for complex queries
- Decentralized oracle network integration
- Enhanced privacy features with zero-knowledge proofs
- Multi-chain oracle attestations

## Additional Resources

**Audience:** All

**For Stakeholders:**

- [Market Oracles Product Overview](https://docs.quub.exchange/market-oracles/overview)
- [Oracle Services Pricing](https://quub.exchange/pricing/market-oracles)
- [Case Studies: Institutional Adoption](https://quub.exchange/case-studies)
- [Regulatory Compliance Guide](https://docs.quub.exchange/compliance/oracles)

**For Technical Teams:**

- [OpenAPI Specification](https://api.quub.exchange/v2/docs/market-oracles)
- [SDK Downloads](https://github.com/quub-fi/quub-sdks)
- [API Rate Limits](https://docs.quub.exchange/api/rate-limits)
- [Webhook Documentation](https://docs.quub.exchange/webhooks)
- [Troubleshooting Guide](https://docs.quub.exchange/troubleshooting)

**For Project Teams:**

- [Integration Examples Repository](https://github.com/quub-fi/integration-examples)
- [Postman Collection](https://github.com/quub-fi/postman-collections)
- [Docker Images](https://hub.docker.com/r/quub/market-oracles)
- [Terraform Modules](https://registry.terraform.io/modules/quub-fi/market-oracles)
- [CI/CD Pipeline Templates](https://github.com/quub-fi/cicd-templates)
