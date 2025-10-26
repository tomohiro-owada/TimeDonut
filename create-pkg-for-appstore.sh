#!/bin/bash

# TimeDonut - Create PKG for App Store Upload
# Creates a signed .pkg file for App Store submission

set -e

APP_NAME="TimeDonut"
BUNDLE_ID="com.timedonut.app"
VERSION="1.0.0"
BUILD_NUMBER="1"
PKG_DIR="build"
PKG_NAME="${APP_NAME}-${VERSION}.pkg"

echo "📦 Creating App Store package for ${APP_NAME}"
echo "=========================================="
echo ""

# Check if app exists
if [ ! -d "${APP_NAME}.app" ]; then
    echo "❌ ${APP_NAME}.app not found!"
    echo "Building app first..."
    swift build -c release
    ./create-app-bundle.sh
fi

echo "✅ App bundle found: ${APP_NAME}.app"
echo ""

# Get signing identity
echo "🔍 Available signing identities:"
security find-identity -v -p codesigning

echo ""
echo "Select signing identity:"
echo "1) Apple Development (for testing)"
echo "2) 3rd Party Mac Developer Application (for App Store)"
echo ""
read -p "Choose (1 or 2): " CHOICE

if [ "$CHOICE" = "1" ]; then
    SIGNING_IDENTITY="Apple Development"
    echo "⚠️  Note: Development signed apps can be uploaded but may not pass review"
elif [ "$CHOICE" = "2" ]; then
    SIGNING_IDENTITY="3rd Party Mac Developer Application"
else
    echo "❌ Invalid choice"
    exit 1
fi

# Find the full identity
IDENTITY=$(security find-identity -v -p codesigning | grep "${SIGNING_IDENTITY}" | head -1 | awk -F'"' '{print $2}')

if [ -z "$IDENTITY" ]; then
    echo "❌ ${SIGNING_IDENTITY} certificate not found!"
    exit 1
fi

echo "✅ Using identity: ${IDENTITY}"
echo ""

# Re-sign the app
echo "🔐 Signing app..."
codesign --force --deep \
    --sign "${IDENTITY}" \
    --entitlements Sources/Resources/TimeDonut.entitlements \
    --options runtime \
    --timestamp \
    "${APP_NAME}.app"

echo "✅ App signed"
echo ""

# Verify signature
echo "🔍 Verifying signature..."
codesign --verify --deep --strict --verbose=2 "${APP_NAME}.app"
echo "✅ Signature verified"
echo ""

# Create build directory
mkdir -p "${PKG_DIR}"

# Create PKG
echo "📦 Creating PKG..."
productbuild --component "${APP_NAME}.app" /Applications \
    --sign "${IDENTITY}" \
    "${PKG_DIR}/${PKG_NAME}"

echo "✅ PKG created: ${PKG_DIR}/${PKG_NAME}"
echo ""

# Package info
PKG_SIZE=$(du -h "${PKG_DIR}/${PKG_NAME}" | awk '{print $1}')
echo "=========================================="
echo "📊 Package Information"
echo "=========================================="
echo "File: ${PKG_DIR}/${PKG_NAME}"
echo "Size: ${PKG_SIZE}"
echo "Bundle ID: ${BUNDLE_ID}"
echo "Version: ${VERSION}"
echo "Build: ${BUILD_NUMBER}"
echo "Identity: ${IDENTITY}"
echo ""

echo "=========================================="
echo "🚀 Next Steps: Upload to App Store"
echo "=========================================="
echo ""
echo "Option 1: Use Transporter app (Recommended)"
echo "  1. Open Transporter app"
echo "  2. Sign in with your Apple ID"
echo "  3. Drag and drop: ${PKG_DIR}/${PKG_NAME}"
echo "  4. Click 'Deliver'"
echo ""
echo "Option 2: Use command line"
echo "  xcrun altool --upload-app -f ${PKG_DIR}/${PKG_NAME} \\"
echo "    --type macos \\"
echo "    -u YOUR_APPLE_ID \\"
echo "    -p YOUR_APP_SPECIFIC_PASSWORD"
echo ""
echo "Option 3: Use App Store Connect API (requires API key)"
echo ""
echo "After upload, wait 5-10 minutes for processing."
echo "Then return to App Store Connect to select the build."
echo ""
