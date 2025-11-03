---
layout: api-reference
title: Sandbox API
permalink: /capabilities/sandbox/api-reference/
service: sandbox
---

# Sandbox API Reference

Development and testing sandbox

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/sandbox.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/sandbox.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/sandbox/)
- [Integration Guide]({{ site.baseurl }}/capabilities/sandbox/sandbox-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/sandbox/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
