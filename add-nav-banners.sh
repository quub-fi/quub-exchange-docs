#!/bin/bash

# Add navigation banners to use-case documentation files

for dir in use-cases/*/; do
    service=$(basename "$dir")

    # Skip if not a service directory
    if [ "$service" = "README.md" ] || [ ! -d "$dir" ]; then
        continue
    fi

    # Add to overview file
    overview_file="${dir}${service}-overview.md"
    if [ -f "$overview_file" ]; then
        # Check if banner already exists
        if ! grep -q "{% include api-nav-banner.html %}" "$overview_file"; then
            # Find the first heading and insert banner after front matter
            awk '
                BEGIN { in_frontmatter=0; frontmatter_done=0; }
                /^---$/ {
                    if (in_frontmatter == 0) {
                        in_frontmatter=1;
                    } else if (in_frontmatter == 1) {
                        in_frontmatter=0;
                        frontmatter_done=1;
                    }
                    print;
                    next;
                }
                frontmatter_done==1 && /^#/ && !banner_added {
                    print "";
                    print "{% include api-nav-banner.html %}";
                    print "";
                    banner_added=1;
                }
                { print }
            ' "$overview_file" > "${overview_file}.tmp" && mv "${overview_file}.tmp" "$overview_file"
            echo "Added banner to $overview_file"
        fi
    fi

    # Add to API documentation file
    api_doc_file="${dir}${service}-api-documentation.md"
    if [ -f "$api_doc_file" ]; then
        # Check if banner already exists
        if ! grep -q "{% include api-nav-banner.html %}" "$api_doc_file"; then
            # Find the first heading and insert banner after front matter
            awk '
                BEGIN { in_frontmatter=0; frontmatter_done=0; }
                /^---$/ {
                    if (in_frontmatter == 0) {
                        in_frontmatter=1;
                    } else if (in_frontmatter == 1) {
                        in_frontmatter=0;
                        frontmatter_done=1;
                    }
                    print;
                    next;
                }
                frontmatter_done==1 && /^#/ && !banner_added {
                    print "";
                    print "{% include api-nav-banner.html %}";
                    print "";
                    banner_added=1;
                }
                { print }
            ' "$api_doc_file" > "${api_doc_file}.tmp" && mv "${api_doc_file}.tmp" "$api_doc_file"
            echo "Added banner to $api_doc_file"
        fi
    fi
done

echo "✅ Navigation banners added to all use-case documentation files!"
