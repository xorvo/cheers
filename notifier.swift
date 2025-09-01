#!/usr/bin/env swift

import Foundation
import UserNotifications
import AppKit

// Notification handler for clicks
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var openURL: String?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                didReceive response: UNNotificationResponse, 
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let urlString = openURL, let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
        completionHandler()
        exit(0)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification, 
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(macOS 11.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.sound, .badge])
        }
    }
}

class Notifier {
    private let center = UNUserNotificationCenter.current()
    private let delegate = NotificationDelegate()
    
    init() {
        center.delegate = delegate
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting authorization: \(error)")
            }
            completion(granted)
        }
    }
    
    func send(title: String, 
              message: String, 
              subtitle: String? = nil,
              sound: String? = nil,
              imageURL: String? = nil,
              openURL: String? = nil) {
        
        delegate.openURL = openURL
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        
        // Set sound
        if let soundName = sound, soundName != "none" {
            if soundName == "default" {
                content.sound = .default
            } else {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(soundName).aiff"))
            }
        }
        
        // Add image if provided
        if let imageURLString = imageURL {
            if let imageURL = URL(string: imageURLString),
               let attachment = try? UNNotificationAttachment(identifier: "image", url: imageURL, options: nil) {
                content.attachments = [attachment]
            } else if FileManager.default.fileExists(atPath: imageURLString) {
                let imageURL = URL(fileURLWithPath: imageURLString)
                if let attachment = try? UNNotificationAttachment(identifier: "image", url: imageURL, options: nil) {
                    content.attachments = [attachment]
                }
            }
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        center.add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
                exit(1)
            }
            // Keep alive briefly to handle clicks
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        }
    }
}

// Command line argument parser
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
                // If no flag, treat as message
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

// Create and send notification
let notifier = Notifier()

notifier.requestAuthorization { granted in
    if granted {
        notifier.send(
            title: args.title,
            message: args.message,
            subtitle: args.subtitle,
            sound: args.sound,
            imageURL: args.imageURL,
            openURL: args.openURL
        )
        RunLoop.main.run()
    } else {
        print("Notification permission denied")
        print("Please enable notifications in System Settings > Notifications")
        exit(1)
    }
}

RunLoop.main.run()