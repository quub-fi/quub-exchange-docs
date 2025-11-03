#!/bin/bash

# Script to remove trailing slashes from all permalinks in capabilities documentation

echo "Removing trailing slashes from permalinks..."

# Find all files with permalinks and remove trailing slashes
find /Users/nrahal/@code_2025/products/quub/quub-exchange-docs/capabilities -type f \( -name "*-overview.md" -o -name "*-api-documentation.md" \) -exec sed -i '' 's|permalink: \(.*\)/$|permalink: \1|g' {} \;

echo "✅ Trailing slashes removed from all permalinks!"
