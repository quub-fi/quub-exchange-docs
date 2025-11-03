---
layout: api-reference
title: Settlements API
permalink: /capabilities/settlements/api-reference/
service: settlements
---

# Settlements API Reference

Trade settlement and clearing

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/settlements.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/settlements.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/settlements/)
- [Integration Guide]({{ site.baseurl }}/capabilities/settlements/settlements-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/settlements/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
