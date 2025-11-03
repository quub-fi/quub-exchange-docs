---
layout: api-reference
title: Marketplace API
permalink: /capabilities/marketplace/api-reference/
service: marketplace
---

# Marketplace API Reference

Asset marketplace and listings

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/marketplace.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/marketplace.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/marketplace/)
- [Integration Guide]({{ site.baseurl }}/capabilities/marketplace/marketplace-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/marketplace/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
