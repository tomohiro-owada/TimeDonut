#!/bin/bash

# TimeDonut App Bundle Creator
# Creates a macOS .app bundle from the Swift Package Manager build

set -e

# Configuration
APP_NAME="TimeDonut"
BUILD_DIR=".build/debug"
BUNDLE_DIR="${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "🍩 Creating ${APP_NAME}.app bundle..."

# Clean up old bundle if it exists
if [ -d "${BUNDLE_DIR}" ]; then
    echo "🗑️  Removing old bundle..."
    rm -rf "${BUNDLE_DIR}"
fi

# Create directory structure
echo "📁 Creating bundle structure..."
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy executable
echo "📦 Copying executable..."
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"

# Copy Info.plist
echo "📝 Copying Info.plist..."
cp "Sources/Resources/Info.plist" "${CONTENTS_DIR}/"

# Process Info.plist variables
sed -i '' "s/\$(EXECUTABLE_NAME)/${APP_NAME}/g" "${CONTENTS_DIR}/Info.plist"
sed -i '' "s/\$(PRODUCT_NAME)/${APP_NAME}/g" "${CONTENTS_DIR}/Info.plist"

# Copy Assets.xcassets (for app icon)
if [ -d "Sources/Resources/Assets.xcassets" ]; then
    echo "🎨 Copying app icon..."
    # Create .icns file from Assets.xcassets
    # We'll use the 1024.png directly for now
    if [ -f "Sources/Resources/Assets.xcassets/AppIcon.appiconset/1024.png" ]; then
        # Create temporary iconset directory
        TEMP_ICONSET="AppIcon.iconset"
        mkdir -p "${TEMP_ICONSET}"

        # Copy icons with proper naming for iconutil
        cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/16.png" "${TEMP_ICONSET}/icon_16x16.png"
        cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/32.png" "${TEMP_ICONSET}/icon_16x16@2x.png"
        cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/32.png" "${TEMP_ICONSET}/icon_32x32.png"
        cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/64.png" "${TEMP_ICONSET}/icon_32x32@2x.png"
        cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/128.png" "${TEMP_ICONSET}/icon_128x128.png"
        cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/256.png" "${TEMP_ICONSET}/icon_128x128@2x.png"
        cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/256.png" "${TEMP_ICONSET}/icon_256x256.png"
        cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/512.png" "${TEMP_ICONSET}/icon_256x256@2x.png"
        cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/512.png" "${TEMP_ICONSET}/icon_512x512.png"
        cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/1024.png" "${TEMP_ICONSET}/icon_512x512@2x.png"

        # Create .icns file
        iconutil -c icns "${TEMP_ICONSET}" -o "${RESOURCES_DIR}/AppIcon.icns"

        # Clean up
        rm -rf "${TEMP_ICONSET}"

        echo "✅ App icon created: ${RESOURCES_DIR}/AppIcon.icns"
    fi
fi

# Copy other resources if needed
if [ -d "${BUILD_DIR}/${APP_NAME}_${APP_NAME}.bundle" ]; then
    echo "📦 Copying resource bundle..."
    cp -r "${BUILD_DIR}/${APP_NAME}_${APP_NAME}.bundle" "${RESOURCES_DIR}/"
fi

# Set executable permissions
chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "✅ ${BUNDLE_DIR} created successfully!"
echo ""
echo "To run the app:"
echo "  open ${BUNDLE_DIR}"
echo ""
echo "To install to Applications:"
echo "  cp -r ${BUNDLE_DIR} /Applications/"
