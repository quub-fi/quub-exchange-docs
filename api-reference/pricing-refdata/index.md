---
layout: api-reference
title: Pricing & Reference Data API
service: pricing-refdata
---

# Pricing & Reference Data API Reference

Market pricing and reference data

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/pricing-refdata.yaml"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/pricing-refdata.yaml)
- [Use Cases Documentation]({{ site.baseurl }}/use-cases/pricing-refdata/)
- [Integration Guide]({{ site.baseurl }}/use-cases/pricing-refdata/pricing-refdata-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/use-cases/pricing-refdata/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
