#!/bin/bash

# Reorganize capability files into proper directory structure
# For each capability, move:
#   {service}-api-documentation.md -> api-documentation/index.md
#   {service}-overview.md -> overview/index.md

for capability_dir in capabilities/*/; do
  service=$(basename "$capability_dir")
  
  # Move API documentation file
  if [ -f "${capability_dir}${service}-api-documentation.md" ]; then
    mkdir -p "${capability_dir}api-documentation"
    git mv "${capability_dir}${service}-api-documentation.md" "${capability_dir}api-documentation/index.md"
    echo "Moved ${service}-api-documentation.md -> api-documentation/index.md"
  fi
  
  # Move overview file
  if [ -f "${capability_dir}${service}-overview.md" ]; then
    mkdir -p "${capability_dir}overview"
    git mv "${capability_dir}${service}-overview.md" "${capability_dir}overview/index.md"
    echo "Moved ${service}-overview.md -> overview/index.md"
  fi
done

echo "Reorganization complete!"
