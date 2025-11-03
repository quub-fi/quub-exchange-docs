#!/bin/bash

# Array of all services
services=(
  "auth:Authentication & Authorization:Secure authentication and authorization services"
  "identity:Identity Management:User and organization identity management"
  "tenancy-trust:Multi-Tenancy:Organization and tenant management"
  "exchange:Exchange:Core trading and order management"
  "marketplace:Marketplace:Asset marketplace and listings"
  "gateway:Gateway:API gateway and routing"
  "market-oracles:Market Oracles:Real-time market data and price feeds"
  "pricing-refdata:Pricing & Reference Data:Market pricing and reference data"
  "primary-market:Primary Market:Primary market operations and issuance"
  "custodian:Custodian:Asset custody and safekeeping"
  "treasury:Treasury:Treasury management and operations"
  "fiat-banking:Fiat Banking:Fiat currency banking operations"
  "escrow:Escrow:Escrow and settlement services"
  "settlements:Settlements:Trade settlement and clearing"
  "transfer-agent:Transfer Agent:Securities transfer agent services"
  "fees-billing:Fees & Billing:Fee calculation and billing"
  "compliance:Compliance:Compliance and regulatory services"
  "risk-limits:Risk & Limits:Risk management and limit controls"
  "governance:Governance:Platform governance and voting"
  "documents:Documents:Document management and storage"
  "analytics-reports:Analytics & Reports:Analytics and reporting services"
  "chain:Blockchain:Blockchain integration services"
  "events:Events:Event streaming and management"
  "notifications:Notifications:Notification delivery services"
  "observability:Observability:Monitoring and observability"
  "sandbox:Sandbox:Development and testing sandbox"
)

for service_data in "${services[@]}"; do
  IFS=':' read -r service_slug service_name service_desc <<< "$service_data"
  
  # Create directory
  mkdir -p "api-reference/${service_slug}"
  
  # Create index.md
  cat > "api-reference/${service_slug}/index.md" << INNER_EOF
---
layout: api-reference
title: ${service_name} API
service: ${service_slug}
---

# ${service_name} API Reference

${service_desc}

<div class="api-explorer">
  <redoc spec-url="{{ site.baseurl }}/openapi/${service_slug}.yaml"></redoc>
</div>

## Quick Links

- [OpenAPI Specification]({{ site.baseurl }}/openapi/${service_slug}.yaml)
- [Use Cases Documentation]({{ site.baseurl }}/capabilities/${service_slug}/)
- [Integration Guide]({{ site.baseurl }}/capabilities/${service_slug}/${service_slug}-api-documentation.html)

## Authentication

All API requests require authentication using JWT tokens. See the [Authentication Guide]({{ site.baseurl }}/api-reference/auth/) for details.

## Base URL

\`\`\`
https://api.quub.exchange/v1/$\{service_slug\}
\`\`\`

## Rate Limits

- **Standard**: 100 requests per minute
- **Premium**: 1000 requests per minute
- **Enterprise**: Custom limits available

## Support

For API support and questions:
- **Documentation**: [Use Cases]({{ site.baseurl }}/capabilities/${service_slug}/)
- **Technical Support**: support@quub.exchange
- **Status Page**: https://status.quub.exchange
INNER_EOF

  echo "Created api-reference/${service_slug}/index.md"
done

echo "All API reference pages created!"
