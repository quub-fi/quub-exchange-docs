---
layout: docs
title: Error Handling
description: Understanding and handling API errors
---

# Error Handling

Learn how to handle errors gracefully in your Quub Exchange integration.

## Error Response Format

All errors follow a consistent structure:

```json
{
  "error": "invalid_request",
  "message": "Invalid order quantity",
  "code": "ORD_001",
  "details": {
    "field": "quantity",
    "reason": "Must be greater than 0"
  },
  "requestId": "req_abc123",
  "timestamp": "2025-11-03T10:30:00Z"
}
```

## HTTP Status Codes

| Code | Status | Description |
|------|--------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created |
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Service temporarily unavailable |

## Error Codes

### Authentication (AUTH_xxx)

| Code | Description | Solution |
|------|-------------|----------|
| AUTH_001 | Invalid or expired token | Refresh token or re-authenticate |
| AUTH_002 | Invalid API credentials | Check API key and secret |
| AUTH_003 | Token revoked | Generate new API key |

### Trading (ORD_xxx, TRD_xxx)

| Code | Description | Solution |
|------|-------------|----------|
| ORD_001 | Invalid order quantity | Check min/max order sizes |
| ORD_002 | Insufficient balance | Add funds to account |
| ORD_003 | Invalid price | Check price precision |
| TRD_001 | Market closed | Wait for market to open |
| TRD_002 | Symbol not found | Verify trading pair |

### Rate Limiting (RATE_xxx)

| Code | Description | Solution |
|------|-------------|----------|
| RATE_001 | Too many requests | Implement rate limiting |
| RATE_002 | Burst limit exceeded | Reduce request frequency |

For complete error codes, see [API Reference](../../api-reference/).

## Handling Errors

### JavaScript Example

```javascript
try {
  const order = await client.placeOrder(orderParams);
  console.log('Order placed:', order.orderId);
} catch (error) {
  if (error.response) {
    const { status, data } = error.response;
    
    switch (status) {
      case 400:
        console.error('Invalid request:', data.message);
        break;
      case 401:
        console.error('Authentication failed, refreshing token...');
        await client.refreshToken();
        break;
      case 429:
        const retryAfter = error.response.headers['retry-after'];
        console.log(`Rate limited. Retry after ${retryAfter}s`);
        break;
      default:
        console.error('Unexpected error:', data);
    }
  } else {
    console.error('Network error:', error.message);
  }
}
```

### Python Example

```python
from requests.exceptions import HTTPError

try:
    order = client.place_order(order_params)
    print(f"Order placed: {order['orderId']}")
except HTTPError as e:
    status = e.response.status_code
    data = e.response.json()
    
    if status == 400:
        print(f"Invalid request: {data['message']}")
    elif status == 401:
        print("Authentication failed, refreshing token...")
        client.refresh_token()
    elif status == 429:
        retry_after = e.response.headers.get('Retry-After', 60)
        print(f"Rate limited. Retry after {retry_after}s")
    else:
        print(f"Unexpected error: {data}")
except Exception as e:
    print(f"Network error: {str(e)}")
```

## Related Resources

- 📚 [API Reference](../../api-reference/)
- 🚀 [Quick Start](../quickstart/)
- 💡 [Best Practices](../best-practices/)
