#!/bin/bash

# Script to refactor capabilities to capabilities

echo "🔄 Refactoring capabilities to capabilities..."
echo ""

BASE_DIR="/Users/nrahal/@code_2025/products/quub/quub-exchange-docs"

# Step 1: Rename the directory
echo "📁 Step 1: Renaming directory..."
if [ -d "$BASE_DIR/capabilities" ]; then
  mv "$BASE_DIR/capabilities" "$BASE_DIR/capabilities"
  echo "  ✓ Renamed capabilities/ to capabilities/"
fi

# Step 2: Update all permalinks in markdown files
echo ""
echo "📝 Step 2: Updating permalinks in all markdown files..."
find "$BASE_DIR/capabilities" -name "*.md" -type f -exec sed -i '' 's|/capabilities/|/capabilities/|g' {} \;
echo "  ✓ Updated permalinks in capabilities/*.md"

# Step 3: Update navigation in layouts
echo ""
echo "🧭 Step 3: Updating navigation links..."
sed -i '' 's|/capabilities/|/capabilities/|g' "$BASE_DIR/_layouts/docs.html"
echo "  ✓ Updated _layouts/docs.html"

# Step 4: Update _config.yml
echo ""
echo "⚙️  Step 4: Updating _config.yml..."
sed -i '' 's|capabilities|capabilities|g' "$BASE_DIR/_config.yml"
echo "  ✓ Updated _config.yml"

# Step 5: Update any other layout files
echo ""
echo "📄 Step 5: Updating other layout files..."
find "$BASE_DIR/_layouts" -name "*.html" -type f -exec sed -i '' 's|capabilities|capabilities|g' {} \;
echo "  ✓ Updated layout files"

# Step 6: Update README and other documentation
echo ""
echo "📚 Step 6: Updating documentation files..."
if [ -f "$BASE_DIR/README.md" ]; then
  sed -i '' 's|capabilities|capabilities|g' "$BASE_DIR/README.md"
  echo "  ✓ Updated README.md"
fi

if [ -f "$BASE_DIR/SITE_SUMMARY.md" ]; then
  sed -i '' 's|capabilities|capabilities|g' "$BASE_DIR/SITE_SUMMARY.md"
  echo "  ✓ Updated SITE_SUMMARY.md"
fi

# Step 7: Update index files
echo ""
echo "🏠 Step 7: Updating index files..."
find "$BASE_DIR" -maxdepth 1 -name "*.md" -type f -exec sed -i '' 's|capabilities|capabilities|g' {} \;
echo "  ✓ Updated index files"

# Step 8: Update any scripts
echo ""
echo "🔧 Step 8: Updating scripts..."
find "$BASE_DIR" -name "*.sh" -type f -exec sed -i '' 's|capabilities|capabilities|g' {} \;
echo "  ✓ Updated shell scripts"

echo ""
echo "✅ Refactoring complete!"
echo ""
echo "Summary:"
echo "  • Renamed: capabilities/ → capabilities/"
echo "  • Updated: All permalinks from /capabilities/ to /capabilities/"
echo "  • Updated: Navigation links in layouts"
echo "  • Updated: Configuration files"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Test locally if possible"
echo "  3. Commit: git add -A && git commit -m 'Refactor: Rename capabilities to capabilities'"
echo "  4. Push: git push origin main"
