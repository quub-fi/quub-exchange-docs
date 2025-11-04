---
layout: docs
title: Solana Integration Guide
permalink: /capabilities/chain/integrations/solana/
---

# 🟣 Solana Integration Guide

> Complete guide for integrating Solana with Quub Exchange Chain Service. All operations reference `openapi/chain.yaml`.

## 📋 Overview

**Solana** is a high-performance blockchain optimized for speed and low costs. Unlike EVM chains, Solana uses a unique architecture with Proof of History (PoH) consensus, achieving sub-second block times and supporting thousands of transactions per second.

### Network Details

| Property            | Value                                   |
| ------------------- | --------------------------------------- |
| **Chain ID**        | Custom identifier (not EVM)             |
| **Native Currency** | SOL                                     |
| **Decimals**        | 9                                       |
| **Block Time**      | ~400ms                                  |
| **Consensus**       | Proof of History + Proof of Stake       |
| **Explorer**        | https://explorer.solana.com             |
| **RPC Providers**   | Solana Labs, Alchemy, Helius, QuickNode |
| **Chain Namespace** | SOLANA                                  |

---

## 🚀 Quick Start

### 1. Register Solana Chain

```javascript
// Node.js - Register Solana Mainnet
const registerSolanaChain = async (token) => {
  const response = await fetch("https://api.quub.exchange/v2/chains", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `solana-mainnet-${Date.now()}`,
    },
    body: JSON.stringify({
      chainId: "solana-mainnet-beta", // Solana uses string identifier
      name: "Solana",
      shortName: "SOL",
      networkType: "MAINNET",
      layer: "L1",
      nativeCurrency: "SOL",
      decimals: 9, // Note: 9 decimals, not 18
      blockTime: 0.4, // 400ms
      confirmations: 32, // Finalized after 32 blocks (~13 seconds)
      explorerUrl: "https://explorer.solana.com",
      docsUrl: "https://docs.solana.com/",
      genesisHash: "5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d", // Mainnet genesis
      chainNamespace: "SOLANA", // Not EVM
      status: "ACTIVE",
      metadata: {
        programRuntime: "sealevel",
        accountModel: "state-based",
        transactionVersion: "v0",
      },
    }),
  });

  return response.json();
};
```

```python
# Python - Register Solana with non-EVM configuration
import requests
import time

def register_solana_chain(token):
    url = 'https://api.quub.exchange/v2/chains'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
        'Idempotency-Key': f'solana-mainnet-{int(time.time())}'
    }
    payload = {
        'chainId': 'solana-mainnet-beta',
        'name': 'Solana',
        'shortName': 'SOL',
        'networkType': 'MAINNET',
        'layer': 'L1',
        'nativeCurrency': 'SOL',
        'decimals': 9,
        'blockTime': 0.4,
        'confirmations': 32,
        'explorerUrl': 'https://explorer.solana.com',
        'docsUrl': 'https://docs.solana.com/',
        'genesisHash': '5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d',
        'chainNamespace': 'SOLANA',
        'status': 'ACTIVE'
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

### 2. Configure RPC Adapters

```javascript
// Node.js - Setup Solana RPC with multiple providers
const setupSolanaRPCAdapters = async (token, apiKeys = {}) => {
  const adapters = [
    {
      name: "Solana Public Primary",
      rpcEndpoint: "https://api.mainnet-beta.solana.com",
      signerPolicy: "MPC_CLUSTER",
      priority: 2,
    },
    {
      name: "Helius Mainnet",
      rpcEndpoint: `https://mainnet.helius-rpc.com/?api-key=${
        apiKeys.helius || "YOUR_HELIUS_KEY"
      }`,
      wsEndpoint: `wss://mainnet.helius-rpc.com/?api-key=${
        apiKeys.helius || "YOUR_HELIUS_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 0,
    },
    {
      name: "Alchemy Solana",
      rpcEndpoint: `https://solana-mainnet.g.alchemy.com/v2/${
        apiKeys.alchemy || "YOUR_ALCHEMY_KEY"
      }`,
      signerPolicy: "MPC_CLUSTER",
      priority: 1,
    },
    {
      name: "QuickNode Solana",
      rpcEndpoint:
        apiKeys.quicknode ||
        "https://your-quicknode-endpoint.solana-mainnet.quiknode.pro/",
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
          "Idempotency-Key": `solana-${adapter.name
            .toLowerCase()
            .replace(/\s+/g, "-")}`,
        },
        body: JSON.stringify({
          chainId: "solana-mainnet-beta",
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
# Python - Configure Solana adapters with commitment levels
def configure_solana_adapters(token, api_keys=None):
    """Configure multiple Solana RPC adapters"""
    url = 'https://api.quub.exchange/v2/chain/adapters'

    adapters_config = [
        {
            'name': 'Solana Public RPC',
            'rpcEndpoint': 'https://api.mainnet-beta.solana.com',
            'priority': 3
        }
    ]

    # Add premium providers if API keys provided
    if api_keys:
        if 'helius' in api_keys:
            adapters_config.insert(0, {
                'name': 'Helius Primary',
                'rpcEndpoint': f"https://mainnet.helius-rpc.com/?api-key={api_keys['helius']}",
                'wsEndpoint': f"wss://mainnet.helius-rpc.com/?api-key={api_keys['helius']}",
                'priority': 0
            })

        if 'alchemy' in api_keys:
            adapters_config.insert(1, {
                'name': 'Alchemy Solana',
                'rpcEndpoint': f"https://solana-mainnet.g.alchemy.com/v2/{api_keys['alchemy']}",
                'priority': 1
            })

        if 'quicknode' in api_keys:
            adapters_config.append({
                'name': 'QuickNode Backup',
                'rpcEndpoint': api_keys['quicknode'],
                'priority': 2
            })

    results = []
    for config in adapters_config:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json',
            'Idempotency-Key': f"solana-{config['name'].lower().replace(' ', '-')}-{int(time.time())}"
        }

        payload = {
            'chainId': 'solana-mainnet-beta',
            'signerPolicy': 'MPC_CLUSTER',
            **config
        }

        response = requests.post(url, json=payload, headers=headers)
        results.append(response.json())

    return results
```

---

## 🏗️ Solana-Specific Integration Patterns

### Transaction Signature Format

```javascript
// Node.js - Handle Solana's base58 transaction signatures
class SolanaTransactionManager {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.chainId = "solana-mainnet-beta";
  }

  async recordSolanaTransaction(txData) {
    // Solana uses base58-encoded signatures, not 0x-prefixed hashes
    const response = await fetch(
      `${this.baseUrl}/orgs/${this.orgId}/onchain/txs`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json",
          "X-Org-Id": this.orgId,
          "Idempotency-Key": `solana-tx-${txData.signature}`,
        },
        body: JSON.stringify({
          chainId: this.chainId,
          hash: txData.signature, // Base58 signature, not hex
          fromAddress: txData.fromPubkey,
          toAddress: txData.toPubkey,
          value: this.lamportsToSol(txData.lamports).toString(),
          direction: txData.direction || "OUTBOUND",
          status: this.mapSolanaStatus(txData.confirmationStatus),
          blockNumber: txData.slot, // Solana uses "slot" instead of block number
          gasPrice: "0", // Solana doesn't have gas price
          nonce: txData.recentBlockhash, // Store recent blockhash as nonce
          txFeeAmount: this.lamportsToSol(txData.fee).toString(),
          source: "NODE",
        }),
      }
    );

    return response.json();
  }

  lamportsToSol(lamports) {
    return lamports / 1e9; // Solana has 9 decimals
  }

  solToLamports(sol) {
    return Math.floor(sol * 1e9);
  }

  mapSolanaStatus(confirmationStatus) {
    // Solana commitment levels: processed, confirmed, finalized
    const statusMap = {
      processed: "PENDING",
      confirmed: "CONFIRMED",
      finalized: "CONFIRMED",
    };
    return statusMap[confirmationStatus] || "PENDING";
  }

  async waitForFinalization(signature, maxAttempts = 30) {
    // Wait for Solana transaction to reach finalized commitment
    for (let attempt = 0; attempt < maxAttempts; attempt++) {
      const status = await this.getTransactionStatus(signature);

      if (status.confirmationStatus === "finalized") {
        return {
          signature,
          status: "FINALIZED",
          slot: status.slot,
        };
      }

      // Wait ~1 second between checks (2-3 Solana blocks)
      await this.sleep(1000);
    }

    return {
      signature,
      status: "TIMEOUT",
      slot: null,
    };
  }

  async getTransactionStatus(signature) {
    // This would call Solana RPC getSignatureStatus
    return {
      signature,
      confirmationStatus: "finalized",
      slot: 250000000,
      err: null,
    };
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Usage
const solanaManager = new SolanaTransactionManager("org-uuid", token);

const solTx = {
  signature:
    "5VERv8NMvzbJMEkV8xnrLkEaWRtSz9CosKDYjCJjBRnbJLgp8uirBgmQpjKhoR4tjF3ZpRzrFmBV6UjKdiSZkQUW",
  fromPubkey: "DYw8jCTfwHNRJhhmFcbXvVDTqWMEVFBX6ZKUmG5CNSKK",
  toPubkey: "FNpU3QJ3X1zJNTnvDh2V4JHmKJNrjhEZ5gKN2fJNJXVN",
  lamports: 1_500_000_000, // 1.5 SOL
  fee: 5_000, // 0.000005 SOL
  slot: 250000000,
  confirmationStatus: "finalized",
  direction: "OUTBOUND",
};

const result = await solanaManager.recordSolanaTransaction(solTx);
console.log("Recorded Solana transaction:", result);
```

### SPL Token Operations

```python
# Python - Handle Solana SPL token transfers
class SolanaSPLTokenManager:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.chain_id = 'solana-mainnet-beta'

    def record_spl_token_transfer(self, tx_data: dict) -> dict:
        """Record SPL token transfer (similar to ERC-20 but on Solana)"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"solana-spl-{tx_data['signature']}"
        }

        # SPL token transfers have minimal SOL for transaction fee
        payload = {
            'chainId': self.chain_id,
            'hash': tx_data['signature'],
            'fromAddress': tx_data['sourceAccount'],
            'toAddress': tx_data['destAccount'],
            'value': '0',  # No SOL transferred (tokens only)
            'direction': tx_data.get('direction', 'OUTBOUND'),
            'status': self.map_commitment_status(tx_data.get('commitment', 'finalized')),
            'blockNumber': tx_data['slot'],
            'gasPrice': '0',
            'txFeeAmount': self.lamports_to_sol(tx_data.get('fee', 5000)),
            'refType': 'SPL_TOKEN_TRANSFER',
            'source': 'NODE'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

    def lamports_to_sol(self, lamports: int) -> str:
        """Convert lamports to SOL (9 decimals)"""
        return str(lamports / 1e9)

    def map_commitment_status(self, commitment: str) -> str:
        """Map Solana commitment level to Quub status"""
        mapping = {
            'processed': 'PENDING',
            'confirmed': 'CONFIRMED',
            'finalized': 'CONFIRMED'
        }
        return mapping.get(commitment, 'PENDING')

    def record_bulk_spl_transfers(self, transfers: list) -> list:
        """Efficiently record multiple SPL token transfers"""
        results = []
        for transfer in transfers:
            try:
                result = self.record_spl_token_transfer(transfer)
                results.append(result)
            except Exception as e:
                print(f"Error recording transfer {transfer['signature']}: {e}")
                results.append({
                    'error': str(e),
                    'signature': transfer['signature']
                })

        return results

# Example usage
spl_manager = SolanaSPLTokenManager('org-uuid', token)

# USDC transfer on Solana
usdc_transfer = {
    'signature': '3KbvREZUat76wgWMtnJfWbJL74Vzh4U2eabVJa3Z3bb2fPtW8AREP5pbmRwUrxZCESbTomWpL7nZTMBKjgahmQdY',
    'sourceAccount': 'DYw8jCTfwHNRJhhmFcbXvVDTqWMEVFBX6ZKUmG5CNSKK',
    'destAccount': 'FNpU3QJ3X1zJNTnvDh2V4JHmKJNrjhEZ5gKN2fJNJXVN',
    'slot': 250000000,
    'fee': 5000,  # 0.000005 SOL
    'commitment': 'finalized',
    'token_mint': 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',  # USDC
    'token_amount': '1000.00',
    'direction': 'OUTBOUND'
}

result = spl_manager.record_spl_token_transfer(usdc_transfer)
print(f"Recorded SPL token transfer: {result}")
```

### Fast Block Time & Slot-Based Architecture

```javascript
// Node.js - Handle Solana's slot-based block system
class SolanaSlotMonitor {
  constructor(token) {
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.blockTime = 400; // 400ms average
  }

  async pollTransactionByCommitment(signature, targetCommitment = "finalized") {
    // Solana has 3 commitment levels: processed, confirmed, finalized
    const commitments = ["processed", "confirmed", "finalized"];
    const targetIndex = commitments.indexOf(targetCommitment);

    for (let attempt = 0; attempt < 40; attempt++) {
      // 40 * 400ms = 16 seconds max
      const status = await this.getSignatureStatus(signature);

      if (status && status.confirmationStatus) {
        const currentIndex = commitments.indexOf(status.confirmationStatus);

        if (currentIndex >= targetIndex) {
          return {
            signature,
            commitment: status.confirmationStatus,
            slot: status.slot,
            success: !status.err,
          };
        }

        console.log(
          `Transaction ${signature}: ${status.confirmationStatus} (waiting for ${targetCommitment})`
        );
      }

      // Wait for ~1 block time
      await this.sleep(this.blockTime);
    }

    return {
      signature,
      commitment: "TIMEOUT",
      slot: null,
      success: false,
    };
  }

  async getSignatureStatus(signature) {
    // This would call Solana RPC getSignatureStatuses
    return {
      slot: 250000000,
      confirmationStatus: "finalized",
      err: null,
    };
  }

  async updateTransactionCommitment(orgId, txId, commitment, slot) {
    // Update transaction status based on commitment level
    const statusMap = {
      processed: "PENDING",
      confirmed: "CONFIRMED",
      finalized: "CONFIRMED",
    };

    console.log(`Transaction ${txId} reached ${commitment} at slot ${slot}`);
    // Implementation would update transaction record
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Usage
const slotMonitor = new SolanaSlotMonitor(token);

// Wait for finalized commitment
const result = await slotMonitor.pollTransactionByCommitment(
  "5VERv8NMvzbJMEkV8xnrLkEaWRtSz9CosKDYjCJjBRnbJLgp8uirBgmQpjKhoR4tjF3ZpRzrFmBV6UjKdiSZkQUW",
  "finalized"
);

console.log(`Transaction finalized: ${result.success} at slot ${result.slot}`);
```

---

## 🔐 Security Considerations

### Account Rent & Balance Management

```python
# Python - Handle Solana's rent-exempt minimum requirements
class SolanaAccountManager:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.rent_exempt_minimum = 0.00089088  # ~890,880 lamports for basic account

    def create_wallet_with_rent(self, wallet_data: dict) -> dict:
        """Create Solana wallet ensuring rent-exempt minimum"""
        url = f'{self.base_url}/orgs/{self.org_id}/wallets'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"solana-wallet-{int(time.time())}"
        }

        payload = {
            'chainId': 'solana-mainnet-beta',
            'walletType': wallet_data.get('walletType', 'HOT'),
            'label': wallet_data.get('label', 'Solana Wallet'),
            'signerPolicy': 'MPC_CLUSTER'
        }

        response = requests.post(url, json=payload, headers=headers)
        wallet = response.json()

        # Note: Ensure wallet has rent-exempt minimum
        print(f"Created wallet: {wallet.get('data', {}).get('address')}")
        print(f"⚠️  Ensure minimum balance of {self.rent_exempt_minimum} SOL for rent exemption")

        return wallet

    def check_rent_exempt_balance(self, balance_sol: float) -> dict:
        """Check if balance meets rent-exempt requirements"""
        is_rent_exempt = balance_sol >= self.rent_exempt_minimum

        return {
            'balance': balance_sol,
            'rentExemptMinimum': self.rent_exempt_minimum,
            'isRentExempt': is_rent_exempt,
            'deficit': max(0, self.rent_exempt_minimum - balance_sol)
        }

    def record_rent_collection(self, account_pubkey: str, lamports_collected: int) -> dict:
        """Record when Solana runtime collects rent from non-exempt accounts"""
        # Solana collects rent from accounts below rent-exempt threshold
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"solana-rent-{account_pubkey}-{int(time.time())}"
        }

        payload = {
            'chainId': 'solana-mainnet-beta',
            'hash': f'RENT_{account_pubkey}_{int(time.time())}',
            'fromAddress': account_pubkey,
            'toAddress': '11111111111111111111111111111111',  # System Program
            'value': str(lamports_collected / 1e9),
            'direction': 'OUTBOUND',
            'status': 'CONFIRMED',
            'refType': 'RENT_PAYMENT',
            'source': 'SYSTEM'
        }

        response = requests.post(url, json=payload, headers=headers)
        return response.json()

# Example usage
account_manager = SolanaAccountManager('org-uuid', token)

# Check if balance is rent-exempt
balance_check = account_manager.check_rent_exempt_balance(0.5)
print(f"Rent exempt: {balance_check['isRentExempt']}")
if not balance_check['isRentExempt']:
    print(f"⚠️  Need {balance_check['deficit']} more SOL for rent exemption")
```

### RPC Rate Limiting

```javascript
// Node.js - Handle Solana RPC rate limits
class SolanaRateLimiter {
  constructor(orgId, token) {
    this.orgId = orgId;
    this.token = token;
    this.baseUrl = "https://api.quub.exchange/v2";
    this.rateLimit = {
      public: 100, // requests per 10 seconds
      paid: 1000, // requests per 10 seconds
    };
  }

  async getSolanaAdapters() {
    const response = await fetch(
      `${this.baseUrl}/chain/adapters?chainId=solana-mainnet-beta`,
      {
        headers: {
          Authorization: `Bearer ${this.token}`,
        },
      }
    );

    return (await response.json()).data;
  }

  async rotateAdapter() {
    // Get all Solana adapters and use round-robin
    const adapters = await this.getSolanaAdapters();

    // Sort by priority
    adapters.sort((a, b) => a.priority - b.priority);

    // Return adapter with lowest current usage
    return adapters[0];
  }

  async executeWithRateLimitRetry(operation, maxRetries = 3) {
    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation();
      } catch (error) {
        if (
          error.message.includes("429") ||
          error.message.includes("rate limit")
        ) {
          console.log(
            `Rate limited, retrying with different adapter (attempt ${
              attempt + 1
            })`
          );

          // Rotate to different adapter
          await this.rotateAdapter();

          // Exponential backoff
          await this.sleep(Math.pow(2, attempt) * 1000);
        } else {
          throw error;
        }
      }
    }

    throw new Error("Max retries exceeded due to rate limiting");
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Usage
const rateLimiter = new SolanaRateLimiter("org-uuid", token);

// Execute operation with automatic rate limit handling
const result = await rateLimiter.executeWithRateLimitRetry(async () => {
  // Your Solana RPC operation here
  return { success: true };
});
```

---

## 📊 Performance Optimization

### High-Throughput Transaction Recording

```python
# Python - Optimize for Solana's high transaction throughput
class SolanaHighThroughputRecorder:
    def __init__(self, org_id: str, token: str):
        self.org_id = org_id
        self.token = token
        self.base_url = 'https://api.quub.exchange/v2'
        self.batch_size = 100

    def process_slot_transactions(self, slot: int, transactions: list) -> dict:
        """Process all transactions from a Solana slot efficiently"""
        results = {
            'slot': slot,
            'total': len(transactions),
            'successful': 0,
            'failed': 0
        }

        # Process in batches
        for i in range(0, len(transactions), self.batch_size):
            batch = transactions[i:i + self.batch_size]
            batch_results = self._process_batch(batch)

            results['successful'] += batch_results['successful']
            results['failed'] += batch_results['failed']

        return results

    def _process_batch(self, transactions: list) -> dict:
        """Process a batch of transactions"""
        successful = 0
        failed = 0

        for tx in transactions:
            try:
                self.record_transaction(tx)
                successful += 1
            except Exception as e:
                print(f"Error recording transaction {tx.get('signature')}: {e}")
                failed += 1

        return {'successful': successful, 'failed': failed}

    def record_transaction(self, tx_data: dict) -> dict:
        """Record a single Solana transaction"""
        url = f'{self.base_url}/orgs/{self.org_id}/onchain/txs'
        headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json',
            'X-Org-Id': self.org_id,
            'Idempotency-Key': f"solana-batch-{tx_data['signature']}"
        }

        payload = {
            'chainId': 'solana-mainnet-beta',
            'hash': tx_data['signature'],
            'fromAddress': tx_data['from'],
            'toAddress': tx_data['to'],
            'value': str(tx_data['lamports'] / 1e9),
            'direction': tx_data.get('direction', 'OUTBOUND'),
            'status': 'CONFIRMED',
            'blockNumber': tx_data['slot'],
            'gasPrice': '0',
            'txFeeAmount': str(tx_data.get('fee', 5000) / 1e9),
            'source': 'INDEXER'
        }

        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()

    def calculate_throughput_stats(self, results: dict, time_seconds: float) -> dict:
        """Calculate TPS statistics"""
        tps = results['total'] / time_seconds
        success_rate = (results['successful'] / results['total'] * 100) if results['total'] > 0 else 0

        return {
            'totalTransactions': results['total'],
            'successful': results['successful'],
            'failed': results['failed'],
            'successRate': success_rate,
            'timeSeconds': time_seconds,
            'transactionsPerSecond': tps
        }

# Example usage
import time as time_module

high_throughput = SolanaHighThroughputRecorder('org-uuid', token)

# Simulate processing 3000 transactions from a single slot
start_time = time_module.time()

transactions = [
    {
        'signature': f'{i:064x}',
        'from': 'DYw8jCTfwHNRJhhmFcbXvVDTqWMEVFBX6ZKUmG5CNSKK',
        'to': 'FNpU3QJ3X1zJNTnvDh2V4JHmKJNrjhEZ5gKN2fJNJXVN',
        'lamports': 1_000_000_000,
        'slot': 250000000,
        'fee': 5000
    }
    for i in range(3000)
]

results = high_throughput.process_slot_transactions(250000000, transactions)
elapsed = time_module.time() - start_time

stats = high_throughput.calculate_throughput_stats(results, elapsed)
print(f"Processed {stats['totalTransactions']} transactions in {stats['timeSeconds']:.2f}s")
print(f"Throughput: {stats['transactionsPerSecond']:.2f} TPS")
print(f"Success rate: {stats['successRate']:.2f}%")
```

---

## 🎯 Production Checklist

### Pre-Launch

- [ ] **Chain Registration**: Solana registered with SOLANA namespace (not EVM)
- [ ] **9 Decimals**: Configured for SOL's 9 decimals (not 18)
- [ ] **RPC Diversity**: Multiple providers (Helius, Alchemy, QuickNode, public)
- [ ] **Commitment Levels**: processed/confirmed/finalized handling implemented
- [ ] **Slot-Based Tracking**: Using slots instead of block numbers
- [ ] **Base58 Signatures**: Handling Solana's base58 transaction signatures
- [ ] **SPL Token Support**: SPL token transfer tracking configured
- [ ] **Rent Exemption**: Account rent-exempt minimums documented
- [ ] **Rate Limiting**: RPC rate limit handling with adapter rotation
- [ ] **High Throughput**: Batch processing for 400ms block times
- [ ] **Testnet Validation**: Fully tested on Solana Devnet

### Monitoring Metrics

- **Block Time**: ~400ms
- **Finalization**: ~13 seconds (32 slots)
- **Transaction Fee**: 0.000005 SOL typical
- **RPC Latency**: < 100ms for premium providers
- **Throughput**: 2,000-3,000 TPS sustained

---

## 📚 Additional Resources

- [Solana Documentation](https://docs.solana.com/)
- [Solana RPC API](https://docs.solana.com/api/http)
- [SPL Token Program](https://spl.solana.com/token)
- [Solana Explorer](https://explorer.solana.com/)
- [Helius RPC](https://www.helius.dev/)
- [Alchemy Solana](https://www.alchemy.com/solana)

---

## 🔗 Related Integrations

- [Ethereum](/capabilities/chain/integrations/ethereum/)
- [BNB Chain](/capabilities/chain/integrations/bnb/)
- [Polygon](/capabilities/chain/integrations/polygon/)

---

**Note**: All code examples reference operations defined in `openapi/chain.yaml`. Solana's non-EVM architecture requires unique handling for signatures, slots, commitment levels, and account rent.
