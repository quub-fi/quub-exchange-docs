---
layout: api-reference
title: Gateway API
service: gateway
---

# Gateway API Reference

API gateway and routing

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/gateway.yaml"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/gateway.yaml)
- [Use Cases Documentation]({{ site.baseurl }}/use-cases/gateway/)
- [Integration Guide]({{ site.baseurl }}/use-cases/gateway/gateway-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/use-cases/gateway/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
