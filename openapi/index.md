---
layout: default
title: OpenAPI Specifications
---

# OpenAPI Specifications

This directory contains the OpenAPI 3.0 specifications for all Quub Exchange services.

## Core Services

### Authentication & Identity

- [**auth.yaml**](./auth.yaml) - Authentication and authorization service
- [**identity.yaml**](./identity.yaml) - Identity management and KYC/KYB

### Trading & Exchange

- [**exchange.yaml**](./exchange.yaml) - Core exchange operations (orders, trades, positions)
- [**marketplace.yaml**](./marketplace.yaml) - Secondary market trading
- [**primary-market.yaml**](./primary-market.yaml) - Primary market issuance

### Asset Management

- [**custodian.yaml**](./custodian.yaml) - Digital asset custody
- [**treasury.yaml**](./treasury.yaml) - Treasury and liquidity management
- [**transfer-agent.yaml**](./transfer-agent.yaml) - Transfer agent services

### Banking & Settlements

- [**fiat-banking.yaml**](./fiat-banking.yaml) - Fiat banking integration
- [**settlements.yaml**](./settlements.yaml) - Settlement processing
- [**escrow.yaml**](./escrow.yaml) - Escrow management

### Blockchain Integration

- [**chain.yaml**](./chain.yaml) - Blockchain integration services
- [**gateway.yaml**](./gateway.yaml) - API gateway and routing

### Risk & Compliance

- [**compliance.yaml**](./compliance.yaml) - Compliance and regulatory reporting
- [**risk-limits.yaml**](./risk-limits.yaml) - Risk management and limits

### Financial Operations

- [**fees-billing.yaml**](./fees-billing.yaml) - Fee calculation and billing
- [**pricing-refdata.yaml**](./pricing-refdata.yaml) - Pricing and reference data
- [**market-oracles.yaml**](./market-oracles.yaml) - Market data oracles

### Governance & Documents

- [**governance.yaml**](./governance.yaml) - Governance and voting
- [**documents.yaml**](./documents.yaml) - Document management

### Platform Services

- [**tenancy-trust.yaml**](./tenancy-trust.yaml) - Multi-tenancy and trust framework
- [**events.yaml**](./events.yaml) - Event sourcing and management
- [**notifications.yaml**](./notifications.yaml) - Notification services
- [**observability.yaml**](./observability.yaml) - Monitoring and observability
- [**analytics-reports.yaml**](./analytics-reports.yaml) - Analytics and reporting
- [**sandbox.yaml**](./sandbox.yaml) - Sandbox environment

## Asynchronous APIs

- [**async/realtime.asyncapi.yaml**](./async/realtime.asyncapi.yaml) - Real-time event streaming (AsyncAPI)

## Common Components

- [**common/components.yaml**](./common/components.yaml) - Shared components and schemas
- [**common/domain-models.yaml**](./common/domain-models.yaml) - Domain models
- [**common/errors.yaml**](./common/errors.yaml) - Error definitions
- [**common/pagination.yaml**](./common/pagination.yaml) - Pagination schemas
- [**common/primitives.yaml**](./common/primitives.yaml) - Primitive types
- [**common/responses.yaml**](./common/responses.yaml) - Standard responses

---

## Usage

### View in Swagger Editor

To view any specification in Swagger Editor:

```bash
# Copy the raw GitHub URL
https://raw.githubusercontent.com/quub-fi/quub-exchange-docs/main/openapi/[service-name].yaml

# Paste into: https://editor.swagger.io/
```

### Download All Specifications

```bash
git clone https://github.com/quub-fi/quub-exchange-docs.git
cd quub-exchange-docs/openapi
```

### Validate Specifications

```bash
# Using OpenAPI CLI
openapi-cli validate *.yaml

# Using Spectral
spectral lint *.yaml
```

---

[← Back to Documentation Home](../)
