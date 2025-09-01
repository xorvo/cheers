#!/usr/bin/env swift

import Foundation
import AppKit

// CLI-only version using NSUserNotification (deprecated but works without bundle)

struct Arguments {
    var title: String = "Notification"
    var message: String = ""
    var subtitle: String?
    var sound: String?
    var imageURL: String?
    var openURL: String?
    var help: Bool = false
    
    init(from args: [String]) {
        var i = 1
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "-h", "--help":
                help = true
                i += 1
            case "-t", "--title":
                if i + 1 < args.count {
                    title = args[i + 1]
                    i += 2
                } else {
                    i += 1
                }
            case "-m", "--message":
                if i + 1 < args.count {
                    message = args[i + 1]
                    i += 2
                } else {
                    i += 1
                }
            case "-s", "--subtitle":
                if i + 1 < args.count {
                    subtitle = args[i + 1]
                    i += 2
                } else {
                    i += 1
                }
            case "--sound":
                if i + 1 < args.count {
                    sound = args[i + 1]
                    i += 2
                } else {
                    i += 1
                }
            case "-i", "--image":
                if i + 1 < args.count {
                    imageURL = args[i + 1]
                    i += 2
                } else {
                    i += 1
                }
            case "-o", "--open":
                if i + 1 < args.count {
                    openURL = args[i + 1]
                    i += 2
                } else {
                    i += 1
                }
            default:
                if message.isEmpty {
                    message = arg
                }
                i += 1
            }
        }
    }
}

func printHelp() {
    print("""
    notifier - A modern, minimal macOS notification tool
    
    Usage:
      notifier [options] [message]
    
    Options:
      -t, --title TEXT      Notification title
      -m, --message TEXT    Notification message
      -s, --subtitle TEXT   Notification subtitle
      --sound NAME          Sound name (default, Glass, Ping, etc.) or 'none'
      -i, --image PATH      Path or URL to image
      -o, --open URL        URL to open when clicked
      -h, --help           Show this help
    
    Examples:
      # Simple notification
      notifier "Hello World"
      
      # With title and message
      notifier -t "Alert" -m "Something happened"
      
      # With all options
      notifier -t "Success" -m "Build complete" -s "CI/CD" --sound Glass \\
               -i /path/to/icon.png -o http://example.com
      
      # Silent notification
      notifier -t "Info" -m "Background task done" --sound none
    """)
}

class NotificationDelegate: NSObject, NSUserNotificationCenterDelegate {
    var openURL: String?
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        if let urlString = openURL, let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
        exit(0)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

// Main execution
let args = Arguments(from: CommandLine.arguments)

if args.help {
    printHelp()
    exit(0)
}

if args.message.isEmpty && !args.help {
    print("Error: Message is required")
    printHelp()
    exit(1)
}

// Create and send notification using NSUserNotification
let notification = NSUserNotification()
notification.title = args.title
notification.informativeText = args.message

if let subtitle = args.subtitle {
    notification.subtitle = subtitle
}

// Set sound
if let soundName = args.sound, soundName != "none" {
    if soundName == "default" {
        notification.soundName = NSUserNotificationDefaultSoundName
    } else {
        // macOS system sounds don't have .aiff extension when using NSUserNotification
        notification.soundName = soundName
    }
}

// Handle image
if let imageURLString = args.imageURL {
    if let imageURL = URL(string: imageURLString) {
        // Try as URL
        if let image = NSImage(contentsOf: imageURL) {
            notification.contentImage = image
        }
    } else if FileManager.default.fileExists(atPath: imageURLString) {
        // Try as file path
        if let image = NSImage(contentsOfFile: imageURLString) {
            notification.contentImage = image
        }
    }
}

// Store URL for click handling
if let openURL = args.openURL {
    notification.userInfo = ["openURL": openURL]
}

// Set up delegate for handling clicks
let delegate = NotificationDelegate()
delegate.openURL = args.openURL
NSUserNotificationCenter.default.delegate = delegate

// Deliver notification
NSUserNotificationCenter.default.deliver(notification)

// Keep alive briefly to handle clicks
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    exit(0)
}

RunLoop.main.run()