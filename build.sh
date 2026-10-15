#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Caffeine"
BUNDLE_DIR="${APP_NAME}.app"
MACOS_DIR="${BUNDLE_DIR}/Contents/MacOS"
RESOURCES_DIR="${BUNDLE_DIR}/Contents/Resources"

echo "☕️ Building ${APP_NAME} for macOS (Apple Silicon & Intel)..."

# 1. Clean previous build
rm -rf "${BUNDLE_DIR}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 2. Generate Application Icons (.icns)
echo "🎨 Generating app icons..."
swift Scripts/generate_icons.swift
if command -v iconutil >/dev/null 2>&1 && [ -d "AppIcon.iconset" ]; then
    iconutil -c icns AppIcon.iconset -o "${RESOURCES_DIR}/AppIcon.icns"
    rm -rf AppIcon.iconset
    echo "✅ AppIcon.icns created successfully"
else
    echo "⚠️ iconutil not found or iconset missing, skipping icns generation"
fi

# 3. Create Info.plist
cat << 'EOF' > "${BUNDLE_DIR}/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Caffeine</string>
    <key>CFBundleIdentifier</key>
    <string>com.yunusemrecagan.caffeine</string>
    <key>CFBundleName</key>
    <string>Caffeine</string>
    <key>CFBundleDisplayName</key>
    <string>Caffeine</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026. All rights reserved.</string>
</dict>
</plist>
EOF

# 4. Compile Swift sources with optimizations
echo "⚡️ Compiling Swift source files..."
SWIFT_SOURCES=(
    Sources/Caffeine/CaffeineApp.swift
    Sources/Caffeine/CaffeineManager.swift
    Sources/Caffeine/Views/StatusHeroView.swift
    Sources/Caffeine/Views/PresetGridView.swift
    Sources/Caffeine/Views/CustomDurationView.swift
    Sources/Caffeine/Views/SettingsView.swift
    Sources/Caffeine/Views/MainContentView.swift
)

swiftc \
    -parse-as-library \
    -O \
    -framework SwiftUI \
    -framework AppKit \
    -framework IOKit \
    -framework UserNotifications \
    -framework Combine \
    "${SWIFT_SOURCES[@]}" \
    -o "${MACOS_DIR}/${APP_NAME}"

# 5. Ad-hoc Codesign
echo "🔏 Signing application bundle..."
codesign -s - --force --deep "${BUNDLE_DIR}"

echo "🎉 ${APP_NAME}.app successfully built at $(pwd)/${BUNDLE_DIR}!"
echo "👉 Uygulamayı başlatmak için: open Caffeine.app veya make run"
