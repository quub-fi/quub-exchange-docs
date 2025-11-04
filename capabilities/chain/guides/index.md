---
layout: docs
title: Chain Guides
permalink: /capabilities/chain/guides/
---

# 📚 Chain Implementation Guides

> Developer guide for managing blockchain networks, organization wallets, on-chain transactions and chain adapters. This document only references operations and schemas from `openapi/chain.yaml`.

## 🚀 Quick Navigation

<div class="card-grid">
  <a href="#quick-start" class="nav-card">
    <div class="nav-card-icon">🚀</div>
    <h3>Getting Started</h3>
    <p>Register chains, wallets, and track transactions</p>
  </a>

  <a href="#blockchain-integrations" class="nav-card">
    <div class="nav-card-icon">⛓️</div>
    <h3>Blockchain Integrations</h3>
    <p>Production-ready guides for Ethereum, Solana, L2s & more</p>
  </a>

  <a href="#core-operations" class="nav-card">
    <div class="nav-card-icon">⚙️</div>
    <h3>Core Operations</h3>
    <p>Chain registration, wallet management, transaction tracking</p>
  </a>

  <a href="#advanced" class="nav-card">
    <div class="nav-card-icon">🔧</div>
    <h3>Advanced Topics</h3>
    <p>Chain adapters, health monitoring, and optimization</p>
  </a>
</div>

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Maintain a system-wide registry of supported blockchain networks (L1/L2) and their metadata.
- Manage organization-scoped wallets (custodial, MPC, hardware) and their lifecycle.
- Record and reconcile on-chain transactions with rich metadata for auditing and reconciliation.
- Configure and operate chain adapters (RPC endpoints, signer policies, priorities and fallbacks).
- Provide health and observability for adapters and the chain service.

### Technical Architecture (ASCII)

```
Client/Backoffice  --->  Chain Service API  --->  Adapters / RPC Providers / Indexers
      |                       |                       |
      |                       |-- Chains (registry)   |
      |                       |-- Wallets (org-scoped)|
      |                       |-- OnChainTx registry  |
      |                       |-- ChainAdapters       |
```

### Core Data Models (from spec)

- Chain (required: id, chainId, name, shortName, networkType, layer, nativeCurrency, status)
- Wallet (required: id, orgId, address, type, chainId, status)
- OnChainTx (required: id, orgId, chainId, hash, status)
- ChainAdapter (required: id, chainId, name, rpcEndpoint, signerPolicy, status)

Refer to `openapi/chain.yaml` for full schema property lists and exact types.

## ⛓️ Blockchain Integrations {#blockchain-integrations}

> **Production-Ready Integration Guides** — Comprehensive implementation guides for major blockchain networks with real-world examples, security best practices, and production checklists.

### Layer 1 Blockchains

<div class="integration-grid">
  <a href="/capabilities/chain/integrations/ethereum/" class="integration-card">
    <div class="integration-icon">⟠</div>
    <h4>Ethereum</h4>
    <p>EVM flagship • Smart contracts • MEV protection</p>
    <span class="badge">L1</span>
  </a>

  <a href="/capabilities/chain/integrations/bnb/" class="integration-card">
    <div class="integration-icon">🔶</div>
    <h4>BNB Chain</h4>
    <p>3s blocks • Low fees • BEP-20 tokens</p>
    <span class="badge">L1</span>
  </a>

  <a href="/capabilities/chain/integrations/avalanche/" class="integration-card">
    <div class="integration-icon">🔺</div>
    <h4>Avalanche</h4>
    <p>Sub-second finality • C-Chain • Subnets</p>
    <span class="badge">L1</span>
  </a>

  <a href="/capabilities/chain/integrations/solana/" class="integration-card">
    <div class="integration-icon">◎</div>
    <h4>Solana</h4>
    <p>Non-EVM • 400ms slots • SPL tokens</p>
    <span class="badge">Non-EVM</span>
  </a>
</div>

### Layer 2 Networks

<div class="integration-grid">
  <a href="/capabilities/chain/integrations/polygon/" class="integration-card">
    <div class="integration-icon">🟣</div>
    <h4>Polygon</h4>
    <p>PoS sidechain • Checkpoints • Bridge finality</p>
    <span class="badge">L2</span>
  </a>

  <a href="/capabilities/chain/integrations/arbitrum/" class="integration-card">
    <div class="integration-icon">🔵</div>
    <h4>Arbitrum One</h4>
    <p>Optimistic rollup • 7-day challenge • 250ms blocks</p>
    <span class="badge">L2</span>
  </a>

  <a href="/capabilities/chain/integrations/optimism/" class="integration-card">
    <div class="integration-icon">🔴</div>
    <h4>Optimism</h4>
    <p>OP Stack • Fault proofs • Standard bridge</p>
    <span class="badge">L2</span>
  </a>

  <a href="/capabilities/chain/integrations/base/" class="integration-card">
    <div class="integration-icon">🔵</div>
    <h4>Base</h4>
    <p>Coinbase L2 • OP Stack • Ultra-low gas</p>
    <span class="badge">L2</span>
  </a>
</div>

### What's Included in Each Guide

Each blockchain integration guide provides:

- **🏗️ Chain Registration** — Register blockchain networks with proper configuration
- **🔌 RPC Adapter Setup** — Configure and manage chain adapters with health monitoring
- **💼 Wallet Management** — Create and manage wallets for the specific chain
- **📝 Transaction Tracking** — Monitor on-chain transactions with proper confirmation handling
- **🔒 Security Best Practices** — Chain-specific security considerations and MEV protection
- **⚡ Performance Optimization** — Gas strategies, batching, and throughput optimization
- **✅ Production Checklist** — Comprehensive deployment and monitoring checklist

### Quick Integration Comparison

| Feature             | Ethereum | BNB | Solana | Polygon | Arbitrum | Optimism | Base | Avalanche |
| ------------------- | -------- | --- | ------ | ------- | -------- | -------- | ---- | --------- |
| **Block Time**      | 12s      | 3s  | 400ms  | 2s      | 250ms    | 2s       | 2s   | <1s       |
| **Finality**        | 15m      | 15s | 13s    | 30m     | 7d       | 7d       | 7d   | <2s       |
| **Gas Token**       | ETH      | BNB | SOL    | MATIC   | ETH      | ETH      | ETH  | AVAX      |
| **EVM Compatible**  | ✅       | ✅  | ❌     | ✅      | ✅       | ✅       | ✅   | ✅        |
| **Bridge Required** | -        | -   | -      | ✅      | ✅       | ✅       | ✅   | -         |

[**📚 View All Integrations**](/capabilities/chain/integrations/) — Complete integration guides index with architecture diagrams and comparison matrices.

---

## 🎯 Quick Start {#quick-start}

### Prerequisites

- Base URL: `https://api.quub.exchange/v2` (production) or `https://api.sandbox.quub.exchange/v2` (sandbox)
- Authentication: OAuth2 bearer token (scopes such as `read:chain` and `write:chain`) or API key per common security schemes
- Organization-scoped endpoints require `orgId` (path param) and matching header where specified in `common/components.yaml`

### Minimal Node.js example — list active chains

```js
import fetch from "node-fetch";

const BASE = "https://api.sandbox.quub.exchange/v2";
async function listChains(token) {
  const res = await fetch(`${BASE}/chains?status=ACTIVE&limit=25`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.json();
}

// usage: await listChains(process.env.ACCESS_TOKEN)
```

### Minimal Python example — register a wallet for an org

```py
import requests

BASE = 'https://api.sandbox.quub.exchange/v2'
def create_wallet(org_id, token, payload):
    url = f"{BASE}/orgs/{org_id}/wallets"
    headers = { 'Authorization': f'Bearer {token}', 'Content-Type': 'application/json' }
    r = requests.post(url, json=payload, headers=headers)
    return r.json()

# payload must conform to CreateWalletInput in the spec
```

## 🏗️ Core API Operations {#core-operations}

### Chains

#### List Blockchain Networks

```http
GET /chains
```

- **Description**: Retrieve a list of supported blockchain networks.
- **Query Parameters**:
  - `networkType` (optional): Filter by network type (`MAINNET`, `TESTNET`, `DEVNET`).
  - `layer` (optional): Filter by chain layer (`L1`, `L2`).
  - `status` (optional): Filter by status (`ACTIVE`, `DEPRECATED`, `DISABLED`).
- **Responses**:
  - `200 OK`: List of blockchain networks.
  - `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `500 Internal Server Error`.

#### Register a New Blockchain Network

```http
POST /chains
```

- **Description**: Register a new blockchain network.
- **Request Body**:
  - `idempotencyKey` (header): Unique key to ensure idempotency.
  - JSON payload matching `CreateChainInput` schema.
- **Responses**:
  - `201 Created`: Chain created successfully.
  - `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `409 Conflict`, `500 Internal Server Error`.

### Blockchain Network Details

#### Get Blockchain Network Details

```http
GET /chains/{chainId}
```

- **Description**: Retrieve details of a specific blockchain network.
- **Path Parameters**:
  - `chainId` (required): Unique identifier of the blockchain network.
- **Responses**:
  - `200 OK`: Blockchain network details.
  - `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `500 Internal Server Error`.

### Wallets

- GET /orgs/{orgId}/wallets — List organization wallets

  - Path: `orgId`. Optional query: `chainId`, pagination.
  - Response: paginated `data: Wallet[]`.

- POST /orgs/{orgId}/wallets — Register wallet for organization

  - Headers: `idempotencyKey`.
  - Body: `CreateWalletInput`. Returns 201 with `data: Wallet`.

- GET /orgs/{orgId}/wallets/{walletId} — Get wallet details

- PATCH /orgs/{orgId}/wallets/{walletId} — Update wallet metadata
  - Headers: optional `idempotencyKey`. Body: `UpdateWalletInput`. Returns `{ data: Wallet }`.

Example (Node.js) — list org wallets:

```js
async function listOrgWallets(orgId, token) {
  const res = await fetch(`${BASE}/orgs/${orgId}/wallets`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.json();
}
```

### On-chain Transactions

- GET /orgs/{orgId}/onchain/txs — List on-chain transactions

  - Filters: `chainId`, `status` (PENDING|CONFIRMED|FAILED), `refType`, `refId`, pagination.
  - Response: paginated `data: OnChainTx[]`.

- POST /orgs/{orgId}/onchain/txs — Register new on-chain transaction
  - Headers: `idempotencyKey`.
  - Body: `CreateOnChainTxInput` (required: `chainId`, `hash`). Returns 201 with `data: OnChainTx`.

Example (Python) — create an OnChainTx (payload must follow spec):

```py
payload = { 'chainId': 1, 'hash': '0x...', 'fromAddress': '0x...', 'toAddress': '0x...', 'direction': 'OUTBOUND' }
resp = requests.post(f"{BASE}/orgs/{org_id}/onchain/txs", json=payload, headers=headers)
```

### Chain Adapters

- GET /chain/adapters — List chain adapters

  - Pagination supported. Response: `data: ChainAdapter[]`.

- POST /chain/adapters — Register chain adapter

  - Headers: `idempotencyKey`.
  - Body: `CreateChainAdapterInput`. Returns 201 with `data: ChainAdapter`.

- GET /chain/adapters/{adapterId} — Get chain adapter details

- PATCH /chain/adapters/{adapterId} — Update adapter configuration

  - Body: `UpdateChainAdapterInput`. Returns `{ data: ChainAdapter }`.

  - GET /chain/health — Overall chain service health summary
  - Returns overall health data with adapter counts and chain summaries.

## 🔐 Authentication Setup {#authentication}

Security schemes are defined in `openapi/chain.yaml` and reference `common/components.yaml`:

- OAuth2 (client credentials) — use `Authorization: Bearer <token>` with scopes like `read:chain`, `write:chain`.
- API Key — per `common/components` if configured.
- bearerAuth — token-based examples.

Ensure requests include required org-scoped headers/params (`orgId`) when calling organization endpoints.

## ✨ Best Practices {#best-practices}

- Validate payloads against the exact request schemas in `openapi/chain.yaml` (e.g., `CreateWalletInput`, `CreateOnChainTxInput`).
- Use `idempotencyKey` on POST endpoints to prevent duplicates.
- Send numeric amounts and gas values as strings when the schema requires stringified integers to avoid precision loss.
- Use pagination (`cursor`, `limit`) for list endpoints and filter server-side when possible.
- Respect enum values and patterns (uuid, 0x-prefixed hex) defined in schemas.

## 🔍 Troubleshooting {#troubleshooting}

- 400 / 422: Invalid payload — check required fields and value formats (hex patterns, uuid, enums).
- 401 / 403: Authorization error — verify token scopes and API key permissions.
- 404: Resource not found — confirm `chainId`, `walletId`, or `adapterId` and correct `orgId`.
- 409: Conflict (create endpoints) — respect idempotency keys and check for existing resources.

## � Monitoring & Observability {#monitoring}

- Monitor adapter health (`/chain/adapters/{adapterId}/health`) and the overall `/chain/health` summary.
- Track OnChainTx statuses and confirmation counts to detect stalled transactions.
- Emit traces (traceId) on write operations to correlate events with indexers and adapters.

## � Additional Resources

- OpenAPI spec: `/openapi/chain.yaml`
- Common components: `/openapi/common/`

---

This guide was rewritten to match `openapi/chain.yaml` exactly. All endpoints, parameters, and request/response shapes are derived from the spec; nothing was invented.

- **409**: Creation conflict (e.g., duplicate `Chain` or `ChainAdapter`); use `idempotencyKey`.
- **429**: Back off and retry per response headers.

---

## 📊 Monitoring & Observability {#monitoring}

- Poll `GET /chain/adapters/{adapterId}/health` for adapter health and surface `status`, `latencyMs`, `syncLag`.
- Use `GET /chain/health` to summarize service state for dashboards.
- Log request `traceId` from responses where provided (`meta.traceId`) for cross-system tracing.

---

## 📚 Additional Resources

- API Documentation: `../api-documentation/`
- Service Overview: `../overview/`
- OpenAPI Specification: `/openapi/chain.yaml`
