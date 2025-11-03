#!/bin/bash

echo "🔍 Verifying all internal links..."
echo ""

# Check if all API reference pages exist
echo "Checking API Reference pages..."
for service in auth identity tenancy-trust exchange marketplace gateway market-oracles pricing-refdata custodian treasury fiat-banking settlements escrow fees-billing sandbox; do
  if [ -f "api-reference/$service/index.md" ]; then
    echo "✅ api-reference/$service/"
  else
    echo "❌ api-reference/$service/ - MISSING"
  fi
done

echo ""
echo "Checking Docs pages..."
for doc in quickstart authentication best-practices errors rate-limits webhooks; do
  if [ -f "docs/$doc/index.md" ]; then
    echo "✅ docs/$doc/"
  else
    echo "❌ docs/$doc/ - MISSING"
  fi
done

echo ""
echo "Checking other pages..."
for page in openapi guides changelog; do
  if [ -f "$page/index.md" ]; then
    echo "✅ $page/"
  else
    echo "❌ $page/ - MISSING"
  fi
done

echo ""
echo "✨ Verification complete!"
