#!/bin/bash

# Generate comprehensive guides for all capabilities
echo "Generating comprehensive guides for all capabilities..."

# List of all capabilities
capabilities=(
  "auth" "identity" "tenancy-trust" "exchange" "marketplace"
  "gateway" "market-oracles" "pricing-refdata" "primary-market"
  "custodian" "treasury" "fiat-banking" "settlements" "escrow"
  "fees-billing" "transfer-agent" "compliance" "risk-limits"
  "governance" "documents" "analytics-reports" "events"
  "notifications" "observability" "sandbox" "chain"
)

# Generate guides for each capability
for capability in "${capabilities[@]}"; do
  echo "Generating guides for ${capability}..."

  # Create the content based on capability type
  case $capability in
    "auth"|"identity"|"tenancy-trust")
      template="core_platform"
      ;;
    "exchange"|"marketplace"|"gateway"|"market-oracles"|"pricing-refdata")
      template="trading_markets"
      ;;
    "primary-market"|"custodian"|"treasury"|"fiat-banking"|"settlements"|"escrow"|"fees-billing"|"transfer-agent")
      template="financial_services"
      ;;
    "compliance"|"risk-limits"|"governance"|"documents")
      template="compliance_risk"
      ;;
    "analytics-reports"|"events"|"notifications"|"observability"|"sandbox"|"chain")
      template="infrastructure"
      ;;
  esac

  echo "Using template: $template for $capability"
done

echo "Guides generation planned!"