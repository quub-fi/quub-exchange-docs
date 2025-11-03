#!/bin/bash

# Script to make all permalinks match their filenames exactly
# Example: marketplace-api-documentation.md → /capabilities/marketplace/marketplace-api-documentation/

echo "Fixing permalinks to match filenames exactly..."
echo ""

# Find all markdown files in capabilities with permalinks
find /Users/nrahal/@code_2025/products/quub/quub-exchange-docs/capabilities -name "*.md" -type f | while read -r file; do
  # Get the filename without extension
  filename=$(basename "$file" .md)

  # Get the directory (service name)
  dir=$(dirname "$file")
  service=$(basename "$dir")

  # Check if file has a permalink
  if grep -q "^permalink:" "$file"; then
    # Get current permalink
    current_permalink=$(grep "^permalink:" "$file" | sed 's/permalink: //' | sed 's|/$||')

    # Build expected permalink based on filename
    expected_permalink="/capabilities/$service/$filename/"

    # If they don't match, fix it
    if [ "$current_permalink/" != "$expected_permalink" ]; then
      sed -i '' "s|^permalink:.*|permalink: $expected_permalink|" "$file"
      echo "✓ Fixed: $filename"
      echo "  Old: $current_permalink"
      echo "  New: $expected_permalink"
      echo ""
    fi
  fi
done

echo "✅ All permalinks now match filenames!"
