---
layout: api-reference
title: Blockchain API
service: chain
---

# Blockchain API Reference

Blockchain integration services

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/chain.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/chain.json)
- [Use Cases Documentation]({{ site.baseurl }}/use-cases/chain/)
- [Integration Guide]({{ site.baseurl }}/use-cases/chain/chain-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/use-cases/chain/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
