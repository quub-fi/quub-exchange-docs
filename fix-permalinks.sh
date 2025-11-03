#!/bin/bash

# Script to add permalinks to API documentation files in use-cases

# Array of service names
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

# Base directory
BASE_DIR="/Users/nrahal/@code_2025/products/quub/quub-exchange-docs/use-cases"

for service in "${services[@]}"; do
  file="$BASE_DIR/$service/${service}-api-documentation.md"

  if [ -f "$file" ]; then
    echo "Processing: $file"

    # Check if file already has a permalink
    if grep -q "^permalink:" "$file"; then
      echo "  ✓ Already has permalink, skipping"
      continue
    fi

    # Check if file has front matter
    if head -n 1 "$file" | grep -q "^---$"; then
      # Has front matter, add permalink after the opening ---
      # Create temp file with permalink added
      awk -v service="$service" '
        NR==1 { print; next }
        NR==2 && /^layout:/ {
          print
          print "permalink: /use-cases/" service "/"
          next
        }
        { print }
      ' "$file" > "$file.tmp"

      mv "$file.tmp" "$file"
      echo "  ✓ Added permalink to existing front matter"
    else
      # No front matter, add it
      temp_file=$(mktemp)
      {
        echo "---"
        echo "layout: use-case"
        echo "permalink: /use-cases/$service/"
        echo "---"
        echo ""
        cat "$file"
      } > "$temp_file"

      mv "$temp_file" "$file"
      echo "  ✓ Added front matter with permalink"
    fi
  else
    echo "File not found: $file"
  fi
done

echo ""
echo "✅ Permalink fix complete!"
