---
layout: docs
title: Getting Started with Quub Exchange
description: Complete guide to integrate Quub Exchange APIs from scratch
---

# Getting Started with Quub Exchange

This guide will walk you through integrating Quub Exchange APIs into your application, from initial setup to making your first successful API call.

**Time Required:** 30 minutes
**Difficulty:** Beginner
**Prerequisites:** Basic programming knowledge, API familiarity

---

## 📋 What You'll Learn

- Setting up your development environment
- Creating and configuring your Quub Exchange account
- Authenticating with the API
- Making your first API request
- Handling responses and errors
- Next steps for building your application

---

## Step 1: Create Your Account

### 1.1 Sign Up

1. Visit [https://app.quub.exchange/signup](https://app.quub.exchange/signup)
2. Choose your account type:

   - **Developer** - For testing and development
   - **Business** - For production applications
   - **Enterprise** - For high-volume trading

3. Complete the registration form
4. Verify your email address

### 1.2 Access the Sandbox

For development, we recommend starting with our sandbox environment:

```
Sandbox Base URL: https://sandbox-api.quub.exchange/v1
Production Base URL: https://api.quub.exchange/v1
```

<div class="callout info">
  <strong>💡 Tip:</strong> The sandbox environment mirrors production but uses test data. No real money or assets are involved.
</div>

---

## Step 2: Generate API Credentials

### 2.1 Create an API Key

1. Log into the [Quub Dashboard](https://app.quub.exchange)
2. Navigate to **Settings → API Keys**
3. Click **Create New API Key**
4. Configure permissions:

   - Read-only (view data)
   - Trade (execute orders)
   - Withdraw (move assets)
   - Admin (full access)

5. Save your credentials securely:
   ```json
   {
     "api_key": "qub_live_1234567890abcdef",
     "api_secret": "sk_live_abcdef1234567890...",
     "tenant_id": "org_abc123"
   }
   ```

<div class="callout warning">
  <strong>⚠️ Security:</strong> Never commit API secrets to version control. Store them in environment variables or a secrets manager.
</div>

---

## Step 3: Install SDK (Optional)

Choose your preferred language:

### JavaScript/Node.js

```bash
npm install @quub/exchange-sdk
```

```javascript
const Quub = require("@quub/exchange-sdk");

const client = new Quub({
  apiKey: process.env.QUUB_API_KEY,
  apiSecret: process.env.QUUB_API_SECRET,
  environment: "sandbox", // or 'production'
});
```

### Python

```bash
pip install quub-exchange
```

```python
from quub import QuubClient

client = QuubClient(
    api_key=os.getenv('QUUB_API_KEY'),
    api_secret=os.getenv('QUUB_API_SECRET'),
    environment='sandbox'
)
```

### Direct REST API

If you prefer not to use an SDK, you can call our REST API directly.

---

## Step 4: Authenticate

### 4.1 Generate JWT Token

```bash
POST /v1/auth/token
Content-Type: application/json

{
  "api_key": "your_api_key",
  "api_secret": "your_api_secret"
}
```

**Response:**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "rt_1234567890abcdef"
}
```

### 4.2 Using the Token

Include the token in all subsequent requests:

```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

<div class="callout info">
  <strong>📚 Learn More:</strong> See our <a href="../../docs/authentication/">Authentication Guide</a> for advanced topics like token refresh and revocation.
</div>

---

## Step 5: Make Your First API Call

### 5.1 Get Account Information

Let's retrieve your account details:

**Using SDK (JavaScript):**

```javascript
const account = await client.auth.getAccount();
console.log("Account ID:", account.id);
console.log("Organization:", account.org_name);
console.log("Status:", account.status);
```

**Using REST API:**

```bash
curl -X GET https://sandbox-api.quub.exchange/v1/auth/account \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

**Response:**

```json
{
  "id": "usr_1234567890",
  "email": "developer@example.com",
  "org_id": "org_abc123",
  "org_name": "My Company",
  "status": "active",
  "created_at": "2025-11-01T10:00:00Z",
  "permissions": ["read", "trade"]
}
```

### 5.2 List Available Assets

```javascript
const assets = await client.custodian.listAssets();
assets.forEach((asset) => {
  console.log(`${asset.symbol}: ${asset.balance} ${asset.currency}`);
});
```

**REST API:**

```bash
curl -X GET https://sandbox-api.quub.exchange/v1/custodian/assets \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**

```json
{
  "assets": [
    {
      "id": "ast_btc_001",
      "symbol": "BTC",
      "name": "Bitcoin",
      "balance": "1.5",
      "available": "1.2",
      "locked": "0.3",
      "value_usd": "67500.00"
    },
    {
      "id": "ast_eth_001",
      "symbol": "ETH",
      "name": "Ethereum",
      "balance": "10.0",
      "available": "8.5",
      "locked": "1.5",
      "value_usd": "23000.00"
    }
  ],
  "total_value_usd": "90500.00"
}
```

---

## Step 6: Place a Test Order

Let's place a simple limit order in the sandbox:

### 6.1 Get Market Data

First, check the current market price:

```javascript
const ticker = await client.exchange.getTicker("BTC-USD");
console.log("Current BTC Price:", ticker.last_price);
```

### 6.2 Create a Limit Order

```javascript
const order = await client.exchange.createOrder({
  instrument: "BTC-USD",
  side: "buy",
  type: "limit",
  quantity: "0.01",
  price: "65000.00",
  time_in_force: "GTC", // Good 'til Canceled
});

console.log("Order placed:", order.id);
console.log("Status:", order.status);
```

**REST API:**

```bash
curl -X POST https://sandbox-api.quub.exchange/v1/exchange/orders \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "instrument": "BTC-USD",
    "side": "buy",
    "type": "limit",
    "quantity": "0.01",
    "price": "65000.00",
    "time_in_force": "GTC"
  }'
```

**Response:**

```json
{
  "id": "ord_1234567890",
  "instrument": "BTC-USD",
  "side": "buy",
  "type": "limit",
  "quantity": "0.01",
  "price": "65000.00",
  "status": "pending",
  "filled_quantity": "0",
  "created_at": "2025-11-03T09:15:00Z",
  "updated_at": "2025-11-03T09:15:00Z"
}
```

---

## Step 7: Handle Responses & Errors

### 7.1 Success Responses

All successful responses follow this structure:

```json
{
  "success": true,
  "data": { ... },
  "metadata": {
    "request_id": "req_abc123",
    "timestamp": "2025-11-03T09:15:00Z"
  }
}
```

### 7.2 Error Handling

```javascript
try {
  const order = await client.exchange.createOrder({...});
} catch (error) {
  console.error('Error Code:', error.code);
  console.error('Message:', error.message);
  console.error('Details:', error.details);
}
```

**Error Response:**

```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_BALANCE",
    "message": "Insufficient balance to place order",
    "details": {
      "required": "650.00",
      "available": "500.00",
      "currency": "USD"
    }
  },
  "request_id": "req_abc123"
}
```

<div class="callout info">
  <strong>📚 Error Reference:</strong> See our <a href="../../docs/errors/">Error Handling Guide</a> for complete error codes and handling strategies.
</div>

---

## Step 8: Set Up Webhooks (Optional)

Get real-time updates for important events:

### 8.1 Create a Webhook Endpoint

```javascript
app.post("/webhooks/quub", (req, res) => {
  const event = req.body;

  switch (event.type) {
    case "order.filled":
      console.log("Order filled:", event.data.order_id);
      break;
    case "withdrawal.completed":
      console.log("Withdrawal completed:", event.data.tx_id);
      break;
  }

  res.sendStatus(200);
});
```

### 8.2 Register Webhook

```javascript
const webhook = await client.events.createWebhook({
  url: "https://yourapp.com/webhooks/quub",
  events: ["order.*", "withdrawal.*"],
  secret: "your_webhook_secret",
});
```

<div class="callout info">
  <strong>📚 Learn More:</strong> See our <a href="../../docs/webhooks/">Webhooks Guide</a> for security, verification, and retry logic.
</div>

---

## 🎯 Next Steps

Congratulations! You've successfully integrated with Quub Exchange. Here's what to explore next:

### Build Your Application

1. **Trading Bot** - [Trading Integration Guide](../trading-integration/)
2. **Custody Solution** - [Custody Integration Guide](../custody-integration/)
3. **Payment System** - [Payment Integration Guide](../payment-integration/)

### Advanced Topics

- [**Authentication**](../../docs/authentication/) - OAuth, API keys, and security
- [**Best Practices**](../../docs/best-practices/) - Production-ready patterns
- [**Rate Limiting**](../../docs/rate-limits/) - Optimize API usage
- [**Testing**](../testing-strategy/) - Test your integration thoroughly

### Explore APIs

- [**Exchange API**](../../capabilities/exchange/api-documentation/) - Trading and orders
- [**Custodian API**](../../capabilities/custodian/api-documentation/) - Asset management
- [**Market Data API**](../../capabilities/market-oracles/api-documentation/) - Price feeds
- [**All APIs**](../../api-reference/) - Complete reference

---

## 💡 Pro Tips

1. **Start in Sandbox** - Always test in sandbox before production
2. **Use Webhooks** - More efficient than polling APIs
3. **Implement Retries** - Handle transient failures gracefully
4. **Monitor API Usage** - Track your rate limits
5. **Keep Tokens Secure** - Use environment variables and secrets managers

---

## 🆘 Need Help?

- **[API Reference](../../api-reference/)** - Complete API documentation
- **[Community Forum](#)** - Ask questions
- **[Support](mailto:support@quub.exchange)** - Get help from our team
- **[Status Page](https://status.quub.exchange)** - Check system status

---

## 📚 Additional Resources

- [Authentication Deep Dive](../../docs/authentication/)
- [SDK Documentation](#)
- [Postman Collection](#)
- [Code Examples on GitHub](#)

---

_Last updated: November 3, 2025_
