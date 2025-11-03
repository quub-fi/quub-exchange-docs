#!/bin/bash

# Script to add trailing slashes to all permalinks in capabilities documentation
# This is the correct approach for Jekyll + GitHub Pages

echo "Adding trailing slashes to permalinks..."

# Find all files with permalinks and add trailing slashes (only if they don't already have one)
find /Users/nrahal/@code_2025/products/quub/quub-exchange-docs/capabilities -type f \( -name "*-overview.md" -o -name "*-api-documentation.md" \) -exec sed -i '' 's|^\(permalink: .*[^/]\)$|\1/|g' {} \;

echo "✅ Trailing slashes added to all permalinks!"
