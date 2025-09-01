# Development Notes

## Project Structure

- `cheers.swift` - Main Swift source code for the CLI tool
- `Makefile` - Build configuration for creating the app bundle
- `justfile` - Task automation and release management
- `Cheers.iconset/` - Icon source files (PNG format)
- `Cheers.icns` - Compiled icon file for macOS
- `build/` - Build output directory (git-ignored)

## Building from Source

### Prerequisites

- macOS 10.14 (Mojave) or later
- Xcode Command Line Tools
- Just (optional, for task automation): `brew install just`

### Build Commands

```bash
# Build the app bundle
make build

# Or using just
just build

# Clean and rebuild
make clean && make build
```

## Testing

```bash
# Run the test (sends a test notification)
make test

# Or using just
just test
just quick-test
```

## Release Process

The release process is fully automated through GitHub Actions:

```bash
# Create and publish a new release
just release 1.0.5
```

This command will:
1. Build and test locally
2. Create a git tag
3. Push to GitHub
4. Trigger GitHub Actions to:
   - Build release artifacts
   - Create a GitHub release
   - Calculate SHA256 for the source tarball
   - Automatically update the Homebrew formula

### Manual Release Steps

If you need to release manually:

1. Update version in code if needed
2. Build and test: `just build && just test`
3. Create tag: `git tag -a v1.0.5 -m "Release v1.0.5"`
4. Push tag: `git push origin v1.0.5`
5. GitHub Actions will handle the rest

## Homebrew Formula

The Homebrew formula is maintained in a separate repository:
- Repository: `xorvo/homebrew-tap`
- Formula: `Formula/cheers.rb`

The formula is automatically updated when a new release is created through the GitHub Actions workflow.

### Testing Formula Locally

```bash
# Test the formula
just test-formula

# Or manually
brew install --build-from-source ../homebrew-tap/Formula/cheers.rb
```

## Icon Management

See [icon-update.md](./icon-update.md) for detailed instructions on updating the application icon.

Quick commands:
```bash
# Validate iconset
just validate-iconset

# Generate icns from iconset
just generate-icon
```

## Code Signing

The app is automatically code-signed during the build process using ad-hoc signing:
```bash
codesign -s - --force --deep build/cheers.app
```

This allows the app to run without Gatekeeper warnings on the local machine.

## Notification Permissions

On first run, macOS will prompt for notification permissions. Users need to:
1. Go to System Settings > Notifications
2. Find "cheers" in the application list
3. Enable notifications

## Troubleshooting

### Build Issues

- Ensure Xcode Command Line Tools are installed: `xcode-select --install`
- Clean build directory: `make clean` or `just clean`

### Notification Not Appearing

- Check notification permissions in System Settings
- Ensure Do Not Disturb is not enabled
- Try with sound: `cheers "Test" --sound Glass`

### Icon Not Updating

See the Troubleshooting section in [icon-update.md](./icon-update.md)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Architecture Notes

The app is built as a simple Swift CLI tool wrapped in a minimal macOS app bundle. This approach:
- Allows command-line usage
- Provides proper notification permissions through the app bundle
- Enables custom icons in notifications
- Maintains a small binary size (~50KB)