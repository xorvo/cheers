EXECUTABLE = notifier
BUILD_DIR = build

.PHONY: all clean build install

all: build

build: clean
	@echo "Building notifier CLI..."
	@mkdir -p $(BUILD_DIR)
	swiftc notifier.swift -o $(BUILD_DIR)/$(EXECUTABLE) -framework AppKit
	@echo "✅ Build complete: $(BUILD_DIR)/$(EXECUTABLE)"

install: build
	@echo "Installing to /usr/local/bin..."
	@mkdir -p /usr/local/bin
	@cp $(BUILD_DIR)/$(EXECUTABLE) /usr/local/bin/
	@chmod +x /usr/local/bin/$(EXECUTABLE)
	@echo "✅ Installed to /usr/local/bin/$(EXECUTABLE)"

clean:
	rm -rf $(BUILD_DIR)

test: build
	@echo "Testing notification..."
	$(BUILD_DIR)/$(EXECUTABLE) -t "Test" -m "Notifier is working!" --sound Glass