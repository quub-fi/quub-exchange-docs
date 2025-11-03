#!/bin/bash

# Script to move permalinks from bottom to proper front matter at top for all overview files

echo "Fixing front matter for overview files..."

find /Users/nrahal/@code_2025/products/quub/quub-exchange-docs/use-cases -name "*-overview.md" | while read -r file; do
  # Check if file has permalink at the bottom
  if grep -q "^permalink:" "$file"; then
    # Extract the permalink
    permalink=$(grep "^permalink:" "$file" | head -1)
    
    # Check if front matter already exists at top
    if head -1 "$file" | grep -q "^---"; then
      echo "  ⚠ Already has front matter: $(basename "$file")"
    else
      # Create temp file with front matter at top
      temp_file=$(mktemp)
      
      # Add front matter
      echo "---" > "$temp_file"
      echo "layout: use-case" >> "$temp_file"
      echo "$permalink" >> "$temp_file"
      echo "---" >> "$temp_file"
      echo "" >> "$temp_file"
      
      # Add original content, removing the permalink line at bottom
      grep -v "^permalink:" "$file" | grep -v "^---$" >> "$temp_file"
      
      # Replace original file
      mv "$temp_file" "$file"
      
      echo "  ✓ Fixed: $(basename "$file")"
    fi
  fi
done

echo ""
echo "✅ All overview files now have proper front matter!"
