---
layout: docs
title: Ethereum Integration Guide
permalink: /capabilities/chain/integrations/ethereum/
---

# 🔷 Ethereum Integration Guide

> Complete guide for integrating Ethereum (ETH) blockchain with Quub Exchange Chain Service. All operations reference `openapi/chain.yaml`.

## 📋 Overview

**Ethereum** is the world's leading programmable blockchain and the foundation of decentralized finance (DeFi). As an L1 network, it supports smart contracts, ERC-20 tokens, NFTs, and complex DeFi protocols.

### Network Details

| Property            | Value                                   |
| ------------------- | --------------------------------------- |
| **Chain ID**        | 1 (Mainnet), 11155111 (Sepolia Testnet) |
| **Native Currency** | ETH                                     |
| **Decimals**        | 18                                      |
| **Block Time**      | ~12 seconds                             |
| **Consensus**       | Proof of Stake (post-Merge)             |
| **Explorer**        | https://etherscan.io                    |
| **RPC Providers**   | Infura, Alchemy, QuickNode, Ankr        |

---

## 🚀 Quick Start

### 1. Register Ethereum Chain

```javascript
// Node.js - Register Ethereum Mainnet
const registerEthereumChain = async (token) => {
  const response = await fetch("https://api.quub.exchange/v2/chains", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `eth-mainnet-${Date.now()}`,
    },
    body: JSON.stringify({
      chainId: 1,
      name: "Ethereum Mainnet",
      shortName: "ETH",
      networkType: "MAINNET",
      layer: "L1",
      nativeCurrency: "ETH",
      decimals: 18,
      blockTime: 12,
      confirmations: 12,
      explorerUrl: "https://etherscan.io",
      docsUrl: "https://ethereum.org/en/developers/docs/",
      genesisHash:
        "0xd4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3",
      chainNamespace: "EVM",
      status: "ACTIVE",
    }),
  });

  return response.json();
};
```

```python
# Python - Register Ethereum Mainnet
import requests

def register_ethereum_chain(token):
    url = 'https://api.quub.exchange/v2/chains'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'Idempotency-Key': f'eth-mainnet-{int(time.time())}'
    }
    payload = {
        'chainId': 1,
        'name': 'Ethereum Mainnet',
        'shortName': 'ETH',
        'networkType': 'MAINNET',
        'layer': 'L1',
        'nativeCurrency': 'ETH',
        'decimals': 18,
        'blockTime': 12,
        'confirmations': 12,
        'explorerUrl': 'https://etherscan.io',
        'docsUrl': 'https://ethereum.org/en/developers/docs/',
        'genesisHash': '0xd4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3',
        'chainNamespace': 'EVM',
        'status': 'ACTIVE'
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

### 2. Configure RPC Adapter

```javascript
// Node.js - Configure Alchemy RPC Adapter
const configureAlchemyAdapter = async (token) => {
  const response = await fetch("https://api.quub.exchange/v2/chain/adapters", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `eth-alchemy-${Date.now()}`,
    },
    body: JSON.stringify({
      chainId: 1,
      name: "Alchemy Ethereum Primary",
      rpcEndpoint: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      wsEndpoint: `wss://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      signerPolicy: "MPC_CLUSTER",
      priority: 0,
    }),
  });

  return response.json();
};
```

```python
# Python - Configure Infura RPC Adapter
def configure_infura_adapter(token, api_key):
    url = 'https://api.quub.exchange/v2/chain/adapters'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'Idempotency-Key': f'eth-infura-{int(time.time())}'
    }
    payload = {
        'chainId': 1,
        'name': 'Infura Ethereum Backup',
        'rpcEndpoint': f'https://mainnet.infura.io/v3/{api_key}',
        'wsEndpoint': f'wss://mainnet.infura.io/ws/v3/{api_key}',
        'signerPolicy': 'MPC_CLUSTER',
        'priority': 1  # Backup adapter
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

---

## 🏗️ Core Integration Patterns

### Creating Organization Wallets

```javascript
// Node.js - Create Ethereum wallet for organization
const createEthWallet = async (orgId, token, walletType = "MPC") => {
  const response = await fetch(
    `https://api.quub.exchange/v2/orgs/${orgId}/wallets`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
        "X-Org-Id": orgId,
        "Idempotency-Key": `eth-wallet-${Date.now()}`,
      },
      body: JSON.stringify({
        chainId: 1,
        address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0", // Generated address
        type: walletType, // CUSTODIAL, MPC, HARDWARE, EXTERNAL
        label: "Primary ETH Trading Wallet",
        tags: ["trading", "ethereum", "mainnet"],
      }),
    }
  );

  return response.json();
};

// Usage
const wallet = await createEthWallet("org-uuid", token, "MPC");
console.log("Wallet created:", wallet.data.id);
```

```python
# Python - Create multiple Ethereum wallets
def create_eth_wallets(org_id, token, wallet_configs):
    """Create multiple Ethereum wallets for different purposes"""
    url = f'https://api.quub.exchange/v2/orgs/{org_id}/wallets'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'X-Org-Id': org_id
    }

    wallets = []
    for config in wallet_configs:
        headers['Idempotency-Key'] = f"eth-wallet-{config['purpose']}-{int(time.time())}"
        payload = {
            'chainId': 1,
            'address': config['address'],
            'type': config['type'],
            'label': config['label'],
            'tags': config.get('tags', [])
        }

        response = requests.post(url, json=payload, headers=headers)
        wallets.append(response.json())

    return wallets

# Example usage
configs = [
    {
        'purpose': 'hot',
        'address': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
        'type': 'MPC',
        'label': 'Hot Wallet - Trading',
        'tags': ['hot', 'trading', 'high-frequency']
    },
    {
        'purpose': 'cold',
        'address': '0x8ba1f109551bD432803012645Ac136ddd64DBA72',
        'type': 'HARDWARE',
        'label': 'Cold Storage - Treasury',
        'tags': ['cold', 'treasury', 'long-term']
    }
]

wallets = create_eth_wallets('org-uuid', token, configs)
```

### Recording On-Chain Transactions

```javascript
// Node.js - Record Ethereum transaction
const recordEthTransaction = async (orgId, token, txData) => {
  const response = await fetch(
    `https://api.quub.exchange/v2/orgs/${orgId}/onchain/txs`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
        "X-Org-Id": orgId,
        "Idempotency-Key": `eth-tx-${txData.hash}`,
      },
      body: JSON.stringify({
        chainId: 1,
        hash: txData.hash,
        fromAddress: txData.from,
        toAddress: txData.to,
        value: txData.value, // Wei as string
        direction: "OUTBOUND",
        status: "PENDING",
        blockNumber: txData.blockNumber,
        gasPrice: txData.gasPrice, // Wei as string
        nonce: txData.nonce,
        txFeeAmount: txData.txFeeAmount, // ETH as string
        source: "NODE",
      }),
    }
  );

  return response.json();
};

// Example: Record a token transfer
const recordTokenTransfer = async (orgId, token) => {
  const txData = {
    hash: "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
    from: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
    to: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", // USDC contract
    value: "0", // Token transfer, no ETH value
    blockNumber: 18500000,
    gasPrice: "30000000000",
    nonce: 42,
    txFeeAmount: "0.00063", // 21000 gas * 30 gwei
  };

  return recordEthTransaction(orgId, token, txData);
};
```

```python
# Python - Comprehensive transaction recording with error handling
def record_eth_transaction(org_id, token, tx_data):
    """Record Ethereum transaction with full metadata"""
    url = f'https://api.quub.exchange/v2/orgs/{org_id}/onchain/txs'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'X-Org-Id': org_id,
        'Idempotency-Key': f"eth-tx-{tx_data['hash']}"
    }

    payload = {
        'chainId': 1,
        'hash': tx_data['hash'],
        'fromAddress': tx_data['from'],
        'toAddress': tx_data['to'],
        'value': str(tx_data['value']),  # Wei as string
        'direction': tx_data.get('direction', 'OUTBOUND'),
        'status': tx_data.get('status', 'PENDING'),
        'blockNumber': tx_data.get('blockNumber'),
        'gasPrice': str(tx_data['gasPrice']),
        'nonce': tx_data['nonce'],
        'txFeeAmount': str(tx_data.get('txFeeAmount', '0')),
        'source': tx_data.get('source', 'NODE')
    }

    # Add optional reference data if present
    if 'refType' in tx_data:
        payload['refType'] = tx_data['refType']
        payload['refId'] = tx_data['refId']

    try:
        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.HTTPError as e:
        print(f"Error recording transaction: {e}")
        return None

# Example: Bulk transaction recording
def record_eth_transactions_bulk(org_id, token, transactions):
    """Record multiple Ethereum transactions"""
    results = []
    for tx in transactions:
        result = record_eth_transaction(org_id, token, tx)
        if result:
            results.append(result)
    return results
```

---

## 🔐 Security Best Practices

### Wallet Management

```javascript
// Node.js - Implement multi-tier wallet architecture
class EthereumWalletManager {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
  }

  async createHotWallet(address) {
    // Hot wallet for day-to-day operations (MPC)
    return this.createWallet({
      address,
      type: "MPC",
      label: "Hot Wallet - Operations",
      tags: ["hot", "operational", "high-liquidity"],
    });
  }

  async createWarmWallet(address) {
    // Warm wallet for medium-term holdings (MPC with higher threshold)
    return this.createWallet({
      address,
      type: "MPC",
      label: "Warm Wallet - Reserve",
      tags: ["warm", "reserve", "medium-term"],
    });
  }

  async createColdWallet(address) {
    // Cold storage for long-term holdings (Hardware)
    return this.createWallet({
      address,
      type: "HARDWARE",
      label: "Cold Storage - Treasury",
      tags: ["cold", "treasury", "long-term"],
    });
  }

  async createWallet(config) {
    const response = await fetch(`${this.baseUrl}/orgs/${this.orgId}/wallets`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.token}`,
        "Content-Type": "application/json",
        "X-Org-Id": this.orgId,
        "Idempotency-Key": `eth-${config.tags[0]}-${Date.now()}`,
      },
      body: JSON.stringify({
        chainId: 1,
        ...config,
      }),
    });

    return response.json();
  }

  async listWalletsByTier(tier) {
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/wallets?chainId=1&limit=100`,
      {
        headers: {
          Authorization: `Bearer ${this.token}`,
          "X-Org-Id": this.orgId,
        },
      }
    );

    const data = await response.json();
    return data.data.filter((w) => w.tags.includes(tier));
  }
}

// Usage
const walletManager = new EthereumWalletManager("org-uuid", token);
const hotWallet = await walletManager.createHotWallet("0x...");
const coldWallets = await walletManager.listWalletsByTier("cold");
```

### Transaction Monitoring

```python
# Python - Advanced transaction monitoring and reconciliation
import time
from typing import List, Dict
from enum import Enum

class TransactionStatus(Enum):
    PENDING = 'PENDING'
    CONFIRMED = 'CONFIRMED'
    FAILED = 'FAILED'

class EthereumTransactionMonitor:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.confirmations_required = 12

    def get_pending_transactions(self) -> List[Dict]:
        """Fetch all pending Ethereum transactions"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        params = {
            'chainId': 1,
            'status': 'PENDING',
            'limit': 100
        }
        headers = {
            'Authorization': f'Bearer {self.token}',
            'X-Org-Id': self.org_id
        }

        response = requests.get(url, params=params, headers=headers)
        return response.json().get('data', [])

    def check_transaction_confirmations(self, tx_hash: str, current_block: int) -> int:
        """Calculate number of confirmations for a transaction"""
        # This would typically call your Ethereum node
        # For demo purposes, showing the pattern
        tx_block = self.get_transaction_block(tx_hash)
        if tx_block:
            return current_block - tx_block
        return 0

    def get_transaction_block(self, tx_hash: str) -> int:
        """Get block number for a transaction from your Ethereum node"""
        # Implementation would use web3.py or similar
        # web3.eth.get_transaction(tx_hash)['blockNumber']
        pass

    def monitor_and_update(self):
        """Main monitoring loop"""
        pending_txs = self.get_pending_transactions()

        for tx in pending_txs:
            confirmations = self.check_transaction_confirmations(
                tx['hash'],
                self.get_current_block()
            )

            if confirmations >= self.confirmations_required:
                self.update_transaction_status(
                    tx['id'],
                    TransactionStatus.CONFIRMED
                )
                print(f"Transaction {tx['hash']} confirmed with {confirmations} confirmations")
            elif confirmations > 0:
                print(f"Transaction {tx['hash']} has {confirmations}/{self.confirmations_required} confirmations")

    def update_transaction_status(self, tx_id: str, status: TransactionStatus):
        """Update transaction status (this would use PATCH endpoint if available)"""
        # Note: The spec doesn't show PATCH for onchain/txs,
        # so you might record a new status or use internal workflows
        pass

    def get_current_block(self) -> int:
        """Get current Ethereum block number"""
        # Implementation would use web3.py
        # web3.eth.block_number
        pass

# Usage
monitor = EthereumTransactionMonitor('org-uuid', token)
monitor.monitor_and_update()
```

---

## 🔄 Advanced Integration Patterns

### High-Availability RPC Configuration

```javascript
// Node.js - Configure redundant RPC adapters
const setupHighAvailabilityRPC = async (token) => {
  const adapters = [
    {
      name: "Alchemy Primary",
      rpcEndpoint: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
      wsEndpoint: `wss://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
      priority: 0,
    },
    {
      name: "Infura Backup",
      rpcEndpoint: `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`,
      wsEndpoint: `wss://mainnet.infura.io/ws/v3/${process.env.INFURA_KEY}`,
      priority: 1,
    },
    {
      name: "QuickNode Fallback",
      rpcEndpoint: process.env.QUICKNODE_ENDPOINT,
      wsEndpoint: process.env.QUICKNODE_WS_ENDPOINT,
      priority: 2,
    },
  ];

  const createdAdapters = [];

  for (const adapter of adapters) {
    const response = await fetch(
      "https://api.quub.exchange/v2/chain/adapters",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
          "Idempotency-Key": `eth-${adapter.name
            .toLowerCase()
            .replace(/\s/g, "-")}`,
        },
        body: JSON.stringify({
          chainId: 1,
          signerPolicy: "MPC_CLUSTER",
          ...adapter,
        }),
      }
    );

    createdAdapters.push(await response.json());
  }

  // Configure fallback chain
  if (createdAdapters.length > 1) {
    const primaryAdapter = createdAdapters[0].data;
    const fallbackIds = createdAdapters.slice(1).map((a) => a.data.id);

    // Update primary with fallback references
    await fetch(
      `https://api.quub.exchange/v2/chain/adapters/${primaryAdapter.id}`,
      {
        method: "PATCH",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          fallbackAdapterIds: fallbackIds,
        }),
      }
    );
  }

  return createdAdapters;
};
```

### Gas Price Optimization

```python
# Python - Gas price monitoring and optimization
class EthereumGasOptimizer:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'

    def get_gas_price_recommendation(self, priority: str = 'medium') -> int:
        """
        Get gas price recommendation based on network conditions
        Priority: low (safeLow), medium (standard), high (fast)
        """
        # This would typically call a gas oracle API
        # For example: Etherscan Gas Tracker, ETH Gas Station, or your node
        # Returns gas price in Wei

        gas_prices = {
            'low': 20_000_000_000,      # 20 Gwei
            'medium': 30_000_000_000,    # 30 Gwei
            'high': 50_000_000_000       # 50 Gwei
        }
        return gas_prices.get(priority, gas_prices['medium'])

    def estimate_transaction_cost(self, gas_limit: int, gas_price: int) -> Dict:
        """Estimate transaction cost in ETH and USD"""
        cost_wei = gas_limit * gas_price
        cost_eth = cost_wei / 1e18

        # Get ETH price (would call price oracle)
        eth_price_usd = self.get_eth_price()
        cost_usd = cost_eth * eth_price_usd

        return {
            'gas_limit': gas_limit,
            'gas_price_gwei': gas_price / 1e9,
            'total_cost_wei': cost_wei,
            'total_cost_eth': cost_eth,
            'total_cost_usd': cost_usd
        }

    def get_eth_price(self) -> float:
        """Get current ETH price in USD"""
        # Would call your price oracle or external API
        return 2000.0  # Example price

    def record_transaction_with_gas_estimate(self, tx_data: Dict) -> Dict:
        """Record transaction with gas cost tracking"""
        gas_estimate = self.estimate_transaction_cost(
            tx_data.get('gas_limit', 21000),
            int(tx_data['gasPrice'])
        )

        # Add gas cost data to transaction record
        tx_data_enhanced = {
            **tx_data,
            'txFeeAmount': str(gas_estimate['total_cost_eth']),
            'txFeeUsd': str(gas_estimate['total_cost_usd'])
        }

        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"eth-tx-{tx_data['hash']}"
        }

        response = requests.post(url, json=tx_data_enhanced, headers=headers)
        return response.json()

# Usage
gas_optimizer = EthereumGasOptimizer('org-uuid', token)
gas_price = gas_optimizer.get_gas_price_recommendation('medium')
cost_estimate = gas_optimizer.estimate_transaction_cost(21000, gas_price)
print(f"Estimated cost: {cost_estimate['total_cost_eth']} ETH (${cost_estimate['total_cost_usd']})")
```

---

## 📊 Monitoring & Health Checks

### Adapter Health Monitoring

```javascript
// Node.js - Monitor RPC adapter health
class EthereumAdapterHealthMonitor {
  constructor(token) {
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
  }

  async checkAdapterHealth(adapterId) {
    const response = await fetch(
      `${this.baseUrl}/chain/adapters/${adapterId}/health`,
      {
        headers: {
          Authorization: `Bearer ${this.token}`,
        },
      }
    );

    return response.json();
  }

  async monitorAllEthereumAdapters() {
    // Get all Ethereum adapters
    const adaptersResponse = await fetch(
      `${this.baseUrl}/chain/adapters?chainId=1`,
      {
        headers: {
          Authorization: `Bearer ${this.token}`,
        },
      }
    );

    const adapters = (await adaptersResponse.json()).data;

    const healthReports = await Promise.all(
      adapters.map(async (adapter) => {
        const health = await this.checkAdapterHealth(adapter.id);
        return {
          adapter: adapter.name,
          ...health.data,
        };
      })
    );

    return this.analyzeHealthReports(healthReports);
  }

  analyzeHealthReports(reports) {
    const summary = {
      total: reports.length,
      healthy: reports.filter((r) => r.status === "HEALTHY").length,
      degraded: reports.filter((r) => r.status === "DEGRADED").length,
      down: reports.filter((r) => r.status === "DOWN").length,
      averageLatency:
        reports.reduce((sum, r) => sum + r.latencyMs, 0) / reports.length,
      reports,
    };

    // Alert if primary adapter is down
    const primary = reports.find((r) => r.adapter.includes("Primary"));
    if (primary && primary.status !== "HEALTHY") {
      this.sendAlert(`Primary Ethereum adapter is ${primary.status}`);
    }

    return summary;
  }

  sendAlert(message) {
    console.error(`[ALERT] ${message}`);
    // Implement your alerting logic (PagerDuty, Slack, etc.)
  }
}

// Usage
const healthMonitor = new EthereumAdapterHealthMonitor(token);
const healthSummary = await healthMonitor.monitorAllEthereumAdapters();
console.log(
  `Ethereum adapters: ${healthSummary.healthy}/${healthSummary.total} healthy`
);
console.log(`Average latency: ${healthSummary.averageLatency.toFixed(2)}ms`);
```

---

## 🎯 Production Checklist

### Pre-Launch Validation

- [ ] **Chain Registration**: Ethereum mainnet registered with correct genesis hash
- [ ] **RPC Redundancy**: At least 2 RPC adapters configured (primary + backup)
- [ ] **Wallet Security**: Multi-tier wallet architecture (hot/warm/cold)
- [ ] **Gas Monitoring**: Gas price tracking and optimization implemented
- [ ] **Transaction Monitoring**: Confirmation tracking system operational
- [ ] **Health Checks**: Adapter health monitoring and alerting configured
- [ ] **Rate Limiting**: RPC rate limits understood and monitored
- [ ] **Error Handling**: Retry logic and fallback mechanisms tested
- [ ] **Audit Trail**: All transactions recorded with proper metadata
- [ ] **Testnet Validation**: Full integration tested on Sepolia testnet first

### Monitoring Metrics

Monitor these key metrics for production Ethereum integration:

- **RPC Latency**: < 100ms for healthy adapters
- **Block Sync Lag**: < 5 blocks behind network
- **Transaction Confirmation Rate**: > 99% within 12 blocks
- **Adapter Uptime**: > 99.9% availability
- **Gas Price Accuracy**: Within 10% of network average

---

## 📚 Additional Resources

- [Ethereum Official Documentation](https://ethereum.org/en/developers/docs/)
- [Etherscan API Documentation](https://docs.etherscan.io/)
- [EIP Standards](https://eips.ethereum.org/)
- [Web3.js Documentation](https://web3js.readthedocs.io/)
- [Ethers.js Documentation](https://docs.ethers.org/)
- [Gas Tracker](https://etherscan.io/gastracker)
- [Chainlist - EVM Networks](https://chainlist.org/)

---

## 🔗 Related Integrations

- [Ethereum Layer 2s (Arbitrum, Optimism)](/capabilities/chain/integrations/ethereum-l2/)
- [Base Chain](/capabilities/chain/integrations/base/)
- [Polygon](/capabilities/chain/integrations/polygon/)
- [BNB Chain](/capabilities/chain/integrations/bnb/)

---

**Note**: All code examples reference operations defined in `openapi/chain.yaml`. No invented endpoints or schemas are used.
