# Custodian API Documentation

_Based on OpenAPI specification: custodian.yaml_

## Executive Summary

**Audience:** Stakeholders

The Custodian API provides institutional-grade digital asset custody services, enabling secure storage, management, and transfer of cryptocurrencies, securities, and fiat assets. This service supports multiple custody models including self-custody, qualified custody, omnibus accounts, and segregated accounts, ensuring regulatory compliance and maximum security for institutional and retail clients.

**Key Business Value:**

- **Institutional Trust**: SOC 2 and ISO 27001 compliant custody operations
- **Regulatory Compliance**: Supports AML/KYC requirements and reporting obligations
- **Multi-Asset Support**: Unified custody for crypto, securities, and fiat assets
- **Operational Efficiency**: Automated deposit/withdrawal workflows with multi-signature security
- **Risk Mitigation**: Comprehensive insurance coverage and fraud prevention measures

**Strategic Importance:**

- **Market Leadership**: Differentiated custody offering in competitive digital asset market
- **Revenue Growth**: Premium pricing for institutional custody services
- **Risk Management**: Reduced operational and regulatory risk exposure
- **Client Retention**: Enhanced security drives long-term client relationships

## Service Overview

**Audience:** All

### Business Purpose

- **Secure Asset Storage**: Institutional-grade custody with multi-signature security and HSM-backed key management
- **Regulatory Compliance**: SOC 2, ISO 27001, and financial custody regulation compliance
- **Multi-Asset Support**: Unified custody platform for cryptocurrencies, digital securities, and fiat assets
- **Operational Automation**: Streamlined deposit/withdrawal processes with automated monitoring and alerts
- **Risk Mitigation**: Comprehensive insurance coverage, fraud detection, and emergency response procedures

### Technical Architecture

- **Multi-Signature Infrastructure**: Configurable m-of-n signature schemes with distributed key management
- **Hardware Security Modules**: FIPS 140-2 Level 3 compliant HSM integration for key generation and storage
- **Cold Storage Solutions**: Air-gapped, geographically distributed cold storage for long-term asset protection
- **Real-time Monitoring**: 24/7 security monitoring with automated alerting and incident response
- **API-First Design**: RESTful API with OAuth 2.0 and API key authentication supporting programmatic access

## API Specifications

**Audience:** Technical

### Base Configuration

```yaml
openapi: 3.1.0
info:
  title: Quub Exchange - Custody API
  version: 2.0.0
servers:
  - url: https://api.quub.exchange/v1
    description: Production API
```

### Authentication & Authorization

The Custodian API supports multiple authentication methods:

- **OAuth 2.0**: Client credentials flow for programmatic access
- **API Keys**: HMAC-SHA256 signed requests for direct API integration
- **Multi-Factor Authentication**: Required for high-value operations

**Required Scopes:**

- `read:custody` - Read custody account information and balances
- `write:custody` - Create accounts, initiate deposits/withdrawals

## Core Endpoints

**Audience:** Technical + Project Teams

### Custody Account Management

#### GET /orgs/{orgId}/custody/accounts

**Business Use Case:** Retrieve all custody accounts for an organization to monitor asset distribution and account status.

**Request Example:**

```bash
curl -X GET "https://api.quub.exchange/v1/orgs/123e4567-e89b-12d3-a456-426614174000/custody/accounts" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Org-Id: 123e4567-e89b-12d3-a456-426614174000"
```

**Response Example:**

```json
{
  "data": [
    {
      "id": "456e7890-e89b-12d3-a456-426614174001",
      "orgId": "123e4567-e89b-12d3-a456-426614174000",
      "accountType": "QUALIFIED_CUSTODY",
      "assetType": "CRYPTO",
      "status": "ACTIVE",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "cursor": "eyJwYWdlIjoxfQ==",
    "hasMore": false
  }
}
```

**Implementation Notes:**

- Supports pagination for large account portfolios
- Filter by account type and status for targeted queries
- Real-time balance aggregation across all accounts
- Audit trail maintained for all account access

#### POST /orgs/{orgId}/custody/accounts

**Business Use Case:** Create new custody accounts for different asset types and custody models.

**Request Example:**

```json
{
  "accountType": "SEGREGATED",
  "assetType": "CRYPTO"
}
```

**Response Example:**

```json
{
  "data": {
    "id": "456e7890-e89b-12d3-a456-426614174001",
    "orgId": "123e4567-e89b-12d3-a456-426614174000",
    "accountType": "SEGREGATED",
    "assetType": "CRYPTO",
    "status": "ACTIVE",
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

**Implementation Notes:**

- Account type determines security and operational requirements
- Segregated accounts require individual client identification
- Multi-signature setup initiated automatically for qualified custody
- Compliance checks performed before account activation

### Asset Operations

#### POST /orgs/{orgId}/custody/deposits

**Business Use Case:** Initiate secure asset deposits into custody accounts with multi-signature approval workflows.

**Request Example:**

```json
{
  "accountId": "456e7890-e89b-12d3-a456-426614174001",
  "asset": "BTC",
  "amount": "0.5"
}
```

**Response Example:**

```json
{
  "data": {
    "id": "789e0123-e89b-12d3-a456-426614174002",
    "accountId": "456e7890-e89b-12d3-a456-426614174001",
    "type": "DEPOSIT",
    "asset": "BTC",
    "amount": "0.5",
    "status": "PENDING",
    "createdAt": "2024-01-15T10:35:00Z"
  }
}
```

**Implementation Notes:**

- Deposits require multi-signature approval for high-value transactions
- Real-time balance updates upon confirmation
- Integration with blockchain networks for crypto deposits
- Automated AML/KYC checks for regulatory compliance

#### POST /orgs/{orgId}/custody/withdrawals

**Business Use Case:** Request secure asset withdrawals with enhanced security controls and approval workflows.

**Request Example:**

```json
{
  "accountId": "456e7890-e89b-12d3-a456-426614174001",
  "asset": "ETH",
  "amount": "10.0",
  "destination": "0x742d35Cc6634C0532925a3b844Bc454e4438f44e"
}
```

**Response Example:**

```json
{
  "data": {
    "id": "890e1234-e89b-12d3-a456-426614174003",
    "accountId": "456e7890-e89b-12d3-a456-426614174001",
    "type": "WITHDRAWAL",
    "asset": "ETH",
    "amount": "10.0",
    "status": "PENDING",
    "destination": "0x742d35Cc6634C0532925a3b844Bc454e4438f44e",
    "createdAt": "2024-01-15T10:40:00Z"
  }
}
```

**Implementation Notes:**

- Enhanced security for withdrawal requests including destination validation
- Multi-signature approval required for withdrawals above threshold
- Real-time compliance checks and sanctions screening
- Integration with external wallet addresses and banking systems

### Proof of Custody

#### GET /orgs/{orgId}/custody/proof-of-custody

**Business Use Case:** Generate cryptographic proof of custody attestations for regulatory compliance and client assurance.

**Response Example:**

```json
{
  "data": {
    "id": "901e2345-e89b-12d3-a456-426614174004",
    "orgId": "123e4567-e89b-12d3-a456-426614174000",
    "attestation": "Merkle tree root hash of all custody positions",
    "assets": [
      {
        "asset": "BTC",
        "balance": "100.5"
      },
      {
        "asset": "ETH",
        "balance": "2500.0"
      }
    ],
    "timestamp": "2024-01-15T10:45:00Z",
    "signature": "0xabcdef123456789..."
  }
}
```

**Implementation Notes:**

- Cryptographically verifiable proof using Merkle tree structures
- Real-time balance snapshots with timestamp authentication
- Digital signatures from HSM-backed private keys
- Compliance with regulatory proof of reserves requirements

## Security Implementation

**Audience:** Technical + Project Teams

### Multi-tenant Isolation

```yaml
# Account-level isolation with RBAC
custody:
  accounts:
    isolation: tenant_based
    permissions:
      - read:own_accounts
      - write:own_accounts
      - admin:organization_accounts
```

### Data Protection Measures

- **Encryption at Rest**: AES-256 encryption for all stored data
- **Encryption in Transit**: TLS 1.3 for all API communications
- **Key Management**: HSM-backed key generation and rotation
- **Access Logging**: Comprehensive audit trails for all operations

### Access Controls

```json
{
  "custody_operations": {
    "deposit": {
      "min_signatures": 1,
      "max_daily_limit": "1000000",
      "approval_required": false
    },
    "withdrawal": {
      "min_signatures": 2,
      "max_daily_limit": "500000",
      "approval_required": true
    },
    "account_creation": {
      "min_signatures": 1,
      "compliance_check": true,
      "kyc_required": true
    }
  }
}
```

## Business Workflows

**Audience:** Stakeholders + Project Teams

### Primary Workflow — Asset Custody Lifecycle

```mermaid
graph TD
    A[Client Onboarding] --> B[Account Creation]
    B --> C[KYC/AML Verification]
    C --> D[Deposit Initiation]
    D --> E[Multi-Signature Approval]
    E --> F[Asset Transfer]
    F --> G[Balance Update]
    G --> H[Proof of Custody]
    H --> I[Reporting & Compliance]

    style A fill:#e1f5fe
    style I fill:#c8e6c9
```

**Business Value:** Complete end-to-end custody workflow ensuring regulatory compliance, security, and operational efficiency.

**Success Metrics:**

- **Client Onboarding Time**: < 24 hours
- **Transaction Processing**: < 5 minutes average
- **Security Incidents**: Zero tolerance
- **Compliance Rate**: 100% regulatory adherence

### Secondary Workflow — Withdrawal Processing

```mermaid
graph TD
    A[Withdrawal Request] --> B[Security Validation]
    B --> C[AML Screening]
    C --> D[Balance Check]
    D --> E{Multi-Sig Required?}
    E -->|Yes| F[Approval Workflow]
    E -->|No| G[Direct Processing]
    F --> H[Signature Collection]
    H --> G
    G --> I[Asset Transfer]
    I --> J[Confirmation]
    J --> K[Balance Update]

    style A fill:#fff3e0
    style K fill:#c8e6c9
```

**Business Value:** Secure withdrawal processing with configurable approval workflows and real-time compliance monitoring.

**Success Metrics:**

- **Processing Time**: < 10 minutes for standard withdrawals
- **Approval Rate**: > 95% first-pass approvals
- **False Positive Rate**: < 0.1% for AML screening

## Integration Guide

**Audience:** Project Teams

### Development Setup

```bash
# Install dependencies
npm install axios crypto-js

# Set environment variables
export QUUB_API_KEY="your-api-key"
export QUUB_API_SECRET="your-api-secret"
export QUUB_BASE_URL="https://api.quub.exchange/v1"
```

### JavaScript/Node.js Example

```javascript
const axios = require("axios");
const crypto = require("crypto");

class QuubCustodyClient {
  constructor(apiKey, apiSecret, baseUrl) {
    this.apiKey = apiKey;
    this.apiSecret = apiSecret;
    this.baseUrl = baseUrl;
  }

  async createCustodyAccount(orgId, accountType, assetType) {
    const timestamp = Date.now();
    const signature = this.generateSignature(
      "POST",
      `/orgs/${orgId}/custody/accounts`,
      timestamp
    );

    try {
      const response = await axios.post(
        `${this.baseUrl}/orgs/${orgId}/custody/accounts`,
        {
          accountType,
          assetType,
        },
        {
          headers: {
            "X-API-Key": this.apiKey,
            "X-Timestamp": timestamp,
            "X-Signature": signature,
            "X-Org-Id": orgId,
            "Content-Type": "application/json",
          },
        }
      );
      return response.data;
    } catch (error) {
      console.error("Error creating custody account:", error.response.data);
      throw error;
    }
  }

  async initiateDeposit(orgId, accountId, asset, amount) {
    const timestamp = Date.now();
    const signature = this.generateSignature(
      "POST",
      `/orgs/${orgId}/custody/deposits`,
      timestamp
    );

    try {
      const response = await axios.post(
        `${this.baseUrl}/orgs/${orgId}/custody/deposits`,
        {
          accountId,
          asset,
          amount,
        },
        {
          headers: {
            "X-API-Key": this.apiKey,
            "X-Timestamp": timestamp,
            "X-Signature": signature,
            "X-Org-Id": orgId,
            "Content-Type": "application/json",
          },
        }
      );
      return response.data;
    } catch (error) {
      console.error("Error initiating deposit:", error.response.data);
      throw error;
    }
  }

  generateSignature(method, path, timestamp) {
    const message = `${method}${path}${timestamp}`;
    return crypto
      .createHmac("sha256", this.apiSecret)
      .update(message)
      .digest("hex");
  }
}

// Usage example
const client = new QuubCustodyClient(
  process.env.QUUB_API_KEY,
  process.env.QUUB_API_SECRET,
  process.env.QUUB_BASE_URL
);

async function exampleUsage() {
  try {
    // Create a segregated crypto custody account
    const account = await client.createCustodyAccount(
      "123e4567-e89b-12d3-a456-426614174000",
      "SEGREGATED",
      "CRYPTO"
    );
    console.log("Created account:", account);

    // Initiate a Bitcoin deposit
    const deposit = await client.initiateDeposit(
      "123e4567-e89b-12d3-a456-426614174000",
      account.data.id,
      "BTC",
      "0.5"
    );
    console.log("Deposit initiated:", deposit);
  } catch (error) {
    console.error("Operation failed:", error.message);
  }
}

exampleUsage();
```

### Python Example

```python
import requests
import hmac
import hashlib
import time
from typing import Dict, Any

class QuubCustodyClient:
    def __init__(self, api_key: str, api_secret: str, base_url: str):
        self.api_key = api_key
        self.api_secret = api_secret
        self.base_url = base_url

    def _generate_signature(self, method: str, path: str, timestamp: int) -> str:
        message = f"{method}{path}{timestamp}"
        return hmac.new(
            self.api_secret.encode(),
            message.encode(),
            hashlib.sha256
        ).hexdigest()

    def create_custody_account(self, org_id: str, account_type: str, asset_type: str) -> Dict[str, Any]:
        timestamp = int(time.time() * 1000)
        path = f"/orgs/{org_id}/custody/accounts"
        signature = self._generate_signature('POST', path, timestamp)

        headers = {
            'X-API-Key': self.api_key,
            'X-Timestamp': str(timestamp),
            'X-Signature': signature,
            'X-Org-Id': org_id,
            'Content-Type': 'application/json'
        }

        payload = {
            'accountType': account_type,
            'assetType': asset_type
        }

        response = requests.post(
            f"{self.base_url}{path}",
            json=payload,
            headers=headers
        )

        if response.status_code == 201:
            return response.json()
        else:
            raise Exception(f"API Error: {response.status_code} - {response.text}")

    def initiate_deposit(self, org_id: str, account_id: str, asset: str, amount: str) -> Dict[str, Any]:
        timestamp = int(time.time() * 1000)
        path = f"/orgs/{org_id}/custody/deposits"
        signature = self._generate_signature('POST', path, timestamp)

        headers = {
            'X-API-Key': self.api_key,
            'X-Timestamp': str(timestamp),
            'X-Signature': signature,
            'X-Org-Id': org_id,
            'Content-Type': 'application/json'
        }

        payload = {
            'accountId': account_id,
            'asset': asset,
            'amount': amount
        }

        response = requests.post(
            f"{self.base_url}{path}",
            json=payload,
            headers=headers
        )

        if response.status_code == 201:
            return response.json()
        else:
            raise Exception(f"API Error: {response.status_code} - {response.text}")

# Usage example
if __name__ == "__main__":
    import os

    client = QuubCustodyClient(
        api_key=os.getenv('QUUB_API_KEY'),
        api_secret=os.getenv('QUUB_API_SECRET'),
        base_url=os.getenv('QUUB_BASE_URL', 'https://api.quub.exchange/v1')
    )

    try:
        # Create qualified custody account for securities
        account = client.create_custody_account(
            org_id='123e4567-e89b-12d3-a456-426614174000',
            account_type='QUALIFIED_CUSTODY',
            asset_type='SECURITIES'
        )
        print(f"Created account: {account}")

        # Initiate fiat deposit
        deposit = client.initiate_deposit(
            org_id='123e4567-e89b-12d3-a456-426614174000',
            account_id=account['data']['id'],
            asset='USD',
            amount='50000.00'
        )
        print(f"Deposit initiated: {deposit}")

    except Exception as e:
        print(f"Error: {e}")
```

### Testing Strategy

```bash
# Unit tests
npm test -- --grep "custody"

# Integration tests with testnet
export QUUB_ENV=testnet
npm run test:integration

# Load testing
npm run test:load -- --endpoint=custody
```

## Error Handling

**Audience:** Technical + Project Teams

### Standard Error Response

```json
{
  "error": {
    "code": "INSUFFICIENT_BALANCE",
    "message": "Account balance insufficient for withdrawal",
    "details": {
      "accountId": "456e7890-e89b-12d3-a456-426614174001",
      "requestedAmount": "100.0",
      "availableBalance": "50.0",
      "asset": "BTC"
    },
    "timestamp": "2024-01-15T10:50:00Z",
    "requestId": "req_123456789"
  }
}
```

### Error Codes Reference

| Error Code             | HTTP Status | Description                           | Resolution                                 |
| ---------------------- | ----------- | ------------------------------------- | ------------------------------------------ |
| `INSUFFICIENT_BALANCE` | 409         | Account lacks sufficient funds        | Check balance before requesting withdrawal |
| `INVALID_DESTINATION`  | 400         | Withdrawal destination invalid        | Verify destination address format          |
| `COMPLIANCE_VIOLATION` | 403         | Transaction violates compliance rules | Review AML/KYC status                      |
| `MULTISIG_REQUIRED`    | 403         | Multi-signature approval required     | Submit for additional approvals            |
| `ACCOUNT_SUSPENDED`    | 403         | Custody account suspended             | Contact support for account status         |
| `RATE_LIMIT_EXCEEDED`  | 429         | Too many requests                     | Implement exponential backoff              |

### Error Handling Best Practices

```javascript
async function handleCustodyOperation(operation) {
  try {
    const result = await operation();

    // Log successful operations
    logger.info("Custody operation successful", {
      operationId: result.data.id,
      type: result.data.type,
    });

    return result;
  } catch (error) {
    const errorCode = error.response?.data?.error?.code;

    switch (errorCode) {
      case "INSUFFICIENT_BALANCE":
        // Handle balance issues
        await notifyUser("Insufficient funds for transaction");
        break;

      case "COMPLIANCE_VIOLATION":
        // Handle compliance issues
        await escalateToCompliance(error.response.data);
        break;

      case "MULTISIG_REQUIRED":
        // Handle approval workflow
        await initiateApprovalWorkflow(error.response.data);
        break;

      default:
        // Handle unexpected errors
        logger.error("Unexpected custody error", error);
        await notifySupport(error);
    }

    throw error;
  }
}
```

## Implementation Checklist

**Audience:** Project Teams

### Pre-Development

- [ ] Review custody regulations and compliance requirements
- [ ] Assess multi-signature and HSM infrastructure needs
- [ ] Design account segregation and isolation strategy
- [ ] Plan insurance and bonding coverage requirements
- [ ] Define operational procedures for deposits/withdrawals

### Development Phase

- [ ] Implement OAuth 2.0 and API key authentication
- [ ] Build multi-signature approval workflows
- [ ] Integrate HSM for key management and signing
- [ ] Implement real-time balance tracking and updates
- [ ] Add comprehensive audit logging for all operations
- [ ] Build proof of custody attestation generation
- [ ] Implement rate limiting and DDoS protection

### Testing Phase

- [ ] Unit test all custody account operations
- [ ] Integration test with blockchain networks
- [ ] Security testing for multi-signature workflows
- [ ] Load testing for high-volume deposit/withdrawal scenarios
- [ ] Compliance testing for AML/KYC integration
- [ ] Disaster recovery testing for cold storage failover

### Production Readiness

- [ ] Complete security audit and penetration testing
- [ ] Obtain necessary regulatory licenses and certifications
- [ ] Set up production HSM infrastructure
- [ ] Configure monitoring and alerting systems
- [ ] Establish incident response procedures
- [ ] Train operations team on custody procedures

## Monitoring & Observability

**Audience:** Technical + Project Teams

### Key Metrics

- **Account Creation Rate**: Target < 5 minutes average setup time
- **Transaction Processing**: Target < 10 minutes end-to-end processing
- **Security Incidents**: Target 0 incidents per quarter
- **Uptime SLA**: Target 99.9% API availability
- **False Positive Rate**: Target < 0.1% for compliance screening
- **Proof of Custody**: Target < 1 hour generation time

### Logging Requirements

```json
{
  "timestamp": "2024-01-15T10:45:00Z",
  "level": "INFO",
  "service": "custody-api",
  "operation": "deposit_initiated",
  "orgId": "123e4567-e89b-12d3-a456-426614174000",
  "accountId": "456e7890-e89b-12d3-a456-426614174001",
  "asset": "BTC",
  "amount": "0.5",
  "requestId": "req_123456789",
  "userAgent": "Quub-Trading-App/1.0",
  "ipAddress": "192.168.1.100"
}
```

### Alerting Configuration

```yaml
alerting:
  rules:
    - name: High-Value Transaction Alert
      condition: "custody_transaction_amount > 100000"
      severity: high
      channels: [security, compliance]

    - name: Failed Multi-Sig Alert
      condition: "multisig_approval_failures > 5"
      severity: medium
      channels: [operations]

    - name: Proof of Custody Delay
      condition: "proof_generation_time > 3600"
      severity: medium
      channels: [technical]

    - name: API Rate Limit Breach
      condition: "rate_limit_exceeded > 10"
      severity: low
      channels: [monitoring]
```

## API Versioning & Evolution

**Audience:** All

### Current Version (v2.0.0)

**Released:** January 2024

- Multi-asset custody support (crypto, securities, fiat)
- Enhanced multi-signature workflows with configurable thresholds
- Proof of custody attestations with cryptographic verification
- Real-time balance monitoring and automated reconciliation
- Advanced compliance integration with AML/KYC screening

### Planned Enhancements (v2.1)

- **Smart Contract Custody**: Direct integration with DeFi protocols
- **Cross-Chain Operations**: Atomic swaps and bridge transaction support
- **Institutional Workflows**: Advanced approval chains and delegation
- **Enhanced Reporting**: Real-time P&L and performance analytics

### Breaking Changes (v3.0 - Future)

- **Unified Account Model**: Single account type replacing current segregation
- **Enhanced Security**: Mandatory hardware security for all operations
- **API Authentication**: Migration to OAuth 2.1 with enhanced scopes
- **Deprecation Timeline**: v2.x support until December 2025

## Additional Resources

**Audience:** All

### For Stakeholders

- [Custody Service Overview](./custodian-overview.md) - Business-focused service description
- [Security Whitepaper](https://docs.quub.exchange/security/custody) - Technical security implementation details
- [Compliance Framework](https://docs.quub.exchange/compliance/custody) - Regulatory compliance documentation
- [Pricing Information](https://quub.exchange/pricing/custody) - Custody service pricing and tiers

### For Technical Teams

- [OpenAPI Specification](../openapi/custodian.yaml) - Complete API specification
- [Postman Collection](https://docs.quub.exchange/api/custodian.postman) - API testing collection
- [SDK Documentation](https://docs.quub.exchange/sdk/custodian) - Official SDKs for multiple languages
- [Integration Examples](https://github.com/quub-fi/custodian-examples) - Sample integration code

### For Project Teams

- [Architecture Diagrams](https://docs.quub.exchange/architecture/custody) - System architecture and data flows
- [Deployment Guide](https://docs.quub.exchange/deployment/custody) - Infrastructure setup and configuration
- [Troubleshooting Guide](https://docs.quub.exchange/troubleshooting/custody) - Common issues and resolutions
- [Support Portal](https://support.quub.exchange/custody) - Technical support and documentation</content>
  <parameter name="filePath">/Users/nrahal/@code_2025/products/quub/quub-exchange-docs/use-cases/custodian/custodian-api-documentation.md
