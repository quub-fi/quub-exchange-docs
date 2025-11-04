---
layout: docs
title: Quick Start Guide
permalink: /guides/getting-started/quick-start/
description: Get up and running with Quub Exchange APIs in minutes
---

# Quick Start Guide

Get started with Quub Exchange in under 10 minutes. This guide will walk you through account setup, authentication, and making your first API call.

## Prerequisites

Before you begin, ensure you have:

- ✅ A Quub Exchange account (sign up at [console.quub.fi](https://console.quub.fi))
- ✅ Basic knowledge of REST APIs
- ✅ A development environment with Node.js 18+ or Python 3.9+
- ✅ Command-line access and curl or similar HTTP client

## Step 1: Create Your Account

1. Visit [console.quub.fi](https://console.quub.fi)
2. Click **Sign Up** and complete registration
3. Verify your email address
4. Complete KYC/KYB requirements (depending on your use case)

## Step 2: Generate API Credentials

1. Log into the Quub Exchange Console
2. Navigate to **Settings** → **API Keys**
3. Click **Create New API Key**
4. Set permissions based on your needs:
   - `read`: View data only
   - `trade`: Execute trades
   - `withdraw`: Move funds
5. Save your credentials securely:
   ```
   API Key: sk_live_abc123...
   API Secret: sk_secret_xyz789...
   Organization ID: org_456...
   ```

⚠️ **Important**: Store your API secret securely. It will only be shown once.

## Step 3: Set Up Your Environment

### Option A: Node.js/JavaScript

Install the Quub SDK:

```bash
npm install @quub/sdk
```

Create a `.env` file:

```bash
QUUB_API_KEY=sk_live_abc123...
QUUB_API_SECRET=sk_secret_xyz789...
QUUB_ORG_ID=org_456...
QUUB_ENVIRONMENT=sandbox  # or 'production'
```

### Option B: Python

Install the Quub SDK:

```bash
pip install quub-sdk
```

Create a `.env` file:

```bash
QUUB_API_KEY=sk_live_abc123...
QUUB_API_SECRET=sk_secret_xyz789...
QUUB_ORG_ID=org_456...
QUUB_ENVIRONMENT=sandbox  # or 'production'
```

### Option C: Direct API Calls (cURL)

Set environment variables:

```bash
export QUUB_API_KEY="sk_live_abc123..."
export QUUB_API_SECRET="sk_secret_xyz789..."
export QUUB_ORG_ID="org_456..."
```

## Step 4: Authenticate

### Using Node.js SDK

```javascript
import { QuubClient } from "@quub/sdk";
import dotenv from "dotenv";

dotenv.config();

const client = new QuubClient({
  apiKey: process.env.QUUB_API_KEY,
  apiSecret: process.env.QUUB_API_SECRET,
  orgId: process.env.QUUB_ORG_ID,
  environment: process.env.QUUB_ENVIRONMENT,
});

// Test authentication
async function testAuth() {
  try {
    const identity = await client.auth.getIdentity();
    console.log("✅ Authentication successful!");
    console.log("Organization:", identity.orgName);
    console.log("User:", identity.username);
  } catch (error) {
    console.error("❌ Authentication failed:", error.message);
  }
}

testAuth();
```

### Using Python SDK

```python
import os
from quub import QuubClient
from dotenv import load_dotenv

load_dotenv()

client = QuubClient(
    api_key=os.getenv('QUUB_API_KEY'),
    api_secret=os.getenv('QUUB_API_SECRET'),
    org_id=os.getenv('QUUB_ORG_ID'),
    environment=os.getenv('QUUB_ENVIRONMENT')
)

# Test authentication
try:
    identity = client.auth.get_identity()
    print('✅ Authentication successful!')
    print(f'Organization: {identity.org_name}')
    print(f'User: {identity.username}')
except Exception as error:
    print(f'❌ Authentication failed: {error}')
```

### Using cURL

First, generate a JWT token:

```bash
curl -X POST https://api.quub.fi/v1/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "apiKey": "'$QUUB_API_KEY'",
    "apiSecret": "'$QUUB_API_SECRET'",
    "orgId": "'$QUUB_ORG_ID'"
  }'
```

Response:

```json
{
  "accessToken": "eyJhbGciOiJSUzI1NiIs...",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

## Step 5: Make Your First API Call

### Fetch Market Data

**Node.js:**

```javascript
async function getMarketData() {
  const markets = await client.exchange.getMarkets();

  console.log("Available Markets:");
  markets.forEach((market) => {
    console.log(
      `${market.symbol}: ${market.lastPrice} ${market.quoteCurrency}`
    );
  });
}

getMarketData();
```

**Python:**

```python
def get_market_data():
    markets = client.exchange.get_markets()

    print('Available Markets:')
    for market in markets:
        print(f"{market['symbol']}: {market['lastPrice']} {market['quoteCurrency']}")

get_market_data()
```

**cURL:**

```bash
TOKEN="eyJhbGciOiJSUzI1NiIs..."

curl https://api.quub.fi/v1/exchange/markets \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Org-ID: $QUUB_ORG_ID"
```

### Place Your First Order (Sandbox)

**Node.js:**

```javascript
async function placeOrder() {
  const order = await client.exchange.createOrder({
    symbol: "BTC-USD",
    side: "buy",
    type: "limit",
    quantity: "0.001",
    price: "45000.00",
    timeInForce: "GTC",
  });

  console.log("Order placed:", order.orderId);
  console.log("Status:", order.status);
}

placeOrder();
```

**Python:**

```python
def place_order():
    order = client.exchange.create_order(
        symbol='BTC-USD',
        side='buy',
        type='limit',
        quantity='0.001',
        price='45000.00',
        time_in_force='GTC'
    )

    print(f'Order placed: {order["orderId"]}')
    print(f'Status: {order["status"]}')

place_order()
```

**cURL:**

```bash
curl -X POST https://api.quub.fi/v1/exchange/orders \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Org-ID: $QUUB_ORG_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "BTC-USD",
    "side": "buy",
    "type": "limit",
    "quantity": "0.001",
    "price": "45000.00",
    "timeInForce": "GTC"
  }'
```

## Step 6: Check Your Balance

**Node.js:**

```javascript
async function checkBalance() {
  const balances = await client.custodian.getBalances();

  console.log("Account Balances:");
  balances.forEach((balance) => {
    if (parseFloat(balance.available) > 0) {
      console.log(
        `${balance.currency}: ${balance.available} (${balance.total} total)`
      );
    }
  });
}

checkBalance();
```

**Python:**

```python
def check_balance():
    balances = client.custodian.get_balances()

    print('Account Balances:')
    for balance in balances:
        if float(balance['available']) > 0:
            print(f"{balance['currency']}: {balance['available']} ({balance['total']} total)")

check_balance()
```

## Common Use Cases

### 1. Real-Time Price Monitoring

```javascript
// Subscribe to market data WebSocket
const ws = client.exchange.subscribeToMarket("BTC-USD", (data) => {
  console.log(`BTC-USD: ${data.price} (${data.change24h}%)`);
});
```

### 2. Portfolio Management

```javascript
async function getPortfolioValue() {
  const balances = await client.custodian.getBalances();
  const prices = await client.exchange.getPrices();

  let totalValue = 0;

  balances.forEach((balance) => {
    const price = prices[balance.currency] || 0;
    totalValue += parseFloat(balance.total) * price;
  });

  console.log(`Portfolio Value: $${totalValue.toFixed(2)}`);
}
```

### 3. Automated Trading Bot

```javascript
async function simpleTradingBot() {
  const market = await client.exchange.getMarket("BTC-USD");

  // Simple moving average strategy
  if (market.price < market.sma20 && market.rsi < 30) {
    // Oversold - Buy signal
    await client.exchange.createOrder({
      symbol: "BTC-USD",
      side: "buy",
      type: "market",
      quantity: "0.001",
    });
    console.log("✅ Buy order executed");
  }
}
```

## Next Steps

Now that you're up and running, explore these resources:

1. **[Integration Guide](../integration-guide/)** - Comprehensive integration instructions
2. **[API Reference]({{ '/capabilities/' | relative_url }})** - Complete API documentation
3. **[Best Practices](../best-practices/)** - Recommended patterns
4. **[Security Guide](../security-guide/)** - Secure your implementation
5. **[Code Examples](/guides/)** - Sample applications

## Troubleshooting

### Authentication Errors

**Problem:** `401 Unauthorized`

**Solution:**

- Verify your API key and secret are correct
- Ensure your organization ID matches your account
- Check if your API key has been revoked
- Verify token hasn't expired (tokens last 1 hour)

### Rate Limiting

**Problem:** `429 Too Many Requests`

**Solution:**

- Implement exponential backoff
- Check the `Retry-After` header
- Reduce request frequency
- Consider upgrading your plan

### Network Errors

**Problem:** Connection timeouts or failures

**Solution:**

- Check your internet connection
- Verify API endpoint URLs
- Test with curl to isolate SDK issues
- Review firewall/proxy settings

## Support

Need help? We're here for you:

- 📚 **Documentation**: [docs.quub.fi](https://docs.quub.fi)
- 💬 **Community Forum**: [community.quub.fi](https://quub.fi/community)
- 📧 **Email Support**: support@quub.fi
- 🐛 **Report Issues**: [github.com/quub-fi/issues](https://github.com/quub-fi/issues)

---

**Congratulations!** 🎉 You've completed the Quick Start Guide. You're now ready to build amazing applications with Quub Exchange.
