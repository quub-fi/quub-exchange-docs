---
layout: docs
permalink: /capabilities/chain/chain-api-documentation/
---

# Blockchain Integration API Documentation

_Based on OpenAPI specification: `chain.yaml`_

## 📋 Executive Summary

> **Audience: Stakeholders**

The Blockchain Integration service provides comprehensive connectivity to multiple blockchain networks, enabling secure smart contract deployment, cross-chain asset transfers, and decentralized finance (DeFi) protocol integration. This service ensures seamless interoperability between traditional financial operations and blockchain-based assets, supporting multi-chain strategies and advanced DeFi yield optimization while maintaining institutional-grade security and compliance standards.

## 🎯 Service Overview

> **Audience: All**

### Business Purpose

- Multi-blockchain connectivity for diverse asset support and liquidity access
- Smart contract deployment and management for automated financial operations
- Cross-chain bridge operations for seamless asset transfers between networks
- DeFi protocol integration for yield optimization and liquidity provision
- Real-time blockchain monitoring and transaction status tracking

### Technical Architecture

- Multi-chain RPC node management with automatic failover capabilities
- Smart contract factory patterns for standardized deployments
- Cross-chain bridge integration with atomic swap capabilities
- Event-driven blockchain monitoring with real-time notifications
- Hardware security module (HSM) integration for private key management

## 📊 API Specifications

> **Audience: Technical**

### Base Configuration

servers:

- url: https://api.quub.fi/v1/chain
  description: Production environment
- url: https://sandbox-api.quub.fi/v1/chain
  description: Sandbox environment

security:

- BearerAuth: []

# Authentication & Authorization (Chain Service)

- JWT token with `chain:read` and `chain:write` scopes required
- Organization-scoped access with `orgId` validation for wallet operations
- Role-based permissions for smart contract deployment & management
- Hardware wallet integration for high-value transaction signing

---

## 🚀 Core Endpoints

**Audience:** Technical + Project Teams

### Network Management

#### Get Supported Networks

**Business Use Case:** Retrieve list of supported blockchain networks and their status

**Response Example:**

```json
{
  "networks": ["ethereum", "polygon", "arbitrum"],
  "status": "available"
}
```

#### Get Network Status

**Business Use Case:** Monitor blockchain network health/performance

**Response Example:**

```json
{
  "chainId": "ethereum",
  "blockHeight": 20719232,
  "gasPrice": "21 gwei"
}
```

---


{% include api-nav-banner.html %}

### Wallet Operations

#### Create Wallet

**Business Use Case:** Generate new blockchain wallets for custody & transaction management

**Request Example:**

```json
{
  "accountId": "user-123"
}
```

**Response Example:**

```json
{
  "walletId": "wal_01",
  "address": "0xabc...def"
}
```

**Project Implementation Notes**

- implement secure key generation (HSM / secure enclave)
- store **addresses only**, never private keys
- validate signer permissions
- support wallet recovery & backup strategy

#### Get Wallet Balance

**Business Use Case:** Monitor wallet asset balances across tokens/networks

**Response Example:**

```json
{
  "address": "0xabc...def",
  "balances": [
    { "symbol": "ETH", "amount": "1.234" },
    { "symbol": "USDC", "amount": "200.00" }
  ]
}
```

---

### Transaction Management

#### Send Transaction

**Business Use Case:** Execute blockchain transactions

**Request Example:**

```json
{
  "to": "0x111...222",
  "value": "0.05",
  "asset": "ETH"
}
```

**Response Example:**

```json
{
  "txHash": "0x9f...b1",
  "status": "PENDING"
}
```

#### Get Transaction Status

**Business Use Case:** Track transaction confirmations

---

### Smart Contract Operations

#### Deploy Contract

**Business Use Case:** Deploy smart contracts for exchange, escrow, DeFi ops

#### Call Contract Function

**Business Use Case:** Interact with deployed smart contracts

---

### DeFi Integration

#### Get DeFi Protocols

**Business Use Case:** discover yield sources / liquidity protocols

#### Execute DeFi Operation

**Business Use Case:** execute yield operations or liquidity management

---

## 🔐 Security Implementation

**Audience:** Technical + Project Teams

### Multi-tenant Isolation

### Private Key Management

- HSM-backed key generation & storage
- multi-sig wallet support (configurable thresholds)
- BIP32/BIP44 deterministic key derivation
- secure encrypted backup & recovery

### Transaction Security

---

## 📈 Business Workflows

**Audience:** Stakeholders + Project Teams

### Primary Workflow: Cross-Chain Asset Transfer

**Value:** liquidity mobility across networks
**Success Metrics:** <5 min transfer completion, 99.99% success rate

### Secondary Workflow: DeFi Yield Optimization

**Value:** maximize idle asset yield
**Success Metrics:** >5% annual improvement, automated rebalancing

---

## 🧪 Integration Guide

**Audience:** Project Teams

- Development Setup
- Code Examples (JS/Python)
- Testing Strategy

---

## 📊 Error Handling

**Audience:** Technical + Project Teams

| Code                  | HTTP Status | Description                       | Action                     |
| --------------------- | ----------: | --------------------------------- | -------------------------- |
| UNAUTHORIZED          |         401 | Invalid/missing JWT               | Check authentication       |
| INSUFFICIENT_BALANCE  |         400 | Wallet balance too low            | Add funds or reduce amount |
| INVALID_ADDRESS       |         400 | Invalid blockchain address format | Validate address           |
| NETWORK_UNAVAILABLE   |         503 | Blockchain network unavailable    | Retry / switch network     |
| GAS_ESTIMATION_FAILED |         400 | Gas estimation failed             | Check contract interaction |
| TRANSACTION_FAILED    |         400 | On-chain execution failed         | Review parameters          |
| CONTRACT_NOT_FOUND    |         404 | Smart contract not deployed       | Verify contract            |
| SLIPPAGE_EXCEEDED     |         400 | DeFi slippage threshold exceeded  | Adjust tolerance           |

---

## 📋 Implementation Checklist

**Audience:** Project Teams

### Pre-Development

- blockchain RPC endpoints configured
- HSM / secure key management in place
- multi-sig requirements defined
- DeFi integration requirements documented
- security audit procedure agreed

### Development Phase

- multi-network wallet mgmt
- tx signing & broadcasting
- smart contract deployment + interaction
- DeFi protocol integration
- event monitoring & tx status tracking
- gas price estimation strategy

### Testing Phase

- unit tests (blockchain ops)
- integration tests (testnet)
- secure key mgmt tests
- performance tests
- cross-chain bridge tests
- DeFi interaction tests

### Production Readiness

- prod node endpoints configured
- HSM fully validated
- multi-sig procedures tested
- monitoring + alerts configured
- incident response documented
- wallet backup + recovery validated

---

## 📈 Monitoring & Observability

Key Metrics

- tx success rate (>99.5%)
- avg confirmation time per network
- gas optimization efficiency
- DeFi yield performance
- cross-chain bridge success rate

---

## 🔄 API Versioning & Evolution

Current Version: **v1**

- Multi-chain: Ethereum, Polygon, Arbitrum
- Smart contract ops
- DeFi integration
- cross-chain transfers

Planned Enhancements (v1.1)

- Solana, Avalanche
- advanced DeFi strategies
- NFT marketplace support
- L2 scaling optimization

Breaking Changes (v2.0 - Future)

- advanced multi-sig policy engine
- account abstraction (gasless tx)
- zero-knowledge privacy
- institutional custody integrations

---

_Last updated: November 2, 2025 • API Version: v1 • Document Version: 1.0_

```

```
