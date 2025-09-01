# Notifier - Modern macOS Notification Tool

A minimal, elegant replacement for terminal-notifier built with Swift.

## Features

- 🎯 **Simple & Minimal** - No bloat, just notifications
- 🖱️ **Clickable** - Open URLs when notifications are clicked
- 🖼️ **Image Support** - Display images in notifications
- 🔊 **Custom Sounds** - Use system sounds or silence
- 📦 **App Bundle** - Proper macOS app structure
- 🚀 **Native Swift** - Built with UserNotifications framework

## Build

```bash
make build
```

This creates:
- `build/Notifier.app` - The app bundle
- `build/notifier` - Command-line tool symlink

## Installation

```bash
# Option 1: Install to /usr/local/bin (requires sudo)
make install

# Option 2: Use directly from build directory
./build/notifier [options]

# Option 3: Add to PATH
export PATH="$PATH:$(pwd)/build"
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

- `-t, --title TEXT` - Notification title
- `-m, --message TEXT` - Notification message  
- `-s, --subtitle TEXT` - Notification subtitle
- `--sound NAME` - Sound name (Glass, Ping, etc.) or 'none'
- `-i, --image PATH` - Path or URL to image
- `-o, --open URL` - URL to open when clicked
- `-h, --help` - Show help

## Permissions

On first run, macOS will ask for notification permissions. You need to:

1. **Option A**: Sign the app with a developer certificate
2. **Option B**: Allow notifications for Terminal/your IDE in System Preferences
3. **Option C**: Run the app bundle directly once to grant permissions:
   ```bash
   open build/Notifier.app
   ```

## Architecture

Built with:
- Swift 5+ 
- UserNotifications framework
- AppKit for URL opening
- Minimal dependencies

## Differences from terminal-notifier

| Feature | terminal-notifier | notifier |
|---------|------------------|----------|
| Language | Objective-C | Swift |
| Last update | 2020 | 2024 |
| Size | ~2MB | ~200KB |
| Dependencies | Many | None |
| Code style | Complex | Minimal |

## Integration with Webhook Server

The parent directory contains a webhook server that can use this notifier:

```ruby
# In webhook_server.rb, replace terminal-notifier with:
system('./notifier/build/notifier', 
       '-t', title,
       '-m', message,
       '-o', url)
```

## License

MIT - Simple, modern, and free to use.