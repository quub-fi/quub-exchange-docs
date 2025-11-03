---
layout: api-reference
title: Custodian API
permalink: /capabilities/custodian/api-reference/
service: custodian
---

# Custodian API Reference

Asset custody and safekeeping

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/custodian.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/custodian.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/custodian/)
- [Integration Guide]({{ site.baseurl }}/capabilities/custodian/custodian-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/custodian/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
