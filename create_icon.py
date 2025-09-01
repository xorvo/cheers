#!/usr/bin/env python3

import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_notification_icon(size):
    """Create a simple, elegant notification bell icon"""
    # Create a new image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Define colors - gradient purple/blue like modern macOS icons
    main_color = (88, 86, 214)  # Nice purple-blue
    shadow_color = (68, 66, 194)
    highlight_color = (108, 106, 234)
    
    # Calculate dimensions
    padding = size * 0.15
    bell_width = size - (padding * 2)
    bell_height = bell_width * 0.8
    
    # Bell body coordinates
    bell_x = padding
    bell_y = padding + (size * 0.05)
    
    # Draw bell shadow/depth
    shadow_offset = size * 0.02
    bell_body = [
        (bell_x + shadow_offset, bell_y + bell_height * 0.3 + shadow_offset),
        (bell_x + bell_width * 0.15 + shadow_offset, bell_y + bell_height * 0.15 + shadow_offset),
        (bell_x + bell_width * 0.3 + shadow_offset, bell_y + shadow_offset),
        (bell_x + bell_width * 0.7 + shadow_offset, bell_y + shadow_offset),
        (bell_x + bell_width * 0.85 + shadow_offset, bell_y + bell_height * 0.15 + shadow_offset),
        (bell_x + bell_width + shadow_offset, bell_y + bell_height * 0.3 + shadow_offset),
        (bell_x + bell_width + shadow_offset, bell_y + bell_height * 0.7 + shadow_offset),
        (bell_x + bell_width * 0.85 + shadow_offset, bell_y + bell_height * 0.8 + shadow_offset),
        (bell_x + bell_width * 0.15 + shadow_offset, bell_y + bell_height * 0.8 + shadow_offset),
        (bell_x + shadow_offset, bell_y + bell_height * 0.7 + shadow_offset),
    ]
    draw.polygon(bell_body, fill=(*shadow_color, 50))
    
    # Draw main bell body
    bell_body = [
        (bell_x, bell_y + bell_height * 0.3),
        (bell_x + bell_width * 0.15, bell_y + bell_height * 0.15),
        (bell_x + bell_width * 0.3, bell_y),
        (bell_x + bell_width * 0.7, bell_y),
        (bell_x + bell_width * 0.85, bell_y + bell_height * 0.15),
        (bell_x + bell_width, bell_y + bell_height * 0.3),
        (bell_x + bell_width, bell_y + bell_height * 0.7),
        (bell_x + bell_width * 0.85, bell_y + bell_height * 0.8),
        (bell_x + bell_width * 0.15, bell_y + bell_height * 0.8),
        (bell_x, bell_y + bell_height * 0.7),
    ]
    
    # Create gradient effect
    for i in range(int(bell_height * 0.3)):
        t = i / (bell_height * 0.3)
        color = tuple(int(highlight_color[j] * (1-t) + main_color[j] * t) for j in range(3))
        offset_body = [
            (bell_x, bell_y + bell_height * 0.3 + i),
            (bell_x + bell_width * 0.15, bell_y + bell_height * 0.15 + i),
            (bell_x + bell_width * 0.3, bell_y + i),
            (bell_x + bell_width * 0.7, bell_y + i),
            (bell_x + bell_width * 0.85, bell_y + bell_height * 0.15 + i),
            (bell_x + bell_width, bell_y + bell_height * 0.3 + i),
            (bell_x + bell_width, bell_y + bell_height * 0.3 + i + 1),
            (bell_x, bell_y + bell_height * 0.3 + i + 1),
        ]
        draw.polygon(offset_body, fill=(*color, 255))
    
    # Draw main bell
    draw.polygon(bell_body, fill=main_color)
    
    # Draw bell clapper (circle at bottom)
    clapper_radius = bell_width * 0.08
    clapper_x = bell_x + bell_width * 0.5
    clapper_y = bell_y + bell_height * 0.9
    draw.ellipse(
        [clapper_x - clapper_radius, clapper_y - clapper_radius,
         clapper_x + clapper_radius, clapper_y + clapper_radius],
        fill=main_color
    )
    
    # Draw notification dot (red circle in top right)
    if size >= 32:  # Only for larger icons
        dot_radius = size * 0.12
        dot_x = bell_x + bell_width * 0.85
        dot_y = bell_y + bell_height * 0.15
        # Shadow
        draw.ellipse(
            [dot_x - dot_radius + 1, dot_y - dot_radius + 1,
             dot_x + dot_radius + 1, dot_y + dot_radius + 1],
            fill=(0, 0, 0, 50)
        )
        # Main dot
        draw.ellipse(
            [dot_x - dot_radius, dot_y - dot_radius,
             dot_x + dot_radius, dot_y + dot_radius],
            fill=(255, 59, 48)  # Apple's red color
        )
    
    return img

def create_iconset():
    """Create all required icon sizes for macOS"""
    sizes = [
        (16, "16x16"),
        (32, "16x16@2x"),
        (32, "32x32"),
        (64, "32x32@2x"),
        (128, "128x128"),
        (256, "128x128@2x"),
        (256, "256x256"),
        (512, "256x256@2x"),
        (512, "512x512"),
        (1024, "512x512@2x"),
    ]
    
    # Create iconset directory
    iconset_dir = "Notifier.iconset"
    os.makedirs(iconset_dir, exist_ok=True)
    
    for size, name in sizes:
        img = create_notification_icon(size)
        img.save(f"{iconset_dir}/icon_{name}.png")
        print(f"Created icon_{name}.png")
    
    return iconset_dir

# Check if Pillow is installed
try:
    create_iconset()
    print("\n✅ Iconset created successfully!")
    print("\nTo create .icns file, run:")
    print("iconutil -c icns Notifier.iconset")
    print("\nThen copy to app bundle:")
    print("cp Notifier.icns build/Notifier.app/Contents/Resources/")
except ImportError:
    print("❌ Pillow not installed. Creating simple icon using sips...")
    
    # Fallback: Create a simple colored square using sips
    os.makedirs("Notifier.iconset", exist_ok=True)
    
    # Create a simple 1024x1024 colored image using sips
    print("Creating basic icon...")
    os.system("""
    # Create a simple purple square as base
    echo 'P3\n1024 1024\n255\n' > temp.ppm
    python3 -c "for i in range(1024*1024): print('88 86 214')" >> temp.ppm
    sips -s format png temp.ppm --out Notifier.iconset/icon_512x512@2x.png
    
    # Create other sizes
    sips -z 512 512 Notifier.iconset/icon_512x512@2x.png --out Notifier.iconset/icon_512x512.png
    sips -z 512 512 Notifier.iconset/icon_512x512@2x.png --out Notifier.iconset/icon_256x256@2x.png
    sips -z 256 256 Notifier.iconset/icon_512x512@2x.png --out Notifier.iconset/icon_256x256.png
    sips -z 256 256 Notifier.iconset/icon_512x512@2x.png --out Notifier.iconset/icon_128x128@2x.png
    sips -z 128 128 Notifier.iconset/icon_512x512@2x.png --out Notifier.iconset/icon_128x128.png
    sips -z 64 64 Notifier.iconset/icon_512x512@2x.png --out Notifier.iconset/icon_32x32@2x.png
    sips -z 32 32 Notifier.iconset/icon_512x512@2x.png --out Notifier.iconset/icon_32x32.png
    sips -z 32 32 Notifier.iconset/icon_512x512@2x.png --out Notifier.iconset/icon_16x16@2x.png
    sips -z 16 16 Notifier.iconset/icon_512x512@2x.png --out Notifier.iconset/icon_16x16.png
    
    rm temp.ppm
    
    # Create icns
    iconutil -c icns Notifier.iconset
    """)
    print("Basic icon created!")