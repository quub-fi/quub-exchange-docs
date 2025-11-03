---
layout: api-reference
title: Authentication & Authorization API
service: auth
---

# Authentication & Authorization API Reference

Secure authentication and authorization services

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/auth.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/auth.json)
- [Use Cases Documentation]({{ site.baseurl }}/use-cases/auth/)
- [Integration Guide]({{ site.baseurl }}/use-cases/auth/auth-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/use-cases/auth/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
