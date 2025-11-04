---
layout: api-reference
title: Risk & Limits API
permalink: /capabilities/risk-limits/api-reference/
service: risk-limits
---

# Risk & Limits API Reference

Risk management and limit controls

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/risk-limits.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/risk-limits.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/risk-limits/)
- [Integration Guide]({{ site.baseurl }}/capabilities/risk-limits/risk-limits-api-documentation.html)

## Authentication

All API requests require authentication using JWT tokens. See the [Authentication Guide]({{ site.baseurl }}/capabilities/auth/api-documentation/) for details.

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/risk-limits/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
