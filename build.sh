#!/bin/bash
set -euo pipefail

APP_NAME="ccpaste"
BUILD_DIR=".build/release"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "Building $APP_NAME..."
swift build -c release

echo "Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "Sources/ccpaste/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

echo "App bundle created at: $APP_BUNDLE"
echo "To install: cp -r $APP_BUNDLE /Applications/"
