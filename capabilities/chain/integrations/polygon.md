---
layout: docs
title: Polygon Integration Guide
permalink: /capabilities/chain/integrations/polygon/
---

# 🟣 Polygon Integration Guide

> Complete guide for integrating Polygon (formerly Matic) with Quub Exchange Chain Service. All operations reference `openapi/chain.yaml`.

## 📋 Overview

**Polygon** is a leading Ethereum Layer 2 scaling solution offering high throughput, low transaction costs, and full EVM compatibility. As a sidechain with its own consensus mechanism, it provides fast finality while maintaining strong security through regular checkpointing to Ethereum.

### Network Details

| Property            | Value                                              |
| ------------------- | -------------------------------------------------- |
| **Chain ID**        | 137 (Mainnet), 80002 (Amoy Testnet)                |
| **Native Currency** | POL (formerly MATIC)                               |
| **Decimals**        | 18                                                 |
| **Block Time**      | ~2 seconds                                         |
| **Consensus**       | Proof of Stake (Heimdall + Bor)                    |
| **Explorer**        | https://polygonscan.com                            |
| **RPC Providers**   | Polygon Official, Alchemy, Infura, QuickNode, Ankr |

---

## 🚀 Quick Start

### 1. Register Polygon Chain

```javascript
// Node.js - Register Polygon Mainnet
const registerPolygonChain = async (token) => {
  const response = await fetch("https://api.quub.exchange/v2/chains", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `polygon-mainnet-${Date.now()}`,
    },
    body: JSON.stringify({
      chainId: 137,
      name: "Polygon",
      shortName: "POLY",
      networkType: "MAINNET",
      layer: "L2",
      parentChainId: 1, // Ethereum mainnet
      nativeCurrency: "POL",
      decimals: 18,
      blockTime: 2,
      confirmations: 128, // ~4 minutes for high-value txs
      explorerUrl: "https://polygonscan.com",
      docsUrl: "https://docs.polygon.technology/",
      genesisHash:
        "0xa9c28ce2141b56c474f1dc504bee9b01eb1bd7d1a507580d5519d4437a97de1b",
      chainNamespace: "EVM",
      status: "ACTIVE",
      metadata: {
        consensusType: "pos",
        checkpointFrequency: 256, // Ethereum blocks between checkpoints
        validatorSet: "heimdall",
      },
    }),
  });

  return response.json();
};
```

```python
# Python - Register Polygon with sidechain metadata
import requests
import time

def register_polygon_chain(token):
    url = 'https://api.quub.exchange/v2/chains'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'Idempotency-Key': f'polygon-mainnet-{int(time.time())}'
    }
    payload = {
        'chainId': 137,
        'name': 'Polygon',
        'shortName': 'POLY',
        'networkType': 'MAINNET',
        'layer': 'L2',
        'parentChainId': 1,
        'nativeCurrency': 'POL',
        'decimals': 18,
        'blockTime': 2,
        'confirmations': 128,
        'explorerUrl': 'https://polygonscan.com',
        'docsUrl': 'https://docs.polygon.technology/',
        'genesisHash': '0xa9c28ce2141b56c474f1dc504bee9b01eb1bd7d1a507580d5519d4437a97de1b',
        'chainNamespace': 'EVM',
        'status': 'ACTIVE'
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

### 2. Configure RPC Adapters

```javascript
// Node.js - Setup Polygon RPC with multiple providers
const setupPolygonRPCAdapters = async (token, apiKeys = {}) => {
  const adapters = [
    {
      name: "Polygon Official Primary",
      rpcEndpoint: "https://polygon-rpc.com",
      signerPolicy: "MPC_CLUSTER",
      priority: 0,
    },
    {
      name: "Alchemy Polygon",
      rpcEndpoint: `https://polygon-mainnet.g.alchemy.com/v2/${
        apiKeys.alchemy || "YOUR_ALCHEMY_KEY"
      }`,
      wsEndpoint: `wss://polygon-mainnet.g.alchemy.com/v2/${
        apiKeys.alchemy || "YOUR_ALCHEMY_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 1,
    },
    {
      name: "Infura Polygon",
      rpcEndpoint: `https://polygon-mainnet.infura.io/v3/${
        apiKeys.infura || "YOUR_INFURA_KEY"
      }`,
      wsEndpoint: `wss://polygon-mainnet.infura.io/ws/v3/${
        apiKeys.infura || "YOUR_INFURA_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 2,
    },
    {
      name: "Ankr Polygon",
      rpcEndpoint: "https://rpc.ankr.com/polygon",
      signerPolicy: "MPC_CLUSTER",
      priority: 3,
    },
    {
      name: "QuickNode Polygon",
      rpcEndpoint:
        apiKeys.quicknode ||
        "https://your-quicknode-endpoint.matic.quiknode.pro/",
      signerPolicy: "MPC_CLUSTER",
      priority: 4,
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
          "Idempotency-Key": `polygon-${adapter.name
            .toLowerCase()
            .replace(/\s+/g, "-")}`,
        },
        body: JSON.stringify({
          chainId: 137,
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
# Python - Configure Polygon adapters with checkpoint awareness
def configure_polygon_adapters(token, api_keys=None):
    """Configure multiple Polygon RPC adapters"""
    url = 'https://api.quub.exchange/v2/chain/adapters'

    adapters_config = [
        {
            'name': 'Polygon Official',
            'rpcEndpoint': 'https://polygon-rpc.com',
            'priority': 0
        },
        {
            'name': 'Polygon Mumbai Backup',
            'rpcEndpoint': 'https://polygon-bor.publicnode.com',
            'priority': 3
        },
        {
            'name': 'Ankr Public',
            'rpcEndpoint': 'https://rpc.ankr.com/polygon',
            'priority': 4
        }
    ]

    # Add premium providers if API keys provided
    if api_keys:
        if 'alchemy' in api_keys:
            adapters_config.insert(0, {
                'name': 'Alchemy Polygon Primary',
                'rpcEndpoint': f"https://polygon-mainnet.g.alchemy.com/v2/{api_keys['alchemy']}",
                'wsEndpoint': f"wss://polygon-mainnet.g.alchemy.com/v2/{api_keys['alchemy']}",
                'priority': 1
            })

        if 'infura' in api_keys:
            adapters_config.insert(1, {
                'name': 'Infura Polygon',
                'rpcEndpoint': f"https://polygon-mainnet.infura.io/v3/{api_keys['infura']}",
                'wsEndpoint': f"wss://polygon-mainnet.infura.io/ws/v3/{api_keys['infura']}",
                'priority': 2
            })

    results = []
    for config in adapters_config:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json',
            'Idempotency-Key': f"polygon-{config['name'].lower().replace(' ', '-')}-{int(time.time())}"
        }

        payload = {
            'chainId': 137,
            'signerPolicy': 'MPC_CLUSTER',
            **config
        }

        response = requests.post(url, json=payload, headers=headers)
        results.append(response.json())

    return results
```

---

## 🏗️ Polygon-Specific Integration Patterns

### Checkpoint-Aware Transaction Finality

```javascript
// Node.js - Handle Polygon's checkpoint-based finality
class PolygonCheckpointManager {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.checkpointInterval = 256; // Ethereum blocks between checkpoints (~50 minutes)
    this.softConfirmations = 16; // For low-value transactions (~32 seconds)
    this.hardConfirmations = 128; // For high-value transactions (~4 minutes)
  }

  async recordTransactionWithFinality(txData, valueCategory = "standard") {
    // Record transaction
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `polygon-tx-${txData.hash}`,
        },
        body: JSON.stringify({
          chainId: 137,
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

    // Determine required confirmations based on value
    const requiredConfirmations = this.getRequiredConfirmations(valueCategory);

    // Wait for confirmations
    const finalized = await this.waitForConfirmations(
      txData.hash,
      requiredConfirmations
    );

    return {
      transaction: recorded,
      finalized: finalized.confirmations >= requiredConfirmations,
      confirmations: finalized.confirmations,
      checkpointed: finalized.checkpointed,
    };
  }

  getRequiredConfirmations(valueCategory) {
    const confirmationLevels = {
      low: 8, // ~16 seconds
      standard: 16, // ~32 seconds
      high: 128, // ~4 minutes (recommended before checkpoint)
      critical: 256, // Wait for checkpoint
    };

    return confirmationLevels[valueCategory] || this.softConfirmations;
  }

  async waitForConfirmations(txHash, requiredConfirmations) {
    const maxAttempts = Math.ceil(requiredConfirmations / 2); // Check every ~2 blocks

    for (let attempt = 0; attempt < maxAttempts; attempt++) {
      const tx = await this.getTransaction(txHash);

      if (tx && tx.blockNumber) {
        const currentBlock = await this.getCurrentBlock();
        const confirmations = currentBlock - tx.blockNumber;

        if (confirmations >= requiredConfirmations) {
          const checkpointed = await this.isCheckpointed(tx.blockNumber);

          return {
            hash: txHash,
            confirmations,
            checkpointed,
            finalityLevel: checkpointed ? "CHECKPOINTED" : "CONFIRMED",
          };
        }

        console.log(
          `Transaction ${txHash}: ${confirmations}/${requiredConfirmations} confirmations`
        );
      }

      // Wait for ~2 blocks
      await this.sleep(4000); // 2 blocks * 2 seconds
    }

    return {
      hash: txHash,
      confirmations: 0,
      checkpointed: false,
      finalityLevel: "TIMEOUT",
    };
  }

  async isCheckpointed(polygonBlockNumber) {
    // Check if block has been checkpointed to Ethereum
    // In production, this would query the checkpoint contract on Ethereum
    return false; // Placeholder
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

  async getCurrentBlock() {
    // This would call Polygon node
    return 52000000; // Example
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Usage
const checkpointManager = new PolygonCheckpointManager("org-uuid", token);

const polyTx = {
  hash: "0x1234567890abcdef...",
  from: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
  to: "0x8ba1f109551bD432803012645Ac136ddd64DBA72",
  value: "100",
  blockNumber: 52000000,
  gasPrice: "30000000000", // 30 Gwei
  nonce: 42,
  txFeeAmount: "0.00063",
};

// High-value transaction - wait for 128 confirmations
const result = await checkpointManager.recordTransactionWithFinality(
  polyTx,
  "high"
);
console.log(`Transaction finalized with ${result.confirmations} confirmations`);
console.log(`Checkpointed to Ethereum: ${result.checkpointed}`);
```

### PoS Bridge Operations

```python
# Python - Track Polygon PoS bridge deposits and withdrawals
class PolygonBridgeManager:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.l1_chain_id = 1  # Ethereum
        self.l2_chain_id = 137  # Polygon
        self.root_chain_manager = '0xA0c68C638235ee32657e8f720a23ceC1bFc77C77'  # Ethereum
        self.checkpoint_interval = 30  # minutes average

    def record_l1_deposit(self, tx_data: dict) -> dict:
        """Record deposit from Ethereum L1 to Polygon"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"polygon-l1-deposit-{tx_data['hash']}"
        }

        payload = {
            'chainId': self.l1_chain_id,
            'hash': tx_data['hash'],
            'fromAddress': tx_data['from'],
            'toAddress': self.root_chain_manager,
            'value': str(tx_data['value']),
            'direction': 'OUTBOUND',
            'status': 'CONFIRMED',
            'blockNumber': tx_data['blockNumber'],
            'gasPrice': str(tx_data['gasPrice']),
            'nonce': tx_data['nonce'],
            'txFeeAmount': str(tx_data.get('txFeeAmount', '0')),
            'refType': 'POLYGON_BRIDGE_DEPOSIT_L1',
            'source': 'NODE'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def record_l2_deposit_completion(self, l1_tx_hash: str, l2_tx_data: dict) -> dict:
        """Record deposit completion on Polygon (8-30 minutes after L1)"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"polygon-l2-deposit-{l2_tx_data['hash']}"
        }

        payload = {
            'chainId': self.l2_chain_id,
            'hash': l2_tx_data['hash'],
            'fromAddress': '0x0000000000000000000000000000000000000000',
            'toAddress': l2_tx_data['to'],
            'value': str(l2_tx_data['value']),
            'direction': 'INBOUND',
            'status': 'CONFIRMED',
            'blockNumber': l2_tx_data['blockNumber'],
            'gasPrice': '0',  # No gas cost for bridged deposit
            'refType': 'POLYGON_BRIDGE_DEPOSIT_L2',
            'refId': l1_tx_hash,
            'source': 'BRIDGE_MONITOR'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def record_l2_withdrawal_burn(self, tx_data: dict) -> dict:
        """Record withdrawal burn on Polygon"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"polygon-l2-withdrawal-{tx_data['hash']}"
        }

        payload = {
            'chainId': self.l2_chain_id,
            'hash': tx_data['hash'],
            'fromAddress': tx_data['from'],
            'toAddress': '0x0000000000000000000000000000000000000000',  # Burn
            'value': str(tx_data['value']),
            'direction': 'OUTBOUND',
            'status': 'CONFIRMED',
            'blockNumber': tx_data['blockNumber'],
            'gasPrice': str(tx_data['gasPrice']),
            'nonce': tx_data['nonce'],
            'txFeeAmount': str(tx_data.get('txFeeAmount', '0')),
            'refType': 'POLYGON_BRIDGE_WITHDRAWAL_L2',
            'source': 'NODE'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def record_l1_withdrawal_claim(self, l2_tx_hash: str, l1_tx_data: dict) -> dict:
        """Record withdrawal claim on Ethereum L1 (after checkpoint)"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"polygon-l1-withdrawal-{l1_tx_data['hash']}"
        }

        payload = {
            'chainId': self.l1_chain_id,
            'hash': l1_tx_data['hash'],
            'fromAddress': self.root_chain_manager,
            'toAddress': l1_tx_data['to'],
            'value': str(l1_tx_data['value']),
            'direction': 'INBOUND',
            'status': 'CONFIRMED',
            'blockNumber': l1_tx_data['blockNumber'],
            'gasPrice': str(l1_tx_data['gasPrice']),
            'refType': 'POLYGON_BRIDGE_WITHDRAWAL_L1',
            'refId': l2_tx_hash,
            'source': 'BRIDGE_MONITOR'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def estimate_deposit_time(self) -> dict:
        """Estimate time for deposit to complete"""
        return {
            'minimumMinutes': 7,
            'averageMinutes': 15,
            'maximumMinutes': 30,
            'note': 'Depends on Ethereum L1 congestion and checkpoint frequency'
        }

    def estimate_withdrawal_time(self) -> dict:
        """Estimate time for withdrawal to complete"""
        return {
            'checkpointWaitMinutes': 30,
            'challengePeriodMinutes': 0,  # No challenge period on Polygon
            'totalMinutes': 45,
            'note': 'Must wait for checkpoint to Ethereum L1, then claim'
        }

# Example usage
bridge_manager = PolygonBridgeManager('org-uuid', token)

# User deposits from Ethereum to Polygon
l1_deposit = {
    'hash': '0xabc123...',
    'from': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
    'value': 5.0,
    'blockNumber': 18500000,
    'gasPrice': 30000000000,
    'nonce': 42,
    'txFeeAmount': 0.00189
}

bridge_manager.record_l1_deposit(l1_deposit)
print("L1 deposit recorded")

# Deposit completes on Polygon (7-30 minutes later)
l2_completion = {
    'hash': '0xdef456...',
    'to': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
    'value': 5.0,
    'blockNumber': 52000000
}

bridge_manager.record_l2_deposit_completion('0xabc123...', l2_completion)
print("L2 deposit completed")

# Estimate times
deposit_time = bridge_manager.estimate_deposit_time()
withdrawal_time = bridge_manager.estimate_withdrawal_time()
print(f"Deposit time: {deposit_time['averageMinutes']} minutes average")
print(f"Withdrawal time: {withdrawal_time['totalMinutes']} minutes total")
```

### Low-Cost Transaction Optimization

```javascript
// Node.js - Optimize for Polygon's low transaction costs
class PolygonGasOptimizer {
  constructor() {
    this.minGasPrice = 30_000_000_000; // 30 Gwei typical minimum
    this.maxGasPrice = 500_000_000_000; // 500 Gwei maximum during congestion
  }

  async getOptimalGasPrice() {
    // Polygon gas prices vary but are generally low
    const networkGasPrice = await this.getNetworkGasPrice();

    // Add 10% buffer for faster inclusion
    const bufferedPrice = Math.floor(networkGasPrice * 1.1);

    // Clamp between min and max
    return Math.max(
      this.minGasPrice,
      Math.min(bufferedPrice, this.maxGasPrice)
    );
  }

  async getNetworkGasPrice() {
    // This would call Polygon node
    // web3.eth.getGasPrice()
    return 50_000_000_000; // 50 Gwei typical
  }

  estimateTransactionCost(gasLimit, gasPrice) {
    const costWei = gasLimit * gasPrice;
    const costPOL = costWei / 1e18;

    // Example: POL at $0.50
    const polPrice = 0.5;
    const costUSD = costPOL * polPrice;

    return {
      gasLimit,
      gasPriceGwei: gasPrice / 1e9,
      totalCostWei: costWei,
      totalCostPOL: costPOL,
      totalCostUSD: costUSD,
    };
  }

  compareToEthereum(gasLimit) {
    // Compare Polygon cost to Ethereum L1
    const polygonGas = 50_000_000_000; // 50 Gwei
    const polygonCost = this.estimateTransactionCost(gasLimit, polygonGas);

    const ethGas = 30_000_000_000; // 30 Gwei on Ethereum
    const ethCostWei = gasLimit * ethGas;
    const ethCostETH = ethCostWei / 1e18;
    const ethCostUSD = ethCostETH * 3000; // ETH at $3000

    const savings = ethCostUSD - polygonCost.totalCostUSD;
    const savingsPercent = (savings / ethCostUSD) * 100;

    return {
      polygon: polygonCost,
      ethereum: {
        totalCostETH: ethCostETH,
        totalCostUSD: ethCostUSD,
      },
      savings: {
        usd: savings,
        percent: savingsPercent,
      },
    };
  }
}

// Usage
const gasOptimizer = new PolygonGasOptimizer();

// Simple transfer on Polygon
const transferCost = gasOptimizer.estimateTransactionCost(
  21000,
  50_000_000_000
);
console.log(
  `Polygon transfer cost: ${transferCost.totalCostPOL.toFixed(
    6
  )} POL ($${transferCost.totalCostUSD.toFixed(4)})`
);

// Compare to Ethereum
const comparison = gasOptimizer.compareToEthereum(21000);
console.log(
  `Savings vs Ethereum: $${comparison.savings.usd.toFixed(
    2
  )} (${comparison.savings.percent.toFixed(2)}% cheaper)`
);
```

---

## 🔐 Security & Best Practices

### Validator Set Monitoring

```python
# Python - Monitor Polygon validator set health
class PolygonValidatorMonitor:
    def __init__(self, token: str):
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.validator_count = 100  # Approximate active validators

    def check_adapter_health(self) -> dict:
        """Check health of Polygon RPC adapters"""
        url = f'{self.base_url}/chain/adapters?chainId=137'
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
                'healthy': health.get('syncLag', 0) < 10
            })

        return {
            'totalAdapters': len(adapters),
            'healthyAdapters': sum(1 for h in health_data if h['healthy']),
            'details': health_data
        }

    def check_checkpoint_status(self) -> dict:
        """Monitor checkpoint submission to Ethereum"""
        return {
            'lastCheckpointBlock': 51900000,
            'lastCheckpointTime': '2024-03-08T11:30:00Z',
            'nextCheckpointEstimate': '2024-03-08T12:00:00Z',
            'checkpointInterval': 256,
            'healthy': True
        }

# Example usage
validator_monitor = PolygonValidatorMonitor(token)

adapter_health = validator_monitor.check_adapter_health()
print(f"Healthy adapters: {adapter_health['healthyAdapters']}/{adapter_health['totalAdapters']}")

checkpoint_status = validator_monitor.check_checkpoint_status()
print(f"Last checkpoint: block {checkpoint_status['lastCheckpointBlock']}")
```

---

## 🎯 Production Checklist

### Pre-Launch

- [ ] **Chain Registration**: Polygon registered with correct genesis hash
- [ ] **Parent Chain**: Ethereum (Chain ID 1) configured as parent
- [ ] **RPC Diversity**: Multiple providers (Official, Alchemy, Infura, Ankr, QuickNode)
- [ ] **Confirmation Strategy**: Tiered confirmations (8/16/128) based on value
- [ ] **Bridge Monitoring**: PoS bridge deposit/withdrawal tracking
- [ ] **Checkpoint Awareness**: 256-block checkpoint intervals documented
- [ ] **Low Gas Costs**: $0.01-$0.10 transaction costs validated
- [ ] **Validator Health**: Monitoring for 100+ validators
- [ ] **Testnet Validation**: Fully tested on Amoy Testnet (Chain ID 80002)

### Monitoring Metrics

- **Block Time**: ~2 seconds
- **Soft Finality**: 16 blocks (~32 seconds)
- **Hard Finality**: 128 blocks (~4 minutes)
- **Checkpoint**: 256 blocks (~8.5 minutes)
- **Gas Price**: 30-100 Gwei typical
- **Transaction Cost**: $0.01-$0.05 typical

---

## 📚 Additional Resources

- [Polygon Documentation](https://docs.polygon.technology/)
- [Polygon PoS Bridge](https://wallet.polygon.technology/polygon/bridge)
- [PolygonScan Explorer](https://polygonscan.com/)
- [Polygon Gas Tracker](https://polygonscan.com/gastracker)
- [Checkpoint Contract](https://etherscan.io/address/0x86e4dc95c7fbdbf52e33d563bbdb00823894c287)

---

## 🔗 Related Integrations

- [Ethereum (Parent Chain)](/capabilities/chain/integrations/ethereum/)
- [Polygon zkEVM](/capabilities/chain/integrations/polygon-zkevm/)
- [Arbitrum](/capabilities/chain/integrations/arbitrum/)
- [Optimism](/capabilities/chain/integrations/optimism/)

---

**Note**: All code examples reference operations defined in `openapi/chain.yaml`. Polygon's checkpoint-based finality and PoS bridge require careful handling of confirmation depths and cross-chain operations.
