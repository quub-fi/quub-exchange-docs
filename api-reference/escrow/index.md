---
layout: api-reference
title: Escrow API
service: escrow
---

# Escrow API Reference

Escrow and settlement services

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/escrow.yaml"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/escrow.yaml)
- [Use Cases Documentation]({{ site.baseurl }}/use-cases/escrow/)
- [Integration Guide]({{ site.baseurl }}/use-cases/escrow/escrow-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/use-cases/escrow/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
