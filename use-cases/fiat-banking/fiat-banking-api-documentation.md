---
layout: docs
permalink: /use-cases/fiat-banking/
title: fiat-banking API Documentation
service: fiat-banking
---

{% include api-nav-banner.html %}

# Fiat Banking API Documentation

_Based on OpenAPI specification: fiat-banking.yaml_

## Executive Summary

**Audience:** Stakeholders

The Fiat Banking API provides comprehensive financial infrastructure for traditional banking operations within the Quub Exchange ecosystem. It enables seamless integration with banking partners, supports multiple fiat currencies, and ensures regulatory compliance for all fiat transactions. This service is critical for maintaining liquidity, enabling fiat on/off-ramps, and supporting institutional-grade financial operations.

**Key Business Value:**

- **Liquidity Management**: Enables fiat deposits and withdrawals for trading operations
- **Regulatory Compliance**: Supports KYC/AML requirements and financial reporting
- **Multi-Currency Support**: Handles USD, EUR, GBP, and other major fiat currencies
- **Banking Integration**: Connects with major banking institutions and payment processors
- **Settlement Processing**: Automates clearing and settlement of fiat transactions

**Strategic Importance:**

- Core component of fiat-crypto exchange operations
- Enables institutional adoption through banking-grade reliability
- Supports global expansion with multi-currency capabilities
- Critical for regulatory compliance and financial reporting

## Service Overview

**Audience:** All

### Business Purpose

The Fiat Banking service serves as the bridge between traditional financial systems and the digital asset ecosystem. It provides secure, compliant, and efficient fiat currency management for exchange operations, supporting deposits, withdrawals, settlements, and banking account management.

**Key Capabilities:**

- **Bank Account Management**: Link and manage multiple banking accounts per organization
- **Deposit Processing**: Handle incoming wire transfers, ACH, and SEPA payments
- **Withdrawal Management**: Process outgoing payments with compliance checks
- **Settlement Operations**: Batch processing and clearing of fiat transactions
- **Multi-Currency Support**: Handle USD, EUR, GBP, and other major currencies
- **Regulatory Compliance**: Built-in KYC/AML and sanctions screening

### Technical Architecture

The service implements a multi-layered architecture with banking partner integrations, compliance middleware, and real-time transaction processing. It uses event-driven patterns for transaction state management and provides RESTful APIs for all banking operations.

**Architecture Components:**

- **Banking Connectors**: Integration layer with banking partners and payment processors
- **Compliance Engine**: Real-time KYC/AML and sanctions screening
- **Transaction Processor**: High-throughput transaction processing with idempotency
- **Settlement Engine**: Automated batch processing and clearing operations
- **Balance Manager**: Real-time fiat balance tracking and reconciliation
- **Audit Trail**: Comprehensive logging for regulatory reporting

## API Specifications

**Audience:** Technical

### Base Configuration

```yaml
openapi: 3.1.0
info:
  title: Quub Exchange - Fiat Banking API
  version: 2.0.0
servers:
  - url: https://api.quub.exchange/v2
    description: Production API
  - url: https://sandbox.quub.exchange/v2
    description: Sandbox API
```

### Authentication & Authorization

The API uses OAuth 2.0 with scope-based permissions and API key authentication:

**OAuth 2.0 Scopes:**

- `read:fiat-banking`: Read access to banking data
- `write:fiat-banking`: Write access for transactions

**API Key Authentication:**

- Header: `X-API-Key`
- Supports organization-level and user-level keys

## Core Endpoints

**Audience:** Technical + Project Teams

### Banking Accounts Management

**GET /orgs/{orgId}/banking/accounts**
_List fiat accounts linked to an organization_

**Business Use Case:** Retrieve all banking accounts configured for an organization to display account options for deposits and withdrawals.

**Request Example:**

```bash
curl -X GET "https://api.quub.exchange/v2/orgs/123e4567-e89b-12d3-a456-426614174000/banking/accounts" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Org-Id: 123e4567-e89b-12d3-a456-426614174000"
```

**Response Example:**

```json
{
  "data": [
    {
      "id": "acc_1234567890",
      "bankName": "Chase Bank",
      "accountNumber": "****1234",
      "routingNumber": "021000021",
      "currency": "USD",
      "status": "active",
      "balance": 150000.0,
      "availableBalance": 145000.0
    }
  ],
  "pagination": {
    "cursor": "eyJpZCI6ImFjY18xMjM0NTY3ODkwIn0",
    "hasMore": false
  }
}
```

**Implementation Notes:**

- Accounts are filtered by organization for multi-tenant isolation
- Balances are real-time but may have slight delays from banking partners
- Account numbers are masked for security in API responses
- Supports pagination for organizations with multiple accounts

### Deposit Operations

**POST /orgs/{orgId}/banking/deposits**
_Initiate a fiat deposit_

**Business Use Case:** Create a deposit request for incoming fiat funds, typically used for funding trading accounts or liquidity management.

**Request Example:**

```bash
curl -X POST "https://api.quub.exchange/v2/orgs/123e4567-e89b-12d3-a456-426614174000/banking/deposits" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Org-Id: 123e4567-e89b-12d3-a456-426614174000" \
  -H "Idempotency-Key: dep_1234567890" \
  -d '{
    "accountId": "acc_1234567890",
    "amount": 50000.00,
    "currency": "USD",
    "reference": "Monthly funding - Q4 2025"
  }'
```

**Response Example:**

```json
{
  "data": {
    "id": "dep_1234567890",
    "accountId": "acc_1234567890",
    "amount": 50000.0,
    "currency": "USD",
    "status": "pending",
    "reference": "Monthly funding - Q4 2025",
    "createdAt": "2025-11-02T10:30:00Z",
    "expectedSettlement": "2025-11-04T10:30:00Z"
  }
}
```

**Implementation Notes:**

- Idempotency keys prevent duplicate deposit requests
- Deposits require pre-verification of account ownership
- Settlement times vary by payment method (1-3 business days)
- Reference field supports reconciliation and audit trails

### Withdrawal Operations

**POST /orgs/{orgId}/banking/withdrawals**
_Initiate a fiat withdrawal_

**Business Use Case:** Process outgoing fiat payments for profit distribution, operational expenses, or liquidity management.

**Request Example:**

```bash
curl -X POST "https://api.quub.exchange/v2/orgs/123e4567-e89b-12d3-a456-426614174000/banking/withdrawals" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Org-Id: 123e4567-e89b-12d3-a456-426614174000" \
  -H "Idempotency-Key: wdr_1234567890" \
  -d '{
    "accountId": "acc_1234567890",
    "amount": 25000.00,
    "currency": "USD",
    "reference": "Profit distribution - October 2025"
  }'
```

**Response Example:**

```json
{
  "data": {
    "id": "wdr_1234567890",
    "accountId": "acc_1234567890",
    "amount": 25000.0,
    "currency": "USD",
    "status": "pending_approval",
    "reference": "Profit distribution - October 2025",
    "createdAt": "2025-11-02T10:45:00Z",
    "estimatedCompletion": "2025-11-05T10:45:00Z"
  }
}
```

**Implementation Notes:**

- Withdrawals may require manual approval for large amounts
- AML checks are performed before processing
- Settlement times depend on banking partner processing
- Failed withdrawals trigger automatic refund processes

### Settlement Operations

**GET /orgs/{orgId}/banking/settlements**
_List settlement batches_

**Business Use Case:** Monitor and reconcile settlement batches for regulatory reporting and financial reconciliation.

**Request Example:**

```bash
curl -X GET "https://api.quub.exchange/v2/orgs/123e4567-e89b-12d3-a456-426614174000/banking/settlements" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Org-Id: 123e4567-e89b-12d3-a456-426614174000"
```

**Response Example:**

```json
{
  "data": [
    {
      "id": "stl_1234567890",
      "batchId": "BATCH_20251102_001",
      "status": "completed",
      "totalAmount": 150000.0,
      "currency": "USD",
      "transactionCount": 45,
      "settlementDate": "2025-11-02T15:00:00Z",
      "bankReference": "STL20251102001"
    }
  ],
  "pagination": {
    "cursor": "eyJpZCI6InN0bF8xMjM0NTY3ODkwIn0",
    "hasMore": false
  }
}
```

**Implementation Notes:**

- Settlements are processed in batches for efficiency
- Each settlement includes detailed transaction breakdowns
- Settlement data is immutable once completed
- Used for financial reporting and regulatory compliance

## Security Implementation

**Audience:** Technical + Project Teams

### Multi-tenant Isolation

```yaml
# Organization-scoped access control
paths:
  /orgs/{orgId}/banking/*:
    parameters:
      - name: orgId
        in: path
        required: true
        schema:
          type: string
          format: uuid
    security:
      - orgScope: ["fiat-banking"]
```

### Data Protection Measures

- **Encryption**: All banking data encrypted at rest and in transit
- **Tokenization**: Sensitive banking credentials tokenized
- **Audit Logging**: All API calls logged with compliance tracking
- **Access Controls**: Role-based permissions with principle of least privilege

### Access Controls

```json
{
  "roles": {
    "fiat_banking_admin": {
      "permissions": ["read:fiat-banking", "write:fiat-banking"],
      "restrictions": ["amount_limit: 1000000"]
    },
    "fiat_banking_viewer": {
      "permissions": ["read:fiat-banking"],
      "restrictions": ["sensitive_data: masked"]
    }
  }
}
```

## Business Workflows

**Audience:** Stakeholders + Project Teams

### Primary Workflow - Fiat Deposit Processing

```mermaid
graph TD
    A[Deposit Request] --> B[KYC/AML Check]
    B --> C{Approved?}
    C -->|Yes| D[Bank Instruction Generated]
    C -->|No| E[Deposit Rejected]
    D --> F[Funds Received]
    F --> G[Balance Updated]
    G --> H[Settlement Processing]
    H --> I[Deposit Completed]
```

**Business Value:**

- **Automated Processing**: Reduces manual intervention by 80%
- **Compliance Assurance**: Built-in regulatory checks prevent violations
- **Real-time Updates**: Immediate balance visibility for trading operations
- **Audit Trail**: Complete transaction history for regulatory reporting

**Success Metrics:**

- Processing time: < 5 minutes for approved deposits
- Success rate: > 99.5% for valid requests
- Compliance accuracy: 100% automated screening

### Secondary Workflow - Withdrawal Processing

```mermaid
graph TD
    A[Withdrawal Request] --> B[Balance Check]
    B --> C{Sufficient Funds?}
    C -->|No| D[Insufficient Funds Error]
    C -->|Yes| E[AML Screening]
    E --> F{Approved?}
    F -->|No| G[Withdrawal Blocked]
    F -->|Yes| H[Bank Transfer Initiated]
    H --> I[Funds Sent]
    I --> J[Balance Deducted]
    J --> K[Confirmation Sent]
```

**Business Value:**

- **Risk Mitigation**: Multi-layer compliance checks prevent fraud
- **Liquidity Management**: Efficient cash outflow for operational needs
- **Cost Optimization**: Batch processing reduces transaction fees
- **Customer Satisfaction**: Fast processing with clear status updates

**Success Metrics:**

- Processing time: < 2 hours for standard withdrawals
- Approval rate: > 95% for compliant requests
- False positive rate: < 0.1% for AML screening

## Integration Guide

**Audience:** Project Teams

### Development Setup

```bash
# Install dependencies
npm install axios oauth2-client

# Environment configuration
export QUUB_API_BASE="https://api.quub.exchange/v2"
export QUUB_CLIENT_ID="your-client-id"
export QUUB_CLIENT_SECRET="your-client-secret"
```

### JavaScript/Node.js Example

```javascript
const axios = require("axios");
const OAuth2 = require("oauth2-client");

class FiatBankingClient {
  constructor(baseURL, clientId, clientSecret) {
    this.baseURL = baseURL;
    this.oauth = new OAuth2({
      clientId,
      clientSecret,
      tokenEndpoint: `${baseURL}/oauth/token`,
    });
  }

  async getAccounts(orgId) {
    const token = await this.oauth.getAccessToken();
    const response = await axios.get(
      `${this.baseURL}/orgs/${orgId}/banking/accounts`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "X-Org-Id": orgId,
        },
      }
    );
    return response.data;
  }

  async createDeposit(orgId, depositData) {
    const token = await this.oauth.getAccessToken();
    const response = await axios.post(
      `${this.baseURL}/orgs/${orgId}/banking/deposits`,
      depositData,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "X-Org-Id": orgId,
          "Idempotency-Key": `dep_${Date.now()}`,
        },
      }
    );
    return response.data;
  }

  async createWithdrawal(orgId, withdrawalData) {
    const token = await this.oauth.getAccessToken();
    const response = await axios.post(
      `${this.baseURL}/orgs/${orgId}/banking/withdrawals`,
      withdrawalData,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "X-Org-Id": orgId,
          "Idempotency-Key": `wdr_${Date.now()}`,
        },
      }
    );
    return response.data;
  }
}

// Usage example
const client = new FiatBankingClient(
  "https://api.quub.exchange/v2",
  "your-client-id",
  "your-client-secret"
);

async function example() {
  const orgId = "123e4567-e89b-12d3-a456-426614174000";

  // Get accounts
  const accounts = await client.getAccounts(orgId);
  console.log("Available accounts:", accounts.data);

  // Create deposit
  const deposit = await client.createDeposit(orgId, {
    accountId: accounts.data[0].id,
    amount: 10000.0,
    currency: "USD",
    reference: "API Integration Test",
  });
  console.log("Deposit created:", deposit.data);

  // Create withdrawal
  const withdrawal = await client.createWithdrawal(orgId, {
    accountId: accounts.data[0].id,
    amount: 5000.0,
    currency: "USD",
    reference: "API Integration Test",
  });
  console.log("Withdrawal created:", withdrawal.data);
}

example().catch(console.error);
```

### Python Example

```python
import requests
import uuid
from datetime import datetime
from typing import List, Dict, Any

class FiatBankingClient:
    def __init__(self, base_url: str, client_id: str, client_secret: str):
        self.base_url = base_url
        self.client_id = client_id
        self.client_secret = client_secret
        self._token = None

    def _get_token(self) -> str:
        if not self._token:
            response = requests.post(
                f"{self.base_url}/oauth/token",
                data={
                    "grant_type": "client_credentials",
                    "client_id": self.client_id,
                    "client_secret": self.client_secret,
                    "scope": "read:fiat-banking write:fiat-banking"
                }
            )
            response.raise_for_status()
            self._token = response.json()["access_token"]
        return self._token

    def get_accounts(self, org_id: str) -> Dict[str, Any]:
        headers = {
            "Authorization": f"Bearer {self._get_token()}",
            "X-Org-Id": org_id
        }
        response = requests.get(
            f"{self.base_url}/orgs/{org_id}/banking/accounts",
            headers=headers
        )
        response.raise_for_status()
        return response.json()

    def create_deposit(self, org_id: str, account_id: str,
                      amount: float, currency: str, reference: str = None) -> Dict[str, Any]:
        headers = {
            "Authorization": f"Bearer {self._get_token()}",
            "X-Org-Id": org_id,
            "Idempotency-Key": f"dep_{uuid.uuid4()}"
        }
        data = {
            "accountId": account_id,
            "amount": amount,
            "currency": currency
        }
        if reference:
            data["reference"] = reference

        response = requests.post(
            f"{self.base_url}/orgs/{org_id}/banking/deposits",
            headers=headers,
            json=data
        )
        response.raise_for_status()
        return response.json()

    def create_withdrawal(self, org_id: str, account_id: str,
                         amount: float, currency: str, reference: str = None) -> Dict[str, Any]:
        headers = {
            "Authorization": f"Bearer {self._get_token()}",
            "X-Org-Id": org_id,
            "Idempotency-Key": f"wdr_{uuid.uuid4()}"
        }
        data = {
            "accountId": account_id,
            "amount": amount,
            "currency": currency
        }
        if reference:
            data["reference"] = reference

        response = requests.post(
            f"{self.base_url}/orgs/{org_id}/banking/withdrawals",
            headers=headers,
            json=data
        )
        response.raise_for_status()
        return response.json()

# Usage example
if __name__ == "__main__":
    client = FiatBankingClient(
        base_url="https://api.quub.exchange/v2",
        client_id="your-client-id",
        client_secret="your-client-secret"
    )

    org_id = "123e4567-e89b-12d3-a456-426614174000"

    try:
        # Get accounts
        accounts_response = client.get_accounts(org_id)
        accounts = accounts_response["data"]
        print(f"Found {len(accounts)} accounts")

        if accounts:
            account_id = accounts[0]["id"]

            # Create deposit
            deposit_response = client.create_deposit(
                org_id=org_id,
                account_id=account_id,
                amount=10000.00,
                currency="USD",
                reference="Python API Integration Test"
            )
            print("Deposit created:", deposit_response["data"])

            # Create withdrawal
            withdrawal_response = client.create_withdrawal(
                org_id=org_id,
                account_id=account_id,
                amount=5000.00,
                currency="USD",
                reference="Python API Integration Test"
            )
            print("Withdrawal created:", withdrawal_response["data"])

    except requests.exceptions.RequestException as e:
        print(f"API request failed: {e}")
    except KeyError as e:
        print(f"Unexpected response format: {e}")
```

### Testing Strategy

```bash
# Unit tests
npm test -- --grep "FiatBanking"

# Integration tests
npm run test:integration -- --service=fiat-banking

# Load testing
npm run test:load -- --service=fiat-banking --concurrency=10
```

## Error Handling

**Audience:** Technical + Project Teams

### Standard Error Response

```json
{
  "error": {
    "code": "INSUFFICIENT_FUNDS",
    "message": "Account balance insufficient for withdrawal",
    "details": {
      "accountId": "acc_1234567890",
      "requestedAmount": 50000.0,
      "availableBalance": 25000.0,
      "currency": "USD"
    },
    "timestamp": "2025-11-02T10:30:00Z",
    "requestId": "req_1234567890"
  }
}
```

### Error Codes Reference

| Error Code           | HTTP Status | Description                     | Resolution                                |
| -------------------- | ----------- | ------------------------------- | ----------------------------------------- |
| `INSUFFICIENT_FUNDS` | 422         | Account balance too low         | Check available balance before requesting |
| `ACCOUNT_INACTIVE`   | 422         | Banking account not active      | Verify account status with bank           |
| `AML_BLOCKED`        | 403         | Transaction blocked by AML      | Contact compliance team                   |
| `INVALID_AMOUNT`     | 400         | Amount outside allowed range    | Check minimum/maximum limits              |
| `DUPLICATE_REQUEST`  | 409         | Idempotency key conflict        | Use unique idempotency keys               |
| `BANKING_ERROR`      | 502         | Banking partner unavailable     | Retry with exponential backoff            |
| `SETTLEMENT_PENDING` | 409         | Previous settlement in progress | Wait for settlement completion            |

### Error Handling Best Practices

```javascript
class FiatBankingErrorHandler {
  static handleError(error) {
    switch (error.code) {
      case "INSUFFICIENT_FUNDS":
        // Notify user and suggest deposit
        this.notifyInsufficientFunds(error.details);
        break;
      case "AML_BLOCKED":
        // Escalate to compliance team
        this.escalateToCompliance(error.details);
        break;
      case "BANKING_ERROR":
        // Implement retry logic
        this.retryWithBackoff(error.requestId);
        break;
      default:
        // Log and notify developers
        this.logUnexpectedError(error);
    }
  }

  static async retryWithBackoff(requestId, maxRetries = 3) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await new Promise((resolve) =>
          setTimeout(resolve, Math.pow(2, attempt) * 1000)
        );
        return await this.retryRequest(requestId);
      } catch (error) {
        if (attempt === maxRetries) throw error;
      }
    }
  }
}
```

## Implementation Checklist

**Audience:** Project Teams

### Pre-Development

- [ ] Review banking partner requirements and SLAs
- [ ] Assess current banking account setup and limits
- [ ] Evaluate KYC/AML compliance requirements
- [ ] Plan for multi-currency support needs
- [ ] Design idempotency key generation strategy
- [ ] Define transaction monitoring thresholds

### Development Phase

- [ ] Implement OAuth 2.0 authentication flow
- [ ] Build account listing and balance retrieval
- [ ] Develop deposit creation with validation
- [ ] Implement withdrawal processing with approvals
- [ ] Add settlement batch monitoring
- [ ] Integrate error handling and retry logic
- [ ] Implement comprehensive logging and audit trails

### Testing Phase

- [ ] Unit tests for all API client methods
- [ ] Integration tests with sandbox environment
- [ ] Load testing for concurrent transactions
- [ ] Error scenario testing (insufficient funds, AML blocks)
- [ ] Idempotency testing for duplicate requests
- [ ] Multi-currency testing across supported currencies
- [ ] End-to-end testing with mock banking partners

### Production Readiness

- [ ] Configure production banking partner credentials
- [ ] Set up monitoring and alerting for transaction failures
- [ ] Implement rate limiting and abuse prevention
- [ ] Configure backup and disaster recovery procedures
- [ ] Set up compliance reporting and audit procedures
- [ ] Train operations team on manual intervention procedures
- [ ] Establish incident response procedures for banking outages

## Monitoring & Observability

**Audience:** Technical + Project Teams

### Key Metrics

- **Transaction Success Rate**: > 99.5% (target: > 99.9%)
- **Average Processing Time**: < 30 seconds for deposits, < 2 hours for withdrawals
- **Error Rate by Type**: Track and alert on error code frequencies
- **Settlement Accuracy**: 100% reconciliation match rate
- **API Response Time**: P95 < 500ms for reads, < 2s for writes
- **Banking Partner Uptime**: Monitor partner API availability

### Logging Requirements

```json
{
  "timestamp": "2025-11-02T10:30:00Z",
  "level": "INFO",
  "service": "fiat-banking",
  "operation": "create_deposit",
  "orgId": "123e4567-e89b-12d3-a456-426614174000",
  "requestId": "req_1234567890",
  "userId": "user_1234567890",
  "amount": 50000.0,
  "currency": "USD",
  "accountId": "acc_1234567890",
  "status": "success",
  "processingTimeMs": 250,
  "bankReference": "DEP20251102001"
}
```

### Alerting Configuration

```yaml
alerting:
  rules:
    - name: High Error Rate
      condition: rate(error_total[5m]) > 0.05
      severity: critical
      description: "Error rate exceeded 5% threshold"

    - name: Banking Partner Down
      condition: up{partner="chase"} == 0
      severity: critical
      description: "Primary banking partner unavailable"

    - name: Large Withdrawal Pending
      condition: pending_withdrawals_total > 10
      severity: warning
      description: "Multiple large withdrawals pending approval"

    - name: Settlement Delay
      condition: settlement_delay_minutes > 60
      severity: warning
      description: "Settlement processing delayed beyond threshold"
```

## API Versioning & Evolution

**Audience:** All

### Current Version (v2.0.0)

The current API version (v2.0.0) provides comprehensive fiat banking functionality with multi-currency support, advanced compliance features, and real-time settlement processing.

**Key Features:**

- Multi-currency banking account management
- Real-time deposit and withdrawal processing
- Automated settlement and reconciliation
- Advanced compliance and AML screening
- Comprehensive audit trails and reporting

### Planned Enhancements (v2.1)

- **Real-time Notifications**: Webhook support for transaction status updates
- **Bulk Operations**: Batch deposit and withdrawal processing
- **Enhanced Reporting**: Advanced analytics and reconciliation reports
- **Multi-bank Aggregation**: Support for multiple banking partners simultaneously

### Breaking Changes (v3.0 - Future)

- **Unified Account Model**: Single account abstraction across multiple banks
- **Enhanced Security**: Mandatory hardware security modules for large transactions
- **Global Expansion**: Support for additional currencies and regulatory regimes
- **AI-Powered Compliance**: Machine learning enhanced AML screening

## Additional Resources

**Audience:** All

### For Stakeholders

- [Fiat Banking Product Roadmap](https://docs.quub.exchange/roadmap/fiat-banking)
- [Financial Services Compliance Guide](https://docs.quub.exchange/compliance/financial-services)
- [Banking Partner Integration Status](https://status.quub.exchange/banking-partners)
- [Regulatory Reporting Requirements](https://docs.quub.exchange/regulatory/fiat-reporting)

### For Technical Teams

- [Banking API Reference](https://developers.quub.exchange/apis/fiat-banking)
- [OAuth 2.0 Implementation Guide](https://developers.quub.exchange/auth/oauth2)
- [Idempotency Key Best Practices](https://developers.quub.exchange/best-practices/idempotency)
- [Error Handling Patterns](https://developers.quub.exchange/patterns/error-handling)
- [Testing Environments](https://developers.quub.exchange/testing/environments)

### For Project Teams

- [Fiat Banking Integration Checklist](https://docs.quub.exchange/integration/fiat-banking)
- [Sample Banking Applications](https://github.com/quub-fi/fiat-banking-examples)
- [Compliance Testing Scenarios](https://docs.quub.exchange/testing/compliance-scenarios)
- [Performance Benchmarking Guide](https://docs.quub.exchange/performance/fiat-banking)
- [Troubleshooting Common Issues](https://docs.quub.exchange/troubleshooting/fiat-banking)
