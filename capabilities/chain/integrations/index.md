---
layout: docs
title: Blockchain Integrations
permalink: /capabilities/chain/integrations/
---

# ⛓️ Blockchain Integration Guides

> Production-ready implementation guides for integrating major blockchain networks with the Quub Exchange Chain API. Each guide provides comprehensive coverage of chain registration, RPC adapter setup, wallet management, transaction tracking, security best practices, and production deployment checklists.

## 🎯 Quick Navigation

<div class="card-grid">
  <a href="#layer-1" class="nav-card">
    <div class="nav-card-icon">1️⃣</div>
    <h3>Layer 1 Blockchains</h3>
    <p>Ethereum, BNB Chain, Avalanche, Solana</p>
  </a>

  <a href="#layer-2" class="nav-card">
    <div class="nav-card-icon">2️⃣</div>
    <h3>Layer 2 Networks</h3>
    <p>Polygon, Arbitrum, Optimism, Base</p>
  </a>

  <a href="#comparison" class="nav-card">
    <div class="nav-card-icon">📊</div>
    <h3>Network Comparison</h3>
    <p>Performance metrics and feature matrix</p>
  </a>

  <a href="#architecture" class="nav-card">
    <div class="nav-card-icon">🏗️</div>
    <h3>Integration Architecture</h3>
    <p>Common patterns and best practices</p>
  </a>
</div>

---

## 🌐 Layer 1 Blockchains {#layer-1}

### Ethereum — The EVM Foundation

<div class="integration-hero">
  <div class="integration-icon-large">⟠</div>
  <div class="integration-details">
    <h4>Ethereum Integration Guide</h4>
    <p><strong>Most mature smart contract platform with robust tooling and ecosystem</strong></p>
    <ul>
      <li>✅ 12-second block times with ~15 minute finality</li>
      <li>✅ EIP-1559 dynamic gas pricing with priority fees</li>
      <li>✅ MEV protection strategies (private mempools, Flashbots)</li>
      <li>✅ Comprehensive ERC standards (20, 721, 1155, 4337)</li>
      <li>✅ Account abstraction and smart contract wallets</li>
    </ul>
    <a href="/capabilities/chain/integrations/ethereum/" class="btn-primary">View Ethereum Guide →</a>
  </div>
</div>

**Best For:** DeFi protocols, NFT platforms, high-value transactions, complex smart contracts

---

### BNB Chain — High Throughput, Low Cost

<div class="integration-hero">
  <div class="integration-icon-large">🔶</div>
  <div class="integration-details">
    <h4>BNB Chain Integration Guide</h4>
    <p><strong>EVM-compatible chain optimized for fast, low-cost transactions</strong></p>
    <ul>
      <li>✅ 3-second block times with ~15 second finality</li>
      <li>✅ Ultra-low gas fees (typically <$0.10 per transaction)</li>
      <li>✅ BEP-20 token standard (ERC-20 compatible)</li>
      <li>✅ High throughput for retail and gaming applications</li>
      <li>✅ Proof of Staked Authority (PoSA) consensus</li>
    </ul>
    <a href="/capabilities/chain/integrations/bnb/" class="btn-primary">View BNB Guide →</a>
  </div>
</div>

**Best For:** Gaming, retail payments, high-frequency trading, token launches

---

### Avalanche — Sub-Second Finality

<div class="integration-hero">
  <div class="integration-icon-large">🔺</div>
  <div class="integration-details">
    <h4>Avalanche Integration Guide</h4>
    <p><strong>High-performance platform with near-instant finality and subnet architecture</strong></p>
    <ul>
      <li>✅ Sub-second block times with <2 second finality</li>
      <li>✅ C-Chain (EVM-compatible) for smart contracts</li>
      <li>✅ Dynamic fee adjustment based on network load</li>
      <li>✅ Subnet support for custom blockchain instances</li>
      <li>✅ Native cross-chain messaging</li>
    </ul>
    <a href="/capabilities/chain/integrations/avalanche/" class="btn-primary">View Avalanche Guide →</a>
  </div>
</div>

**Best For:** Real-time applications, institutional DeFi, custom subnets, low-latency trading

---

### Solana — Non-EVM High Performance

<div class="integration-hero">
  <div class="integration-icon-large">◎</div>
  <div class="integration-details">
    <h4>Solana Integration Guide</h4>
    <p><strong>Ultra-fast non-EVM blockchain with unique architecture and SPL token standard</strong></p>
    <ul>
      <li>✅ 400ms slot times with 12.8s finality (67 slots)</li>
      <li>✅ Base58 signatures and account-based architecture</li>
      <li>✅ SPL token standard (distinct from ERC-20)</li>
      <li>✅ Commitment levels (processed, confirmed, finalized)</li>
      <li>✅ Ultra-low transaction costs ($0.00025 per tx)</li>
    </ul>
    <a href="/capabilities/chain/integrations/solana/" class="btn-primary">View Solana Guide →</a>
  </div>
</div>

**Best For:** High-frequency trading, on-chain order books, NFT minting, payment processing

---

## 🔗 Layer 2 Networks {#layer-2}

### Polygon — Mature PoS Sidechain

<div class="integration-hero">
  <div class="integration-icon-large">🟣</div>
  <div class="integration-details">
    <h4>Polygon Integration Guide</h4>
    <p><strong>Established PoS sidechain with Ethereum bridging and checkpoint finality</strong></p>
    <ul>
      <li>✅ 2-second block times with ~30 minute checkpoint finality</li>
      <li>✅ Native Ethereum bridge with security guarantees</li>
      <li>✅ Tiered confirmation strategy (probabilistic → checkpointed)</li>
      <li>✅ Very low gas fees (~$0.01 per transaction)</li>
      <li>✅ zkEVM rollup option for enhanced security</li>
    </ul>
    <a href="/capabilities/chain/integrations/polygon/" class="btn-primary">View Polygon Guide →</a>
  </div>
</div>

**Best For:** NFT marketplaces, gaming, enterprise applications, Ethereum scaling

---

### Arbitrum One — Leading Optimistic Rollup

<div class="integration-hero">
  <div class="integration-icon-large">🔵</div>
  <div class="integration-details">
    <h4>Arbitrum Integration Guide</h4>
    <p><strong>Most adopted optimistic rollup with full EVM equivalence</strong></p>
    <ul>
      <li>✅ 250ms block times with 7-day challenge period</li>
      <li>✅ Full EVM compatibility with fraud proofs</li>
      <li>✅ Standard bridge operations (deposit/withdraw)</li>
      <li>✅ Nitro upgrade for improved performance</li>
      <li>✅ Low L2 gas fees, batched L1 settlement</li>
    </ul>
    <a href="/capabilities/chain/integrations/arbitrum/" class="btn-primary">View Arbitrum Guide →</a>
  </div>
</div>

**Best For:** DeFi protocols, complex dApps, Ethereum L2 scaling with security priority

---

### Optimism — OP Stack Foundation

<div class="integration-hero">
  <div class="integration-icon-large">🔴</div>
  <div class="integration-details">
    <h4>Optimism Integration Guide</h4>
    <p><strong>Modular OP Stack rollup with governance token and public goods funding</strong></p>
    <ul>
      <li>✅ 2-second block times with 7-day challenge period</li>
      <li>✅ Standard Bridge and fault proof system</li>
      <li>✅ OP Stack modularity for custom chains</li>
      <li>✅ Batch submission for cost efficiency</li>
      <li>✅ Bedrock upgrade for improved performance</li>
    </ul>
    <a href="/capabilities/chain/integrations/optimism/" class="btn-primary">View Optimism Guide →</a>
  </div>
</div>

**Best For:** Superchain ecosystem, custom OP Stack rollups, DeFi and governance applications

---

### Base — Coinbase L2

<div class="integration-hero">
  <div class="integration-icon-large">🔵</div>
  <div class="integration-details">
    <h4>Base Integration Guide</h4>
    <p><strong>Coinbase-backed OP Stack L2 with seamless onramp integration</strong></p>
    <ul>
      <li>✅ 2-second block times with OP Stack architecture</li>
      <li>✅ Ultra-low gas fees and high throughput</li>
      <li>✅ Native Coinbase integration for fiat onramps</li>
      <li>✅ Standard Bridge compatibility with Optimism</li>
      <li>✅ Growing ecosystem with retail focus</li>
    </ul>
    <a href="/capabilities/chain/integrations/base/" class="btn-primary">View Base Guide →</a>
  </div>
</div>

**Best For:** Consumer applications, social platforms, onchain products with fiat connectivity

---

## 📊 Network Comparison Matrix {#comparison}

### Performance Metrics

| Blockchain    | Type | Block Time | Finality  | Gas Token | Avg Gas Cost | TPS    |
| ------------- | ---- | ---------- | --------- | --------- | ------------ | ------ |
| **Ethereum**  | L1   | 12s        | ~15 min   | ETH       | $5-50        | 15-30  |
| **BNB Chain** | L1   | 3s         | ~15s      | BNB       | <$0.10       | 160+   |
| **Avalanche** | L1   | <1s        | <2s       | AVAX      | $0.10-1      | 4,500+ |
| **Solana**    | L1   | 400ms      | 12.8s     | SOL       | <$0.001      | 2,000+ |
| **Polygon**   | L2   | 2s         | ~30 min\* | MATIC     | ~$0.01       | 7,000+ |
| **Arbitrum**  | L2   | 250ms      | 7 days\*  | ETH       | $0.10-1      | 4,000+ |
| **Optimism**  | L2   | 2s         | 7 days\*  | ETH       | $0.10-1      | 2,000+ |
| **Base**      | L2   | 2s         | 7 days\*  | ETH       | $0.10-1      | 2,000+ |

<small>\* Finality times represent withdrawal/challenge periods. Practical/probabilistic finality is much faster.</small>

### Feature Compatibility

| Feature                 | Ethereum     | BNB         | Avalanche   | Solana    | Polygon     | Arbitrum     | Optimism     | Base         |
| ----------------------- | ------------ | ----------- | ----------- | --------- | ----------- | ------------ | ------------ | ------------ |
| **EVM Compatible**      | ✅ Native    | ✅ Yes      | ✅ C-Chain  | ❌ No     | ✅ Yes      | ✅ Yes       | ✅ Yes       | ✅ Yes       |
| **Smart Contracts**     | ✅ Solidity  | ✅ Solidity | ✅ Solidity | ✅ Rust   | ✅ Solidity | ✅ Solidity  | ✅ Solidity  | ✅ Solidity  |
| **Token Standard**      | ERC-20       | BEP-20      | ERC-20      | SPL       | ERC-20      | ERC-20       | ERC-20       | ERC-20       |
| **Bridge Required**     | -            | -           | -           | -         | ✅ Yes      | ✅ Yes       | ✅ Yes       | ✅ Yes       |
| **MEV Protection**      | ✅ Flashbots | ⚠️ Limited  | ⚠️ Limited  | ✅ Jito   | ⚠️ Limited  | ✅ Available | ✅ Available | ✅ Available |
| **Account Abstraction** | ✅ EIP-4337  | ⚠️ Limited  | ✅ Yes      | ✅ Native | ✅ EIP-4337 | ✅ EIP-4337  | ✅ EIP-4337  | ✅ EIP-4337  |

### Use Case Recommendations

| Use Case                   | Recommended Networks          | Rationale                                 |
| -------------------------- | ----------------------------- | ----------------------------------------- |
| **DeFi Protocols**         | Ethereum, Arbitrum, Optimism  | Deep liquidity, security, composability   |
| **NFT Marketplaces**       | Ethereum, Polygon, Base       | Established standards, low minting costs  |
| **Gaming**                 | BNB Chain, Polygon, Avalanche | High throughput, low costs, fast finality |
| **Payment Processing**     | Solana, BNB Chain, Base       | Ultra-low fees, fast confirmation         |
| **High-Frequency Trading** | Solana, Avalanche             | Sub-second finality, low latency          |
| **Enterprise Apps**        | Polygon, Avalanche Subnets    | Scalability, custom network options       |
| **Consumer Social**        | Base, Polygon                 | Low barrier to entry, fiat integration    |

---

## 🏗️ Common Integration Architecture {#architecture}

### Standard Integration Pattern

All blockchain integrations follow a consistent pattern with the Quub Exchange Chain API:

```
┌─────────────────────────────────────────────────────────────┐
│                     Your Application                         │
│  (Trading Platform, DeFi Protocol, Exchange, etc.)           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ REST API Calls
                         │ (JWT Bearer Token)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Quub Exchange Chain API                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Chains     │  │   Wallets    │  │ OnChainTxs   │      │
│  │  Registry    │  │  Management  │  │   Tracking   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Chain      │  │   Health     │  │   Events     │      │
│  │  Adapters    │  │  Monitoring  │  │   Webhooks   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ RPC Calls / Indexer Queries
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Blockchain Networks                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Ethereum │  │   BNB    │  │  Solana  │  │ Polygon  │   │
│  │   RPC    │  │   RPC    │  │   RPC    │  │   RPC    │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Arbitrum │  │ Optimism │  │   Base   │  │Avalanche │   │
│  │   RPC    │  │   RPC    │  │   RPC    │  │   RPC    │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Integration Workflow

**1. Chain Registration**

```javascript
// Register blockchain network with metadata
POST /chains
{
  "chainId": 1,
  "name": "Ethereum Mainnet",
  "networkType": "MAINNET",
  "layer": "L1",
  "nativeCurrency": { "symbol": "ETH", "decimals": 18 }
}
```

**2. RPC Adapter Configuration**

```javascript
// Configure chain adapter with RPC endpoints
POST /chain/adapters
{
  "chainId": 1,
  "name": "Ethereum Primary Adapter",
  "rpcEndpoint": "https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY",
  "signerPolicy": "HOT_WALLET",
  "priority": 1
}
```

**3. Wallet Management**

```javascript
// Register organization wallet
POST /orgs/{orgId}/wallets
{
  "chainId": 1,
  "address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "type": "HOT_WALLET",
  "label": "Trading Wallet"
}
```

**4. Transaction Tracking**

```javascript
// Record on-chain transaction
POST /orgs/{orgId}/onchain/txs
{
  "chainId": 1,
  "hash": "0xabc123...",
  "fromAddress": "0x742d...",
  "toAddress": "0x123abc...",
  "direction": "OUTBOUND",
  "status": "PENDING"
}
```

**5. Health Monitoring**

```javascript
// Monitor adapter health
GET / chain / adapters / { adapterId } / health;
// Returns: status, latencyMs, syncLag, lastBlockHeight
```

### Security Best Practices (All Chains)

<div class="security-checklist">

#### 🔐 Authentication & Authorization

- ✅ Use OAuth2 with appropriate scopes (`read:chain`, `write:chain`)
- ✅ Rotate API keys regularly (90-day maximum)
- ✅ Implement rate limiting at application level
- ✅ Use separate credentials for production and sandbox

#### 🔒 Transaction Security

- ✅ Validate all addresses using chain-specific formats
- ✅ Implement multi-signature requirements for high-value transactions
- ✅ Use hardware wallets or MPC for custody
- ✅ Enable MEV protection on supported chains

#### 🛡️ Data Protection

- ✅ Encrypt sensitive data at rest and in transit
- ✅ Never log private keys or seed phrases
- ✅ Implement proper key management (HSM, KMS)
- ✅ Regular security audits of wallet infrastructure

#### ⚡ Operational Security

- ✅ Monitor for unusual transaction patterns
- ✅ Set up alerts for failed transactions
- ✅ Maintain hot/cold wallet separation
- ✅ Implement withdrawal limits and velocity checks

</div>

### Performance Optimization Strategies

#### Gas Optimization

```javascript
// Dynamic gas pricing based on network conditions
async function estimateOptimalGas(chainId, tx) {
  const adapter = await getChainAdapter(chainId);
  const health = await adapter.getHealth();

  if (health.congestion === "high") {
    return tx.gasLimit * 1.2; // 20% buffer
  }
  return tx.gasLimit;
}
```

#### Transaction Batching

```javascript
// Batch multiple operations for efficiency
async function batchWalletCreation(orgId, wallets) {
  const promises = wallets.map((wallet) => createWallet(orgId, wallet));
  return Promise.all(promises);
}
```

#### Caching Strategy

```javascript
// Cache chain metadata to reduce API calls
const chainCache = new Map();
const CACHE_TTL = 3600000; // 1 hour

async function getChainMetadata(chainId) {
  const cached = chainCache.get(chainId);
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return cached.data;
  }

  const data = await fetchChainDetails(chainId);
  chainCache.set(chainId, { data, timestamp: Date.now() });
  return data;
}
```

---

## 🚀 Getting Started

### Choose Your Integration Path

1. **Start with a Specific Blockchain** — Select from the guides above based on your use case
2. **Review the Chain API Guide** — Understand the [core Chain API operations](/capabilities/chain/guides/)
3. **Set Up Authentication** — Configure [OAuth2 credentials](/docs/authentication/)
4. **Deploy to Production** — Follow blockchain-specific production checklists

### Quick Links

- [Chain API Documentation](/capabilities/chain/api-documentation/)
- [Chain API Reference](/capabilities/chain/api-reference/)
- [OpenAPI Specification](/openapi/chain.yaml)
- [Authentication Guide](/docs/authentication/)
- [Webhooks & Events](/docs/webhooks/)

---

## 📚 Additional Resources

### Development Tools

- **Ethereum**: Hardhat, Foundry, Remix
- **Solana**: Anchor, Solana CLI
- **Multi-Chain**: ethers.js, web3.js, viem

### Network Explorers

- **Ethereum**: Etherscan
- **BNB Chain**: BscScan
- **Avalanche**: SnowTrace
- **Solana**: Solscan, Solana Explorer
- **Polygon**: PolygonScan
- **Arbitrum**: Arbiscan
- **Optimism**: Optimistic Etherscan
- **Base**: BaseScan

### Official Documentation

- [Ethereum Docs](https://ethereum.org/developers)
- [BNB Chain Docs](https://docs.bnbchain.org)
- [Avalanche Docs](https://docs.avax.network)
- [Solana Docs](https://docs.solana.com)
- [Polygon Docs](https://docs.polygon.technology)
- [Arbitrum Docs](https://docs.arbitrum.io)
- [Optimism Docs](https://docs.optimism.io)
- [Base Docs](https://docs.base.org)

---

<div class="footer-cta">
  <h3>Ready to Integrate?</h3>
  <p>Choose a blockchain guide above to start building your integration with production-ready code examples and best practices.</p>
  <a href="/docs/quickstart/" class="btn-primary-large">View Quickstart Guide →</a>
</div>
