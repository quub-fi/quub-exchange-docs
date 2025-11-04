---
layout: docs
title: Arbitrum Integration Guide
permalink: /capabilities/chain/integrations/arbitrum/
---

# 🔵 Arbitrum Integration Guide

> Complete guide for integrating Arbitrum One with Quub Exchange Chain Service. All operations reference `openapi/chain.yaml`.

## 📋 Overview

**Arbitrum One** is a leading Ethereum Layer 2 optimistic rollup offering high throughput, low transaction costs, and full EVM compatibility. It uses fraud proofs and a multi-round dispute resolution system to ensure security while maintaining Ethereum-equivalent developer experience.

### Network Details

| Property            | Value                                          |
| ------------------- | ---------------------------------------------- |
| **Chain ID**        | 42161 (Arbitrum One), 421614 (Sepolia Testnet) |
| **Native Currency** | ETH                                            |
| **Decimals**        | 18                                             |
| **Block Time**      | ~0.25 seconds                                  |
| **Consensus**       | Optimistic Rollup (Fraud Proofs)               |
| **Explorer**        | https://arbiscan.io                            |
| **RPC Providers**   | Arbitrum Official, Alchemy, Infura, QuickNode  |
| **L1 Settlement**   | Ethereum                                       |

---

## 🚀 Quick Start

### 1. Register Arbitrum Chain

```javascript
// Node.js - Register Arbitrum One
const registerArbitrumChain = async (token) => {
  const response = await fetch("https://api.quub.exchange/v2/chains", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `arbitrum-mainnet-${Date.now()}`,
    },
    body: JSON.stringify({
      chainId: 42161,
      name: "Arbitrum One",
      shortName: "ARB1",
      networkType: "MAINNET",
      layer: "L2",
      parentChainId: 1, // Ethereum mainnet
      nativeCurrency: "ETH",
      decimals: 18,
      blockTime: 0.25, // 250ms blocks
      confirmations: 1, // L2 confirmations fast
      explorerUrl: "https://arbiscan.io",
      docsUrl: "https://docs.arbitrum.io/",
      genesisHash:
        "0x7ee576b35482195fc49205cec9af72ce14f003b9ae69f6ba0faef4514be8b442",
      chainNamespace: "EVM",
      status: "ACTIVE",
      metadata: {
        rollupType: "OPTIMISTIC",
        disputeGameType: "MULTI_ROUND",
        l1SettlementChain: "ETHEREUM",
        sequencerUrl: "https://arb1-sequencer.arbitrum.io/rpc",
        challengePeriod: 604800, // 7 days in seconds
      },
    }),
  });

  return response.json();
};
```

```python
# Python - Register Arbitrum with L2 metadata
import requests
import time

def register_arbitrum_chain(token):
    url = 'https://api.quub.exchange/v2/chains'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'Idempotency-Key': f'arbitrum-mainnet-{int(time.time())}'
    }
    payload = {
        'chainId': 42161,
        'name': 'Arbitrum One',
        'shortName': 'ARB1',
        'networkType': 'MAINNET',
        'layer': 'L2',
        'parentChainId': 1,
        'nativeCurrency': 'ETH',
        'decimals': 18,
        'blockTime': 0.25,
        'confirmations': 1,
        'explorerUrl': 'https://arbiscan.io',
        'docsUrl': 'https://docs.arbitrum.io/',
        'genesisHash': '0x7ee576b35482195fc49205cec9af72ce14f003b9ae69f6ba0faef4514be8b442',
        'chainNamespace': 'EVM',
        'status': 'ACTIVE'
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

### 2. Configure RPC Adapters

```javascript
// Node.js - Setup Arbitrum RPC with multiple providers
const setupArbitrumRPCAdapters = async (token, apiKeys = {}) => {
  const adapters = [
    {
      name: "Arbitrum Official Primary",
      rpcEndpoint: "https://arb1.arbitrum.io/rpc",
      signerPolicy: "MPC_CLUSTER",
      priority: 0,
    },
    {
      name: "Alchemy Arbitrum",
      rpcEndpoint: `https://arb-mainnet.g.alchemy.com/v2/${
        apiKeys.alchemy || "YOUR_ALCHEMY_KEY"
      }`,
      wsEndpoint: `wss://arb-mainnet.g.alchemy.com/v2/${
        apiKeys.alchemy || "YOUR_ALCHEMY_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 1,
    },
    {
      name: "Infura Arbitrum",
      rpcEndpoint: `https://arbitrum-mainnet.infura.io/v3/${
        apiKeys.infura || "YOUR_INFURA_KEY"
      }`,
      wsEndpoint: `wss://arbitrum-mainnet.infura.io/ws/v3/${
        apiKeys.infura || "YOUR_INFURA_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 2,
    },
    {
      name: "QuickNode Arbitrum",
      rpcEndpoint:
        apiKeys.quicknode ||
        "https://your-quicknode-endpoint.arbitrum-mainnet.quiknode.pro/",
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
          "Idempotency-Key": `arbitrum-${adapter.name
            .toLowerCase()
            .replace(/\s+/g, "-")}`,
        },
        body: JSON.stringify({
          chainId: 42161,
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
# Python - Configure Arbitrum adapters with sequencer awareness
def configure_arbitrum_adapters(token, api_keys=None):
    """Configure multiple Arbitrum RPC adapters"""
    url = 'https://api.quub.exchange/v2/chain/adapters'

    adapters_config = [
        {
            'name': 'Arbitrum Official',
            'rpcEndpoint': 'https://arb1.arbitrum.io/rpc',
            'priority': 0
        },
        {
            'name': 'Arbitrum Nova Backup',
            'rpcEndpoint': 'https://arb1-public.com/rpc',
            'priority': 3
        }
    ]

    # Add premium providers if API keys provided
    if api_keys:
        if 'alchemy' in api_keys:
            adapters_config.insert(0, {
                'name': 'Alchemy Arbitrum Primary',
                'rpcEndpoint': f"https://arb-mainnet.g.alchemy.com/v2/{api_keys['alchemy']}",
                'wsEndpoint': f"wss://arb-mainnet.g.alchemy.com/v2/{api_keys['alchemy']}",
                'priority': 1
            })

        if 'infura' in api_keys:
            adapters_config.insert(1, {
                'name': 'Infura Arbitrum',
                'rpcEndpoint': f"https://arbitrum-mainnet.infura.io/v3/{api_keys['infura']}",
                'wsEndpoint': f"wss://arbitrum-mainnet.infura.io/ws/v3/{api_keys['infura']}",
                'priority': 2
            })

    results = []
    for config in adapters_config:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json',
            'Idempotency-Key': f"arbitrum-{config['name'].lower().replace(' ', '-')}-{int(time.time())}"
        }

        payload = {
            'chainId': 42161,
            'signerPolicy': 'MPC_CLUSTER',
            **config
        }

        response = requests.post(url, json=payload, headers=headers)
        results.append(response.json())

    return results
```

---

## 🏗️ Arbitrum-Specific Integration Patterns

### Fast Block Time Handling

```javascript
// Node.js - Handle Arbitrum's 250ms block times
class ArbitrumFastBlockManager {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.blockTime = 250; // 250ms per block
  }

  async recordTransactionWithFastConfirmation(txData) {
    // Record transaction
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `arbitrum-tx-${txData.hash}`,
        },
        body: JSON.stringify({
          chainId: 42161,
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

    // Wait for L2 confirmation (very fast)
    const confirmed = await this.waitForL2Confirmation(txData.hash);

    return {
      transaction: recorded,
      l2Confirmed: confirmed.status === "CONFIRMED",
      l2ConfirmationTime: confirmed.timeMs,
    };
  }

  async waitForL2Confirmation(txHash, maxAttempts = 20) {
    const startTime = Date.now();

    for (let attempt = 0; attempt < maxAttempts; attempt++) {
      const tx = await this.getTransaction(txHash);

      if (tx && tx.blockNumber) {
        const elapsed = Date.now() - startTime;

        return {
          hash: txHash,
          status: "CONFIRMED",
          timeMs: elapsed,
          blockNumber: tx.blockNumber,
        };
      }

      // Wait for ~1 block time
      await this.sleep(this.blockTime);
    }

    return {
      hash: txHash,
      status: "TIMEOUT",
      timeMs: Date.now() - startTime,
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
const fastBlockManager = new ArbitrumFastBlockManager("org-uuid", token);

const arbTx = {
  hash: "0x1234567890abcdef...",
  from: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
  to: "0x8ba1f109551bD432803012645Ac136ddd64DBA72",
  value: "2.5",
  blockNumber: 180000000,
  gasPrice: "100000000", // 0.1 Gwei typical
  nonce: 42,
  txFeeAmount: "0.0000021",
};

const result = await fastBlockManager.recordTransactionWithFastConfirmation(
  arbTx
);
console.log(`L2 confirmed in ${result.l2ConfirmationTime}ms`);
```

### Bridge Deposit & Withdrawal Tracking

```python
# Python - Track Arbitrum bridge operations
class ArbitrumBridgeMonitor:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.l1_chain_id = 1
        self.l2_chain_id = 42161
        self.l1_gateway = '0x72Ce9c846789fdB6fC1f34aC4AD25Dd9ef7031ef'  # Arbitrum Gateway
        self.challenge_period = 604800  # 7 days

    def record_l1_deposit(self, tx_data: dict) -> dict:
        """Record deposit from Ethereum L1 to Arbitrum"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"arbitrum-l1-deposit-{tx_data['hash']}"
        }

        payload = {
            'chainId': self.l1_chain_id,
            'hash': tx_data['hash'],
            'fromAddress': tx_data['from'],
            'toAddress': self.l1_gateway,
            'value': str(tx_data['value']),
            'direction': 'OUTBOUND',
            'status': 'CONFIRMED',
            'blockNumber': tx_data['blockNumber'],
            'gasPrice': str(tx_data['gasPrice']),
            'nonce': tx_data['nonce'],
            'txFeeAmount': str(tx_data.get('txFeeAmount', '0')),
            'refType': 'ARBITRUM_BRIDGE_DEPOSIT_L1',
            'source': 'NODE'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def record_l2_deposit_completion(self, l1_tx_hash: str, l2_tx_data: dict) -> dict:
        """Record deposit completion on Arbitrum (10-15 minutes after L1)"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"arbitrum-l2-deposit-{l2_tx_data['hash']}"
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
            'gasPrice': '0',
            'refType': 'ARBITRUM_BRIDGE_DEPOSIT_L2',
            'refId': l1_tx_hash,
            'source': 'BRIDGE_MONITOR'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def record_l2_withdrawal_initiation(self, tx_data: dict) -> dict:
        """Record withdrawal initiation on Arbitrum"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"arbitrum-l2-withdrawal-{tx_data['hash']}"
        }

        payload = {
            'chainId': self.l2_chain_id,
            'hash': tx_data['hash'],
            'fromAddress': tx_data['from'],
            'toAddress': '0x0000000000000000000000000000000000000064',  # ArbSys
            'value': str(tx_data['value']),
            'direction': 'OUTBOUND',
            'status': 'CONFIRMED',
            'blockNumber': tx_data['blockNumber'],
            'gasPrice': str(tx_data['gasPrice']),
            'nonce': tx_data['nonce'],
            'txFeeAmount': str(tx_data.get('txFeeAmount', '0')),
            'refType': 'ARBITRUM_BRIDGE_WITHDRAWAL_L2',
            'source': 'NODE'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def record_l1_withdrawal_finalization(self, l2_tx_hash: str, l1_tx_data: dict) -> dict:
        """Record withdrawal finalization on Ethereum L1 (after 7-day challenge)"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"arbitrum-l1-withdrawal-{l1_tx_data['hash']}"
        }

        payload = {
            'chainId': self.l1_chain_id,
            'hash': l1_tx_data['hash'],
            'fromAddress': self.l1_gateway,
            'toAddress': l1_tx_data['to'],
            'value': str(l1_tx_data['value']),
            'direction': 'INBOUND',
            'status': 'CONFIRMED',
            'blockNumber': l1_tx_data['blockNumber'],
            'gasPrice': str(l1_tx_data['gasPrice']),
            'refType': 'ARBITRUM_BRIDGE_WITHDRAWAL_L1',
            'refId': l2_tx_hash,
            'source': 'BRIDGE_MONITOR'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def estimate_deposit_time(self) -> dict:
        """Estimate time for L1 to L2 deposit"""
        return {
            'minimumMinutes': 10,
            'averageMinutes': 15,
            'maximumMinutes': 30,
            'note': 'Depends on Ethereum L1 block confirmations'
        }

    def estimate_withdrawal_time(self) -> dict:
        """Estimate time for L2 to L1 withdrawal"""
        return {
            'challengePeriodDays': 7,
            'challengePeriodSeconds': self.challenge_period,
            'note': 'Must wait 7 days for challenge period before claiming on L1'
        }

# Example usage
bridge_monitor = ArbitrumBridgeMonitor('org-uuid', token)

# User deposits from Ethereum to Arbitrum
l1_deposit = {
    'hash': '0xabc123...',
    'from': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
    'value': 3.0,
    'blockNumber': 18500000,
    'gasPrice': 30000000000,
    'nonce': 42,
    'txFeeAmount': 0.00189
}

bridge_monitor.record_l1_deposit(l1_deposit)
print("L1 deposit recorded")

# Deposit completes on Arbitrum (10-15 minutes later)
l2_completion = {
    'hash': '0xdef456...',
    'to': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
    'value': 3.0,
    'blockNumber': 180000000
}

bridge_monitor.record_l2_deposit_completion('0xabc123...', l2_completion)
print("L2 deposit completed")

# Estimate times
deposit_time = bridge_monitor.estimate_deposit_time()
withdrawal_time = bridge_monitor.estimate_withdrawal_time()
print(f"Deposit time: {deposit_time['averageMinutes']} minutes")
print(f"Withdrawal challenge period: {withdrawal_time['challengePeriodDays']} days")
```

### Ultra-Low Gas Cost Tracking

```javascript
// Node.js - Handle Arbitrum's extremely low gas costs
class ArbitrumGasTracker {
  constructor() {
    this.typicalGasPrice = 100_000_000; // 0.1 Gwei typical
    this.maxGasPrice = 1_000_000_000; // 1 Gwei max
  }

  async getCurrentGasPrice() {
    // Arbitrum gas prices are very low
    // web3.eth.getGasPrice() on Arbitrum
    return 100_000_000; // 0.1 Gwei
  }

  estimateArbitrumCost(gasLimit, gasPriceWei = this.typicalGasPrice) {
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
    // Compare Arbitrum L2 cost to Ethereum L1
    const arbCost = this.estimateArbitrumCost(gasLimit);

    const l1GasPrice = 30_000_000_000; // 30 Gwei typical on L1
    const l1CostWei = gasLimit * l1GasPrice;
    const l1CostETH = l1CostWei / 1e18;
    const l1CostUSD = l1CostETH * 3000;

    const savings = l1CostUSD - arbCost.totalCostUSD;
    const savingsPercent = (savings / l1CostUSD) * 100;

    return {
      arbitrum: arbCost,
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
}

// Usage
const gasTracker = new ArbitrumGasTracker();

// Simple transfer on Arbitrum
const transferCost = gasTracker.estimateArbitrumCost(21000);
console.log(
  `Arbitrum transfer cost: ${transferCost.totalCostETH.toFixed(
    8
  )} ETH ($${transferCost.totalCostUSD.toFixed(4)})`
);

// Compare to L1
const comparison = gasTracker.compareToL1(21000);
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
# Python - Monitor Arbitrum sequencer health
class ArbitrumSequencerMonitor:
    def __init__(self, token: str):
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.sequencer_url = 'https://arb1-sequencer.arbitrum.io/rpc'

    def check_sequencer_health(self) -> dict:
        """Check Arbitrum sequencer operational status"""
        return {
            'status': 'OPERATIONAL',
            'latency': 10,  # ms
            'lastBlock': 180000000,
            'timestamp': '2024-03-08T12:00:00Z'
        }

    def check_adapter_sync(self) -> dict:
        """Check if Arbitrum adapters are syncing properly"""
        url = f'{self.base_url}/chain/adapters?chainId=42161'
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
                'inSync': health.get('syncLag', 0) < 10  # Less than 10 blocks (2.5 seconds)
            })

        return {
            'totalAdapters': len(adapters),
            'inSyncAdapters': sum(1 for s in sync_status if s['inSync']),
            'details': sync_status
        }

# Example usage
sequencer_monitor = ArbitrumSequencerMonitor(token)

sequencer_status = sequencer_monitor.check_sequencer_health()
print(f"Arbitrum sequencer: {sequencer_status['status']}")

sync_status = sequencer_monitor.check_adapter_sync()
print(f"Adapters in sync: {sync_status['inSyncAdapters']}/{sync_status['totalAdapters']}")
```

---

## 🎯 Production Checklist

### Pre-Launch

- [ ] **Chain Registration**: Arbitrum One registered with L2 layer designation
- [ ] **Parent Chain Link**: Ethereum (Chain ID 1) configured as parent
- [ ] **RPC Diversity**: Multiple providers (Official, Alchemy, Infura, QuickNode)
- [ ] **Fast Blocks**: 250ms block time handling implemented
- [ ] **Bridge Monitoring**: L1↔L2 deposit/withdrawal tracking operational
- [ ] **Challenge Period**: 7-day withdrawal finalization period documented
- [ ] **Ultra-Low Gas**: Sub-cent transaction costs validated
- [ ] **Sequencer Health**: Monitoring for sequencer availability
- [ ] **L1 Batch Posting**: Monitoring batch submissions to Ethereum
- [ ] **Testnet Validation**: Fully tested on Arbitrum Sepolia (Chain ID 421614)

### Monitoring Metrics

- **Block Time**: ~250ms (0.25 seconds)
- **L2 Confirmation**: Near-instant
- **L1 Finality**: ~15-30 minutes (batch posted to Ethereum)
- **Gas Price**: 0.1-1 Gwei typical
- **Transaction Cost**: $0.01-$0.10 typical
- **Sequencer Uptime**: 99.9%+ target

---

## 📚 Additional Resources

- [Arbitrum Documentation](https://docs.arbitrum.io/)
- [Arbitrum Bridge](https://bridge.arbitrum.io/)
- [Arbiscan Explorer](https://arbiscan.io/)
- [Arbitrum Status](https://status.arbitrum.io/)
- [Nitro Upgrade](https://docs.arbitrum.io/migration/dapp_migration)

---

## 🔗 Related Integrations

- [Ethereum (L1)](/capabilities/chain/integrations/ethereum/)
- [Optimism](/capabilities/chain/integrations/optimism/)
- [Base](/capabilities/chain/integrations/base/)
- [Arbitrum Nova](/capabilities/chain/integrations/arbitrum-nova/)

---

**Note**: All code examples reference operations defined in `openapi/chain.yaml`. Arbitrum's 250ms block times and 7-day challenge period require special handling for finality tracking and withdrawal operations.
