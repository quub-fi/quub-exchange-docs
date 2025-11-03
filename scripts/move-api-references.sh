#!/bin/bash

# Script to move API reference content into capabilities directories
# Each capability will have its own api-reference/index.md

echo "🔄 Moving API reference content to capabilities directories..."
echo ""

# List of all services
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

# Move each API reference
for service in "${services[@]}"; do
  source_file="api-reference/${service}/index.md"
  target_dir="capabilities/${service}/api-reference"
  target_file="${target_dir}/index.md"
  
  if [ -f "$source_file" ]; then
    # Create target directory
    mkdir -p "$target_dir"
    
    # Move the file
    mv "$source_file" "$target_file"
    
    echo "  ✓ Moved: ${service}/api-reference/index.md"
  else
    echo "  ⚠ Missing: ${source_file}"
  fi
done

echo ""
echo "✅ API reference files moved to capabilities directories!"
echo ""
echo "🔄 Removing empty api-reference subdirectories..."

# Remove empty service directories
for service in "${services[@]}"; do
  dir="api-reference/${service}"
  if [ -d "$dir" ] && [ -z "$(ls -A $dir)" ]; then
    rmdir "$dir"
    echo "  ✓ Removed empty: ${dir}"
  fi
done

echo ""
echo "✅ Complete! All API references now under capabilities/*/api-reference/"
