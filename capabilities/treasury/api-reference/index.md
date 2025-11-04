---
layout: api-reference
title: Treasury API
permalink: /capabilities/treasury/api-reference/
service: treasury
---

# Treasury API Reference

Treasury management and operations

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/treasury.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/treasury.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/treasury/)
- [Integration Guide]({{ site.baseurl }}/capabilities/treasury/treasury-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/treasury/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
