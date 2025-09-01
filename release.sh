#!/bin/bash

# Simple release script for Notifier CLI

VERSION=${1:-"1.0.0"}
DIST_DIR="dist"
EXECUTABLE="notifier"
ARCHIVE_NAME="notifier-${VERSION}-macos.tar.gz"

echo "🚀 Building Notifier v${VERSION} for distribution"
echo "================================================"

# Clean and create dist directory
echo "🧹 Cleaning previous builds..."
make clean
rm -rf $DIST_DIR
mkdir -p $DIST_DIR

# Build the CLI
echo "🔨 Building CLI..."
make build

# Copy files to dist
echo "📦 Preparing distribution..."
cp build/$EXECUTABLE $DIST_DIR/
cp README.md $DIST_DIR/
cp LICENSE $DIST_DIR/ 2>/dev/null || echo "⚠️  No LICENSE file found"

# Create simple install script
echo "📝 Creating install script..."
cat > $DIST_DIR/install.sh << 'EOF'
#!/bin/bash

echo "📦 Installing Notifier CLI..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This installer is for macOS only"
    exit 1
fi

# Determine install location
INSTALL_DIR="/usr/local/bin"
if [ -w "$INSTALL_DIR" ]; then
    # Can write without sudo
    cp notifier "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/notifier"
elif [ -w "$HOME/.local/bin" ]; then
    # Use user's local bin
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    cp notifier "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/notifier"
    echo "⚠️  Installed to $INSTALL_DIR - make sure it's in your PATH"
else
    # Need sudo
    echo "Need admin privileges to install to $INSTALL_DIR"
    sudo cp notifier "$INSTALL_DIR/"
    sudo chmod +x "$INSTALL_DIR/notifier"
fi

# Test installation
echo "🧪 Testing installation..."
if command -v notifier &> /dev/null; then
    notifier -t "Installation Complete" -m "Notifier CLI has been successfully installed!" --sound Glass
    echo "✅ Installation successful!"
    echo ""
    echo "Usage: notifier -t 'Title' -m 'Message'"
    echo "Help:  notifier --help"
else
    echo "⚠️  notifier not in PATH. Add $INSTALL_DIR to your PATH"
fi
EOF

chmod +x $DIST_DIR/install.sh

# Create tarball
echo "📦 Creating tarball..."
cd $DIST_DIR
tar -czf $ARCHIVE_NAME notifier install.sh README.md
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