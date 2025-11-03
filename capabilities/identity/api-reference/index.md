---
layout: api-reference
title: Identity Management API
permalink: /capabilities/identity/api-reference/
service: identity
---

# Identity Management API Reference

User and organization identity management

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/identity.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/identity.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/identity/)
- [Integration Guide]({{ site.baseurl }}/capabilities/identity/identity-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/identity/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
