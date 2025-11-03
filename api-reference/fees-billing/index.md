---
layout: api-reference
title: Fees & Billing API
service: fees-billing
---

# Fees & Billing API Reference

Fee calculation and billing

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/fees-billing.yaml"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/fees-billing.yaml)
- [Use Cases Documentation]({{ site.baseurl }}/use-cases/fees-billing/)
- [Integration Guide]({{ site.baseurl }}/use-cases/fees-billing/fees-billing-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/use-cases/fees-billing/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
