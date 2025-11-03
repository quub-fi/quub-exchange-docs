---
layout: api-reference
title: Transfer Agent API
service: transfer-agent
---

# Transfer Agent API Reference

Securities transfer agent services

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/transfer-agent.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/transfer-agent.json)
- [Use Cases Documentation]({{ site.baseurl }}/use-cases/transfer-agent/)
- [Integration Guide]({{ site.baseurl }}/use-cases/transfer-agent/transfer-agent-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/use-cases/transfer-agent/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
