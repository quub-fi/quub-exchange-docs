---
layout: api-reference
title: Analytics & Reports API
permalink: /capabilities/analytics-reports/api-reference/
service: analytics-reports
---

# Analytics & Reports API Reference

Analytics and reporting services

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/analytics-reports.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/analytics-reports.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/analytics-reports/)
- [Integration Guide]({{ site.baseurl }}/capabilities/analytics-reports/analytics-reports-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/analytics-reports/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
