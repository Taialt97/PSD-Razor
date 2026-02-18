#!/bin/bash

APP_NAME="PSD Razor"
SOURCE_DIR="PSDrazorApp"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
EXECUTABLE="$APP_BUNDLE/Contents/MacOS/$APP_NAME"
PLIST="$APP_BUNDLE/Contents/Info.plist"

# 1. Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 2. Compile Swift files
echo "Compiling Swift sources..."
swiftc \
    -parse-as-library \
    "$SOURCE_DIR/PSDRazorApp.swift" \
    "$SOURCE_DIR/ContentView.swift" \
    "$SOURCE_DIR/ShellRunner.swift" \
    -o "$EXECUTABLE" \
    -target arm64-apple-macosx13.0

if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

# 2.5 Copy resources
echo "Copying resources..."
cp psd_ockham "$APP_BUNDLE/Contents/Resources/"
chmod +x "$APP_BUNDLE/Contents/Resources/psd_ockham"

if [ -f "icon.icns" ]; then
    echo "Copying icon..."
    cp icon.icns "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# 3. Create Info.plist
echo "Creating Info.plist..."
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.$APP_NAME</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 4. Ad-hoc code signing (required for arm64)
echo "Signing app..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "Build complete: $APP_BUNDLE"
echo "You can move this app to your Applications folder or run it directly."
