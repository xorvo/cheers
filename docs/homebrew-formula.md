# Homebrew Formula Documentation

This document explains how the Cheers Homebrew formula works and how to maintain it.

## Formula Overview

The Cheers formula is hosted in a custom tap repository: `xorvo/homebrew-tap`

Users install Cheers via:
```bash
brew tap xorvo/tap
brew install cheers
```

## Formula Structure

The formula (`homebrew-tap/Formula/cheers.rb`) contains:

```ruby
class Cheers < Formula
  desc "Delightful macOS notification tool"
  homepage "https://github.com/xorvo/cheers"
  url "https://github.com/xorvo/cheers/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "971037c92287d9226cc89a5122c79fdc68e9b52fa192195c410109c3a7b3d6d7"
  license "MIT"

  depends_on :macos => :mojave

  def install
    # Build from source
    # Create app bundle
    # Install smart wrapper
  end

  test do
    # Test the installation
  end
end
```

## Key Components

### 1. Source URL

Points to GitHub release tarball:
```ruby
url "https://github.com/xorvo/cheers/archive/refs/tags/v1.3.0.tar.gz"
```

Homebrew automatically downloads and extracts this during installation.

### 2. SHA256 Verification

Ensures download integrity:
```ruby
sha256 "971037c92287d9226cc89a5122c79fdc68e9b52fa192195c410109c3a7b3d6d7"
```

Calculate manually:
```bash
curl -L https://github.com/xorvo/cheers/archive/refs/tags/v1.3.0.tar.gz | shasum -a 256
```

### 3. Build Process

The formula compiles from source:
```ruby
system "swiftc", "cheers.swift", "-o", "cheers",
       "-framework", "UserNotifications",
       "-framework", "AppKit"
```

Benefits:
- Native compilation for user's system
- No need to distribute pre-built binaries
- Automatic architecture support (Intel/Apple Silicon)

### 4. App Bundle Creation

Creates proper macOS app structure:
```ruby
app_bundle = prefix/"cheers.app"
(app_bundle/"Contents/MacOS").mkpath
(app_bundle/"Contents/Resources").mkpath
```

This ensures:
- Notifications display correctly
- Icon appears in notifications
- macOS recognizes it as an app

### 5. Smart Wrapper Script

The critical innovation for CLI usability:
```ruby
(bin/"cheers").write <<~EOS
  #!/bin/bash
  # Smart wrapper for cheers
  
  # Check if requesting help or no arguments
  if [ $# -eq 0 ] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
      # Run directly for terminal output
      exec "#{app_bundle}/Contents/MacOS/cheers" "$@"
  fi
  
  # For notifications, use open to ensure proper app bundle context
  exec open -n "#{app_bundle}" --args "$@"
EOS
```

This solves two problems:
1. Help text outputs to terminal (direct execution)
2. Notifications work properly (via `open` command)

## Tap Repository Structure

```
homebrew-tap/
├── Formula/
│   └── cheers.rb
├── .github/
│   └── workflows/
│       └── update-formula.yml
└── README.md
```

## Testing the Formula

### Local Testing

Test formula changes locally before committing:

```bash
# Clone the tap
git clone https://github.com/xorvo/homebrew-tap
cd homebrew-tap

# Test installation
brew install --build-from-source Formula/cheers.rb

# Test specific version
brew install --build-from-source Formula/cheers.rb --HEAD
```

### Audit Formula

Check for common issues:
```bash
brew audit --strict Formula/cheers.rb
```

### Test Block

The formula includes a test:
```ruby
test do
  assert_match "Cheers - A delightful macOS notification tool", 
               shell_output("#{bin}/cheers --help 2>&1", 0)
end
```

Run with:
```bash
brew test cheers
```

## Common Issues and Solutions

### Issue: Notifications Don't Appear

**Cause**: Not using app bundle context
**Solution**: Smart wrapper uses `open` command for notifications

### Issue: Help Text Doesn't Show

**Cause**: `open` command doesn't pass stdout
**Solution**: Smart wrapper detects help flags and runs directly

### Issue: Permission Denied

**Cause**: Script not executable
**Solution**: Ensure `chmod(0755)` on wrapper script

### Issue: Icon Not Showing

**Cause**: Icon not copied to Resources
**Solution**: Check icon copy step in formula

## Updating the Formula

### Automated Update (Preferred)

1. Push a new tag to cheers repo
2. GitHub Actions automatically:
   - Creates release
   - Calculates SHA256
   - Updates formula via repository dispatch

### Manual Update

1. Edit `Formula/cheers.rb`:
   ```ruby
   url "https://github.com/xorvo/cheers/archive/refs/tags/vNEW_VERSION.tar.gz"
   sha256 "NEW_SHA256"
   ```

2. Test locally:
   ```bash
   brew uninstall cheers
   brew install --build-from-source Formula/cheers.rb
   ```

3. Commit and push:
   ```bash
   git add Formula/cheers.rb
   git commit -m "Update Cheers to vNEW_VERSION"
   git push
   ```

## Homebrew Best Practices

### DO:
- ✅ Use semantic versioning
- ✅ Include comprehensive test block
- ✅ Specify minimum macOS version
- ✅ Use proper formula class name (CamelCase)
- ✅ Include accurate description
- ✅ Specify license

### DON'T:
- ❌ Include unnecessary dependencies
- ❌ Download pre-built binaries (build from source)
- ❌ Modify system files outside prefix
- ❌ Print unnecessary output during installation
- ❌ Use hard-coded paths

## Formula Dependencies

Current dependencies:
- `macOS >= 10.14 (Mojave)` - For UserNotifications framework
- Swift compiler (provided by Xcode Command Line Tools)

No external library dependencies keeps installation simple.

## Debugging Installation

Enable verbose output:
```bash
brew install cheers --verbose --debug
```

Check installation files:
```bash
# List installed files
brew list cheers

# Show formula info
brew info cheers

# Check installation prefix
echo $(brew --prefix)/opt/cheers
```

## Distribution Metrics

Monitor usage (approximate):
```bash
# Check GitHub traffic
# https://github.com/xorvo/homebrew-tap/graphs/traffic

# View clone count (tap updates)
# Indicates active users
```

## Future Enhancements

Potential formula improvements:

1. **Cask Distribution**
   - Could distribute as cask for pre-built app
   - Trade-off: Loses architecture flexibility

2. **Bottling**
   - Pre-compile for common systems
   - Requires CI infrastructure

3. **Options**
   - Add build options (e.g., `--without-icon`)
   - Generally discouraged by Homebrew

4. **HEAD Build**
   - Allow installing from main branch
   - Useful for testing

Example HEAD support:
```ruby
head do
  url "https://github.com/xorvo/cheers.git", branch: "main"
end
```

## Tap Maintenance

### Renaming/Moving

If tap needs to be renamed:
```bash
brew tap-new new-name/tap
# Move formula files
brew untap old-name/tap
```

### Deprecation

If deprecating:
```ruby
deprecate! date: "2024-01-01", because: "replaced by new-tool"
```

### Deletion

Remove formula and add to tap's `tap_migrations.json`:
```json
{
  "cheers": "new-tap/new-formula"
}
```