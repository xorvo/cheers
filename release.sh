#!/bin/bash

# Release script for Notifier CLI with app bundle

VERSION=${1:-"1.0.0"}
DIST_DIR="dist"
APPNAME="notifier"
ARCHIVE_NAME="notifier-${VERSION}-macos.tar.gz"

echo "🚀 Building Notifier v${VERSION} for distribution"
echo "================================================"

# Clean and build
echo "🧹 Cleaning previous builds..."
make clean
rm -rf $DIST_DIR
mkdir -p $DIST_DIR

# Build the app bundle
echo "🔨 Building app bundle..."
make build

# Copy app bundle to dist
echo "📦 Preparing distribution..."
cp -R build/${APPNAME}.app $DIST_DIR/
cp README.md $DIST_DIR/
cp LICENSE $DIST_DIR/ 2>/dev/null || echo "⚠️  No LICENSE file found"

# Create installer script
echo "📝 Creating install script..."
cat > $DIST_DIR/install.sh << 'EOF'
#!/bin/bash

echo "📦 Installing Notifier..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This installer is for macOS only"
    exit 1
fi

# Determine install location for app bundle
APP_INSTALL_DIR="$HOME/.local/opt"
BIN_DIR=""

# Check where we can install the symlink
if [ -w "/usr/local/bin" ]; then
    BIN_DIR="/usr/local/bin"
elif [ -d "$HOME/.local/bin" ]; then
    BIN_DIR="$HOME/.local/bin"
else
    # Create user local bin
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR"
    echo "ℹ️  Created $BIN_DIR - make sure it's in your PATH"
fi

# Install app bundle
echo "📦 Installing app bundle to $APP_INSTALL_DIR..."
mkdir -p "$APP_INSTALL_DIR"
rm -rf "$APP_INSTALL_DIR/notifier.app"
cp -R notifier.app "$APP_INSTALL_DIR/"

# Create symlink
echo "🔗 Creating symlink in $BIN_DIR..."
rm -f "$BIN_DIR/notifier"
ln -sf "$APP_INSTALL_DIR/notifier.app/Contents/MacOS/notifier" "$BIN_DIR/notifier"

# Test installation
echo "🧪 Testing installation..."
if command -v notifier &> /dev/null; then
    echo "✅ Installation successful!"
    echo ""
    echo "⚠️  IMPORTANT: On first run, macOS will ask for notification permissions."
    echo "   Go to System Settings > Notifications to grant permission to 'notifier'"
    echo ""
    echo "Usage: notifier 'Hello World'"
    echo "Help:  notifier --help"
else
    echo "⚠️  notifier not in PATH. Add $BIN_DIR to your PATH:"
    echo "   export PATH=\"$BIN_DIR:\$PATH\""
fi
EOF

chmod +x $DIST_DIR/install.sh

# Create tarball
echo "📦 Creating tarball..."
cd $DIST_DIR
tar -czf $ARCHIVE_NAME notifier.app install.sh README.md
cd ..

# Generate checksums
echo "🔐 Generating checksums..."
cd $DIST_DIR
shasum -a 256 $ARCHIVE_NAME > checksums.txt
cd ..

# Summary
echo ""
echo "✅ Release build complete!"
echo "================================"
echo "Version: ${VERSION}"
echo "File: $DIST_DIR/$ARCHIVE_NAME"
echo "Size: $(du -h $DIST_DIR/$ARCHIVE_NAME | cut -f1)"
echo ""
echo "To distribute:"
echo "1. Upload $DIST_DIR/$ARCHIVE_NAME to GitHub Releases"
echo "2. Users can install with:"
echo "   curl -L [url] | tar -xz && ./install.sh"