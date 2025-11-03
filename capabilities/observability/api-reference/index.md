---
layout: api-reference
title: Observability API
permalink: /capabilities/observability/api-reference/
service: observability
---

# Observability API Reference

Monitoring and observability

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/observability.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/observability.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/observability/)
- [Integration Guide]({{ site.baseurl }}/capabilities/observability/observability-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/observability/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
