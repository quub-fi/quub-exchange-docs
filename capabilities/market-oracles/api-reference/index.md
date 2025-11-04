---
layout: api-reference
title: Market Oracles API
permalink: /capabilities/market-oracles/api-reference/
service: market-oracles
---

# Market Oracles API Reference

Real-time market data and price feeds

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/market-oracles.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/market-oracles.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/market-oracles/)
- [Integration Guide]({{ site.baseurl }}/capabilities/market-oracles/market-oracles-api-documentation.html)

## Authentication

All API requests require authentication using JWT tokens. See the [Authentication Guide]({{ site.baseurl }}/capabilities/auth/api-documentation/) for details.

## Base URL

```
https://api.quub.exchange/v1/$\{service_slug\}
```

## Rate Limits

- **Standard**: 100 requests per minute
- **Premium**: 1000 requests per minute
- **Enterprise**: Custom limits available

## Support

For API support and questions:
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/market-oracles/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
