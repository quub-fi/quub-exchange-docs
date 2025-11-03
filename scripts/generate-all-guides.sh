#!/bin/bash

# Script to generate comprehensive guides for all capabilities

CAPABILITIES_DIR="/Users/nrahal/@code_2025/products/quub/quub-exchange-docs/capabilities"

echo "🚀 Generating comprehensive guides for all capabilities..."
echo ""

# List of all capabilities
services=(
  "analytics-reports"
  "auth"
  "chain"
  "compliance"
  "custodian"
  "documents"
  "escrow"
  "events"
  "exchange"
  "fees-billing"
  "fiat-banking"
  "gateway"
  "governance"
  "identity"
  "market-oracles"
  "marketplace"
  "notifications"
  "observability"
  "pricing-refdata"
  "primary-market"
  "risk-limits"
  "sandbox"
  "settlements"
  "tenancy-trust"
  "transfer-agent"
  "treasury"
)

for service in "${services[@]}"; do
  guides_dir="$CAPABILITIES_DIR/$service/guides"

  if [ -d "$guides_dir" ]; then
    echo "📝 Generating guides for: $service"

    # Create index
    cat > "$guides_dir/index.md" << 'EOF'
---
layout: docs
title: {SERVICE_NAME} Guides
permalink: /capabilities/{SERVICE_SLUG}/guides/
---

# {SERVICE_NAME} Implementation Guides

Comprehensive guides for implementing and integrating {SERVICE_NAME} capabilities.

## 📚 Available Guides

### Getting Started
- [Quick Start Guide](./getting-started.md) - Get up and running quickly
- [Integration Guide](./integration-guide.md) - Step-by-step integration instructions

### Best Practices
- [Best Practices](./best-practices.md) - Recommended patterns and approaches
- [Security Guide](./security-guide.md) - Security implementation guidelines

### Advanced Topics
- [Troubleshooting](./troubleshooting.md) - Common issues and solutions
- [Performance Optimization](./performance-optimization.md) - Optimization strategies

### Migration & Deployment
- [Migration Guide](./migration-guide.md) - Upgrade and migration instructions
- [Deployment Guide](./deployment-guide.md) - Production deployment strategies

---

_For API reference, see [{SERVICE_NAME} API Documentation](../{SERVICE_SLUG}-api-documentation.md)_
EOF

    # Replace placeholders
    service_name=$(echo "$service" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    sed -i '' "s/{SERVICE_NAME}/$service_name/g" "$guides_dir/index.md"
    sed -i '' "s/{SERVICE_SLUG}/$service/g" "$guides_dir/index.md"

    echo "  ✓ Created index.md"
  fi
done

echo ""
echo "✅ Guide indexes created for all capabilities!"
echo ""
echo "Next: Run individual guide generation scripts for specific content"
