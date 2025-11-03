---
layout: docs
title: Authentication Guide
description: Secure authentication patterns for Quub Exchange APIs
---

# Authentication Guide

Quub Exchange uses JWT (JSON Web Tokens) with multi-tenant security to ensure secure API access. This guide covers authentication flows, token management, and security best practices.

## Overview

All API requests to Quub Exchange require:

1. **JWT Access Token** - Obtained through authentication
2. **Tenant ID Header** - Multi-tenant isolation (`X-Tenant-ID`)
3. **HTTPS** - All API calls must use TLS 1.2+

## Authentication Flow

```mermaid
sequenceDiagram
    participant Client
    participant Auth API
    participant Resource API

    Client->>Auth API: POST /auth/v1/login (API Key + Secret)
    Auth API->>Client: Access Token + Refresh Token
    Client->>Resource API: GET /resource (Bearer Token + Tenant ID)
    Resource API->>Client: Protected Resource

    Note over Client,Auth API: Token expires after 1 hour

    Client->>Auth API: POST /auth/v1/refresh (Refresh Token)
    Auth API->>Client: New Access Token
```

## Getting API Credentials

### 1. Create API Key

```bash
# Via API (requires admin role)
curl -X POST https://api.quub.exchange/auth/v1/api-keys \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "X-Tenant-ID: your-org-id" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Production Trading Bot",
    "permissions": ["trading:execute", "market:read"],
    "expiresAt": "2026-12-31T23:59:59Z"
  }'
```

### Response

```json
{
  "apiKeyId": "key_abc123",
  "apiKey": "qx_live_1234567890abcdef",
  "apiSecret": "secret_xyz9876543210fedcba",
  "createdAt": "2025-11-03T10:00:00Z",
  "expiresAt": "2026-12-31T23:59:59Z"
}
```

<div class="callout danger">
  <strong>🔒 Critical:</strong> The API secret is shown only once. Store it securely in a secrets manager (e.g., AWS Secrets Manager, HashiCorp Vault).
</div>

## Login & Token Acquisition

### Basic Login

```bash
curl -X POST https://api.quub.exchange/auth/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "apiKey": "qx_live_1234567890abcdef",
    "apiSecret": "secret_xyz9876543210fedcba"
  }'
```

### Response

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c3JfMTIzIiwib3JnSWQiOiJvcmdfNDU2IiwiaWF0IjoxNzMwNjI4MDAwLCJleHAiOjE3MzA2MzE2MDB9.signature",
  "refreshToken": "refresh_token_here",
  "tokenType": "Bearer",
  "expiresIn": 3600,
  "userId": "usr_123",
  "orgId": "org_456"
}
```

### Token Properties

| Property       | Description                      | Lifetime |
| -------------- | -------------------------------- | -------- |
| `accessToken`  | Used for API authentication      | 1 hour   |
| `refreshToken` | Used to obtain new access tokens | 30 days  |
| `expiresIn`    | Seconds until token expires      | 3600     |

## Using Access Tokens

Include the access token in the `Authorization` header:

```bash
curl -X GET https://api.quub.exchange/exchange/v1/orders \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Tenant-ID: org_456"
```

## Multi-Tenant Security

Every API request must include the `X-Tenant-ID` header for tenant isolation:

```javascript
const headers = {
  Authorization: `Bearer ${accessToken}`,
  "X-Tenant-ID": "org_456",
  "Content-Type": "application/json",
};
```

### How Tenant Isolation Works

- **Database RLS**: Row-level security filters all queries by `orgId`
- **Token Validation**: JWT contains `orgId` claim, validated on every request
- **Cross-Tenant Prevention**: Cannot access resources from other organizations

## Token Refresh

Refresh tokens before they expire to maintain uninterrupted access:

```bash
curl -X POST https://api.quub.exchange/auth/v1/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "refresh_token_here"
  }'
```

### Response

```json
{
  "accessToken": "new_access_token_here",
  "expiresIn": 3600
}
```

### Refresh Strategy

```javascript
class TokenManager {
  async getValidToken() {
    if (this.isTokenExpired()) {
      return await this.refreshToken();
    }
    return this.accessToken;
  }

  isTokenExpired() {
    const expirationTime = this.tokenExpiresAt;
    const now = Date.now();
    // Refresh 5 minutes before expiry
    return expirationTime - now < 5 * 60 * 1000;
  }
}
```

## Token Revocation

### Revoke Refresh Token

```bash
curl -X POST https://api.quub.exchange/auth/v1/revoke \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "token_to_revoke"
  }'
```

### Revoke API Key

```bash
curl -X DELETE https://api.quub.exchange/auth/v1/api-keys/key_abc123 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "X-Tenant-ID: your-org-id"
```

## Security Best Practices

### 1. Credential Storage

❌ **DON'T:**

```javascript
// Never hardcode credentials
const apiKey = "qx_live_1234567890abcdef";
const apiSecret = "secret_xyz9876543210fedcba";
```

✅ **DO:**

```javascript
// Use environment variables
const apiKey = process.env.QUUB_API_KEY;
const apiSecret = process.env.QUUB_API_SECRET;
```

### 2. Token Storage

- **Server-Side**: Store in memory or encrypted database
- **Client-Side**: Use HttpOnly cookies (never localStorage)
- **Mobile**: Use secure storage (Keychain/Keystore)

### 3. API Key Rotation

```bash
# Create new key
NEW_KEY=$(curl -X POST https://api.quub.exchange/auth/v1/api-keys ...)

# Update your services to use new key
# Wait for all services to migrate (monitor logs)

# Revoke old key
curl -X DELETE https://api.quub.exchange/auth/v1/api-keys/OLD_KEY_ID ...
```

### 4. Principle of Least Privilege

Grant minimal required permissions:

```json
{
  "permissions": [
    "market:read", // Read market data only
    "trading:execute" // Execute trades only
  ]
}
```

### 5. IP Whitelisting (Coming Soon)

```json
{
  "allowedIPs": ["203.0.113.0/24", "2001:db8::/32"]
}
```

## Permission Scopes

| Scope              | Description                 |
| ------------------ | --------------------------- |
| `market:read`      | Read market data and prices |
| `trading:execute`  | Place and cancel orders     |
| `trading:read`     | View order history          |
| `custody:read`     | View wallet balances        |
| `custody:withdraw` | Withdraw assets             |
| `admin:full`       | Full administrative access  |

## Error Responses

### 401 Unauthorized

```json
{
  "error": "unauthorized",
  "message": "Invalid or expired token",
  "code": "AUTH_001"
}
```

**Solutions:**

- Verify token is valid and not expired
- Check Authorization header format: `Bearer <token>`
- Refresh token if expired

### 403 Forbidden

```json
{
  "error": "forbidden",
  "message": "Insufficient permissions for this resource",
  "code": "AUTH_002"
}
```

**Solutions:**

- Check API key permissions
- Verify tenant ID matches token

### 429 Too Many Requests

```json
{
  "error": "rate_limit_exceeded",
  "message": "Too many authentication attempts",
  "retryAfter": 60
}
```

## Code Examples

### JavaScript/Node.js

```javascript
const axios = require("axios");

class QuubAuthClient {
  constructor(apiKey, apiSecret) {
    this.apiKey = apiKey;
    this.apiSecret = apiSecret;
    this.baseURL = "https://api.quub.exchange";
  }

  async login() {
    const response = await axios.post(`${this.baseURL}/auth/v1/login`, {
      apiKey: this.apiKey,
      apiSecret: this.apiSecret,
    });

    this.accessToken = response.data.accessToken;
    this.refreshToken = response.data.refreshToken;
    this.orgId = response.data.orgId;
    this.tokenExpiresAt = Date.now() + response.data.expiresIn * 1000;

    return this.accessToken;
  }

  async makeAuthenticatedRequest(endpoint, options = {}) {
    if (this.isTokenExpired()) {
      await this.refresh();
    }

    return axios({
      url: `${this.baseURL}${endpoint}`,
      ...options,
      headers: {
        Authorization: `Bearer ${this.accessToken}`,
        "X-Tenant-ID": this.orgId,
        ...options.headers,
      },
    });
  }

  isTokenExpired() {
    return this.tokenExpiresAt - Date.now() < 5 * 60 * 1000;
  }

  async refresh() {
    const response = await axios.post(`${this.baseURL}/auth/v1/refresh`, {
      refreshToken: this.refreshToken,
    });

    this.accessToken = response.data.accessToken;
    this.tokenExpiresAt = Date.now() + response.data.expiresIn * 1000;
  }
}

// Usage
const client = new QuubAuthClient(
  process.env.QUUB_API_KEY,
  process.env.QUUB_API_SECRET
);

await client.login();

const orders = await client.makeAuthenticatedRequest("/exchange/v1/orders", {
  method: "GET",
});
```

### Python

```python
import requests
import time
from datetime import datetime, timedelta

class QuubAuthClient:
    def __init__(self, api_key, api_secret):
        self.api_key = api_key
        self.api_secret = api_secret
        self.base_url = 'https://api.quub.exchange'
        self.access_token = None
        self.refresh_token = None
        self.org_id = None
        self.token_expires_at = None

    def login(self):
        response = requests.post(
            f'{self.base_url}/auth/v1/login',
            json={
                'apiKey': self.api_key,
                'apiSecret': self.api_secret
            }
        )
        response.raise_for_status()

        data = response.json()
        self.access_token = data['accessToken']
        self.refresh_token = data['refreshToken']
        self.org_id = data['orgId']
        self.token_expires_at = datetime.now() + timedelta(seconds=data['expiresIn'])

        return self.access_token

    def make_authenticated_request(self, endpoint, method='GET', **kwargs):
        if self.is_token_expired():
            self.refresh()

        headers = kwargs.pop('headers', {})
        headers.update({
            'Authorization': f'Bearer {self.access_token}',
            'X-Tenant-ID': self.org_id
        })

        response = requests.request(
            method,
            f'{self.base_url}{endpoint}',
            headers=headers,
            **kwargs
        )
        response.raise_for_status()
        return response.json()

    def is_token_expired(self):
        if not self.token_expires_at:
            return True
        return (self.token_expires_at - datetime.now()).total_seconds() < 300

    def refresh(self):
        response = requests.post(
            f'{self.base_url}/auth/v1/refresh',
            json={'refreshToken': self.refresh_token}
        )
        response.raise_for_status()

        data = response.json()
        self.access_token = data['accessToken']
        self.token_expires_at = datetime.now() + timedelta(seconds=data['expiresIn'])

# Usage
import os

client = QuubAuthClient(
    os.environ['QUUB_API_KEY'],
    os.environ['QUUB_API_SECRET']
)

client.login()

orders = client.make_authenticated_request('/exchange/v1/orders')
```

## Testing Authentication

### Sandbox Environment

Use sandbox credentials for testing:

```bash
export QUUB_API_KEY="qx_test_sandbox123"
export QUUB_API_SECRET="secret_sandbox456"
export QUUB_API_URL="https://sandbox.api.quub.exchange"
```

## Related Resources

- 🔐 [Auth API Reference](../../api-reference/auth/) - Complete API documentation
- 🏢 [Tenancy & Trust](../../api-reference/tenancy-trust/) - Multi-tenant architecture
- 🔑 [Identity Service](../../api-reference/identity/) - User management
- 📚 [Best Practices](../best-practices/) - Security recommendations

## Support

Questions about authentication?

- 💬 [Community Forum](#)
- 📧 Email: security@quub.exchange
- 🐛 [Report Security Issue](mailto:security@quub.exchange)
