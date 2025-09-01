#!/bin/bash

echo "🧪 Testing Notifier App"
echo "======================"
echo ""

NOTIFIER="./build/Notifier.app/Contents/MacOS/notifier"

if [ ! -f "$NOTIFIER" ]; then
    echo "❌ Notifier not found. Run 'make build' first."
    exit 1
fi

echo "1️⃣ Testing simple notification..."
$NOTIFIER "Hello from Notifier!"
sleep 2

echo "2️⃣ Testing with title..."
$NOTIFIER -t "Test Title" -m "This is the message"
sleep 2

echo "3️⃣ Testing with subtitle..."
$NOTIFIER -t "Complete" -m "Task finished" -s "All tests passed"
sleep 2

echo "4️⃣ Testing with sound..."
$NOTIFIER -t "Sound Test" -m "Playing Glass sound" --sound Glass
sleep 2

echo "5️⃣ Testing silent notification..."
$NOTIFIER -t "Silent" -m "No sound" --sound none
sleep 2

echo "6️⃣ Testing with URL..."
$NOTIFIER -t "Click Me" -m "Opens localhost" -o "http://localhost:8080"
sleep 2

echo ""
echo "✅ Test complete!"
echo ""
echo "Note: If you see permission errors:"
echo "1. Open System Preferences > Security & Privacy > Notifications"
echo "2. Look for 'Terminal' or 'Notifier' and enable notifications"
echo "3. Or try: codesign -s - --force --deep build/Notifier.app"