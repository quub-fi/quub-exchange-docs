---
layout: api-reference
title: Multi-Tenancy API
service: tenancy-trust
---

# Multi-Tenancy API Reference

Organization and tenant management

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/tenancy-trust.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/tenancy-trust.json)
- [Use Cases Documentation]({{ site.baseurl }}/use-cases/tenancy-trust/)
- [Integration Guide]({{ site.baseurl }}/use-cases/tenancy-trust/tenancy-trust-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/use-cases/tenancy-trust/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
