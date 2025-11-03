#!/bin/bash

# Script to add permalinks to all use-case overview files

# Find all overview files
FILES=$(find /Users/nrahal/@code_2025/products/quub/quub-exchange-docs/capabilities -name "*-overview.md" -type f | sort)

for file in $FILES; do
    echo "Processing: $file"

    # Extract service name from path (e.g., /path/to/marketplace/marketplace-overview.md -> marketplace)
    service_name=$(basename $(dirname "$file"))

    # Check if file already has front matter
    if grep -q "^---" "$file"; then
        # Check if permalink already exists
        if grep -q "^permalink:" "$file"; then
            echo "  ✓ Already has permalink, skipping"
        else
            # Add permalink to existing front matter
            sed -i '' "/^---/a\\
permalink: /capabilities/$service_name/$service_name-overview/\\
" "$file"
            echo "  ✓ Added permalink to existing front matter"
        fi
    else
        # Add new front matter with permalink at the beginning
        temp_file=$(mktemp)
        cat > "$temp_file" << EOF
---
layout: use-case
permalink: /capabilities/$service_name/$service_name-overview/
---

EOF
        cat "$file" >> "$temp_file"
        mv "$temp_file" "$file"
        echo "  ✓ Added front matter with permalink"
    fi
done

echo ""
echo "✅ Overview permalink fix complete!"
