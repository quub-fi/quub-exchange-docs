---
layout: docs
title: Rate Limiting
description: API rate limits and best practices
---

# Rate Limiting

Quub Exchange implements rate limiting to ensure fair usage and system stability.

## Rate Limits

### Standard Limits

| Endpoint Type | Limit | Window |
|--------------|-------|--------|
| Public Market Data | 100 requests | 1 minute |
| Private Trading APIs | 60 requests | 1 minute |
| Account Management | 30 requests | 1 minute |
| Webhooks | 10 creates | 1 hour |

### Burst Limits

- **Maximum burst**: 20 requests in 1 second
- **After burst**: Throttled to standard rate

## Rate Limit Headers

Every API response includes rate limit information:

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1730628000
```

| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Total requests allowed |
| `X-RateLimit-Remaining` | Remaining requests in window |
| `X-RateLimit-Reset` | Unix timestamp when limit resets |

## Handling Rate Limits

### Client-Side Rate Limiting

```javascript
class RateLimiter {
  constructor(maxRequests, windowMs) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.requests = [];
  }
  
  async acquire() {
    const now = Date.now();
    this.requests = this.requests.filter(t => now - t < this.windowMs);
    
    if (this.requests.length >= this.maxRequests) {
      const oldestRequest = this.requests[0];
      const waitTime = this.windowMs - (now - oldestRequest);
      await sleep(waitTime);
      return this.acquire();
    }
    
    this.requests.push(now);
  }
}
```

### Handle 429 Responses

```javascript
async function apiRequest(endpoint) {
  try {
    return await api.get(endpoint);
  } catch (error) {
    if (error.response?.status === 429) {
      const retryAfter = error.response.headers['retry-after'] || 60;
      await sleep(retryAfter * 1000);
      return apiRequest(endpoint);
    }
    throw error;
  }
}
```

## Best Practices

1. **Monitor headers**: Check remaining requests
2. **Implement backoff**: Exponential backoff on errors
3. **Batch requests**: Combine multiple operations
4. **Cache responses**: Reduce redundant calls
5. **Use WebSockets**: For real-time data

## Related Resources

- 🚀 [Quick Start](../quickstart/)
- 💡 [Best Practices](../best-practices/)
- 📚 [API Reference](../../api-reference/)
