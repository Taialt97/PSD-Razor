#!/bin/bash

APP_NAME="PSD Razor"
SOURCE_DIR="PSDRazorApp"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
EXECUTABLE="$APP_BUNDLE/Contents/MacOS/$APP_NAME"
PLIST="$APP_BUNDLE/Contents/Info.plist"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# 1. Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 2. Build psd_ockham from C source as a universal binary (arm64 + x86_64)
if [ -d "$REPO_ROOT/src" ]; then
    echo "Building psd_ockham universal binary from source..."
    clang \
        -arch arm64 -arch x86_64 \
        -O2 \
        -mmacosx-version-min=13.0 \
        -I"$REPO_ROOT/src/libpsd/include" \
        -I"$REPO_ROOT/src/libpsd/src" \
        "$REPO_ROOT/src/main.c" \
        "$REPO_ROOT/src/libpsd/src/descriptor.c" \
        "$REPO_ROOT/src/libpsd/src/file_header.c" \
        "$REPO_ROOT/src/libpsd/src/image_resource.c" \
        "$REPO_ROOT/src/libpsd/src/layer_mask.c" \
        "$REPO_ROOT/src/libpsd/src/linked_layer.c" \
        "$REPO_ROOT/src/libpsd/src/psd.c" \
        "$REPO_ROOT/src/libpsd/src/psd_system.c" \
        "$REPO_ROOT/src/libpsd/src/stream.c" \
        -o psd_ockham
    if [ $? -ne 0 ]; then
        echo "psd_ockham compilation failed!"
        exit 1
    fi
    chmod +x psd_ockham
    echo "psd_ockham built (universal: arm64 + x86_64)"
else
    echo "Using existing psd_ockham binary..."
fi

# 3. Compile Swift app as a universal binary (arm64 + x86_64)
echo "Compiling Swift sources (arm64)..."
swiftc \
    -parse-as-library \
    "$SOURCE_DIR/PSDRazorApp.swift" \
    "$SOURCE_DIR/ContentView.swift" \
    "$SOURCE_DIR/ShellRunner.swift" \
    -o "${EXECUTABLE}_arm64" \
    -target arm64-apple-macosx13.0

if [ $? -ne 0 ]; then
    echo "arm64 compilation failed!"
    exit 1
fi

echo "Compiling Swift sources (x86_64)..."
swiftc \
    -parse-as-library \
    "$SOURCE_DIR/PSDRazorApp.swift" \
    "$SOURCE_DIR/ContentView.swift" \
    "$SOURCE_DIR/ShellRunner.swift" \
    -o "${EXECUTABLE}_x86_64" \
    -target x86_64-apple-macosx13.0

if [ $? -ne 0 ]; then
    echo "x86_64 compilation failed!"
    exit 1
fi

echo "Creating universal Swift binary..."
lipo -create "${EXECUTABLE}_arm64" "${EXECUTABLE}_x86_64" -output "$EXECUTABLE"
rm -f "${EXECUTABLE}_arm64" "${EXECUTABLE}_x86_64"

if [ $? -ne 0 ]; then
    echo "lipo merge failed!"
    exit 1
fi

# 4. Copy resources
echo "Copying resources..."
cp psd_ockham "$APP_BUNDLE/Contents/Resources/"
chmod +x "$APP_BUNDLE/Contents/Resources/psd_ockham"

if [ -f "icon.icns" ]; then
    echo "Copying icon..."
    cp icon.icns "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# 4.5 Sign psd_ockham with Hardened Runtime
SIGN_IDENTITY="${SIGN_IDENTITY:--}"
echo "Signing psd_ockham (Hardened Runtime)..."
codesign --force --options runtime --sign "$SIGN_IDENTITY" "$APP_BUNDLE/Contents/Resources/psd_ockham"

# 5. Create Info.plist
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
    <string>com.psdrazor.psd-razor</string>
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

# 6. Code signing with Hardened Runtime
echo "Signing app..."
codesign --force --options runtime --sign "$SIGN_IDENTITY" "$APP_BUNDLE"

echo ""
echo "Build complete: $APP_BUNDLE"
echo "You can move this app to your Applications folder or run it directly."
