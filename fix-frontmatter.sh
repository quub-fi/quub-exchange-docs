#!/bin/bash

# Add front matter to all use-case documentation files

for dir in capabilities/*/; do
    service=$(basename "$dir")
    
    # Skip if README
    if [ "$service" = "README.md" ]; then
        continue
    fi
    
    # Process overview file
    overview_file="${dir}${service}-overview.md"
    if [ -f "$overview_file" ] && ! grep -q "^---$" "$overview_file"; then
        echo "Adding frontmatter to $overview_file"
        temp_file=$(mktemp)
        cat > "$temp_file" << FRONTMATTER
---
layout: docs
title: ${service} Overview
service: ${service}
---

{% include api-nav-banner.html %}

FRONTMATTER
        cat "$overview_file" >> "$temp_file"
        mv "$temp_file" "$overview_file"
    fi
    
    # Process api-documentation file
    doc_file="${dir}${service}-api-documentation.md"
    if [ -f "$doc_file" ] && ! grep -q "^---$" "$doc_file"; then
        echo "Adding frontmatter to $doc_file"
        temp_file=$(mktemp)
        cat > "$temp_file" << FRONTMATTER
---
layout: docs
title: ${service} API Documentation
service: ${service}
---

{% include api-nav-banner.html %}

FRONTMATTER
        cat "$doc_file" >> "$temp_file"
        mv "$temp_file" "$doc_file"
    fi
done

echo "✅ Front matter added to all use-case documentation files!"
