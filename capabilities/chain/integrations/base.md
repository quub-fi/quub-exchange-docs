---
layout: docs
title: Base Integration Guide
permalink: /capabilities/chain/integrations/base/
---

# 🔵 Base Integration Guide

> Complete guide for integrating Base (Coinbase L2) with Quub Exchange Chain Service. All operations reference `openapi/chain.yaml`.

## 📋 Overview

**Base** is Coinbase's Ethereum Layer 2 solution built on the OP Stack. It offers low-cost transactions, Ethereum-equivalent security, and seamless integration with Coinbase's ecosystem while remaining fully decentralized and permissionless.

### Network Details

| Property            | Value                                   |
| ------------------- | --------------------------------------- |
| **Chain ID**        | 8453 (Mainnet), 84532 (Sepolia Testnet) |
| **Native Currency** | ETH                                     |
| **Decimals**        | 18                                      |
| **Block Time**      | ~2 seconds                              |
| **Consensus**       | Optimistic Rollup (OP Stack)            |
| **Explorer**        | https://basescan.org                    |
| **RPC Providers**   | Coinbase, Alchemy, Infura, QuickNode    |
| **L1 Settlement**   | Ethereum                                |

---

## 🚀 Quick Start

### 1. Register Base Chain

```javascript
// Node.js - Register Base Mainnet
const registerBaseChain = async (token) => {
  const response = await fetch("https://api.quub.exchange/v2/chains", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `base-mainnet-${Date.now()}`,
    },
    body: JSON.stringify({
      chainId: 8453,
      name: "Base",
      shortName: "BASE",
      networkType: "MAINNET",
      layer: "L2",
      parentChainId: 1, // Ethereum mainnet
      nativeCurrency: "ETH",
      decimals: 18,
      blockTime: 2,
      confirmations: 1, // Faster on L2
      explorerUrl: "https://basescan.org",
      docsUrl: "https://docs.base.org/",
      genesisHash:
        "0x0000000000000000000000000000000000000000000000000000000000000000",
      chainNamespace: "EVM",
      status: "ACTIVE",
      metadata: {
        rollupType: "OPTIMISTIC",
        l1SettlementChain: "ETHEREUM",
        sequencerUrl: "https://mainnet-sequencer.base.org",
        challengePeriod: 604800, // 7 days in seconds
      },
    }),
  });

  return response.json();
};
```

```python
# Python - Register Base with L2-specific configuration
import requests
import time

def register_base_chain(token):
    url = 'https://api.quub.exchange/v2/chains'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'Idempotency-Key': f'base-mainnet-{int(time.time())}'
    }
    payload = {
        'chainId': 8453,
        'name': 'Base',
        'shortName': 'BASE',
        'networkType': 'MAINNET',
        'layer': 'L2',
        'parentChainId': 1,
        'nativeCurrency': 'ETH',
        'decimals': 18,
        'blockTime': 2,
        'confirmations': 1,
        'explorerUrl': 'https://basescan.org',
        'docsUrl': 'https://docs.base.org/',
        'genesisHash': '0x0000000000000000000000000000000000000000000000000000000000000000',
        'chainNamespace': 'EVM',
        'status': 'ACTIVE'
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

### 2. Configure RPC Adapters

```javascript
// Node.js - Setup Base RPC with Coinbase and other providers
const setupBaseRPCAdapters = async (token, apiKeys = {}) => {
  const adapters = [
    {
      name: "Base Public Primary",
      rpcEndpoint: "https://mainnet.base.org",
      signerPolicy: "MPC_CLUSTER",
      priority: 0,
    },
    {
      name: "Alchemy Base",
      rpcEndpoint: `https://base-mainnet.g.alchemy.com/v2/${
        apiKeys.alchemy || "YOUR_ALCHEMY_KEY"
      }`,
      wsEndpoint: `wss://base-mainnet.g.alchemy.com/v2/${
        apiKeys.alchemy || "YOUR_ALCHEMY_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 1,
    },
    {
      name: "Infura Base",
      rpcEndpoint: `https://base-mainnet.infura.io/v3/${
        apiKeys.infura || "YOUR_INFURA_KEY"
      }`,
      wsEndpoint: `wss://base-mainnet.infura.io/ws/v3/${
        apiKeys.infura || "YOUR_INFURA_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 2,
    },
    {
      name: "QuickNode Base",
      rpcEndpoint:
        apiKeys.quicknode ||
        "https://your-quicknode-endpoint.base.quiknode.pro/",
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
          "Idempotency-Key": `base-${adapter.name
            .toLowerCase()
            .replace(/\s+/g, "-")}`,
        },
        body: JSON.stringify({
          chainId: 8453,
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
# Python - Configure Base adapters with L2-optimized settings
def configure_base_adapters(token, api_keys=None):
    """Configure multiple Base RPC adapters"""
    url = 'https://api.quub.exchange/v2/chain/adapters'

    adapters_config = [
        {
            'name': 'Base Public RPC',
            'rpcEndpoint': 'https://mainnet.base.org',
            'priority': 2
        },
        {
            'name': 'Coinbase Cloud Base',
            'rpcEndpoint': 'https://api.developer.coinbase.com/rpc/v1/base',
            'priority': 1
        }
    ]

    # Add premium providers if API keys provided
    if api_keys:
        if 'alchemy' in api_keys:
            adapters_config.insert(0, {
                'name': 'Alchemy Base Primary',
                'rpcEndpoint': f"https://base-mainnet.g.alchemy.com/v2/{api_keys['alchemy']}",
                'wsEndpoint': f"wss://base-mainnet.g.alchemy.com/v2/{api_keys['alchemy']}",
                'priority': 0
            })

        if 'infura' in api_keys:
            adapters_config.append({
                'name': 'Infura Base Backup',
                'rpcEndpoint': f"https://base-mainnet.infura.io/v3/{api_keys['infura']}",
                'wsEndpoint': f"wss://base-mainnet.infura.io/ws/v3/{api_keys['infura']}",
                'priority': 1
            })

    results = []
    for config in adapters_config:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json',
            'Idempotency-Key': f"base-{config['name'].lower().replace(' ', '-')}-{int(time.time())}"
        }

        payload = {
            'chainId': 8453,
            'signerPolicy': 'MPC_CLUSTER',
            **config
        }

        response = requests.post(url, json=payload, headers=headers)
        results.append(response.json())

    return results
```

---

## 🏗️ Base-Specific Integration Patterns

### L2 Bridge Deposit Tracking

```javascript
// Node.js - Track ETH deposits from Ethereum L1 to Base L2
class BaseBridgeMonitor {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.l1ChainId = 1; // Ethereum
    this.l2ChainId = 8453; // Base
    this.bridgeContractL1 = "0x49048044D57e1C92A77f79988d21Fa8fAF74E97e"; // Base Portal
  }

  async recordL1Deposit(txData) {
    // Record the L1 deposit transaction
    const l1Response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `base-l1-deposit-${txData.hash}`,
        },
        body: JSON.stringify({
          chainId: this.l1ChainId,
          hash: txData.hash,
          fromAddress: txData.from,
          toAddress: this.bridgeContractL1,
          value: txData.value,
          direction: "OUTBOUND",
          status: "CONFIRMED",
          blockNumber: txData.blockNumber,
          gasPrice: txData.gasPrice,
          nonce: txData.nonce,
          txFeeAmount: txData.txFeeAmount,
          refType: "BRIDGE_DEPOSIT_L1",
          source: "NODE",
        }),
      }
    );

    return l1Response.json();
  }

  async recordL2Mint(l1TxHash, l2TxHash, value, l2BlockNumber) {
    // Record the corresponding L2 mint/credit
    const l2Response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `base-l2-mint-${l2TxHash}`,
        },
        body: JSON.stringify({
          chainId: this.l2ChainId,
          hash: l2TxHash,
          fromAddress: "0x0000000000000000000000000000000000000000", // Mint
          toAddress: "0x...", // User's Base address
          value: value,
          direction: "INBOUND",
          status: "CONFIRMED",
          blockNumber: l2BlockNumber,
          gasPrice: "0", // No gas cost for bridged mint
          refType: "BRIDGE_DEPOSIT_L2",
          refId: l1TxHash, // Link to L1 deposit
          source: "BRIDGE_MONITOR",
        }),
      }
    );

    return l2Response.json();
  }

  async trackBridgeDeposit(l1TxHash) {
    // Monitor L1 transaction until confirmed
    const l1Tx = await this.waitForL1Confirmation(l1TxHash);
    await this.recordL1Deposit(l1Tx);

    // Wait for L2 processing (typically 1-2 minutes on Base)
    const l2Tx = await this.waitForL2Mint(l1TxHash);
    await this.recordL2Mint(l1TxHash, l2Tx.hash, l1Tx.value, l2Tx.blockNumber);

    return {
      l1Transaction: l1TxHash,
      l2Transaction: l2Tx.hash,
      status: "COMPLETED",
    };
  }

  async waitForL1Confirmation(txHash) {
    // Implementation would check L1 transaction status
    return {
      hash: txHash,
      from: "0x...",
      value: "1.5",
      blockNumber: 18500000,
      gasPrice: "30000000000",
      nonce: 42,
      txFeeAmount: "0.00063",
    };
  }

  async waitForL2Mint(l1TxHash) {
    // Implementation would monitor Base bridge events
    return {
      hash: "0x...",
      blockNumber: 8500000,
    };
  }
}

// Usage
const bridgeMonitor = new BaseBridgeMonitor("org-uuid", token);
const result = await bridgeMonitor.trackBridgeDeposit("0xabc123...");
console.log("Bridge deposit completed:", result);
```

### L2 Withdrawal Tracking

```python
# Python - Track withdrawals from Base L2 to Ethereum L1
class BaseWithdrawalMonitor:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.l1_chain_id = 1
        self.l2_chain_id = 8453
        self.challenge_period = 604800  # 7 days in seconds

    def record_l2_withdrawal_initiation(self, tx_data: dict) -> dict:
        """Record withdrawal initiation on Base L2"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"base-l2-withdrawal-{tx_data['hash']}"
        }

        payload = {
            'chainId': self.l2_chain_id,
            'hash': tx_data['hash'],
            'fromAddress': tx_data['from'],
            'toAddress': '0x4200000000000000000000000000000000000016',  # L2 Bridge
            'value': str(tx_data['value']),
            'direction': 'OUTBOUND',
            'status': 'CONFIRMED',
            'blockNumber': tx_data['blockNumber'],
            'gasPrice': str(tx_data['gasPrice']),
            'nonce': tx_data['nonce'],
            'txFeeAmount': str(tx_data.get('txFeeAmount', '0')),
            'refType': 'BRIDGE_WITHDRAWAL_L2',
            'source': 'NODE'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def record_l1_withdrawal_finalization(self, l2_tx_hash: str, l1_tx_data: dict) -> dict:
        """Record withdrawal finalization on Ethereum L1 (after 7-day challenge period)"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"base-l1-withdrawal-{l1_tx_data['hash']}"
        }

        payload = {
            'chainId': self.l1_chain_id,
            'hash': l1_tx_data['hash'],
            'fromAddress': '0x49048044D57e1C92A77f79988d21Fa8fAF74E97e',  # Base Portal
            'toAddress': l1_tx_data['to'],
            'value': str(l1_tx_data['value']),
            'direction': 'INBOUND',
            'status': 'CONFIRMED',
            'blockNumber': l1_tx_data['blockNumber'],
            'gasPrice': str(l1_tx_data['gasPrice']),
            'refType': 'BRIDGE_WITHDRAWAL_L1',
            'refId': l2_tx_hash,  # Link to L2 withdrawal
            'source': 'BRIDGE_MONITOR'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def get_withdrawal_status(self, l2_tx_hash: str) -> dict:
        """Check withdrawal status and challenge period"""
        # This would query the withdrawal status from Base bridge
        return {
            'l2Transaction': l2_tx_hash,
            'status': 'CHALLENGE_PERIOD',
            'readyToProve': True,
            'readyToFinalize': False,
            'challengePeriodEnds': '2024-03-15T00:00:00Z'
        }

# Example usage
withdrawal_monitor = BaseWithdrawalMonitor('org-uuid', token)

# User initiates withdrawal on Base
l2_withdrawal = {
    'hash': '0xdef456...',
    'from': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
    'value': 2.5,
    'blockNumber': 8500000,
    'gasPrice': 100000,  # Very low on Base
    'nonce': 15,
    'txFeeAmount': 0.00001  # ~$0.01 on Base
}

result = withdrawal_monitor.record_l2_withdrawal_initiation(l2_withdrawal)
print(f"L2 withdrawal initiated: {result}")

# After 7-day challenge period, finalize on L1
l1_finalization = {
    'hash': '0xghi789...',
    'to': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
    'value': 2.5,
    'blockNumber': 18520000,
    'gasPrice': 30000000000
}

final_result = withdrawal_monitor.record_l1_withdrawal_finalization(
    '0xdef456...', l1_finalization
)
print(f"L1 withdrawal finalized: {final_result}")
```

### Ultra-Low Gas Cost Tracking

```javascript
// Node.js - Handle Base's extremely low gas costs
class BaseGasTracker {
  constructor() {
    this.typicalGasPrice = 100_000; // 0.0001 Gwei typical on Base
    this.maxGasPrice = 1_000_000; // 0.001 Gwei max
  }

  async getCurrentGasPrice() {
    // Base gas prices are extremely low
    // web3.eth.getGasPrice() on Base
    return 100_000; // 0.0001 Gwei
  }

  estimateBaseCost(gasLimit, gasPriceWei = this.typicalGasPrice) {
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
    // Compare Base L2 cost to Ethereum L1
    const baseCost = this.estimateBaseCost(gasLimit);

    const l1GasPrice = 30_000_000_000; // 30 Gwei typical on L1
    const l1CostWei = gasLimit * l1GasPrice;
    const l1CostETH = l1CostWei / 1e18;
    const l1CostUSD = l1CostETH * 3000;

    const savings = l1CostUSD - baseCost.totalCostUSD;
    const savingsPercent = (savings / l1CostUSD) * 100;

    return {
      base: baseCost,
      l1: {
        totalCostETH: l1CostETH,
        totalCostUSD: l1CostUSD,
      },
      savings: {
        usd: savings,
        percent: savingsPercent,
      },
    };
  }

  async recordTransactionWithL2Cost(orgId, token, txData) {
    const gasEstimate = this.estimateBaseCost(
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
          "Idempotency-Key": `base-tx-${txData.hash}`,
        },
        body: JSON.stringify({
          chainId: 8453,
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
const gasTracker = new BaseGasTracker();

// Simple transfer cost on Base
const transferCost = gasTracker.estimateBaseCost(21000);
console.log(
  `Base transfer cost: ${transferCost.totalCostETH.toFixed(
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
# Python - Monitor Base sequencer health
class BaseSequencerMonitor:
    def __init__(self, token: str):
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.sequencer_url = 'https://mainnet-sequencer.base.org'

    def check_sequencer_health(self) -> dict:
        """Check Base sequencer operational status"""
        # In production, this would call the actual sequencer endpoint
        return {
            'status': 'OPERATIONAL',
            'latency': 15,  # ms
            'lastBlock': 8500000,
            'timestamp': '2024-03-08T12:00:00Z'
        }

    def check_adapter_sync(self) -> dict:
        """Check if Base adapters are syncing properly"""
        url = f'{self.base_url}/chain/adapters?chainId=8453'
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
                'inSync': health.get('syncLag', 0) < 3
            })

        return {
            'totalAdapters': len(adapters),
            'inSyncAdapters': sum(1 for s in sync_status if s['inSync']),
            'details': sync_status
        }

    def monitor_l1_finality(self) -> dict:
        """Monitor L1 (Ethereum) finality for Base batches"""
        # Base batches transactions and posts them to L1
        # Monitor L1 finality for true transaction finality
        return {
            'lastBatchSubmitted': 18500500,
            'lastBatchFinalized': 18500300,
            'batchesUnfinalized': 200,
            'estimatedFinalizationTime': '20 minutes'
        }

# Example usage
sequencer_monitor = BaseSequencerMonitor(token)

# Check sequencer
sequencer_status = sequencer_monitor.check_sequencer_health()
print(f"Base sequencer: {sequencer_status['status']}")

# Check adapter sync
sync_status = sequencer_monitor.check_adapter_sync()
print(f"Adapters in sync: {sync_status['inSyncAdapters']}/{sync_status['totalAdapters']}")

# Check L1 finality
finality_status = sequencer_monitor.monitor_l1_finality()
print(f"Batches unfinalized on L1: {finality_status['batchesUnfinalized']}")
```

---

## 📊 Advanced Patterns

### Coinbase Integration Benefits

```javascript
// Node.js - Leverage Coinbase ecosystem integration
class BaseCoinbaseIntegration {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
  }

  async createCoinbaseOptimizedWallet() {
    // Create wallet optimized for Coinbase <-> Base flow
    const response = await fetch(`${this.baseUrl}/orgs/${this.orgId}/wallets`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.token}`,
        "Content-Type": "application/json",
        "X-Org-Id": this.orgId,
        "Idempotency-Key": `base-coinbase-wallet-${Date.now()}`,
      },
      body: JSON.stringify({
        chainId: 8453,
        walletType: "HOT",
        label: "Base Coinbase Flow",
        signerPolicy: "MPC_CLUSTER",
        metadata: {
          purpose: "coinbase-base-bridge",
          optimizedFor: "fast-deposits",
        },
      }),
    });

    return response.json();
  }

  async recordCoinbaseDeposit(depositData) {
    // User deposits from Coinbase to Base (near-instant)
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `coinbase-deposit-${depositData.hash}`,
        },
        body: JSON.stringify({
          chainId: 8453,
          hash: depositData.hash,
          fromAddress: depositData.from,
          toAddress: depositData.to,
          value: depositData.value,
          direction: "INBOUND",
          status: "CONFIRMED",
          blockNumber: depositData.blockNumber,
          gasPrice: "0", // Coinbase subsidizes
          txFeeAmount: "0",
          refType: "COINBASE_DEPOSIT",
          source: "COINBASE_BRIDGE",
        }),
      }
    );

    return response.json();
  }
}

// Usage
const coinbaseIntegration = new BaseCoinbaseIntegration("org-uuid", token);
const wallet = await coinbaseIntegration.createCoinbaseOptimizedWallet();
console.log("Created Coinbase-optimized wallet:", wallet.data.address);
```

---

## 🎯 Production Checklist

### Pre-Launch

- [ ] **Chain Registration**: Base registered with L2 layer designation
- [ ] **Parent Chain Link**: Ethereum (Chain ID 1) configured as parent
- [ ] **RPC Diversity**: Multiple providers (Coinbase, Alchemy, Infura, public)
- [ ] **Bridge Monitoring**: L1↔L2 deposit/withdrawal tracking implemented
- [ ] **Challenge Period**: 7-day withdrawal finalization period documented
- [ ] **Ultra-Low Gas**: Sub-cent transaction costs validated
- [ ] **Sequencer Health**: Monitoring for sequencer availability
- [ ] **L1 Finality**: Batch submission to Ethereum L1 tracked
- [ ] **Coinbase Integration**: Native Coinbase deposit flow tested
- [ ] **Testnet Validation**: Fully tested on Base Sepolia (Chain ID 84532)

### Monitoring Metrics

- **Block Time**: ~2 seconds
- **L2 Confirmation**: 1 block (~2 seconds)
- **L1 Finality**: ~20 minutes (batch posted to Ethereum)
- **Gas Price**: 0.0001-0.001 Gwei
- **Transaction Cost**: $0.01-$0.10 typical
- **Sequencer Uptime**: 99.9%+ target

---

## 📚 Additional Resources

- [Base Documentation](https://docs.base.org/)
- [Base Bridge](https://bridge.base.org/)
- [BaseScan Explorer](https://basescan.org/)
- [OP Stack Documentation](https://stack.optimism.io/)
- [Coinbase Cloud](https://www.coinbase.com/cloud)
- [Base Status Page](https://status.base.org/)

---

## 🔗 Related Integrations

- [Ethereum (L1)](/capabilities/chain/integrations/ethereum/)
- [Optimism](/capabilities/chain/integrations/optimism/)
- [Arbitrum](/capabilities/chain/integrations/arbitrum/)

---

**Note**: All code examples reference operations defined in `openapi/chain.yaml`. Base's L2 architecture requires special handling for bridge operations and L1 finality tracking.
