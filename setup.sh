#!/bin/bash
#
# Generates the Xcode project for PSD Razor.
# Run this after cloning the repo:  ./setup.sh
#

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GUI_DIR="$SCRIPT_DIR/Photoshop Reducer GUI"

echo "=== PSD Razor - Project Setup ==="
echo ""

# 1. Check for xcodegen, install if missing
if ! command -v xcodegen &>/dev/null; then
    echo "xcodegen not found. Installing via Homebrew..."
    if ! command -v brew &>/dev/null; then
        echo "Error: Homebrew is required. Install it from https://brew.sh"
        exit 1
    fi
    brew install xcodegen
    echo ""
fi

# 2. Build psd_ockham from C source as a universal binary
if [ -d "$SCRIPT_DIR/src" ]; then
    echo "Building psd_ockham (universal: arm64 + x86_64)..."
    clang \
        -arch arm64 -arch x86_64 \
        -O2 \
        -mmacosx-version-min=13.0 \
        -I"$SCRIPT_DIR/src/libpsd/include" \
        -I"$SCRIPT_DIR/src/libpsd/src" \
        "$SCRIPT_DIR/src/main.c" \
        "$SCRIPT_DIR/src/libpsd/src/descriptor.c" \
        "$SCRIPT_DIR/src/libpsd/src/file_header.c" \
        "$SCRIPT_DIR/src/libpsd/src/image_resource.c" \
        "$SCRIPT_DIR/src/libpsd/src/layer_mask.c" \
        "$SCRIPT_DIR/src/libpsd/src/linked_layer.c" \
        "$SCRIPT_DIR/src/libpsd/src/psd.c" \
        "$SCRIPT_DIR/src/libpsd/src/psd_system.c" \
        "$SCRIPT_DIR/src/libpsd/src/stream.c" \
        -o "$GUI_DIR/psd_ockham"
    chmod +x "$GUI_DIR/psd_ockham"
    echo "Done."
    echo ""
fi

# 3. Generate the Xcode project
echo "Generating Xcode project..."
cd "$GUI_DIR"
xcodegen generate
echo ""

echo "=== Setup complete ==="
echo ""
echo "Open the project:"
echo "  open \"$GUI_DIR/PSD Razor.xcodeproj\""
echo ""
echo "Or build from the command line:"
echo "  cd \"Photoshop Reducer GUI\" && bash build_native_app.sh"
