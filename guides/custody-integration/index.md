---
layout: docs
title: Digital Asset Custody Integration
permalink: /guides/custody-integration/
description: Integrate secure digital asset custody with multi-sig wallets and transaction signing
---

# Digital Asset Custody Integration

Integrate secure digital asset custody with Quub Exchange's custodian services.

## Wallet Management

### Create Wallets

```javascript
// Create multi-sig wallet
const wallet = await client.custodian.createWallet({
  currency: "BTC",
  type: "multi-sig",
  signers: ["signer1_id", "signer2_id", "signer3_id"],
  threshold: 2, // 2-of-3 multi-sig
});

console.log(`Wallet created: ${wallet.address}`);
```

### Get Balances

```javascript
// Get all balances
const balances = await client.custodian.getBalances();

balances.forEach((balance) => {
  console.log(
    `${balance.currency}: ${balance.available} (${balance.locked} locked)`
  );
});
```

## Transaction Signing

### Initiate Withdrawal

```javascript
// Create withdrawal
const withdrawal = await client.custodian.createWithdrawal({
  currency: "BTC",
  address: "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa",
  amount: "0.1",
  memo: "Customer withdrawal",
});

// Get signing request
const signingRequest = await client.custodian.getSigningRequest(withdrawal.id);

// Sign with each required signer
const signature1 = await signer1.sign(signingRequest.message);
const signature2 = await signer2.sign(signingRequest.message);

// Submit signatures
await client.custodian.submitSignatures(withdrawal.id, {
  signatures: [
    { signerId: "signer1_id", signature: signature1 },
    { signerId: "signer2_id", signature: signature2 },
  ],
});
```

## Security Controls

### Transaction Policies

```javascript
// Set withdrawal limits
await client.custodian.setPolicy({
  type: "withdrawal_limit",
  currency: "BTC",
  dailyLimit: "10",
  singleTxLimit: "1",
  requireApproval: true,
});

// Whitelist addresses
await client.custodian.whitelistAddress({
  currency: "BTC",
  address: "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa",
  label: "Exchange hot wallet",
});
```

---

**Next Steps:**

- [Treasury Management](../treasury-management/)
- [Security Guide]({{ '/guides/getting-started/security-guide/' | relative_url }})
- [Custodian API]({{ '/capabilities/custodian/api-reference/' | relative_url }})
