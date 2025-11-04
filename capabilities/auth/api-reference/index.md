---
layout: api-reference
title: Authentication & Authorization API
permalink: /capabilities/auth/api-reference/
service: auth
---

# Authentication & Authorization API Reference

Secure authentication and authorization services

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/auth.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/auth.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/auth/)
- [Integration Guide]({{ site.baseurl }}/capabilities/auth/auth-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/auth/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
