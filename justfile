# Cheers - Justfile for build and release automation

# Default recipe - show available commands
default:
    @just --list

# Build the app bundle
build:
    make build

# Clean build artifacts
clean:
    make clean

# Install locally
install:
    make install

# Run tests
test:
    make test

# 🚀 Create a new release - fully automated (e.g., just release 1.0.1)
release version:
    @echo "🚀 Creating release v{{version}}"
    @echo "================================"
    
    # Ensure working directory is clean
    @if [ -n "$(git status --porcelain)" ]; then \
        echo "❌ Working directory is not clean. Commit or stash changes first."; \
        exit 1; \
    fi
    
    # Build and test locally first
    @echo "📦 Building and testing locally..."
    @just build
    @just test
    
    # Create and push tag
    @echo "🏷️  Creating git tag v{{version}}..."
    @git tag -a v{{version}} -m "Release v{{version}}"
    
    @echo "📤 Pushing tag to GitHub..."
    @git push origin v{{version}}
    
    @echo ""
    @echo "✅ Release initiated!"
    @echo ""
    @echo "GitHub Actions will now:"
    @echo "  1. Build the release artifacts"
    @echo "  2. Create a GitHub release"
    @echo "  3. Calculate SHA256 for the source tarball"
    @echo "  4. Automatically update the Homebrew formula"
    @echo ""
    @echo "📊 Monitor progress at:"
    @echo "   https://github.com/xorvo/cheers/actions"
    @echo ""
    @echo "🍺 Once complete, users can install with:"
    @echo "   brew tap xorvo/tap"
    @echo "   brew install cheers"

# Manual: Tag a version without pushing
tag version:
    git tag -a v{{version}} -m "Release v{{version}}"
    @echo "Tagged v{{version}}. Push with: git push origin v{{version}}"

# Calculate SHA256 for a GitHub release tarball
sha version:
    @echo "Calculating SHA256 for v{{version}}..."
    @curl -sL https://github.com/xorvo/cheers/archive/refs/tags/v{{version}}.tar.gz | shasum -a 256

# Manual: Update the Homebrew formula with new version and SHA256
update-formula version sha256:
    @echo "Updating formula for v{{version}} with SHA256: {{sha256}}"
    @sed -i '' 's|url ".*"|url "https://github.com/xorvo/cheers/archive/refs/tags/v{{version}}.tar.gz"|' ../homebrew-tap/Formula/cheers.rb
    @sed -i '' 's|sha256 ".*"|sha256 "{{sha256}}"|' ../homebrew-tap/Formula/cheers.rb
    @echo "Formula updated. Review changes with: just review-formula"

# Review the current formula
review-formula:
    @echo "Current formula content:"
    @echo "========================"
    @grep -E '(url|sha256|version)' ../homebrew-tap/Formula/cheers.rb

# Test the formula locally
test-formula:
    brew install --build-from-source ../homebrew-tap/Formula/cheers.rb

# Uninstall the brew-installed version
uninstall-brew:
    brew uninstall cheers || true

# Quick test of the current build
quick-test:
    @build/cheers.app/Contents/MacOS/cheers "Test notification" --sound Glass

# Show current version from Makefile
current-version:
    @grep "CFBundleShortVersionString" Makefile | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "1.0.0"

# Generate icns file from iconset
generate-icon:
    @echo "🎨 Generating Cheers.icns from Cheers.iconset..."
    @if [ -d "Cheers.iconset" ]; then \
        iconutil -c icns Cheers.iconset; \
        echo "✅ Generated Cheers.icns successfully"; \
        ls -lh Cheers.icns | awk '{print "   Size: " $$5}'; \
    else \
        echo "❌ Cheers.iconset directory not found"; \
        exit 1; \
    fi

# Validate iconset before generating
validate-iconset:
    @echo "🔍 Validating Cheers.iconset..."
    @if [ -d "Cheers.iconset" ]; then \
        echo "Required icon sizes:"; \
        for size in 16 32 128 256 512; do \
            file1="Cheers.iconset/icon_$${size}x$${size}.png"; \
            file2="Cheers.iconset/icon_$${size}x$${size}@2x.png"; \
            if [ -f "$$file1" ]; then \
                echo "  ✅ icon_$${size}x$${size}.png"; \
            else \
                echo "  ❌ icon_$${size}x$${size}.png (missing)"; \
            fi; \
            if [ -f "$$file2" ] && [ "$$size" != "512" ]; then \
                echo "  ✅ icon_$${size}x$${size}@2x.png"; \
            elif [ "$$size" != "512" ]; then \
                echo "  ❌ icon_$${size}x$${size}@2x.png (missing)"; \
            fi; \
        done; \
    else \
        echo "❌ Cheers.iconset directory not found"; \
        exit 1; \
    fi

# Lint Swift code
lint:
    @if command -v swiftlint &> /dev/null; then \
        swiftlint; \
    else \
        echo "SwiftLint not installed. Install with: brew install swiftlint"; \
    fi

# Format Swift code
format:
    @if command -v swift-format &> /dev/null; then \
        swift-format -i cheers.swift; \
    else \
        echo "swift-format not installed. Install with: brew install swift-format"; \
    fi