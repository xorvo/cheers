# Icon Update Guide

This guide explains how to update the application icon for Cheers.

## Icon Requirements

macOS requires specific icon sizes for application bundles. The icon should be provided as a set of PNG files in an `.iconset` folder, which is then compiled into an `.icns` file.

### Required Icon Sizes

Create PNG files with the following names and dimensions in the `Cheers.iconset` folder:

| Filename | Size | Purpose |
|----------|------|---------|
| `icon_16x16.png` | 16×16 px | Finder list view, small |
| `icon_16x16@2x.png` | 32×32 px | Retina display, small |
| `icon_32x32.png` | 32×32 px | Finder list view |
| `icon_32x32@2x.png` | 64×64 px | Retina display |
| `icon_128x128.png` | 128×128 px | Finder thumbnail |
| `icon_128x128@2x.png` | 256×256 px | Retina display thumbnail |
| `icon_256x256.png` | 256×256 px | Finder cover flow |
| `icon_256x256@2x.png` | 512×512 px | Retina display cover flow |
| `icon_512x512.png` | 512×512 px | Large icon |
| `icon_512x512@2x.png` | 1024×1024 px | Retina display large icon |

## Updating the Icon

### Step 1: Prepare the Iconset

1. Create or obtain your icon design at 1024×1024 px resolution
2. Create a folder named `Cheers.iconset` in the project root
3. Generate all required sizes and place them in the iconset folder with the correct filenames

### Step 2: Validate the Iconset

Run the validation command to ensure all required files are present:

```bash
just validate-iconset
```

### Step 3: Generate the ICNS File

Once all icon files are in place, generate the `.icns` file:

```bash
just generate-icon
```

Or manually with:

```bash
iconutil -c icns Cheers.iconset
```

This will create `Cheers.icns` in the project root.

### Step 4: Test the Icon

Build the application and verify the icon appears correctly:

```bash
just build
just quick-test
```

Check that the icon appears in:
- The dock when the app sends a notification
- Finder when viewing the app bundle
- The notification itself (if applicable)

## Design Guidelines

- **Simplicity**: Keep the design clean and recognizable at small sizes
- **Color**: Use colors that work well on both light and dark backgrounds
- **Padding**: Include appropriate padding; the icon shouldn't touch the edges
- **Format**: Use PNG format with transparency for best results
- **Testing**: Test the icon on both light and dark mode macOS themes

## Troubleshooting

### Icon Not Updating

If the icon doesn't update after building:
1. Clean the build: `just clean`
2. Rebuild: `just build`
3. Clear icon cache: `sudo rm -rf /Library/Caches/com.apple.iconservices.store`
4. Restart Finder: `killall Finder`

### Validation Errors

If `just validate-iconset` reports missing files:
- Ensure all files use the exact naming convention shown above
- Check that @2x files are exactly double the base resolution
- Verify PNG format and transparency

## Automation

The build process automatically copies the `Cheers.icns` file to the app bundle during compilation. See the `Makefile` for implementation details.