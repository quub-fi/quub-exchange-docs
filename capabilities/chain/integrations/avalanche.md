---
layout: docs
title: Avalanche Integration Guide
permalink: /capabilities/chain/integrations/avalanche/
---

# 🔺 Avalanche Integration Guide

> Complete guide for integrating Avalanche with Quub Exchange Chain Service. All operations reference `openapi/chain.yaml`.

## 📋 Overview

**Avalanche** is a high-performance, scalable blockchain platform featuring multiple subnetworks and chains. The C-Chain (Contract Chain) is EVM-compatible, making it ideal for DeFi applications with sub-second finality and low transaction costs.

### Network Details

| Property            | Value                                         |
| ------------------- | --------------------------------------------- |
| **Chain ID**        | 43114 (C-Chain Mainnet), 43113 (Fuji Testnet) |
| **Native Currency** | AVAX                                          |
| **Decimals**        | 18                                            |
| **Block Time**      | ~2 seconds                                    |
| **Consensus**       | Avalanche Consensus (Snow\*)                  |
| **Explorer**        | https://snowtrace.io                          |
| **RPC Providers**   | Avalanche Official, Infura, Ankr, BlastAPI    |

---

## 🚀 Quick Start

### 1. Register Avalanche C-Chain

```javascript
// Node.js - Register Avalanche C-Chain Mainnet
const registerAvalancheChain = async (token) => {
  const response = await fetch("https://api.quub.exchange/v2/chains", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `avalanche-mainnet-${Date.now()}`,
    },
    body: JSON.stringify({
      chainId: 43114,
      name: "Avalanche C-Chain",
      shortName: "AVAX",
      networkType: "MAINNET",
      layer: "L1",
      nativeCurrency: "AVAX",
      decimals: 18,
      blockTime: 2,
      confirmations: 1, // Sub-second finality
      explorerUrl: "https://snowtrace.io",
      docsUrl: "https://docs.avax.network/",
      genesisHash:
        "0x31ced5b9beb7f8782b014660da0cb18cc409f121f408186886e1ca3e8eeca96b",
      chainNamespace: "EVM",
      status: "ACTIVE",
      metadata: {
        consensus: "avalanche",
        subnet: "primary-network",
        vmType: "evm",
      },
    }),
  });

  return response.json();
};
```

```python
# Python - Register Avalanche with subnet metadata
import requests
import time

def register_avalanche_chain(token):
    url = 'https://api.quub.exchange/v2/chains'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'Idempotency-Key': f'avalanche-mainnet-{int(time.time())}'
    }
    payload = {
        'chainId': 43114,
        'name': 'Avalanche C-Chain',
        'shortName': 'AVAX',
        'networkType': 'MAINNET',
        'layer': 'L1',
        'nativeCurrency': 'AVAX',
        'decimals': 18,
        'blockTime': 2,
        'confirmations': 1,
        'explorerUrl': 'https://snowtrace.io',
        'docsUrl': 'https://docs.avax.network/',
        'genesisHash': '0x31ced5b9beb7f8782b014660da0cb18cc409f121f408186886e1ca3e8eeca96b',
        'chainNamespace': 'EVM',
        'status': 'ACTIVE'
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

### 2. Configure RPC Adapters

```javascript
// Node.js - Setup Avalanche RPC with multiple providers
const setupAvalancheRPCAdapters = async (token, apiKeys = {}) => {
  const adapters = [
    {
      name: "Avalanche Official Primary",
      rpcEndpoint: "https://api.avax.network/ext/bc/C/rpc",
      signerPolicy: "MPC_CLUSTER",
      priority: 0,
    },
    {
      name: "Infura Avalanche",
      rpcEndpoint: `https://avalanche-mainnet.infura.io/v3/${
        apiKeys.infura || "YOUR_INFURA_KEY"
      }`,
      wsEndpoint: `wss://avalanche-mainnet.infura.io/ws/v3/${
        apiKeys.infura || "YOUR_INFURA_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 1,
    },
    {
      name: "Ankr Avalanche",
      rpcEndpoint: "https://rpc.ankr.com/avalanche",
      signerPolicy: "MPC_CLUSTER",
      priority: 2,
    },
    {
      name: "BlastAPI Avalanche",
      rpcEndpoint: `https://ava-mainnet.public.blastapi.io/ext/bc/C/rpc`,
      signerPolicy: "MPC_CLUSTER",
      priority: 3,
    },
  ];

  const results = [];
  for (const adapter of adapters) {
    const response = await fetch(
      "https://api.quub.exchange/v2/chain/adapters",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
          "Idempotency-Key": `avalanche-${adapter.name
            .toLowerCase()
            .replace(/\s+/g, "-")}`,
        },
        body: JSON.stringify({
          chainId: 43114,
          ...adapter,
        }),
      }
    );
    results.push(await response.json());
  }

  return results;
};
```

```python
# Python - Configure Avalanche adapters with failover
def configure_avalanche_adapters(token, api_keys=None):
    """Configure multiple Avalanche RPC adapters"""
    url = 'https://api.quub.exchange/v2/chain/adapters'

    adapters_config = [
        {
            'name': 'Avalanche Official',
            'rpcEndpoint': 'https://api.avax.network/ext/bc/C/rpc',
            'priority': 0
        },
        {
            'name': 'Ankr Public',
            'rpcEndpoint': 'https://rpc.ankr.com/avalanche',
            'priority': 2
        },
        {
            'name': 'BlastAPI Public',
            'rpcEndpoint': 'https://ava-mainnet.public.blastapi.io/ext/bc/C/rpc',
            'priority': 3
        }
    ]

    # Add premium providers if API keys provided
    if api_keys:
        if 'infura' in api_keys:
            adapters_config.insert(1, {
                'name': 'Infura Avalanche',
                'rpcEndpoint': f"https://avalanche-mainnet.infura.io/v3/{api_keys['infura']}",
                'wsEndpoint': f"wss://avalanche-mainnet.infura.io/ws/v3/{api_keys['infura']}",
                'priority': 1
            })

    results = []
    for config in adapters_config:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json',
            'Idempotency-Key': f"avalanche-{config['name'].lower().replace(' ', '-')}-{int(time.time())}"
        }

        payload = {
            'chainId': 43114,
            'signerPolicy': 'MPC_CLUSTER',
            **config
        }

        response = requests.post(url, json=payload, headers=headers)
        results.append(response.json())

    return results
```

---

## 🏗️ Avalanche-Specific Integration Patterns

### Sub-Second Finality Handling

```javascript
// Node.js - Leverage Avalanche's fast finality
class AvalancheFinalityManager {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.blockTime = 2000; // 2 seconds
    this.finalityTime = 1000; // Sub-second finality
  }

  async recordTransactionWithFastFinality(txData) {
    // Record transaction
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `avalanche-tx-${txData.hash}`,
        },
        body: JSON.stringify({
          chainId: 43114,
          hash: txData.hash,
          fromAddress: txData.from,
          toAddress: txData.to,
          value: txData.value,
          direction: txData.direction || "OUTBOUND",
          status: "PENDING",
          blockNumber: txData.blockNumber,
          gasPrice: txData.gasPrice,
          nonce: txData.nonce,
          txFeeAmount: txData.txFeeAmount,
          source: "NODE",
        }),
      }
    );

    const recorded = await response.json();

    // Check finality quickly due to Avalanche's consensus
    const finalized = await this.waitForFinality(txData.hash, 3); // Only 3 attempts needed

    return {
      transaction: recorded,
      finalized: finalized.status === "CONFIRMED",
    };
  }

  async waitForFinality(txHash, maxAttempts = 3) {
    for (let attempt = 0; attempt < maxAttempts; attempt++) {
      await this.sleep(this.finalityTime);

      const tx = await this.getTransaction(txHash);

      if (tx && tx.blockNumber) {
        // On Avalanche, 1 confirmation is typically sufficient
        return {
          hash: txHash,
          status: "CONFIRMED",
          finalityTime: (attempt + 1) * this.finalityTime,
        };
      }
    }

    return {
      hash: txHash,
      status: "TIMEOUT",
      finalityTime: maxAttempts * this.finalityTime,
    };
  }

  async getTransaction(txHash) {
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs?hash=${txHash}`,
      {
        headers: {
          Authorization: `Bearer ${this.token}`,
          "X-Org-Id": this.orgId,
        },
      }
    );

    const data = await response.json();
    return data.data?.[0];
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Usage
const finalityManager = new AvalancheFinalityManager("org-uuid", token);

const avaxTx = {
  hash: "0x1234567890abcdef...",
  from: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
  to: "0x8ba1f109551bD432803012645Ac136ddd64DBA72",
  value: "2.5",
  blockNumber: 35000000,
  gasPrice: "25000000000", // 25 nAVAX
  nonce: 42,
  txFeeAmount: "0.000525",
};

const result = await finalityManager.recordTransactionWithFastFinality(avaxTx);
console.log(`Transaction finalized: ${result.finalized}`);
```

### Dynamic Fee Management

```python
# Python - Handle Avalanche's dynamic fee structure
class AvalancheFeeManager:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.min_base_fee = 25_000_000_000  # 25 nAVAX minimum
        self.target_block_utilization = 0.5  # 50%

    def estimate_avalanche_fee(self, base_fee: int, priority_fee: int = 0) -> dict:
        """Estimate transaction fee on Avalanche"""
        # Avalanche uses dynamic base fee + optional priority fee
        total_gas_price = base_fee + priority_fee

        # Standard transfer gas limit
        gas_limit = 21000

        cost_wei = gas_limit * total_gas_price
        cost_avax = cost_wei / 1e18

        # Example: AVAX at $40
        avax_price = 40
        cost_usd = cost_avax * avax_price

        return {
            'baseFee': base_fee,
            'priorityFee': priority_fee,
            'totalGasPrice': total_gas_price,
            'gasLimit': gas_limit,
            'costWei': cost_wei,
            'costAVAX': cost_avax,
            'costUSD': cost_usd
        }

    def record_transaction_with_dynamic_fee(self, tx_data: dict) -> dict:
        """Record transaction with Avalanche's dynamic fee"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"avalanche-fee-{tx_data['hash']}"
        }

        fee_estimate = self.estimate_avalanche_fee(
            tx_data.get('baseFee', self.min_base_fee),
            tx_data.get('priorityFee', 0)
        )

        payload = {
            'chainId': 43114,
            'hash': tx_data['hash'],
            'fromAddress': tx_data['from'],
            'toAddress': tx_data['to'],
            'value': str(tx_data['value']),
            'direction': tx_data.get('direction', 'OUTBOUND'),
            'status': tx_data.get('status', 'PENDING'),
            'blockNumber': tx_data.get('blockNumber'),
            'gasPrice': str(fee_estimate['totalGasPrice']),
            'nonce': tx_data['nonce'],
            'txFeeAmount': str(fee_estimate['costAVAX']),
            'txFeeUsd': str(fee_estimate['costUSD']),
            'source': 'NODE'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def get_recommended_priority_fee(self, urgency: str = 'standard') -> int:
        """Get recommended priority fee based on urgency"""
        # Avalanche typically has low congestion
        priority_fees = {
            'low': 0,  # No priority
            'standard': 2_000_000_000,  # 2 nAVAX
            'fast': 5_000_000_000,  # 5 nAVAX
            'urgent': 10_000_000_000  # 10 nAVAX
        }

        return priority_fees.get(urgency, priority_fees['standard'])

# Example usage
fee_manager = AvalancheFeeManager('org-uuid', token)

# Estimate fee for fast transaction
base_fee = 25_000_000_000  # 25 nAVAX
priority_fee = fee_manager.get_recommended_priority_fee('fast')

estimate = fee_manager.estimate_avalanche_fee(base_fee, priority_fee)
print(f"Transaction cost: {estimate['costAVAX']:.6f} AVAX (${estimate['costUSD']:.4f})")

# Record transaction
avax_tx = {
    'hash': '0xabc123...',
    'from': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
    'to': '0x8ba1f109551bD432803012645Ac136ddd64DBA72',
    'value': 5.0,
    'baseFee': base_fee,
    'priorityFee': priority_fee,
    'nonce': 15
}

result = fee_manager.record_transaction_with_dynamic_fee(avax_tx)
print(f"Recorded transaction: {result}")
```

### Subnet Wallet Management

```javascript
// Node.js - Manage wallets across Avalanche subnets
class AvalancheSubnetWalletManager {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.cChainId = 43114; // Primary Network C-Chain
  }

  async createCChainWallet(label = "Avalanche C-Chain Wallet") {
    // Create wallet for C-Chain (EVM-compatible)
    const response = await fetch(`${this.baseUrl}/orgs/${this.orgId}/wallets`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.token}`,
        "Content-Type": "application/json",
        "X-Org-Id": this.orgId,
        "Idempotency-Key": `avalanche-cchain-wallet-${Date.now()}`,
      },
      body: JSON.stringify({
        chainId: this.cChainId,
        walletType: "HOT",
        label: label,
        signerPolicy: "MPC_CLUSTER",
        metadata: {
          subnet: "primary-network",
          chain: "c-chain",
        },
      }),
    });

    return response.json();
  }

  async createSubnetWallet(subnetChainId, subnetName) {
    // Create wallet for custom Avalanche subnet
    const response = await fetch(`${this.baseUrl}/orgs/${this.orgId}/wallets`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.token}`,
        "Content-Type": "application/json",
        "X-Org-Id": this.orgId,
        "Idempotency-Key": `avalanche-subnet-wallet-${subnetChainId}-${Date.now()}`,
      },
      body: JSON.stringify({
        chainId: subnetChainId,
        walletType: "HOT",
        label: `${subnetName} Wallet`,
        signerPolicy: "MPC_CLUSTER",
        metadata: {
          subnet: subnetName,
          network: "avalanche-ecosystem",
        },
      }),
    });

    return response.json();
  }

  async getWalletsBySubnet() {
    // Get all Avalanche-related wallets
    const response = await fetch(`${this.baseUrl}/orgs/${this.orgId}/wallets`, {
      headers: {
        Authorization: `Bearer ${this.token}`,
        "X-Org-Id": this.orgId,
      },
    });

    const wallets = (await response.json()).data || [];

    // Group by subnet
    const bySubnet = {};
    wallets.forEach((wallet) => {
      if (
        wallet.chainId === this.cChainId ||
        wallet.metadata?.network === "avalanche-ecosystem"
      ) {
        const subnet = wallet.metadata?.subnet || "primary-network";
        if (!bySubnet[subnet]) bySubnet[subnet] = [];
        bySubnet[subnet].push(wallet);
      }
    });

    return bySubnet;
  }
}

// Usage
const subnetManager = new AvalancheSubnetWalletManager("org-uuid", token);

// Create C-Chain wallet
const cchainWallet = await subnetManager.createCChainWallet(
  "Main Trading Wallet"
);
console.log("C-Chain wallet created:", cchainWallet.data.address);

// Create custom subnet wallet (example: DeFi Kingdoms subnet)
const subnetWallet = await subnetManager.createSubnetWallet(
  53935,
  "DeFi Kingdoms"
);
console.log("Subnet wallet created:", subnetWallet.data.address);

// List all wallets by subnet
const walletsBySubnet = await subnetManager.getWalletsBySubnet();
console.log("Wallets by subnet:", Object.keys(walletsBySubnet));
```

---

## 🔐 Security & Best Practices

### Network Health Monitoring

```python
# Python - Monitor Avalanche network health
class AvalancheHealthMonitor:
    def __init__(self, token: str):
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'

    def check_adapter_health(self) -> dict:
        """Check health of all Avalanche RPC adapters"""
        url = f'{self.base_url}/chain/adapters?chainId=43114'
        headers = {
            'Authorization': f'Bearer {self.token}'
        }

        response = requests.get(url, headers=headers)
        adapters = response.json().get('data', [])

        health_data = []
        for adapter in adapters:
            health_url = f'{self.base_url}/chain/adapters/{adapter["id"]}/health'
            health_response = requests.get(health_url, headers=headers)
            health = health_response.json().get('data', {})

            health_data.append({
                'name': adapter['name'],
                'priority': adapter['priority'],
                'syncLag': health.get('syncLag', 0),
                'latencyMs': health.get('latencyMs', 0),
                'healthy': health.get('syncLag', 0) < 2  # Less than 2 blocks behind
            })

        return {
            'totalAdapters': len(adapters),
            'healthyAdapters': sum(1 for h in health_data if h['healthy']),
            'details': health_data
        }

    def monitor_finality_time(self, sample_size: int = 10) -> dict:
        """Monitor Avalanche finality times"""
        # In production, this would sample recent transactions
        finality_times = [800, 950, 1100, 750, 900, 1050, 850, 1000, 920, 880]  # ms

        avg_finality = sum(finality_times) / len(finality_times)
        max_finality = max(finality_times)
        min_finality = min(finality_times)

        return {
            'sampleSize': sample_size,
            'averageFinalityMs': avg_finality,
            'minFinalityMs': min_finality,
            'maxFinalityMs': max_finality,
            'withinTarget': avg_finality < 2000  # Target: < 2 seconds
        }

    def check_consensus_health(self) -> dict:
        """Check Avalanche consensus health metrics"""
        return {
            'consensusType': 'avalanche',
            'validatorCount': 1500,  # Approximate active validators
            'stakingRatio': 0.62,  # 62% of AVAX staked
            'networkHealthy': True
        }

# Example usage
health_monitor = AvalancheHealthMonitor(token)

# Check adapter health
adapter_health = health_monitor.check_adapter_health()
print(f"Healthy adapters: {adapter_health['healthyAdapters']}/{adapter_health['totalAdapters']}")

# Monitor finality
finality_stats = health_monitor.monitor_finality_time()
print(f"Average finality: {finality_stats['averageFinalityMs']:.0f}ms")
print(f"Within target: {finality_stats['withinTarget']}")

# Check consensus
consensus = health_monitor.check_consensus_health()
print(f"Active validators: {consensus['validatorCount']}")
```

---

## 🎯 Production Checklist

### Pre-Launch

- [ ] **Chain Registration**: Avalanche C-Chain registered with correct genesis hash
- [ ] **RPC Diversity**: Multiple providers (Official, Infura, Ankr, BlastAPI)
- [ ] **Fast Finality**: Sub-second finality handling implemented
- [ ] **Dynamic Fees**: Base fee + priority fee tracking configured
- [ ] **Confirmation Depth**: 1 confirmation sufficient for most cases
- [ ] **Subnet Support**: C-Chain wallet creation operational
- [ ] **Health Monitoring**: Adapter sync lag monitoring < 2 blocks
- [ ] **Finality Tracking**: Average finality time < 2 seconds
- [ ] **Testnet Validation**: Fully tested on Fuji Testnet (Chain ID 43113)

### Monitoring Metrics

- **Block Time**: ~2 seconds
- **Finality Time**: < 1 second typical
- **Gas Price**: 25-100 nAVAX typical
- **Transaction Cost**: $0.10-$0.50 typical
- **RPC Latency**: < 100ms for official nodes

---

## 📚 Additional Resources

- [Avalanche Documentation](https://docs.avax.network/)
- [Snowtrace Explorer](https://snowtrace.io/)
- [Avalanche Consensus](https://docs.avax.network/learn/avalanche/avalanche-consensus)
- [Subnet Development](https://docs.avax.network/build/subnet)
- [Avalanche Bridge](https://bridge.avax.network/)

---

## 🔗 Related Integrations

- [Ethereum](/capabilities/chain/integrations/ethereum/)
- [BNB Chain](/capabilities/chain/integrations/bnb/)
- [Polygon](/capabilities/chain/integrations/polygon/)

---

**Note**: All code examples reference operations defined in `openapi/chain.yaml`. Avalanche's sub-second finality and dynamic fee structure require specialized handling.
