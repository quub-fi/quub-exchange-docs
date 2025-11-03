#!/bin/bash

# Update all use-case documentation files to use the use-case layout

for file in capabilities/*/*-{overview,api-documentation}.md; do
  if [ -f "$file" ]; then
    # Replace layout: docs with layout: use-case
    sed -i '' 's/^layout: docs$/layout: use-case/' "$file"
    # Also replace layout: api_doc if it exists
    sed -i '' 's/^layout: api_doc$/layout: use-case/' "$file"
    echo "Updated layout in: $file"
  fi
done

echo ""
echo "✅ All use-case files updated to use 'use-case' layout!"
