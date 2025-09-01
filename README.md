# Notifier - Modern macOS Notification Tool

A minimal, elegant replacement for terminal-notifier built with Swift.

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
- 🪶 **Lightweight** - ~200KB vs terminal-notifier's 2MB

## Quick Install

### Download Pre-built Release

```bash
# One-line install
curl -L https://github.com/xorvo/notifier/releases/latest/download/notifier-macos.tar.gz | tar -xz && ./install.sh
```

### Build from Source

```bash
# Clone and install
git clone https://github.com/xorvo/notifier.git
cd notifier
make install
```

### Manual Install

```bash
# Download and extract
curl -L https://github.com/xorvo/notifier/releases/latest/download/notifier-macos.tar.gz | tar -xz

# Copy to your bin directory
cp notifier /usr/local/bin/
```

## Usage

```bash
# Simple notification
notifier "Hello World"

# With title and message
notifier -t "Alert" -m "Something happened"

# Full example with all options
notifier -t "Success" \
         -m "Build complete" \
         -s "CI/CD Pipeline" \
         --sound Glass \
         -i /path/to/icon.png \
         -o http://example.com

# Silent notification
notifier -t "Background Task" -m "Processing complete" --sound none
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
git clone https://github.com/xorvo/notifier.git
cd notifier

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
notifier -t "Backup Complete" -m "All files backed up successfully" --sound Glass
```

### Ruby
```ruby
system('notifier', '-t', 'Deploy', '-m', 'Application deployed to production')
```

### Python
```python
import subprocess
subprocess.run(['notifier', '-t', 'Alert', '-m', 'Process completed'])
```

### Node.js
```javascript
const { exec } = require('child_process');
exec('notifier -t "Build" -m "Build successful"');
```

## Differences from terminal-notifier

| Feature | terminal-notifier | notifier |
|---------|------------------|----------|
| Language | Objective-C | Swift |
| Last update | 2020 | 2024 |
| Size | ~2MB | ~200KB |
| Dependencies | Many | None |
| Code style | Complex | Minimal |
| Icon support | Limited | Full |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT - See [LICENSE](LICENSE) file for details.

## Author

Created by [@xorvo](https://github.com/xorvo)

## Acknowledgments

- Inspired by [terminal-notifier](https://github.com/julienXX/terminal-notifier)
- Built with Swift and Apple's UserNotifications framework