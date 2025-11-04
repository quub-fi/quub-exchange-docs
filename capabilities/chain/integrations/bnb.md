---
layout: docs
title: BNB Chain Integration Guide
permalink: /capabilities/chain/integrations/bnb/
---

# 🟡 BNB Chain Integration Guide

> Complete guide for integrating BNB Chain (formerly Binance Smart Chain) with Quub Exchange Chain Service. All operations reference `openapi/chain.yaml`.

## 📋 Overview

**BNB Chain** is a high-performance blockchain optimized for DeFi and high-throughput applications. As an EVM-compatible L1 network, it offers fast block times and low transaction costs while maintaining compatibility with Ethereum tooling.

### Network Details

| Property            | Value                              |
| ------------------- | ---------------------------------- |
| **Chain ID**        | 56 (Mainnet), 97 (Testnet)         |
| **Native Currency** | BNB                                |
| **Decimals**        | 18                                 |
| **Block Time**      | ~3 seconds                         |
| **Consensus**       | Proof of Staked Authority (PoSA)   |
| **Explorer**        | https://bscscan.com                |
| **RPC Providers**   | Binance, Ankr, NodeReal, QuickNode |

---

## 🚀 Quick Start

### 1. Register BNB Chain

```javascript
// Node.js - Register BNB Chain Mainnet
const registerBNBChain = async (token) => {
  const response = await fetch("https://api.quub.exchange/v2/chains", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `bnb-mainnet-${Date.now()}`,
    },
    body: JSON.stringify({
      chainId: 56,
      name: "BNB Smart Chain",
      shortName: "BSC",
      networkType: "MAINNET",
      layer: "L1",
      nativeCurrency: "BNB",
      decimals: 18,
      blockTime: 3,
      confirmations: 15, // Higher due to faster blocks
      explorerUrl: "https://bscscan.com",
      docsUrl: "https://docs.bnbchain.org/",
      genesisHash:
        "0x0d21840abff46b96c84b2ac9e10e4f5cdaeb5693cb665db62a2f3b02d2d57b5b",
      chainNamespace: "EVM",
      status: "ACTIVE",
    }),
  });

  return response.json();
};
```

```python
# Python - Register BNB Chain with comprehensive config
import requests
import time

def register_bnb_chain(token):
    url = 'https://api.quub.exchange/v2/chains'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'Idempotency-Key': f'bnb-mainnet-{int(time.time())}'
    }
    payload = {
        'chainId': 56,
        'name': 'BNB Smart Chain',
        'shortName': 'BSC',
        'networkType': 'MAINNET',
        'layer': 'L1',
        'nativeCurrency': 'BNB',
        'decimals': 18,
        'blockTime': 3,
        'confirmations': 15,
        'explorerUrl': 'https://bscscan.com',
        'docsUrl': 'https://docs.bnbchain.org/',
        'genesisHash': '0x0d21840abff46b96c84b2ac9e10e4f5cdaeb5693cb665db62a2f3b02d2d57b5b',
        'chainNamespace': 'EVM',
        'status': 'ACTIVE'
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

### 2. Configure RPC Adapters

```javascript
// Node.js - Setup BNB Chain RPC with multiple providers
const setupBNBRPCAdapters = async (token) => {
  const adapters = [
    {
      name: "Binance Official Primary",
      rpcEndpoint: "https://bsc-dataseed.binance.org/",
      signerPolicy: "MPC_CLUSTER",
      priority: 0,
    },
    {
      name: "Ankr BNB Backup",
      rpcEndpoint: "https://rpc.ankr.com/bsc",
      signerPolicy: "MPC_CLUSTER",
      priority: 1,
    },
    {
      name: "NodeReal Fallback",
      rpcEndpoint: `https://bsc-mainnet.nodereal.io/v1/${process.env.NODEREAL_API_KEY}`,
      signerPolicy: "MPC_CLUSTER",
      priority: 2,
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
          "Idempotency-Key": `bnb-${adapter.name
            .toLowerCase()
            .replace(/\s/g, "-")}`,
        },
        body: JSON.stringify({
          chainId: 56,
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
# Python - Configure BNB Chain adapters with health monitoring
def configure_bnb_adapters(token, api_keys=None):
    """Configure multiple BNB Chain RPC adapters"""
    url = 'https://api.quub.exchange/v2/chain/adapters'

    adapters_config = [
        {
            'name': 'Binance Official Primary',
            'rpcEndpoint': 'https://bsc-dataseed1.binance.org/',
            'wsEndpoint': 'wss://bsc-ws-node.nariox.org:443',
            'priority': 0
        },
        {
            'name': 'Binance Backup 1',
            'rpcEndpoint': 'https://bsc-dataseed2.binance.org/',
            'priority': 1
        },
        {
            'name': 'Ankr Public',
            'rpcEndpoint': 'https://rpc.ankr.com/bsc',
            'priority': 2
        }
    ]

    # Add NodeReal if API key provided
    if api_keys and 'nodereal' in api_keys:
        adapters_config.append({
            'name': 'NodeReal Premium',
            'rpcEndpoint': f"https://bsc-mainnet.nodereal.io/v1/{api_keys['nodereal']}",
            'wsEndpoint': f"wss://bsc-mainnet.nodereal.io/ws/v1/{api_keys['nodereal']}",
            'priority': 0  # Make this primary if paid tier
        })

    results = []
    for config in adapters_config:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json',
            'Idempotency-Key': f"bnb-{config['name'].lower().replace(' ', '-')}-{int(time.time())}"
        }

        payload = {
            'chainId': 56,
            'signerPolicy': 'MPC_CLUSTER',
            **config
        }

        response = requests.post(url, json=payload, headers=headers)
        results.append(response.json())

    return results
```

---

## 🏗️ BNB-Specific Integration Patterns

### Fast Block Time Handling

```javascript
// Node.js - Handle BNB Chain's fast block times
class BNBTransactionMonitor {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.blockTime = 3; // 3-second blocks
    this.confirmationsRequired = 15; // ~45 seconds for finality
  }

  async pollTransactionStatus(txHash, maxAttempts = 20) {
    for (let attempt = 0; attempt < maxAttempts; attempt++) {
      const tx = await this.getTransaction(txHash);

      if (tx && tx.blockNumber) {
        const currentBlock = await this.getCurrentBlock();
        const confirmations = currentBlock - tx.blockNumber;

        if (confirmations >= this.confirmationsRequired) {
          await this.updateTransactionStatus(tx.id, "CONFIRMED");
          return { status: "CONFIRMED", confirmations };
        }

        console.log(
          `Transaction ${txHash}: ${confirmations}/${this.confirmationsRequired} confirmations`
        );
      }

      // Wait for ~2 blocks before checking again
      await this.sleep(this.blockTime * 2 * 1000);
    }

    return { status: "PENDING", confirmations: 0 };
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
    // This would call your BNB Chain node
    // web3.eth.getBlockNumber()
    return 35000000; // Example
  }

  async updateTransactionStatus(txId, status) {
    // Implementation for updating transaction status
    console.log(`Updated transaction ${txId} to ${status}`);
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Usage
const monitor = new BNBTransactionMonitor("org-uuid", token);
const result = await monitor.pollTransactionStatus("0xabc123...");
```

### BEP-20 Token Operations

```python
# Python - Handle BEP-20 token transfers on BNB Chain
class BNBTokenManager:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.chain_id = 56

    def record_bep20_transfer(self, tx_data: dict) -> dict:
        """Record BEP-20 token transfer transaction"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"bnb-bep20-{tx_data['hash']}"
        }

        # BEP-20 transfer typically has 0 BNB value (tokens transferred via contract)
        payload = {
            'chainId': self.chain_id,
            'hash': tx_data['hash'],
            'fromAddress': tx_data['from'],
            'toAddress': tx_data['token_contract'],  # Token contract address
            'value': '0',  # No BNB transferred
            'direction': tx_data.get('direction', 'OUTBOUND'),
            'status': 'PENDING',
            'blockNumber': tx_data.get('blockNumber'),
            'gasPrice': str(tx_data['gasPrice']),
            'nonce': tx_data['nonce'],
            'txFeeAmount': self.calculate_bnb_fee(
                tx_data.get('gasUsed', 65000),  # BEP-20 typical gas
                tx_data['gasPrice']
            ),
            'source': 'NODE'
        }

        # Add token-specific metadata if tracking
        if 'token_symbol' in tx_data:
            payload['refType'] = 'TOKEN_TRANSFER'
            # Could store token details in a separate system

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def calculate_bnb_fee(self, gas_used: int, gas_price: int) -> str:
        """Calculate transaction fee in BNB"""
        fee_wei = gas_used * gas_price
        fee_bnb = fee_wei / 1e18
        return str(fee_bnb)

    def record_bulk_transfers(self, transfers: list) -> list:
        """Record multiple BEP-20 transfers efficiently"""
        results = []
        for transfer in transfers:
            try:
                result = self.record_bep20_transfer(transfer)
                results.append(result)
            except Exception as e:
                print(f"Error recording transfer {transfer['hash']}: {e}")
                results.append({'error': str(e), 'hash': transfer['hash']})

        return results

# Example usage
token_manager = BNBTokenManager('org-uuid', token)

# USDT transfer on BNB Chain
usdt_transfer = {
    'hash': '0x1234567890abcdef...',
    'from': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
    'token_contract': '0x55d398326f99059fF775485246999027B3197955',  # USDT on BSC
    'gasPrice': 5000000000,  # 5 Gwei
    'nonce': 42,
    'token_symbol': 'USDT',
    'token_amount': '1000.00',
    'direction': 'OUTBOUND'
}

result = token_manager.record_bep20_transfer(usdt_transfer)
```

### Low Gas Cost Optimization

```javascript
// Node.js - Optimize for BNB Chain's low gas costs
class BNBGasOptimizer {
  constructor() {
    this.minGasPrice = 3_000_000_000; // 3 Gwei minimum
    this.maxGasPrice = 20_000_000_000; // 20 Gwei maximum
  }

  async getOptimalGasPrice() {
    // BNB Chain typically has very low gas prices
    // Check current network gas price
    const networkGasPrice = await this.getNetworkGasPrice();

    // Add small buffer for faster inclusion
    const bufferedPrice = Math.floor(networkGasPrice * 1.1);

    // Clamp between min and max
    return Math.max(
      this.minGasPrice,
      Math.min(bufferedPrice, this.maxGasPrice)
    );
  }

  async getNetworkGasPrice() {
    // This would call your BNB Chain node
    // web3.eth.getGasPrice()
    return 5_000_000_000; // 5 Gwei typical
  }

  estimateTransactionCost(gasLimit, gasPrice) {
    const costWei = gasLimit * gasPrice;
    const costBNB = costWei / 1e18;

    // Example: BNB at $300
    const bnbPrice = 300;
    const costUSD = costBNB * bnbPrice;

    return {
      gasLimit,
      gasPriceGwei: gasPrice / 1e9,
      totalCostWei: costWei,
      totalCostBNB: costBNB,
      totalCostUSD: costUSD,
    };
  }

  async recordTransactionWithGasCost(orgId, token, txData) {
    const gasPrice = await this.getOptimalGasPrice();
    const gasEstimate = this.estimateTransactionCost(
      txData.gasLimit || 21000,
      parseInt(txData.gasPrice || gasPrice)
    );

    const response = await fetch(
      `https://api.quub.exchange/v2/orgs/${orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
          "X-Org-Id": orgId,
          "Idempotency-Key": `bnb-tx-${txData.hash}`,
        },
        body: JSON.stringify({
          chainId: 56,
          hash: txData.hash,
          fromAddress: txData.from,
          toAddress: txData.to,
          value: txData.value,
          direction: txData.direction || "OUTBOUND",
          status: "PENDING",
          gasPrice: String(gasEstimate.gasPriceGwei * 1e9),
          txFeeAmount: String(gasEstimate.totalCostBNB),
          txFeeUsd: String(gasEstimate.totalCostUSD),
          source: "NODE",
        }),
      }
    );

    return response.json();
  }
}

// Usage
const gasOptimizer = new BNBGasOptimizer();
const optimalGas = await gasOptimizer.getOptimalGasPrice();
console.log(`Optimal BNB Chain gas price: ${optimalGas / 1e9} Gwei`);

const cost = gasOptimizer.estimateTransactionCost(21000, optimalGas);
console.log(
  `Transaction cost: ${cost.totalCostBNB.toFixed(
    6
  )} BNB ($${cost.totalCostUSD.toFixed(4)})`
);
```

---

## 🔐 Security Considerations

### MEV Protection on BNB Chain

```python
# Python - Implement MEV-aware transaction submission
class BNBMEVProtection:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'

    def estimate_mev_risk(self, tx_data: dict) -> str:
        """Estimate MEV risk level for transaction"""
        value = float(tx_data.get('value', 0))

        # High value transactions are more attractive to MEV bots
        if value > 100:  # > 100 BNB
            return 'HIGH'
        elif value > 10:  # > 10 BNB
            return 'MEDIUM'
        else:
            return 'LOW'

    def use_private_rpc(self, tx_data: dict) -> bool:
        """Determine if transaction should use private RPC"""
        risk = self.estimate_mev_risk(tx_data)

        # Use private RPC for high-value or sensitive transactions
        return risk in ['HIGH', 'MEDIUM']

    def record_protected_transaction(self, tx_data: dict) -> dict:
        """Record transaction with MEV protection metadata"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"bnb-protected-{tx_data['hash']}"
        }

        mev_risk = self.estimate_mev_risk(tx_data)
        used_private_rpc = self.use_private_rpc(tx_data)

        payload = {
            'chainId': 56,
            'hash': tx_data['hash'],
            'fromAddress': tx_data['from'],
            'toAddress': tx_data['to'],
            'value': str(tx_data['value']),
            'direction': tx_data.get('direction', 'OUTBOUND'),
            'status': 'PENDING',
            'blockNumber': tx_data.get('blockNumber'),
            'gasPrice': str(tx_data['gasPrice']),
            'nonce': tx_data['nonce'],
            'txFeeAmount': str(tx_data.get('txFeeAmount', '0')),
            'source': 'NODE',
            # Store MEV protection info in syncVersion or custom field
            'syncVersion': f"mev-risk-{mev_risk.lower()}"
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

# Usage
mev_protection = BNBMEVProtection('org-uuid', token)

high_value_tx = {
    'hash': '0xabc123...',
    'from': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
    'to': '0x8ba1f109551bD432803012645Ac136ddd64DBA72',
    'value': 150,  # 150 BNB - high value
    'gasPrice': 5000000000,
    'nonce': 42
}

result = mev_protection.record_protected_transaction(high_value_tx)
```

### Validator Monitoring

```javascript
// Node.js - Monitor BNB Chain validator set
class BNBValidatorMonitor {
  constructor(token) {
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.validatorCount = 21; // BNB Chain active validators
  }

  async getChainHealth() {
    const response = await fetch(`${this.baseUrl}/chain/health`, {
      headers: {
        Authorization: `Bearer ${this.token}`,
      },
    });

    return response.json();
  }

  async monitorBNBAdapters() {
    // Get all BNB Chain adapters
    const response = await fetch(`${this.baseUrl}/chain/adapters?chainId=56`, {
      headers: {
        Authorization: `Bearer ${this.token}`,
      },
    });

    const adapters = (await response.json()).data;

    // Check each adapter's health
    const healthChecks = await Promise.all(
      adapters.map(async (adapter) => {
        const healthResponse = await fetch(
          `${this.baseUrl}/chain/adapters/${adapter.id}/health`,
          {
            headers: {
              Authorization: `Bearer ${this.token}`,
            },
          }
        );

        const health = await healthResponse.json();
        return {
          name: adapter.name,
          priority: adapter.priority,
          ...health.data,
        };
      })
    );

    // Analyze sync status
    const syncedAdapters = healthChecks.filter((h) => h.syncLag < 5);

    if (syncedAdapters.length === 0) {
      this.alert("CRITICAL: No BNB Chain adapters are in sync!");
    } else if (syncedAdapters.length < adapters.length / 2) {
      this.alert("WARNING: Less than 50% of BNB Chain adapters are in sync");
    }

    return {
      totalAdapters: adapters.length,
      syncedAdapters: syncedAdapters.length,
      averageLatency:
        healthChecks.reduce((sum, h) => sum + h.latencyMs, 0) /
        healthChecks.length,
      details: healthChecks,
    };
  }

  alert(message) {
    console.error(`[ALERT] ${message}`);
    // Implement alerting (Slack, PagerDuty, etc.)
  }
}

// Usage
const validatorMonitor = new BNBValidatorMonitor(token);
const status = await validatorMonitor.monitorBNBAdapters();
console.log(
  `BNB Chain: ${status.syncedAdapters}/${status.totalAdapters} adapters synced`
);
```

---

## 📊 Performance Optimization

### Batch Transaction Processing

```python
# Python - Efficient batch processing for BNB Chain's high throughput
class BNBBatchProcessor:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.batch_size = 50  # Process 50 transactions per batch

    def process_transaction_batch(self, transactions: list) -> dict:
        """Process a batch of transactions efficiently"""
        results = {
            'successful': [],
            'failed': [],
            'total': len(transactions)
        }

        for i in range(0, len(transactions), self.batch_size):
            batch = transactions[i:i + self.batch_size]
            batch_results = self._process_batch(batch)

            results['successful'].extend(batch_results['successful'])
            results['failed'].extend(batch_results['failed'])

        return results

    def _process_batch(self, batch: list) -> dict:
        """Process a single batch of transactions"""
        successful = []
        failed = []

        for tx in batch:
            try:
                result = self.record_transaction(tx)
                successful.append(result)
            except Exception as e:
                failed.append({
                    'transaction': tx,
                    'error': str(e)
                })

        return {'successful': successful, 'failed': failed}

    def record_transaction(self, tx_data: dict) -> dict:
        """Record a single transaction"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"bnb-batch-{tx_data['hash']}"
        }

        payload = {
            'chainId': 56,
            'hash': tx_data['hash'],
            'fromAddress': tx_data['from'],
            'toAddress': tx_data['to'],
            'value': str(tx_data['value']),
            'direction': tx_data.get('direction', 'OUTBOUND'),
            'status': tx_data.get('status', 'PENDING'),
            'blockNumber': tx_data.get('blockNumber'),
            'gasPrice': str(tx_data['gasPrice']),
            'nonce': tx_data['nonce'],
            'txFeeAmount': str(tx_data.get('txFeeAmount', '0')),
            'source': 'INDEXER'  # Batch processing typically from indexer
        }

        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()

    def get_transaction_stats(self, results: dict) -> dict:
        """Generate statistics from batch processing results"""
        return {
            'total_processed': results['total'],
            'successful': len(results['successful']),
            'failed': len(results['failed']),
            'success_rate': (len(results['successful']) / results['total'] * 100) if results['total'] > 0 else 0
        }

# Example usage
batch_processor = BNBBatchProcessor('org-uuid', token)

# Simulate processing 200 transactions
transactions = [
    {
        'hash': f'0x{i:064x}',
        'from': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
        'to': '0x8ba1f109551bD432803012645Ac136ddd64DBA72',
        'value': 1.5,
        'gasPrice': 5000000000,
        'nonce': i,
        'blockNumber': 35000000 + i
    }
    for i in range(200)
]

results = batch_processor.process_transaction_batch(transactions)
stats = batch_processor.get_transaction_stats(results)
print(f"Processed {stats['total_processed']} transactions: {stats['success_rate']:.2f}% success rate")
```

---

## 🎯 Production Checklist

### Pre-Launch

- [ ] **Chain Registration**: BNB Chain registered with correct genesis hash
- [ ] **RPC Diversity**: Multiple RPC providers configured (Binance, Ankr, NodeReal)
- [ ] **Fast Block Handling**: 3-second block time accounted for in polling logic
- [ ] **Confirmation Depth**: 15 confirmations configured for finality
- [ ] **Gas Price Optimization**: Dynamic gas pricing implemented (3-20 Gwei range)
- [ ] **BEP-20 Support**: Token transfer tracking configured
- [ ] **MEV Protection**: High-value transaction protection implemented
- [ ] **Batch Processing**: High-throughput transaction recording operational
- [ ] **Health Monitoring**: Adapter sync lag monitoring < 5 blocks
- [ ] **Testnet Validation**: Fully tested on BSC Testnet (Chain ID 97)

### Monitoring Metrics

- **Block Time**: ~3 seconds average
- **RPC Latency**: < 50ms for in-region providers
- **Sync Lag**: < 5 blocks
- **Confirmation Time**: ~45 seconds (15 blocks)
- **Gas Price Range**: 3-10 Gwei typical
- **Transaction Throughput**: 100+ TPS

---

## 📚 Additional Resources

- [BNB Chain Documentation](https://docs.bnbchain.org/)
- [BSCScan API](https://docs.bscscan.com/)
- [BEP-20 Token Standard](https://github.com/bnb-chain/BEPs/blob/master/BEP20.md)
- [NodeReal API](https://docs.nodereal.io/docs/getting-started)
- [BNB Chain RPC Endpoints](https://docs.bnbchain.org/docs/rpc)
- [BSC Gas Tracker](https://bscscan.com/gastracker)

---

## 🔗 Related Integrations

- [Ethereum](/capabilities/chain/integrations/ethereum/)
- [opBNB (BNB Layer 2)](/capabilities/chain/integrations/opbnb/)
- [Polygon](/capabilities/chain/integrations/polygon/)

---

**Note**: All code examples reference operations defined in `openapi/chain.yaml`. BNB Chain's fast block times and low gas costs require adapted confirmation depths and polling intervals.
