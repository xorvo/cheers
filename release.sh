#!/bin/bash

# Release script for Notifier
# Creates a distributable package

VERSION=${1:-"1.0.0"}
DIST_DIR="dist"
APP_NAME="Notifier"
ARCHIVE_NAME="notifier-${VERSION}-macos.tar.gz"
DMG_NAME="notifier-${VERSION}.dmg"

echo "🚀 Building Notifier v${VERSION} for distribution"
echo "================================================"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
make clean
rm -rf $DIST_DIR
mkdir -p $DIST_DIR

# Build the app
echo "🔨 Building app..."
make build

# Sign the app
echo "🔏 Signing app..."
codesign -s - --force --deep build/${APP_NAME}.app

# Verify the app
echo "✅ Verifying signature..."
codesign -v build/${APP_NAME}.app

# Create command-line tool standalone
echo "📦 Creating standalone CLI..."
cp build/${APP_NAME}.app/Contents/MacOS/notifier $DIST_DIR/notifier
chmod +x $DIST_DIR/notifier

# Create tarball with app and CLI
echo "📦 Creating tarball..."
cd build
tar -czf ../$DIST_DIR/$ARCHIVE_NAME ${APP_NAME}.app ../README.md ../LICENSE
cd ..

# Create DMG (optional, for GUI distribution)
echo "💿 Creating DMG..."
create-dmg \
  --volname "${APP_NAME} ${VERSION}" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "${APP_NAME}.app" 150 150 \
  --app-drop-link 450 150 \
  "$DIST_DIR/$DMG_NAME" \
  "build/${APP_NAME}.app" 2>/dev/null || {
    echo "⚠️  create-dmg not found. Skipping DMG creation."
    echo "   Install with: brew install create-dmg"
  }

# Create install script
cat > $DIST_DIR/install.sh << 'EOF'
#!/bin/bash

echo "📦 Installing Notifier..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This installer is for macOS only"
    exit 1
fi

# Extract if needed
if [ -f "notifier-*.tar.gz" ]; then
    echo "📂 Extracting archive..."
    tar -xzf notifier-*.tar.gz
fi

# Install locations
APP_DEST="/Applications"
CLI_DEST="/usr/local/bin"

# Install app
if [ -d "Notifier.app" ]; then
    echo "🎯 Installing Notifier.app to $APP_DEST..."
    cp -R Notifier.app "$APP_DEST/"
    echo "✅ App installed to $APP_DEST/Notifier.app"
fi

# Install CLI
if [ -f "notifier" ]; then
    echo "🎯 Installing notifier CLI to $CLI_DEST..."
    sudo mkdir -p "$CLI_DEST"
    sudo cp notifier "$CLI_DEST/"
    sudo chmod +x "$CLI_DEST/notifier"
    echo "✅ CLI installed to $CLI_DEST/notifier"
fi

# Test installation
echo "🧪 Testing installation..."
if command -v notifier &> /dev/null; then
    notifier -t "Installation Complete" -m "Notifier has been successfully installed!" --sound Glass
    echo "✅ Installation successful!"
else
    echo "⚠️  CLI not in PATH. You may need to restart your terminal."
fi

echo ""
echo "Usage:"
echo "  CLI: notifier -t 'Title' -m 'Message'"
echo "  App: Open /Applications/Notifier.app"
echo ""
echo "For help: notifier --help"
EOF

chmod +x $DIST_DIR/install.sh

# Generate checksums
echo "🔐 Generating checksums..."
cd $DIST_DIR
shasum -a 256 * > checksums.txt
cd ..

# Summary
echo ""
echo "✅ Release build complete!"
echo "================================"
echo "Version: ${VERSION}"
echo "Files created in $DIST_DIR/:"
ls -lh $DIST_DIR/
echo ""
echo "To distribute:"
echo "1. Upload $DIST_DIR/$ARCHIVE_NAME to GitHub Releases"
echo "2. Users can download and run: ./install.sh"
echo ""
echo "Installation methods:"
echo "  - Homebrew: brew install --cask notifier (after creating formula)"
echo "  - Manual: ./install.sh"
echo "  - Direct: cp notifier /usr/local/bin/"