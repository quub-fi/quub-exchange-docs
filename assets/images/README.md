# Favicon Assets

This directory contains favicon and icon assets for the Quub Exchange documentation site.

## Files

- `favicon.svg` - SVG favicon (already created)
- `favicon-16x16.png` - 16x16 PNG favicon
- `favicon-32x32.png` - 32x32 PNG favicon
- `favicon-192x192.png` - 192x192 PNG for Android
- `favicon-512x512.png` - 512x512 PNG for Android
- `apple-touch-icon.png` - 180x180 PNG for iOS

## Generating PNG Files

To generate PNG files from the SVG:

### Option 1: Using ImageMagick

```bash
cd assets/images

# 16x16
convert -background none -resize 16x16 favicon.svg favicon-16x16.png

# 32x32
convert -background none -resize 32x32 favicon.svg favicon-32x32.png

# 192x192
convert -background none -resize 192x192 favicon.svg favicon-192x192.png

# 512x512
convert -background none -resize 512x512 favicon.svg favicon-512x512.png

# Apple touch icon (180x180)
convert -background none -resize 180x180 favicon.svg apple-touch-icon.png
```

### Option 2: Using Online Tools

1. Go to https://realfavicongenerator.net/
2. Upload `favicon.svg`
3. Download generated package
4. Place files in this directory

### Option 3: Using Node.js (sharp)

```bash
npm install sharp sharp-cli -g

sharp -i favicon.svg -o favicon-16x16.png resize 16 16
sharp -i favicon.svg -o favicon-32x32.png resize 32 32
sharp -i favicon.svg -o favicon-192x192.png resize 192 192
sharp -i favicon.svg -o favicon-512x512.png resize 512 512
sharp -i favicon.svg -o apple-touch-icon.png resize 180 180
```

## Design

The favicon features:

- Purple gradient background (#667eea to #764ba2)
- White "Q" with magnifying glass design
- Modern, clean aesthetic matching the Quub Exchange brand
- Rounded corners (6px border-radius)
- SVG-first approach for crisp rendering at any size
