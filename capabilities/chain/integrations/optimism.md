---
layout: docs
title: Optimism Integration Guide
permalink: /capabilities/chain/integrations/optimism/
---

# 🔴 Optimism Integration Guide

> Complete guide for integrating Optimism with Quub Exchange Chain Service. All operations reference `openapi/chain.yaml`.

## 📋 Overview

**Optimism** is an Ethereum Layer 2 optimistic rollup built on the OP Stack, offering low-cost transactions, fast block times, and full EVM equivalence. As a foundational L2 solution, Optimism pioneered the optimistic rollup design and powers a growing ecosystem of chains.

### Network Details

| Property            | Value                                               |
| ------------------- | --------------------------------------------------- |
| **Chain ID**        | 10 (Mainnet), 11155420 (Sepolia Testnet)            |
| **Native Currency** | ETH                                                 |
| **Decimals**        | 18                                                  |
| **Block Time**      | ~2 seconds                                          |
| **Consensus**       | Optimistic Rollup (Fault Proofs)                    |
| **Explorer**        | https://optimistic.etherscan.io                     |
| **RPC Providers**   | Optimism Official, Alchemy, Infura, QuickNode, Ankr |
| **L1 Settlement**   | Ethereum                                            |

---

## 🚀 Quick Start

### 1. Register Optimism Chain

```javascript
// Node.js - Register Optimism Mainnet
const registerOptimismChain = async (token) => {
  const response = await fetch("https://api.quub.exchange/v2/chains", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `optimism-mainnet-${Date.now()}`,
    },
    body: JSON.stringify({
      chainId: 10,
      name: "Optimism",
      shortName: "OP",
      networkType: "MAINNET",
      layer: "L2",
      parentChainId: 1, // Ethereum mainnet
      nativeCurrency: "ETH",
      decimals: 18,
      blockTime: 2,
      confirmations: 1, // Fast L2 confirmations
      explorerUrl: "https://optimistic.etherscan.io",
      docsUrl: "https://docs.optimism.io/",
      genesisHash:
        "0x7ca38a1916c42007829c55e69d3e9a73265554b586a499015373241b8a3fa48b",
      chainNamespace: "EVM",
      status: "ACTIVE",
      metadata: {
        rollupType: "OPTIMISTIC",
        l1SettlementChain: "ETHEREUM",
        sequencerUrl: "https://mainnet-sequencer.optimism.io",
        challengePeriod: 604800, // 7 days in seconds
        framework: "OP_STACK",
      },
    }),
  });

  return response.json();
};
```

```python
# Python - Register Optimism with OP Stack metadata
import requests
import time

def register_optimism_chain(token):
    url = 'https://api.quub.exchange/v2/chains'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'Idempotency-Key': f'optimism-mainnet-{int(time.time())}'
    }
    payload = {
        'chainId': 10,
        'name': 'Optimism',
        'shortName': 'OP',
        'networkType': 'MAINNET',
        'layer': 'L2',
        'parentChainId': 1,
        'nativeCurrency': 'ETH',
        'decimals': 18,
        'blockTime': 2,
        'confirmations': 1,
        'explorerUrl': 'https://optimistic.etherscan.io',
        'docsUrl': 'https://docs.optimism.io/',
        'genesisHash': '0x7ca38a1916c42007829c55e69d3e9a73265554b586a499015373241b8a3fa48b',
        'chainNamespace': 'EVM',
        'status': 'ACTIVE'
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

### 2. Configure RPC Adapters

```javascript
// Node.js - Setup Optimism RPC with multiple providers
const setupOptimismRPCAdapters = async (token, apiKeys = {}) => {
  const adapters = [
    {
      name: "Optimism Official Primary",
      rpcEndpoint: "https://mainnet.optimism.io",
      signerPolicy: "MPC_CLUSTER",
      priority: 0,
    },
    {
      name: "Alchemy Optimism",
      rpcEndpoint: `https://opt-mainnet.g.alchemy.com/v2/${
        apiKeys.alchemy || "YOUR_ALCHEMY_KEY"
      }`,
      wsEndpoint: `wss://opt-mainnet.g.alchemy.com/v2/${
        apiKeys.alchemy || "YOUR_ALCHEMY_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 1,
    },
    {
      name: "Infura Optimism",
      rpcEndpoint: `https://optimism-mainnet.infura.io/v3/${
        apiKeys.infura || "YOUR_INFURA_KEY"
      }`,
      wsEndpoint: `wss://optimism-mainnet.infura.io/ws/v3/${
        apiKeys.infura || "YOUR_INFURA_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 2,
    },
    {
      name: "Ankr Optimism",
      rpcEndpoint: "https://rpc.ankr.com/optimism",
      signerPolicy: "MPC_CLUSTER",
      priority: 3,
    },
    {
      name: "QuickNode Optimism",
      rpcEndpoint:
        apiKeys.quicknode ||
        "https://your-quicknode-endpoint.optimism.quiknode.pro/",
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
          "Idempotency-Key": `optimism-${adapter.name
            .toLowerCase()
            .replace(/\s+/g, "-")}`,
        },
        body: JSON.stringify({
          chainId: 10,
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
# Python - Configure Optimism adapters with OP Stack awareness
def configure_optimism_adapters(token, api_keys=None):
    """Configure multiple Optimism RPC adapters"""
    url = 'https://api.quub.exchange/v2/chain/adapters'

    adapters_config = [
        {
            'name': 'Optimism Official',
            'rpcEndpoint': 'https://mainnet.optimism.io',
            'priority': 0
        },
        {
            'name': 'Ankr Public',
            'rpcEndpoint': 'https://rpc.ankr.com/optimism',
            'priority': 3
        }
    ]

    # Add premium providers if API keys provided
    if api_keys:
        if 'alchemy' in api_keys:
            adapters_config.insert(0, {
                'name': 'Alchemy Optimism Primary',
                'rpcEndpoint': f"https://opt-mainnet.g.alchemy.com/v2/{api_keys['alchemy']}",
                'wsEndpoint': f"wss://opt-mainnet.g.alchemy.com/v2/{api_keys['alchemy']}",
                'priority': 1
            })

        if 'infura' in api_keys:
            adapters_config.insert(1, {
                'name': 'Infura Optimism',
                'rpcEndpoint': f"https://optimism-mainnet.infura.io/v3/{api_keys['infura']}",
                'wsEndpoint': f"wss://optimism-mainnet.infura.io/ws/v3/{api_keys['infura']}",
                'priority': 2
            })

    results = []
    for config in adapters_config:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json',
            'Idempotency-Key': f"optimism-{config['name'].lower().replace(' ', '-')}-{int(time.time())}"
        }

        payload = {
            'chainId': 10,
            'signerPolicy': 'MPC_CLUSTER',
            **config
        }

        response = requests.post(url, json=payload, headers=headers)
        results.append(response.json())

    return results
```

---

## 🏗️ Optimism-Specific Integration Patterns

### Standard Bridge Operations

```javascript
// Node.js - Track Optimism Standard Bridge deposits and withdrawals
class OptimismBridgeMonitor {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.l1ChainId = 1; // Ethereum
    this.l2ChainId = 10; // Optimism
    this.l1StandardBridge = "0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1";
    this.challengePeriod = 604800; // 7 days
  }

  async recordL1Deposit(txData) {
    // Record deposit from Ethereum L1 to Optimism L2
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `optimism-l1-deposit-${txData.hash}`,
        },
        body: JSON.stringify({
          chainId: this.l1ChainId,
          hash: txData.hash,
          fromAddress: txData.from,
          toAddress: this.l1StandardBridge,
          value: txData.value,
          direction: "OUTBOUND",
          status: "CONFIRMED",
          blockNumber: txData.blockNumber,
          gasPrice: txData.gasPrice,
          nonce: txData.nonce,
          txFeeAmount: txData.txFeeAmount,
          refType: "OPTIMISM_BRIDGE_DEPOSIT_L1",
          source: "NODE",
        }),
      }
    );

    return response.json();
  }

  async recordL2DepositCompletion(l1TxHash, l2TxHash, value, l2BlockNumber) {
    // Record deposit completion on Optimism (typically 1-5 minutes)
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `optimism-l2-deposit-${l2TxHash}`,
        },
        body: JSON.stringify({
          chainId: this.l2ChainId,
          hash: l2TxHash,
          fromAddress: "0x0000000000000000000000000000000000000000",
          toAddress: "0x...", // User's Optimism address
          value: value,
          direction: "INBOUND",
          status: "CONFIRMED",
          blockNumber: l2BlockNumber,
          gasPrice: "0", // No gas cost for bridged deposit
          refType: "OPTIMISM_BRIDGE_DEPOSIT_L2",
          refId: l1TxHash,
          source: "BRIDGE_MONITOR",
        }),
      }
    );

    return response.json();
  }

  async recordL2WithdrawalInitiation(txData) {
    // Record withdrawal initiation on Optimism L2
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `optimism-l2-withdrawal-${txData.hash}`,
        },
        body: JSON.stringify({
          chainId: this.l2ChainId,
          hash: txData.hash,
          fromAddress: txData.from,
          toAddress: "0x4200000000000000000000000000000000000010", // L2StandardBridge
          value: txData.value,
          direction: "OUTBOUND",
          status: "CONFIRMED",
          blockNumber: txData.blockNumber,
          gasPrice: txData.gasPrice,
          nonce: txData.nonce,
          txFeeAmount: txData.txFeeAmount,
          refType: "OPTIMISM_BRIDGE_WITHDRAWAL_L2",
          source: "NODE",
        }),
      }
    );

    return response.json();
  }

  async recordL1WithdrawalFinalization(l2TxHash, l1TxData) {
    // Record withdrawal finalization on Ethereum L1 (after 7-day challenge period)
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `optimism-l1-withdrawal-${l1TxData.hash}`,
        },
        body: JSON.stringify({
          chainId: this.l1ChainId,
          hash: l1TxData.hash,
          fromAddress: this.l1StandardBridge,
          toAddress: l1TxData.to,
          value: l1TxData.value,
          direction: "INBOUND",
          status: "CONFIRMED",
          blockNumber: l1TxData.blockNumber,
          gasPrice: l1TxData.gasPrice,
          refType: "OPTIMISM_BRIDGE_WITHDRAWAL_L1",
          refId: l2TxHash,
          source: "BRIDGE_MONITOR",
        }),
      }
    );

    return response.json();
  }

  estimateBridgeTimes() {
    return {
      deposit: {
        minimumMinutes: 1,
        averageMinutes: 3,
        maximumMinutes: 10,
        note: "Fast deposits on Optimism",
      },
      withdrawal: {
        challengePeriodDays: 7,
        challengePeriodSeconds: this.challengePeriod,
        note: "Must wait 7 days for fault proof window",
      },
    };
  }
}

// Usage
const bridgeMonitor = new OptimismBridgeMonitor("org-uuid", token);

const l1Deposit = {
  hash: "0xabc123...",
  from: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
  value: "2.0",
  blockNumber: 18500000,
  gasPrice: "30000000000",
  nonce: 42,
  txFeeAmount: "0.00189",
};

await bridgeMonitor.recordL1Deposit(l1Deposit);
console.log("L1 deposit recorded, waiting for L2 completion...");

// Estimate bridge times
const times = bridgeMonitor.estimateBridgeTimes();
console.log(`Deposit time: ~${times.deposit.averageMinutes} minutes`);
console.log(
  `Withdrawal challenge period: ${times.withdrawal.challengePeriodDays} days`
);
```

### OP Stack Transaction Finality

```python
# Python - Handle Optimism's L2 to L1 finality model
class OptimismFinalityManager:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.l2_chain_id = 10
        self.block_time = 2  # 2 seconds

    def record_transaction_with_finality(self, tx_data: dict) -> dict:
        """Record transaction with L2 finality awareness"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"optimism-tx-{tx_data['hash']}"
        }

        payload = {
            'chainId': self.l2_chain_id,
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
            'source': 'NODE'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def get_finality_level(self, tx_data: dict) -> str:
        """Determine finality level of Optimism transaction"""
        # Optimism has two finality levels:
        # 1. L2 Confirmed: Fast (seconds)
        # 2. L1 Finalized: Once batched and finalized on Ethereum (~20 min)

        if tx_data.get('l1BatchSubmitted'):
            if tx_data.get('l1BatchFinalized'):
                return 'L1_FINALIZED'
            return 'L1_PENDING'
        return 'L2_CONFIRMED'

    def estimate_l1_finalization_time(self, l2_block_number: int) -> dict:
        """Estimate when L2 block will be finalized on L1"""
        # Optimism batches L2 blocks and posts to L1 periodically
        avg_batch_interval = 20  # minutes

        return {
            'l2BlockNumber': l2_block_number,
            'estimatedL1FinalizationMinutes': avg_batch_interval,
            'note': 'Depends on batch submission frequency'
        }

# Example usage
finality_manager = OptimismFinalityManager('org-uuid', token)

op_tx = {
    'hash': '0xdef456...',
    'from': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
    'to': '0x8ba1f109551bD432803012645Ac136ddd64DBA72',
    'value': 1.5,
    'blockNumber': 115000000,
    'gasPrice': 1000000,  # 0.001 Gwei
    'nonce': 15,
    'txFeeAmount': 0.000021
}

result = finality_manager.record_transaction_with_finality(op_tx)
print(f"Recorded transaction: {result}")

finalization = finality_manager.estimate_l1_finalization_time(115000000)
print(f"L1 finalization ETA: {finalization['estimatedL1FinalizationMinutes']} minutes")
```

### Low Gas Cost Optimization

```javascript
// Node.js - Optimize for Optimism's low transaction costs
class OptimismGasOptimizer {
  constructor() {
    this.typicalGasPrice = 1_000_000; // 0.001 Gwei typical
    this.maxGasPrice = 10_000_000; // 0.01 Gwei max
  }

  async getCurrentGasPrice() {
    // Optimism gas prices are very low
    // web3.eth.getGasPrice() on Optimism
    return 1_000_000; // 0.001 Gwei
  }

  estimateOptimismCost(gasLimit, gasPriceWei = this.typicalGasPrice) {
    const costWei = gasLimit * gasPriceWei;
    const costETH = costWei / 1e18;

    // Example: ETH at $3000
    const ethPrice = 3000;
    const costUSD = costETH * ethPrice;

    return {
      gasLimit,
      gasPriceGwei: gasPriceWei / 1e9,
      gasPriceWei: gasPriceWei,
      totalCostWei: costWei,
      totalCostETH: costETH,
      totalCostUSD: costUSD,
    };
  }

  compareToL1(gasLimit) {
    // Compare Optimism L2 cost to Ethereum L1
    const opCost = this.estimateOptimismCost(gasLimit);

    const l1GasPrice = 30_000_000_000; // 30 Gwei typical on L1
    const l1CostWei = gasLimit * l1GasPrice;
    const l1CostETH = l1CostWei / 1e18;
    const l1CostUSD = l1CostETH * 3000;

    const savings = l1CostUSD - opCost.totalCostUSD;
    const savingsPercent = (savings / l1CostUSD) * 100;

    return {
      optimism: opCost,
      ethereum: {
        totalCostETH: l1CostETH,
        totalCostUSD: l1CostUSD,
      },
      savings: {
        usd: savings,
        percent: savingsPercent,
      },
    };
  }

  async recordTransactionWithOptimizedGas(orgId, token, txData) {
    const gasEstimate = this.estimateOptimismCost(
      txData.gasLimit || 21000,
      parseInt(txData.gasPrice || this.typicalGasPrice)
    );

    const response = await fetch(
      `https://api.quub.exchange/v2/orgs/${orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
          "X-Org-Id": orgId,
          "Idempotency-Key": `optimism-tx-${txData.hash}`,
        },
        body: JSON.stringify({
          chainId: 10,
          hash: txData.hash,
          fromAddress: txData.from,
          toAddress: txData.to,
          value: txData.value,
          direction: txData.direction || "OUTBOUND",
          status: "PENDING",
          gasPrice: String(gasEstimate.gasPriceWei),
          txFeeAmount: String(gasEstimate.totalCostETH),
          txFeeUsd: String(gasEstimate.totalCostUSD),
          source: "NODE",
        }),
      }
    );

    return response.json();
  }
}

// Usage
const gasOptimizer = new OptimismGasOptimizer();

// Simple transfer on Optimism
const transferCost = gasOptimizer.estimateOptimismCost(21000);
console.log(
  `Optimism transfer cost: ${transferCost.totalCostETH.toFixed(
    8
  )} ETH ($${transferCost.totalCostUSD.toFixed(4)})`
);

// Compare to L1
const comparison = gasOptimizer.compareToL1(21000);
console.log(
  `Savings vs L1: $${comparison.savings.usd.toFixed(
    2
  )} (${comparison.savings.percent.toFixed(2)}% cheaper)`
);
```

---

## 🔐 Security & Best Practices

### Sequencer Monitoring

```python
# Python - Monitor Optimism sequencer health
class OptimismSequencerMonitor:
    def __init__(self, token: str):
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.sequencer_url = 'https://mainnet-sequencer.optimism.io'

    def check_sequencer_health(self) -> dict:
        """Check Optimism sequencer operational status"""
        return {
            'status': 'OPERATIONAL',
            'latency': 20,  # ms
            'lastBlock': 115000000,
            'timestamp': '2024-03-08T12:00:00Z'
        }

    def check_adapter_sync(self) -> dict:
        """Check if Optimism adapters are syncing properly"""
        url = f'{self.base_url}/chain/adapters?chainId=10'
        headers = {
            'Authorization': f'Bearer {self.token}'
        }

        response = requests.get(url, headers=headers)
        adapters = response.json().get('data', [])

        sync_status = []
        for adapter in adapters:
            health_url = f'{self.base_url}/chain/adapters/{adapter["id"]}/health'
            health_response = requests.get(health_url, headers=headers)
            health = health_response.json().get('data', {})

            sync_status.append({
                'adapter': adapter['name'],
                'syncLag': health.get('syncLag', 0),
                'latencyMs': health.get('latencyMs', 0),
                'inSync': health.get('syncLag', 0) < 5
            })

        return {
            'totalAdapters': len(adapters),
            'inSyncAdapters': sum(1 for s in sync_status if s['inSync']),
            'details': sync_status
        }

    def monitor_l1_batch_submissions(self) -> dict:
        """Monitor L2 batch submissions to Ethereum L1"""
        return {
            'lastBatchSubmitted': 18500500,
            'lastBatchFinalized': 18500400,
            'batchesUnfinalized': 100,
            'estimatedFinalizationTime': '20 minutes'
        }

# Example usage
sequencer_monitor = OptimismSequencerMonitor(token)

sequencer_status = sequencer_monitor.check_sequencer_health()
print(f"Optimism sequencer: {sequencer_status['status']}")

sync_status = sequencer_monitor.check_adapter_sync()
print(f"Adapters in sync: {sync_status['inSyncAdapters']}/{sync_status['totalAdapters']}")

batch_status = sequencer_monitor.monitor_l1_batch_submissions()
print(f"Batches awaiting L1 finalization: {batch_status['batchesUnfinalized']}")
```

---

## 🎯 Production Checklist

### Pre-Launch

- [ ] **Chain Registration**: Optimism registered with L2 layer designation
- [ ] **Parent Chain Link**: Ethereum (Chain ID 1) configured as parent
- [ ] **RPC Diversity**: Multiple providers (Official, Alchemy, Infura, Ankr, QuickNode)
- [ ] **Bridge Monitoring**: Standard Bridge deposit/withdrawal tracking
- [ ] **Challenge Period**: 7-day withdrawal finalization period documented
- [ ] **Ultra-Low Gas**: Sub-cent transaction costs validated
- [ ] **Sequencer Health**: Monitoring for sequencer availability
- [ ] **L1 Batch Tracking**: Batch submission to Ethereum L1 monitored
- [ ] **OP Stack Awareness**: OP Stack framework patterns implemented
- [ ] **Testnet Validation**: Fully tested on Optimism Sepolia (Chain ID 11155420)

### Monitoring Metrics

- **Block Time**: ~2 seconds
- **L2 Confirmation**: Near-instant
- **L1 Finality**: ~20 minutes (batch posted to Ethereum)
- **Gas Price**: 0.001-0.01 Gwei typical
- **Transaction Cost**: $0.01-$0.05 typical
- **Sequencer Uptime**: 99.9%+ target

---

## 📚 Additional Resources

- [Optimism Documentation](https://docs.optimism.io/)
- [Optimism Bridge](https://app.optimism.io/bridge)
- [Optimism Etherscan](https://optimistic.etherscan.io/)
- [OP Stack Documentation](https://stack.optimism.io/)
- [Optimism Status](https://status.optimism.io/)

---

## 🔗 Related Integrations

- [Ethereum (L1)](/capabilities/chain/integrations/ethereum/)
- [Base](/capabilities/chain/integrations/base/)
- [Arbitrum](/capabilities/chain/integrations/arbitrum/)
- [OP Mainnet Superchain](/capabilities/chain/integrations/op-mainnet/)

---

**Note**: All code examples reference operations defined in `openapi/chain.yaml`. Optimism's OP Stack architecture and 7-day challenge period require careful handling of bridge operations and L1 finality tracking.
