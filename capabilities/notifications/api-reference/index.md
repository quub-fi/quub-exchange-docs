---
layout: api-reference
title: Notifications API
permalink: /capabilities/notifications/api-reference/
service: notifications
---

# Notifications API Reference

Notification delivery services

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/notifications.json"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/notifications.json)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/notifications/)
- [Integration Guide]({{ site.baseurl }}/capabilities/notifications/notifications-api-documentation.html)

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
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/notifications/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
