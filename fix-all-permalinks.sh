#!/bin/bash

# Script to fix all permalinks in capabilities documentation
# API docs get: /capabilities/{service}/{service}-api-documentation/
# Overview docs get: /capabilities/{service}/{service}-overview/

echo "Fixing all permalinks..."

# Process all API documentation files
find /Users/nrahal/@code_2025/products/quub/quub-exchange-docs/capabilities -name "*-api-documentation.md" | while read -r file; do
  # Get service name from path
  dir=$(dirname "$file")
  service=$(basename "$dir")

  # Check if file has front matter with permalink
  if grep -q "^permalink:" "$file"; then
    # Update existing permalink
    sed -i '' "s|^permalink:.*|permalink: /capabilities/$service/${service}-api-documentation/|" "$file"
    echo "  ✓ Fixed API permalink: $service"
  fi
done

# Process all overview files - add front matter if missing
find /Users/nrahal/@code_2025/products/quub/quub-exchange-docs/capabilities -name "*-overview.md" | while read -r file; do
  # Get service name from path
  dir=$(dirname "$file")
  service=$(basename "$dir")

  # Check if file has front matter
  if head -1 "$file" | grep -q "^---"; then
    # Has front matter, update permalink
    if grep -q "^permalink:" "$file"; then
      sed -i '' "s|^permalink:.*|permalink: /capabilities/$service/${service}-overview/|" "$file"
    else
      # Add permalink to existing front matter
      sed -i '' "/^---$/a\\
permalink: /capabilities/$service/${service}-overview/
" "$file"
    fi
    echo "  ✓ Fixed overview permalink: $service"
  else
    # No front matter, add it
    temp_file=$(mktemp)
    echo "---" > "$temp_file"
    echo "layout: use-case" >> "$temp_file"
    echo "permalink: /capabilities/$service/${service}-overview/" >> "$temp_file"
    echo "---" >> "$temp_file"
    echo "" >> "$temp_file"
    cat "$file" >> "$temp_file"
    mv "$temp_file" "$file"
    echo "  ✓ Added front matter + permalink: $service"
  fi
done

echo ""
echo "✅ All permalinks fixed!"
echo ""
echo "Permalink structure:"
echo "  - API docs: /capabilities/{service}/{service}-api-documentation/"
echo "  - Overview: /capabilities/{service}/{service}-overview/"
