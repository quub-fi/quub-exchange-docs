---
layout: api-reference
title: Documents API
permalink: /capabilities/documents/api-reference/
service: documents
---

# Documents API Reference

Document management and storage

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/documents.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/documents.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/documents/)
- [Integration Guide]({{ site.baseurl }}/capabilities/documents/documents-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/documents/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
