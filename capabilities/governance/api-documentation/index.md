---
layout: docs
permalink: /capabilities/governance/api-documentation/
title: governance API Documentation
service: governance
---

{% include api-nav-banner.html %}

# Governance API Documentation

_Based on OpenAPI specification: governance.yaml_

## Executive Summary

**Audience:** Stakeholders

The Governance Service provides comprehensive corporate governance capabilities for Quub Exchange, enabling organizations to manage corporate actions, voting sessions, and shareholder communications. This service ensures regulatory compliance while providing transparent governance mechanisms for token holders and stakeholders.

**Key Business Value:**

- **Regulatory Compliance**: Automated corporate action processing with full audit trails
- **Stakeholder Engagement**: Transparent voting mechanisms and shareholder communications
- **Operational Efficiency**: Streamlined governance workflows reducing manual processing time by 80%
- **Risk Mitigation**: Built-in compliance checks and validation rules
- **Scalability**: Multi-tenant architecture supporting thousands of concurrent governance events

**Strategic Importance:**

- Enables compliant token offerings and secondary market operations
- Provides governance framework for DAO and traditional corporate structures
- Supports regulatory reporting and transparency requirements
- Critical for investor confidence and market integrity

## Service Overview

**Audience:** All

**Business Purpose:**

- Corporate action management (dividends, splits, mergers, buybacks)
- Voting session orchestration and ballot management
- Shareholder communication and notification systems
- Regulatory compliance and audit trail maintenance
- Multi-jurisdictional governance support

**Technical Architecture:**

- Event-driven architecture with immutable audit logs
- Multi-tenant isolation with organization-level data segregation
- RESTful API with comprehensive OpenAPI specification
- Integration with identity and compliance services
- Real-time notification and webhook delivery systems

## API Specifications

**Audience:** Technical

**Base Configuration:**

```yaml
openapi: 3.1.0
info:
  title: Quub Exchange - Governance Service
  version: "2.0.0"
servers:
  - url: https://api.quub.exchange/v1
    description: Production
  - url: https://api.sandbox.quub.exchange/v1
    description: Sandbox
```

**Authentication & Authorization:**

- OAuth 2.0 with scopes: `read:governance`, `write:governance`
- API key authentication for service-to-service calls
- Organization-level access control with role-based permissions
- Multi-tenant isolation ensuring data privacy

## Core Endpoints

**Audience:** Technical + Project Teams

### Corporate Actions Management

**GET /orgs/{orgId}/corporate-actions**

- **Business Use Case**: Retrieve paginated list of corporate actions for an organization
- **Request Example**:

```json
GET /orgs/123e4567-e89b-12d3-a456-426614174000/corporate-actions?limit=20&type=DIVIDEND
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

- **Response Example**:

```json
{
  "data": [
    {
      "id": "ca_1234567890",
      "type": "DIVIDEND",
      "targetTokenClassId": "tc_abcdef123456",
      "recordDate": "2025-12-01",
      "effectiveDate": "2025-12-15",
      "status": "PENDING",
      "params": {
        "dividendAmount": 0.05,
        "currency": "USD"
      }
    }
  ],
  "pagination": {
    "cursor": "eyJwYWdlIjoxfQ==",
    "hasMore": true
  }
}
```

- **Implementation Notes**:
  - Supports filtering by corporate action type
  - Pagination required for large result sets
  - Real-time status updates via webhooks
  - Audit trail maintained for all actions

**POST /orgs/{orgId}/corporate-actions**

- **Business Use Case**: Create new corporate action (dividend, stock split, merger, etc.)
- **Request Example**:

```json
POST /orgs/123e4567-e89b-12d3-a456-426614174000/corporate-actions
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "type": "DIVIDEND",
  "targetTokenClassId": "tc_abcdef123456",
  "recordDate": "2025-12-01",
  "effectiveDate": "2025-12-15",
  "params": {
    "dividendAmount": 0.05,
    "currency": "USD"
  }
}
```

- **Response Example**:

```json
{
  "data": {
    "id": "ca_1234567890",
    "type": "DIVIDEND",
    "targetTokenClassId": "tc_abcdef123456",
    "recordDate": "2025-12-01",
    "effectiveDate": "2025-12-15",
    "status": "PENDING",
    "createdAt": "2025-11-01T10:00:00Z"
  }
}
```

- **Implementation Notes**:
  - Idempotency key required for duplicate prevention
  - Validation against token class eligibility
  - Automatic notification to affected shareholders
  - Integration with settlement service for distribution

### Voting Session Management

**GET /orgs/{orgId}/voting-sessions**

- **Business Use Case**: List voting sessions for governance decisions
- **Request Example**:

```json
GET /orgs/123e4567-e89b-12d3-a456-426614174000/voting-sessions?ca_id=ca_1234567890
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

- **Response Example**:

```json
{
  "data": [
    {
      "id": "vs_abcdef123456",
      "corporateActionId": "ca_1234567890",
      "title": "Board Election 2025",
      "description": "Vote for board members",
      "startDate": "2025-11-01T00:00:00Z",
      "endDate": "2025-11-15T23:59:59Z",
      "status": "ACTIVE",
      "quorum": 0.5,
      "options": [
        { "id": "opt_1", "text": "Candidate A" },
        { "id": "opt_2", "text": "Candidate B" }
      ]
    }
  ]
}
```

- **Implementation Notes**:
  - Real-time voting status and results
  - Quorum validation and early closure logic
  - Integration with identity service for voter verification
  - Webhook notifications for vote changes

## Security Implementation

**Audience:** Technical + Project Teams

**Multi-tenant Isolation:**

```yaml
# Organization-level data segregation
components:
  securitySchemes:
    oauth2:
      type: oauth2
      flows:
        clientCredentials:
          tokenUrl: /oauth/token
          scopes:
            read:governance: Read governance data
            write:governance: Create/modify governance data
```

**Data Protection Measures:**

- End-to-end encryption for sensitive governance data
- Audit logging for all governance actions
- Token-based authentication with short-lived tokens
- Rate limiting on voting endpoints to prevent manipulation
- IP whitelisting for administrative operations

**Access Controls:**

- Role-based permissions (admin, manager, viewer)
- Organization-level access control
- Time-based access restrictions for voting windows
- Multi-signature requirements for critical actions

## Business Workflows

**Audience:** Stakeholders + Project Teams

### Primary Workflow — Corporate Action Lifecycle

```mermaid
graph TD
    A[Corporate Action Proposed] --> B[Validation & Approval]
    B --> C[Record Date Set]
    C --> D[Shareholder Notification]
    D --> E[Voting Period]
    E --> F[Action Execution]
    F --> G[Settlement & Distribution]
    G --> H[Audit & Reporting]

    style A fill:#e1f5fe
    style F fill:#c8e6c9
    style H fill:#fff3e0
```

**Business Value:**

- Ensures regulatory compliance and transparency
- Reduces processing time from weeks to days
- Provides real-time visibility for stakeholders
- Enables automated distribution and settlement

**Success Metrics:**

- 99.9% uptime for governance operations
- < 24 hours processing time for standard actions
- 100% audit trail completeness
- > 95% shareholder participation rate

### Secondary Workflow — Voting Session Management

```mermaid
graph TD
    A[Voting Session Created] --> B[Eligibility Verification]
    B --> C[Voter Registration]
    C --> D[Voting Window Opens]
    D --> E[Real-time Vote Counting]
    E --> F[Quorum Check]
    F --> G[Results Finalization]
    G --> H[Blockchain Recording]

    style D fill:#e1f5fe
    style G fill:#c8e6c9
    style H fill:#fff3e0
```

**Business Value:**

- Enables democratic governance mechanisms
- Provides transparent and tamper-proof voting
- Supports various voting types (single-choice, ranked, etc.)
- Integrates with identity verification systems

**Success Metrics:**

- 100% vote integrity verification
- < 5 minute result finalization
- > 90% voter participation
- Zero security incidents

## Integration Guide

**Audience:** Project Teams

**Development Setup:**

```bash
# Install dependencies
npm install axios uuid

# Environment configuration
export QUUB_API_BASE=https://api.sandbox.quub.exchange/v1
export QUUB_CLIENT_ID=your_client_id
export QUUB_CLIENT_SECRET=your_client_secret
```

**JavaScript/Node.js Example:**

```javascript
const axios = require("axios");

class GovernanceService {
  constructor(baseURL, clientId, clientSecret) {
    this.client = axios.create({
      baseURL,
      headers: {
        "Content-Type": "application/json",
      },
    });
    this.clientId = clientId;
    this.clientSecret = clientSecret;
  }

  async getToken() {
    const response = await this.client.post("/oauth/token", {
      grant_type: "client_credentials",
      client_id: this.clientId,
      client_secret: this.clientSecret,
      scope: "read:governance write:governance",
    });
    return response.data.access_token;
  }

  async createCorporateAction(orgId, actionData) {
    const token = await this.getToken();
    const response = await this.client.post(
      `/orgs/${orgId}/corporate-actions`,
      actionData,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "Idempotency-Key": uuidv4(),
        },
      }
    );
    return response.data;
  }

  async listVotingSessions(orgId, caId = null) {
    const token = await this.getToken();
    const params = caId ? { ca_id: caId } : {};
    const response = await this.client.get(`/orgs/${orgId}/voting-sessions`, {
      headers: { Authorization: `Bearer ${token}` },
      params,
    });
    return response.data;
  }
}

// Usage example
const governance = new GovernanceService(
  "https://api.sandbox.quub.exchange/v1",
  "your_client_id",
  "your_client_secret"
);

governance
  .createCorporateAction("org_123", {
    type: "DIVIDEND",
    targetTokenClassId: "tc_456",
    recordDate: "2025-12-01",
    effectiveDate: "2025-12-15",
    params: { dividendAmount: 0.05, currency: "USD" },
  })
  .then((result) => console.log(result));
```

**Python Example:**

```python
import requests
import uuid
from typing import Optional, Dict, Any

class GovernanceClient:
    def __init__(self, base_url: str, client_id: str, client_secret: str):
        self.base_url = base_url
        self.client_id = client_id
        self.client_secret = client_secret
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json'
        })

    def _get_token(self) -> str:
        response = self.session.post(f'{self.base_url}/oauth/token', json={
            'grant_type': 'client_credentials',
            'client_id': self.client_id,
            'client_secret': self.client_secret,
            'scope': 'read:governance write:governance'
        })
        response.raise_for_status()
        return response.json()['access_token']

    def create_corporate_action(self, org_id: str, action_data: Dict[str, Any]) -> Dict[str, Any]:
        token = self._get_token()
        headers = {
            'Authorization': f'Bearer {token}',
            'Idempotency-Key': str(uuid.uuid4())
        }
        response = self.session.post(
            f'{self.base_url}/orgs/{org_id}/corporate-actions',
            json=action_data,
            headers=headers
        )
        response.raise_for_status()
        return response.json()

    def list_voting_sessions(self, org_id: str, ca_id: Optional[str] = None) -> Dict[str, Any]:
        token = self._get_token()
        headers = {'Authorization': f'Bearer {token}'}
        params = {'ca_id': ca_id} if ca_id else {}
        response = self.session.get(
            f'{self.base_url}/orgs/{org_id}/voting-sessions',
            headers=headers,
            params=params
        )
        response.raise_for_status()
        return response.json()

# Usage example
client = GovernanceClient(
    'https://api.sandbox.quub.exchange/v1',
    'your_client_id',
    'your_client_secret'
)

action = client.create_corporate_action('org_123', {
    'type': 'DIVIDEND',
    'targetTokenClassId': 'tc_456',
    'recordDate': '2025-12-01',
    'effectiveDate': '2025-12-15',
    'params': {
        'dividendAmount': 0.05,
        'currency': 'USD'
    }
})
print(action)
```

**Testing Strategy:**

```bash
# Unit tests
npm test -- --grep "governance"

# Integration tests
npm run test:integration -- --service=governance

# Load testing
npm run test:load -- --service=governance --vus=100 --duration=5m
```

## Error Handling

**Audience:** Technical + Project Teams

**Standard Error Response:**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Corporate action parameters are invalid",
    "details": {
      "field": "effectiveDate",
      "issue": "Date cannot be in the past"
    },
    "requestId": "req_1234567890",
    "timestamp": "2025-11-01T10:00:00Z"
  }
}
```

**Error Codes Reference:**

| Code                  | HTTP Status | Description              | Resolution                                |
| --------------------- | ----------- | ------------------------ | ----------------------------------------- |
| `VALIDATION_ERROR`    | 422         | Input validation failed  | Check request parameters against API spec |
| `UNAUTHORIZED`        | 401         | Authentication required  | Provide valid OAuth token                 |
| `FORBIDDEN`           | 403         | Insufficient permissions | Verify user roles and scopes              |
| `NOT_FOUND`           | 404         | Resource not found       | Check resource ID and organization access |
| `CONFLICT`            | 409         | Resource state conflict  | Check current state before retrying       |
| `RATE_LIMITED`        | 429         | Too many requests        | Implement exponential backoff             |
| `SERVICE_UNAVAILABLE` | 503         | Service temporarily down | Retry with circuit breaker pattern        |

**Error Handling Best Practices:**

```javascript
class GovernanceErrorHandler {
  static handleError(error) {
    switch (error.response?.status) {
      case 422:
        // Validation error - show field-specific messages
        this.showValidationErrors(error.response.data.error.details);
        break;
      case 409:
        // Conflict - check current state
        this.handleConflict(error.response.data.error);
        break;
      case 429:
        // Rate limited - implement backoff
        this.handleRateLimit(error.response.headers["retry-after"]);
        break;
      default:
        // Generic error handling
        this.showGenericError(error.response.data.error);
    }
  }
}
```

## Implementation Checklist

**Audience:** Project Teams

### Pre-Development

- [ ] Review governance requirements with legal/compliance teams
- [ ] Set up OAuth 2.0 client credentials for API access
- [ ] Configure webhook endpoints for real-time notifications
- [ ] Define corporate action types and validation rules
- [ ] Set up monitoring and alerting for governance operations
- [ ] Review voting session security requirements

### Development Phase

- [ ] Implement corporate action CRUD operations
- [ ] Add voting session management functionality
- [ ] Integrate with identity service for user verification
- [ ] Implement audit logging for all governance actions
- [ ] Add rate limiting and abuse prevention
- [ ] Create comprehensive test suites (unit, integration, e2e)
- [ ] Implement error handling and retry logic

### Testing Phase

- [ ] Test corporate action lifecycle end-to-end
- [ ] Validate voting session integrity and security
- [ ] Perform load testing with concurrent users
- [ ] Test multi-tenant isolation and data segregation
- [ ] Validate webhook delivery and notification systems
- [ ] Conduct security penetration testing
- [ ] Perform compliance and regulatory validation

### Production Readiness

- [ ] Set up production OAuth clients and secrets
- [ ] Configure production webhook endpoints
- [ ] Enable monitoring and alerting dashboards
- [ ] Set up backup and disaster recovery procedures
- [ ] Conduct final security review and audit
- [ ] Train operations team on monitoring procedures
- [ ] Create runbooks for incident response

## Monitoring & Observability

**Audience:** Technical + Project Teams

**Key Metrics:**

- **Corporate Action Success Rate**: > 99.5% (target: 99.9%)
- **Voting Session Uptime**: > 99.9% (target: 99.99%)
- **Average Response Time**: < 200ms (target: < 100ms)
- **Error Rate**: < 0.1% (target: < 0.01%)
- **Audit Log Completeness**: 100% (target: 100%)

**Logging Requirements:**

```json
{
  "timestamp": "2025-11-01T10:00:00Z",
  "level": "INFO",
  "service": "governance",
  "operation": "create_corporate_action",
  "orgId": "org_1234567890",
  "userId": "user_abcdef123456",
  "actionId": "ca_1234567890",
  "requestId": "req_abcdef123456",
  "details": {
    "actionType": "DIVIDEND",
    "tokenClassId": "tc_abcdef123456",
    "amount": 0.05
  }
}
```

**Alerting Configuration:**

```yaml
alerts:
  - name: High Error Rate
    condition: error_rate > 0.1
    severity: critical
    channels: [slack, pager-duty]

  - name: Corporate Action Failure
    condition: corporate_action_success_rate < 99.5
    severity: warning
    channels: [email, slack]

  - name: Voting Session Down
    condition: voting_session_uptime < 99.9
    severity: critical
    channels: [pager-duty, slack]

  - name: Audit Log Gap
    condition: audit_log_completeness < 100
    severity: critical
    channels: [security-team, compliance]
```

## API Versioning & Evolution

**Audience:** All

**Current Version (v2.0.0):**

- Enhanced corporate action types support
- Improved voting session security
- Real-time notification webhooks
- Multi-tenant isolation improvements
- Enhanced audit logging capabilities

**Planned Enhancements (v2.1):**

- Advanced voting algorithms (quadratic voting, conviction voting)
- Integration with decentralized identity systems
- Enhanced reporting and analytics dashboard
- Mobile-optimized voting interfaces
- Cross-chain governance support

**Breaking Changes (v3.0 - Future):**

- Migration to GraphQL API for complex queries
- Decentralized governance protocol integration
- Enhanced privacy features with zero-knowledge proofs
- Multi-signature corporate action approvals

## Additional Resources

**Audience:** All

**For Stakeholders:**

- [Corporate Governance Best Practices](https://docs.quub.exchange/governance/best-practices)
- [Regulatory Compliance Guide](https://docs.quub.exchange/compliance/governance)
- [Token Holder Rights & Responsibilities](https://docs.quub.exchange/legal/token-holder-rights)
- [Governance Case Studies](https://docs.quub.exchange/case-studies/governance)

**For Technical Teams:**

- [OpenAPI Specification](https://api.quub.exchange/docs/governance.yaml)
- [Webhook Event Reference](https://docs.quub.exchange/webhooks/governance)
- [SDK Libraries](https://github.com/quub-fi/governance-sdk)
- [API Rate Limits](https://docs.quub.exchange/rate-limits)
- [Troubleshooting Guide](https://docs.quub.exchange/troubleshooting/governance)

**For Project Teams:**

- [Integration Examples Repository](https://github.com/quub-fi/governance-examples)
- [Testing Utilities](https://github.com/quub-fi/governance-testing)
- [Deployment Playbooks](https://docs.quub.exchange/deploy/governance)
- [Security Guidelines](https://docs.quub.exchange/security/governance)
- [Performance Optimization](https://docs.quub.exchange/performance/governance)
