#!/bin/bash

# Create API reference pages for all services
services=(
  "tenancy-trust:Tenancy & Trust Service"
  "marketplace:Marketplace Service"
  "gateway:Gateway Service"
  "market-oracles:Market Oracles Service"
  "pricing-refdata:Pricing & Reference Data Service"
  "treasury:Treasury Service"
  "fiat-banking:Fiat Banking Service"
  "settlements:Settlements Service"
  "escrow:Escrow Service"
  "fees-billing:Fees & Billing Service"
  "primary-market:Primary Market Service"
  "transfer-agent:Transfer Agent Service"
  "documents:Documents Service"
  "compliance:Compliance Service"
  "risk-limits:Risk & Limits Service"
  "governance:Governance Service"
  "analytics-reports:Analytics & Reports Service"
  "chain:Chain Integration Service"
  "events:Events Service"
  "notifications:Notifications Service"
  "observability:Observability Service"
  "sandbox:Sandbox Service"
)

for service in "${services[@]}"; do
  IFS=':' read -r slug title <<< "$service"
  mkdir -p "api-reference/$slug"
  
  cat > "api-reference/$slug/index.md" << ENDOFFILE
---
layout: api-reference
title: $title API Reference
api: $slug
description: Complete API reference for the Quub Exchange $title
---
ENDOFFILE
  
  echo "Created api-reference/$slug/index.md"
done

echo "All API reference pages created!"
