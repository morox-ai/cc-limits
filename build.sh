#!/usr/bin/env bash
set -euo pipefail

APP_NAME="ClaudeCodeLimits"
BUNDLE="${APP_NAME}.app"
MACOS_DIR="${BUNDLE}/Contents/MacOS"
INFO_PLIST="${BUNDLE}/Contents/Info.plist"
BUNDLE_VERSION="1.0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

mkdir -p "$MACOS_DIR"

export MACOSX_DEPLOYMENT_TARGET=12.0
swiftc main.swift -o "${MACOS_DIR}/${APP_NAME}"

cat > "$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>${APP_NAME}</string>
	<key>CFBundleExecutable</key>
	<string>${APP_NAME}</string>
	<key>CFBundleIdentifier</key>
	<string>ai.morox.cc-limits</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>${BUNDLE_VERSION}</string>
	<key>CFBundleVersion</key>
	<string>${BUNDLE_VERSION}</string>
	<key>LSUIElement</key>
	<true/>
	<key>LSMinimumSystemVersion</key>
	<string>12.0</string>
</dict>
</plist>
PLIST

echo "Built ${BUNDLE}"
