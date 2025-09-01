APPNAME = Notifier
BUNDLE_ID = com.webhook.notifier
EXECUTABLE = notifier
BUILD_DIR = build

.PHONY: all clean build install

all: build

build: clean
	@echo "Building Swift executable..."
	swiftc notifier.swift -o $(EXECUTABLE) -framework UserNotifications -framework AppKit
	
	@echo "Creating app bundle..."
	mkdir -p $(BUILD_DIR)/$(APPNAME).app/Contents/MacOS
	mkdir -p $(BUILD_DIR)/$(APPNAME).app/Contents/Resources
	
	@echo "Moving executable..."
	mv $(EXECUTABLE) $(BUILD_DIR)/$(APPNAME).app/Contents/MacOS/
	
	@echo "Creating Info.plist..."
	@printf '<?xml version="1.0" encoding="UTF-8"?>\n' > $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '<plist version="1.0">\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '<dict>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <key>CFBundleExecutable</key>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <string>notifier</string>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <key>CFBundleIdentifier</key>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <string>com.webhook.notifier</string>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <key>CFBundleName</key>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <string>Notifier</string>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <key>CFBundlePackageType</key>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <string>APPL</string>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <key>CFBundleShortVersionString</key>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <string>1.0.0</string>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <key>CFBundleVersion</key>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <string>1</string>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <key>CFBundleIconFile</key>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <string>Notifier</string>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <key>LSMinimumSystemVersion</key>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <string>10.14</string>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <key>LSUIElement</key>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <true/>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <key>NSUserNotificationAlertStyle</key>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '    <string>alert</string>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '</dict>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	@printf '</plist>\n' >> $(BUILD_DIR)/$(APPNAME).app/Contents/Info.plist
	
	@echo "Creating symlink for command-line access..."
	ln -sf $(APPNAME).app/Contents/MacOS/$(EXECUTABLE) $(BUILD_DIR)/$(EXECUTABLE)
	
	@echo "✅ Build complete: $(BUILD_DIR)/$(APPNAME).app"
	@echo "Command-line tool: $(BUILD_DIR)/$(EXECUTABLE)"

install: build
	@echo "Installing to /usr/local/bin..."
	sudo cp $(BUILD_DIR)/$(EXECUTABLE) /usr/local/bin/
	sudo chmod +x /usr/local/bin/$(EXECUTABLE)
	@echo "✅ Installed to /usr/local/bin/$(EXECUTABLE)"

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(EXECUTABLE)

test: build
	@echo "Testing notification..."
	$(BUILD_DIR)/$(EXECUTABLE) -t "Test" -m "Notifier is working!" --sound Glass