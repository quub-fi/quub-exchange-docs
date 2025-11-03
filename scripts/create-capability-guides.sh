#!/bin/bash

# Script to create /guides subdirectory for each capability

echo "Creating guides directories for all capabilities..."
echo ""

CAPABILITIES_DIR="/Users/nrahal/@code_2025/products/quub/quub-exchange-docs/capabilities"

# List of all capabilities
capabilities=(
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

for capability in "${capabilities[@]}"; do
  guides_dir="$CAPABILITIES_DIR/$capability/guides"

  # Create guides directory if it doesn't exist
  if [ ! -d "$guides_dir" ]; then
    mkdir -p "$guides_dir"
    echo "✓ Created: $capability/guides/"
  else
    echo "⊘ Exists: $capability/guides/"
  fi
done

echo ""
echo "✅ Guides structure created for all capabilities!"
echo ""
echo "Next steps:"
echo "  1. Populate each guides/ directory with relevant documentation"
echo "  2. Common guide types:"
echo "     - getting-started.md"
echo "     - integration-guide.md"
echo "     - best-practices.md"
echo "     - troubleshooting.md"
echo "     - migration-guide.md"
