# Shipping Custom Sounds with Cheers

This document explains how to bundle custom sounds directly with the Cheers app for distribution.

## Overview

Custom sounds can be included in the app bundle so they're available to all users without requiring them to manually install sound files.

## Implementation Steps

### 1. Add Sounds to the Project

Create a `Sounds` directory in your project:

```bash
mkdir -p Sounds
```

Place your `.aiff` sound files in this directory:
```bash
Sounds/
├── CustomPing.aiff
├── Success.aiff
└── Alert.aiff
```

### 2. Update the Makefile

Modify the `Makefile` to copy sounds during the build process:

```makefile
build:
	@echo "🔨 Building cheers..."
	@swiftc cheers.swift -o cheers \
		-framework UserNotifications \
		-framework AppKit
	
	# Create app bundle structure
	@mkdir -p build/cheers.app/Contents/MacOS
	@mkdir -p build/cheers.app/Contents/Resources
	@mkdir -p build/cheers.app/Contents/Resources/Sounds  # Add this
	
	# Copy executable
	@cp cheers build/cheers.app/Contents/MacOS/
	
	# Copy icon if exists
	@if [ -f Cheers.icns ]; then \
		cp Cheers.icns build/cheers.app/Contents/Resources/; \
	fi
	
	# Copy bundled sounds if they exist
	@if [ -d Sounds ]; then \
		cp Sounds/*.aiff build/cheers.app/Contents/Resources/Sounds/ 2>/dev/null || true; \
		echo "📢 Copied bundled sounds"; \
	fi
	
	# Create Info.plist and sign...
```

### 3. Update Swift Code to Find Bundled Sounds

Modify `cheers.swift` to look for sounds in the app bundle:

```swift
// In the Notifier.send() method, update sound handling:
if let soundName = sound, soundName != "none" {
    if soundName == "default" {
        content.sound = .default
    } else {
        // First try bundled sounds
        if let bundlePath = Bundle.main.resourcePath {
            let bundledSoundPath = "\(bundlePath)/Sounds/\(soundName).aiff"
            if FileManager.default.fileExists(atPath: bundledSoundPath) {
                let soundURL = URL(fileURLWithPath: bundledSoundPath)
                // Copy to user's Library/Sounds on first use (optional)
                let userSoundsDir = FileManager.default.homeDirectoryForCurrentUser
                    .appendingPathComponent("Library/Sounds")
                let destURL = userSoundsDir.appendingPathComponent("\(soundName).aiff")
                
                if !FileManager.default.fileExists(atPath: destURL.path) {
                    try? FileManager.default.createDirectory(at: userSoundsDir, 
                                                            withIntermediateDirectories: true)
                    try? FileManager.default.copyItem(at: soundURL, to: destURL)
                }
            }
        }
        // Fall back to system/user sounds
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(soundName).aiff"))
    }
}
```

### 4. Update Homebrew Formula

When shipping bundled sounds, update the formula to preserve them:

```ruby
def install
  system "swiftc", "cheers.swift", "-o", "cheers",
         "-framework", "UserNotifications",
         "-framework", "AppKit"
  
  # Create app bundle structure
  app_bundle = prefix/"cheers.app"
  (app_bundle/"Contents/MacOS").mkpath
  (app_bundle/"Contents/Resources").mkpath
  (app_bundle/"Contents/Resources/Sounds").mkpath  # Add this
  
  # Copy executable
  cp "cheers", app_bundle/"Contents/MacOS/cheers"
  
  # Copy bundled sounds if available
  if Dir.exist?("Sounds")
    Dir.glob("Sounds/*.aiff").each do |sound|
      cp sound, app_bundle/"Contents/Resources/Sounds/"
    end
  end
  
  # Rest of installation...
end
```

## Sound File Guidelines

### Format Requirements
- **Format**: AIFF (Audio Interchange File Format)
- **Sample Rate**: 44.1 kHz or 48 kHz
- **Bit Depth**: 16-bit or 24-bit
- **Channels**: Mono or Stereo (mono recommended for smaller size)
- **Duration**: 0.5 - 3 seconds (shorter is better)

### Creating AIFF Files

Using ffmpeg to convert audio files:
```bash
# Convert MP3 to AIFF
ffmpeg -i input.mp3 -acodec pcm_s16be output.aiff

# Convert with specific sample rate
ffmpeg -i input.wav -ar 44100 -acodec pcm_s16be output.aiff

# Trim to 2 seconds and convert
ffmpeg -i input.mp3 -t 2 -acodec pcm_s16be output.aiff
```

Using macOS Audio MIDI Setup:
1. Open Audio MIDI Setup.app
2. File → Open Audio File
3. File → Export As → AIFF

## Distribution Considerations

### Pros of Bundling Sounds
- Users get custom sounds immediately
- No manual installation required
- Consistent experience across installations
- Sounds survive system updates

### Cons of Bundling Sounds
- Increases app bundle size
- May override user preferences
- Updates require new app releases

### Alternative: Download on First Use

Instead of bundling, you could download sounds on first use:

```swift
func downloadBundledSounds() {
    let soundsURL = "https://github.com/xorvo/cheers/releases/latest/download/sounds.zip"
    // Download and extract to ~/Library/Sounds/
}
```

## Testing Bundled Sounds

```bash
# Build with sounds
make build

# Test bundled sound
./build/cheers.app/Contents/MacOS/cheers -t "Test" -m "Custom sound" --sound CustomPing

# Verify sound files are in bundle
ls -la build/cheers.app/Contents/Resources/Sounds/
```

## Example Sound Pack Structure

```
cheers-sounds/
├── README.md
├── Makefile
└── sounds/
    ├── cheers-success.aiff    # Success/completion sound
    ├── cheers-alert.aiff      # Alert/warning sound
    ├── cheers-info.aiff       # Information sound
    ├── cheers-error.aiff      # Error sound
    └── cheers-party.aiff      # Celebration sound
```

## Notes

- Bundled sounds should have unique names to avoid conflicts with system sounds
- Consider prefixing custom sounds with "cheers-" to avoid naming collisions
- The app bundle approach ensures sounds are available even if the user doesn't have write access to ~/Library/Sounds/
- For Homebrew distribution, sounds would need to be included in the source tarball