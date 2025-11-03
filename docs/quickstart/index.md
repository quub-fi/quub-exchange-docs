---
layout: docs
title: Quick Start Guide
description: Get started with Quub Exchange APIs in 5 minutes
---

# Quick Start Guide

Get your Quub Exchange integration up and running in minutes. This guide will walk you through authentication, making your first API call, and executing a basic trade.

## Prerequisites

Before you begin, ensure you have:

- ✅ A Quub Exchange account
- ✅ API credentials (API Key and Secret)
- ✅ Basic knowledge of REST APIs
- ✅ A tool to make HTTP requests (curl, Postman, or code)

## Step 1: Get Your API Credentials

1. Log in to your Quub Exchange account
2. Navigate to **Settings → API Keys**
3. Click **"Create New API Key"**
4. Save your **API Key** and **API Secret** securely

<div class="callout warning">
  <strong>⚠️ Security Warning:</strong> Never share your API secret or commit it to version control. Treat it like a password.
</div>

## Step 2: Authenticate

Quub Exchange uses JWT-based authentication. Here's how to get an access token:

### cURL Example

```bash
curl -X POST https://api.quub.exchange/auth/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "apiKey": "your-api-key",
    "apiSecret": "your-api-secret"
  }'
```

### Response

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "refreshToken": "refresh-token-here"
}
```

Save the `token` - you'll need it for all subsequent API calls.

## Step 3: Make Your First API Call

Let's fetch your account information:

### cURL Example

```bash
curl -X GET https://api.quub.exchange/identity/v1/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "X-Tenant-ID: your-org-id"
```

### Response

```json
{
  "userId": "usr_123abc",
  "email": "trader@example.com",
  "orgId": "org_456def",
  "verified": true,
  "createdAt": "2025-01-15T10:30:00Z"
}
```

## Step 4: Check Market Data

Before trading, let's check current prices:

```bash
curl -X GET https://api.quub.exchange/pricing-refdata/v1/prices/BTC-USD \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "X-Tenant-ID: your-org-id"
```

### Response

```json
{
  "symbol": "BTC-USD",
  "price": 45250.5,
  "bid": 45248.25,
  "ask": 45252.75,
  "timestamp": "2025-11-03T09:15:30Z"
}
```

## Step 5: Place Your First Order

Now let's place a simple limit buy order:

```bash
curl -X POST https://api.quub.exchange/exchange/v1/orders \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "X-Tenant-ID: your-org-id" \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "BTC-USD",
    "side": "buy",
    "type": "limit",
    "quantity": 0.01,
    "price": 45000.00,
    "timeInForce": "GTC"
  }'
```

### Response

```json
{
  "orderId": "ord_789xyz",
  "symbol": "BTC-USD",
  "side": "buy",
  "type": "limit",
  "status": "open",
  "quantity": 0.01,
  "price": 45000.0,
  "filled": 0.0,
  "remaining": 0.01,
  "createdAt": "2025-11-03T09:20:00Z"
}
```

## Step 6: Check Order Status

Monitor your order:

```bash
curl -X GET https://api.quub.exchange/exchange/v1/orders/ord_789xyz \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "X-Tenant-ID: your-org-id"
```

## Next Steps

🎉 Congratulations! You've successfully:

- ✅ Authenticated with the API
- ✅ Retrieved account information
- ✅ Checked market data
- ✅ Placed an order

### Continue Learning

- 📖 [Authentication Guide](../authentication/) - Deep dive into security
- 🔐 [Multi-Tenancy](../../api-reference/tenancy-trust/) - Understand tenant isolation
- 💱 [Trading APIs](../../api-reference/exchange/) - Advanced order types
- 🏦 [Custody APIs](../../api-reference/custodian/) - Manage wallets and assets
- 🔔 [Webhooks](../webhooks/) - Real-time notifications

### Code Examples

- [Python SDK Example](#)
- [JavaScript/Node.js Example](#)
- [Java Example](#)
- [Go Example](#)

## Common Issues

### 401 Unauthorized

- Check that your API key and secret are correct
- Verify your token hasn't expired
- Ensure you're including the `Authorization` header

### 403 Forbidden

- Verify you have the necessary permissions
- Check that your `X-Tenant-ID` header is correct
- Ensure your API key is enabled

### 429 Too Many Requests

- You've exceeded the rate limit
- Implement exponential backoff
- See [Rate Limiting Guide](../rate-limits/)

## Support

Need help?

- 💬 [Community Forum](#)
- 📧 Email: support@quub.exchange
- 📚 [Full API Reference](../../api-reference/)

---

**Ready for production?** Check our [Best Practices Guide](../best-practices/) to ensure your integration is secure and optimized.
