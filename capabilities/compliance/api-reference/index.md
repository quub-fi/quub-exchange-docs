---
layout: api-reference
title: Compliance API
permalink: /capabilities/compliance/api-reference/
service: compliance
---

# Compliance API Reference

Compliance and regulatory services

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/compliance.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/compliance.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/compliance/)
- [Integration Guide]({{ site.baseurl }}/capabilities/compliance/compliance-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/compliance/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
