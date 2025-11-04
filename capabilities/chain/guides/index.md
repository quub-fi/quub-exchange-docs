```md
---
layout: docs
title: Chain Guides
permalink: /capabilities/chain/guides/
---

# 📚 Chain Implementation Guides

> Comprehensive developer guide for wallet management, on-chain transaction registry, and blockchain adapter lifecycle across supported L1/L2 networks.

## 🚀 Quick Navigation

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 30px 0;">

<div style="border: 2px solid #667eea; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #667eea10 0%, #764ba210 100%);">
  <h3 style="margin-top: 0; color: #667eea;">🎯 Getting Started</h3>
  <p>Start here to integrate Chain service.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#quick-start">Quick Start</a></li>
    <li><a href="#overview">API Overview & Architecture</a></li>
    <li><a href="#authentication">Authentication Setup</a></li>
  </ul>
</div>

<div style="border: 2px solid #10b981; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #10b98110 0%, #059669100%);">
  <h3 style="margin-top: 0; color: #10b981;">🧩 Core Operations</h3>
  <p>Chains, Wallets, On-chain TXs, and Adapters.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#core-operations">Endpoint Guides</a></li>
    <li><a href="#best-practices">Implementation Best Practices</a></li>
    <li><a href="#performance">Performance Optimization</a></li>
  </ul>
</div>

<div style="border: 2px solid #f59e0b; border-radius: 8px; padding: 20px; background: linear-gradient(135deg, #f59e0b10 0%, #d9770610 100%);">
  <h3 style="margin-top: 0; color: #f59e0b;">🛡️ Ops & Reliability</h3>
  <p>Security, troubleshooting, and health checks.</p>
  <ul style="margin-bottom: 0;">
    <li><a href="#security">Security Guidelines</a></li>
    <li><a href="#troubleshooting">Troubleshooting</a></li>
    <li><a href="#monitoring">Monitoring & Observability</a></li>
  </ul>
</div>

</div>

---

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- Manage blockchain network registry (L1/L2, namespaces, status).
- Register and operate organization wallets (custodial, non-custodial, MPC, hardware).
- Record and monitor on-chain transactions (multi-asset types, confirmations, fees).
- Configure chain adapters (RPC endpoints, signer policy, health, fallbacks).
- Provide cross-chain visibility with confirmations/finality and health summaries.

### Technical Architecture
```

┌──────────────────────────┐ ┌─────────────────────────────┐
│ Client / Backoffice │ HTTPS│ Chain Service │
│ • Investor Portal │──────▶│ • Chains Registry │
│ • Ops Console │ │ • Wallets │
│ │ │ • On-Chain Tx Registry │
│ │ │ • Chain Adapters (RPC) │
└──────────────────────────┘ └──────────────┬──────────────┘
│
┌───────────────▼───────────────┐
│ Org-Scoped Data Stores │
│ • Chain │
│ • Wallet │
│ • OnChainTx │
│ • ChainAdapter │
└───────────────────────────────┘

````

### Core Data Models

**Chain**
`id` (uuid), `chainId` (int), `name`, `shortName`, `networkType` (`MAINNET|TESTNET|DEVNET`), `layer` (`L1|L2`), `nativeCurrency`, `decimals` (int), `blockTime` (int), `confirmations` (int), `explorerUrl` (uri), `docsUrl` (uri), `iconUrl` (uri), `genesisHash` (0x64 hex), `chainNamespace` (`EVM|COSMOS|SOLANA|POLKADOT`), `status` (`ACTIVE|DEPRECATED|DISABLED`), `createdAt` (date-time), `updatedAt` (date-time), `deprecationReason`, `replacedBy` (int), `createdBy` (uuid), `updatedBy` (uuid).

**Wallet**
`id` (uuid), `orgId` (uuid), `ownerAccountId` (uuid), `address` (0x40 hex), `type` (`CUSTODIAL|NON_CUSTODIAL|MPC|HARDWARE`), `label`, `chainId` (int), `status` (`ACTIVE|DISABLED|ARCHIVED`), `derivationPath`, `parentWalletId` (uuid), `walletIndex` (int), `kycStatus` (`PENDING|VERIFIED|REJECTED|NOT_REQUIRED`), `jurisdiction`, `createdAt` (date-time), `updatedAt` (date-time), `source` (`MANUAL|IMPORTED|CUSTODIAL_API|MPC_CLUSTER`), `createdBy` (uuid), `updatedBy` (uuid).

**OnChainTx**
`id` (uuid), `orgId` (uuid), `chainId` (int), `hash` (0x64 hex), `fromAddress` (0x40 hex), `toAddress` (0x40 hex), `direction` (`INBOUND|OUTBOUND`), `status` (`PENDING|CONFIRMED|FAILED`), `amount` (string int), `assetType` (`NATIVE|ERC20|ERC721|ERC1155`), `tokenAddress` (0x40 hex), `tokenId` (string), `decimals` (int), `blockNumber` (int), `blockTime` (date-time), `gasUsed` (string int), `gasPrice` (string int), `txFeeAmount` (string number), `txFeeUsd` (string number), `nonce` (int), `refType` (string), `refId` (uuid), `source` (`NODE|WEBHOOK|INDEXER|MANUAL`), `syncVersion` (string), `rawTx` (object), `logs` (array), `createdAt` (date-time), `updatedAt` (date-time), `confirmations` (int), `finalized` (boolean), `fiatRateSource` (`COINGECKO|CHAINLINK|BINANCE|INTERNAL`), `fiatRateTimestamp` (date-time), `createdBy` (uuid).

**ChainAdapter**
`id` (uuid), `chainId` (int), `name`, `rpcEndpoint` (uri), `wsEndpoint` (uri), `signerPolicy` (`LOCAL_SIGNER|MPC_CLUSTER|HSM|FIREBLOCKS|CUSTODY_PROVIDER`), `priority` (int), `fallbackAdapterIds` (uuid[]), `status` (`ACTIVE|DISABLED|MAINTENANCE`), `lastHealthCheck` (date-time), `healthStatus` (`latency` int, `blockHeight` int, `synced` bool), `createdAt` (date-time), `updatedAt` (date-time), `createdBy` (uuid), `updatedBy` (uuid).

**HealthMetrics**
`status` (`HEALTHY|DEGRADED|DOWN`), `latencyMs` (int), `blockHeight` (int), `syncLag` (int), `uptime` (number), `lastChecked` (date-time).

---

## 🎯 Quick Start {#quick-start}

### Prerequisites

- Base URL: `https://api.quub.exchange/v2` (production) or `https://api.sandbox.quub.exchange/v2` (sandbox)
- Security schemes: `oauth2` scopes (`read:chain`, `write:chain`) and/or `apiKey`
- Org-scoped calls require `orgId` in path and referenced headers from `./common/components.yaml`
- Use `idempotencyKey` on POST endpoints where defined

### 5-Minute Setup

#### Node.js

```js
import axios from "axios";

const baseURL = "https://api.sandbox.quub.exchange/v2";
const client = axios.create({ baseURL });

// Example auth/header wiring (match names from ./common/components.yaml)
client.interceptors.request.use((cfg) => {
  cfg.headers = cfg.headers || {};
  // cfg.headers.Authorization = `Bearer ${process.env.ACCESS_TOKEN}`;
  // cfg.headers["X-API-Key"] = process.env.QUUB_API_KEY;
  return cfg;
});

// First call: list active mainnets
const chains = await client.get("/chains", { params: { status: "ACTIVE", networkType: "MAINNET", limit: 20 } });
console.log(chains.data);
````

#### Python

```python
import requests

base_url = "https://api.sandbox.quub.exchange/v2"
session = requests.Session()
# session.headers.update({"Authorization": f"Bearer {ACCESS_TOKEN}"})
# session.headers.update({"X-API-Key": QUUB_API_KEY})

r = session.get(f"{base_url}/chains", params={"status": "ACTIVE", "networkType": "MAINNET", "limit": 20})
print(r.json())
```

---

## 🏗️ Core API Operations {#core-operations}

### Chains

**List blockchain networks — `GET /chains`**
Filters: `networkType` (`MAINNET|TESTNET|DEVNET`), `layer` (`L1|L2`), `status` (`ACTIVE|DEPRECATED|DISABLED`), `cursor`, `limit`. Returns pagination + `data: Chain[]`.

```js
const res = await client.get("/chains", {
  params: { layer: "L1", status: "ACTIVE", limit: 50 },
});
console.log(res.data);
```

**Register a new blockchain network — `POST /chains`**
Header: `idempotencyKey`. Body: `CreateChainInput`. Returns `{ data: Chain, meta: { traceId, timestamp } }`.

```python
payload = {
  "chainId": 1,
  "name": "Ethereum Mainnet",
  "shortName": "ETH",
  "networkType": "MAINNET",
  "layer": "L1",
  "nativeCurrency": "ETH"
}
r = session.post(f"{base_url}/chains", json=payload)
print(r.status_code, r.json())
```

**Get blockchain network details — `GET /chains/{chainId}`**
Path: `chainId` (integer). Returns `{ data: Chain }`.

```js
const res = await client.get("/chains/1");
console.log(res.data);
```

**Update blockchain network — `PATCH /chains/{chainId}`**
Path: `chainId` (integer). Body: `UpdateChainInput`. Returns `{ data: Chain }`.

```python
r = session.patch(f"{base_url}/chains/1", json={"status": "ACTIVE"})
print(r.json())
```

---

### Wallets

**List organization wallets — `GET /orgs/{orgId}/wallets`**
Path: `orgId`. Optional: `chainId`, `cursor`, `limit`. Returns pagination + `data: Wallet[]`.

```js
const orgId = "11111111-1111-1111-1111-111111111111";
const res = await client.get(`/orgs/${orgId}/wallets`, {
  params: { chainId: 1, limit: 25 },
});
console.log(res.data);
```

**Register wallet for organization — `POST /orgs/{orgId}/wallets`**
Headers: `idempotencyKey`. Body: `CreateWalletInput`. Returns `{ data: Wallet }`.

```python
org_id = "11111111-1111-1111-1111-111111111111"
payload = {
  "address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
  "type": "MPC",
  "chainId": 1,
  "label": "Trading Wallet"
}
r = session.post(f"{base_url}/orgs/{org_id}/wallets", json=payload)
print(r.status_code, r.json())
```

**Get wallet details — `GET /orgs/{orgId}/wallets/{walletId}`**
Path: `walletId` (uuid). Returns `{ data: Wallet }`.

```js
const orgId = "11111111-1111-1111-1111-111111111111";
const walletId = "550e8400-e29b-41d4-a716-446655440001";
const res = await client.get(`/orgs/${orgId}/wallets/${walletId}`);
console.log(res.data);
```

**Update wallet metadata — `PATCH /orgs/{orgId}/wallets/{walletId}`**
Headers: `idempotencyKey`. Body: `UpdateWalletInput`. Returns `{ data: Wallet }`.

```python
org_id = "11111111-1111-1111-1111-111111111111"
wallet_id = "550e8400-e29b-41d4-a716-446655440001"
r = session.patch(f"{base_url}/orgs/{org_id}/wallets/{wallet_id}", json={"label": "Ops Wallet", "status": "ACTIVE"})
print(r.json())
```

---

### On-chain Transactions

**List on-chain transactions — `GET /orgs/{orgId}/onchain/txs`**
Optional filters: `chainId`, `status` (`PENDING|CONFIRMED|FAILED`), `refType`, `refId`, plus `cursor`, `limit`. Returns pagination + `data: OnChainTx[]`.

```js
const orgId = "11111111-1111-1111-1111-111111111111";
const res = await client.get(`/orgs/${orgId}/onchain/txs`, {
  params: { status: "CONFIRMED", limit: 20 },
});
console.log(res.data);
```

**Register new on-chain transaction — `POST /orgs/{orgId}/onchain/txs`**
Headers: `idempotencyKey`. Body: `CreateOnChainTxInput` (required: `chainId`, `hash`). Returns `{ data: OnChainTx }`.

```python
org_id = "11111111-1111-1111-1111-111111111111"
payload = {
  "chainId": 1,
  "hash": "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
  "fromAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
  "toAddress": "0x1234567890123456789012345678901234567890",
  "direction": "OUTBOUND",
  "assetType": "NATIVE",
  "amount": "2100000000000000"
}
r = session.post(f"{base_url}/orgs/{org_id}/onchain/txs", json=payload)
print(r.status_code, r.json())
```

---

### Chain Adapters

**List chain adapters — `GET /chain/adapters`**
Optional: `cursor`, `limit`. Returns pagination + `data: ChainAdapter[]`.

```js
const res = await client.get("/chain/adapters", { params: { limit: 50 } });
console.log(res.data);
```

**Register chain adapter — `POST /chain/adapters`**
Header: `idempotencyKey`. Body: `CreateChainAdapterInput`. Returns `{ data: ChainAdapter }`.

```python
payload = {
  "chainId": 1,
  "name": "Alchemy Primary",
  "rpcEndpoint": "https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY",
  "signerPolicy": "MPC_CLUSTER",
  "priority": 0
}
r = session.post(f"{base_url}/chain/adapters", json=payload)
print(r.status_code, r.json())
```

**Get chain adapter details — `GET /chain/adapters/{adapterId}`**
Path: `adapterId` (uuid). Returns `{ data: ChainAdapter }`.

```js
const adapterId = "550e8400-e29b-41d4-a716-446655440030";
const res = await client.get(`/chain/adapters/${adapterId}`);
console.log(res.data);
```

**Update adapter configuration — `PATCH /chain/adapters/{adapterId}`**
Body: `UpdateChainAdapterInput`. Returns `{ data: ChainAdapter }`.

```python
adapter_id = "550e8400-e29b-41d4-a716-446655440030"
r = session.patch(f"{base_url}/chain/adapters/{adapter_id}", json={"status": "ACTIVE", "priority": 0})
print(r.json())
```

**Check adapter health status — `GET /chain/adapters/{adapterId}/health`**
Returns `{ data: HealthMetrics, meta: { traceId, timestamp } }`.

```js
const adapterId = "550e8400-e29b-41d4-a716-446655440030";
const res = await client.get(`/chain/adapters/${adapterId}/health`);
console.log(res.data);
```

**Overall chain service health — `GET /chain/health`**
Returns `{ data: { status, adaptersHealthy, adaptersDegraded, adaptersDown, chains[], timestamp } }`.

```python
r = session.get(f"{base_url}/chain/health")
print(r.json())
```

---

## 🔐 Authentication Setup {#authentication}

Supported security schemes:

- `oauth2` (scopes include: `read:chain`, `write:chain`, `chain.audit`, `wallet.read`, `wallet.write`)
- `apiKey`
- `bearerAuth` (defined in components)

Example header wiring (match exact names from `./common/components.yaml`):

```js
client.interceptors.request.use((cfg) => {
  cfg.headers = cfg.headers || {};
  // cfg.headers.Authorization = `Bearer ${process.env.ACCESS_TOKEN}`; // oauth2/bearer
  // cfg.headers["X-API-Key"] = process.env.QUUB_API_KEY;             // apiKey header name may differ per common/components.yaml
  return cfg;
});
```

---

## ✨ Best Practices {#best-practices}

- Use `idempotencyKey` on POST to `chains`, `wallets`, `onchain/txs`, and `chain/adapters` to prevent duplicate creation.
- Filter with documented query params (`status`, `networkType`, `layer`, `chainId`, etc.) and paginate via `cursor`/`limit`.
- For amounts and gas fields in `OnChainTx`, pass values as **stringified integers** or **stringified decimals** exactly per schema.
- Respect enums (`status`, `type`, `assetType`, `signerPolicy`) and formats (uuid, date-time, uri, hex patterns).

---

## 🔒 Security Guidelines {#security}

- Scope tokens appropriately: `read:chain` for reads, `write:chain` for mutations.
- Restrict wallet operations to the correct `orgId` path and include required organization headers when applicable.
- Do not include properties not defined in schemas; validation will fail.
- Store RPC endpoints and keys securely when creating/updating `ChainAdapter`.

---

## 🚀 Performance Optimization {#performance}

- Prefer bulk listing with `limit` and iterate with `cursor` for large datasets.
- Narrow results with filters (`status`, `chainId`, `refType`, `refId`) to minimize payload sizes.
- Use adapter `priority` and `fallbackAdapterIds` to build resilient RPC routing on your side.

---

## 🔧 Advanced Configuration {#advanced}

- Use `signerPolicy` to align with your signing infrastructure (`MPC_CLUSTER`, `HSM`, `FIREBLOCKS`, etc.).
- Employ `replacedBy` and `status: DEPRECATED` on `Chain` to manage network migrations.
- Track `syncVersion` on `OnChainTx` for reconciliation workflows between indexers and internal ledgers.

---

## 🔍 Troubleshooting {#troubleshooting}

- **400/422**: Check enum values, hex/uuid patterns, and required fields. Ensure `CreateOnChainTxInput` includes `chainId` and `hash`.
- **401/403**: Verify token validity and scopes or API key presence.
- **404**: Confirm resource IDs (`chainId`, `walletId`, `adapterId`) are correct and belong to the target org where applicable.
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

```

```
