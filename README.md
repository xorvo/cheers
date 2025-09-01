# Cheers 🥂 - A Delightful macOS Notification Tool

A minimal, elegant notification tool for macOS built with Swift.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS-blue.svg)]()
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)]()

## Features

- 🎯 **Simple & Minimal** - No bloat, just notifications
- 🖱️ **Clickable** - Open URLs when notifications are clicked
- 🖼️ **Image Support** - Display images in notifications
- 🔊 **Custom Sounds** - Use system sounds or silence
- 📦 **Single Binary** - Just one executable, no complex app bundles
- 🚀 **Native Swift** - Built with macOS native frameworks
- 🪶 **Lightweight** - Small and efficient
- 🥂 **Delightful** - Beautiful cocktail icon

## Quick Install

### Homebrew (Recommended)

```bash
brew tap xorvo/tap
brew install cheers
```

### Download Pre-built Release

```bash
# One-line install
curl -L https://github.com/xorvo/cheers/releases/latest/download/cheers-macos.tar.gz | tar -xz && ./install.sh
```

### Build from Source

```bash
# Clone and install
git clone https://github.com/xorvo/cheers.git
cd cheers
make install
```

### Manual Install

```bash
# Download and extract
curl -L https://github.com/xorvo/cheers/releases/latest/download/cheers-macos.tar.gz | tar -xz

# Install the app bundle
cp -R cheers.app ~/.local/opt/
ln -s ~/.local/opt/cheers.app/Contents/MacOS/cheers ~/.local/bin/cheers
```

## Usage

```bash
# Simple notification
cheers "Hello World"

# With title and message
cheers -t "Alert" -m "Something happened"

# Full example with all options
cheers -t "Success" \
      -m "Build complete" \
      -s "CI/CD Pipeline" \
      --sound Glass \
      -i /path/to/icon.png \
      -o http://example.com

# Silent notification
cheers -t "Background Task" -m "Processing complete" --sound none
```

## Options

| Option | Description |
|--------|-------------|
| `-t, --title TEXT` | Notification title |
| `-m, --message TEXT` | Notification message |
| `-s, --subtitle TEXT` | Notification subtitle |
| `--sound NAME` | Sound name (Glass, Ping, etc.) or 'none' |
| `-i, --image PATH` | Path or URL to image |
| `-o, --open URL` | URL to open when clicked |
| `-h, --help` | Show help |

## Available Sounds

`Basso`, `Blow`, `Bottle`, `Frog`, `Funk`, `Glass`, `Hero`, `Morse`, `Ping`, `Pop`, `Purr`, `Sosumi`, `Submarine`, `Tink`

## Permissions

On first run, macOS will ask for notification permissions.

If you encounter permission issues:
1. Open System Settings → Notifications
2. Allow notifications for Terminal (or your terminal app)

## Building from Source

### Requirements

- macOS 10.14+
- Xcode Command Line Tools
- Swift 5.0+

### Build Steps

```bash
# Clone repository
git clone https://github.com/xorvo/cheers.git
cd cheers

# Build
make build

# Install locally
make install

# Or create a release package
./release.sh 1.0.0
```

## Integration Examples

### Shell Script
```bash
#!/bin/bash
cheers -t "Backup Complete" -m "All files backed up successfully" --sound Glass
```

### Ruby
```ruby
system('cheers', '-t', 'Deploy', '-m', 'Application deployed to production')
```

### Python
```python
import subprocess
subprocess.run(['cheers', '-t', 'Alert', '-m', 'Process completed'])
```

### Node.js
```javascript
const { exec } = require('child_process');
exec('cheers -t "Build" -m "Build successful"');
```

## Why Cheers?

- **🥂 Delightful** - Beautiful cocktail icon that makes notifications feel celebratory
- **⚡ Fast** - Lightweight and efficient
- **🎯 Simple** - Clean, minimal API
- **🍎 Native** - Built with Swift for modern macOS
- **🔧 Reliable** - Proper app bundle structure ensures notifications always work

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT - See [LICENSE](LICENSE) file for details.

## Author

Created by [@xorvo](https://github.com/xorvo)

## Acknowledgments

- Inspired by [terminal-notifier](https://github.com/julienXX/terminal-notifier)
- Built with Swift and Apple's UserNotifications framework