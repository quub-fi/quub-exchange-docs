---
layout: api-reference
title: Primary Market API
permalink: /capabilities/primary-market/api-reference/
service: primary-market
---

# Primary Market API Reference

Primary market operations and issuance

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/primary-market.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/primary-market.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/primary-market/)
- [Integration Guide]({{ site.baseurl }}/capabilities/primary-market/primary-market-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/primary-market/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
