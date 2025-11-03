---
layout: api-reference
title: Gateway API
permalink: /capabilities/gateway/api-reference/
service: gateway
---

# Gateway API Reference

API gateway and routing

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/gateway.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/gateway.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/gateway/)
- [Integration Guide]({{ site.baseurl }}/capabilities/gateway/gateway-api-documentation.html)

## Authentication

All API requests require authentication using JWT tokens. See the [Authentication Guide]({{ site.baseurl }}/api-reference/auth/) for details.

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/gateway/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
