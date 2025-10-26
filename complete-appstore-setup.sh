#!/bin/bash

# TimeDonut - Complete App Store Setup Script
# Automates all possible steps for App Store submission

set -e

BUNDLE_ID="com.timedonut.app"
APP_NAME="TimeDonut"
CSR_FILE="TimeDonut_CSR.certSigningRequest"

echo "🍩 TimeDonut - Complete App Store Setup"
echo "=========================================="
echo ""

# ========================================
# Step 1: Certificate Setup
# ========================================
echo "📋 Step 1/6: Certificate Status Check"
echo "----------------------------------------"
echo ""

# Check current certificates
echo "Current certificates:"
security find-identity -v -p codesigning
echo ""

# Check if Mac App Distribution certificate exists
if security find-identity -v -p codesigning | grep -q "Mac App Distribution"; then
    echo "✅ Mac App Distribution certificate found!"
    DISTRIBUTION_IDENTITY=$(security find-identity -v -p codesigning | grep "Mac App Distribution" | head -1 | awk -F'"' '{print $2}')
    echo "   Identity: $DISTRIBUTION_IDENTITY"
    CERT_READY=true
else
    echo "⚠️  Mac App Distribution certificate not found"
    echo ""
    echo "Creating CSR (Certificate Signing Request)..."

    # Create CSR automatically
    cat > /tmp/csr_config.conf << 'EOF'
[ req ]
default_bits = 2048
distinguished_name = req_distinguished_name
prompt = no

[ req_distinguished_name ]
CN = TimeDonut Team
emailAddress = oowada.tomohiro@gmail.com
EOF

    if [ ! -f "${CSR_FILE}" ]; then
        openssl req -new -newkey rsa:2048 -nodes \
            -keyout TimeDonut_Private.key \
            -out "${CSR_FILE}" \
            -config /tmp/csr_config.conf
        echo "✅ CSR created: $(pwd)/${CSR_FILE}"
    else
        echo "✅ CSR already exists: $(pwd)/${CSR_FILE}"
    fi

    echo ""
    echo "Opening Apple Developer Portal pages..."
    open "https://developer.apple.com/account/resources/certificates/add"
    open "https://developer.apple.com/account/resources/identifiers/add/bundleId"

    echo ""
    echo "📖 Opening certificate setup instructions..."
    open CERTIFICATE_SETUP_INSTRUCTIONS.md

    echo ""
    echo "⏸️  WAITING: Please complete certificate setup"
    echo ""
    echo "Follow the instructions in CERTIFICATE_SETUP_INSTRUCTIONS.md"
    echo "Press Enter when you've installed the certificate..."
    read

    # Verify certificate installation
    if security find-identity -v -p codesigning | grep -q "Mac App Distribution"; then
        echo "✅ Certificate verified!"
        DISTRIBUTION_IDENTITY=$(security find-identity -v -p codesigning | grep "Mac App Distribution" | head -1 | awk -F'"' '{print $2}')
        CERT_READY=true
    else
        echo "❌ Certificate not found. Please install the certificate and try again."
        exit 1
    fi
fi

echo ""
echo "=========================================="

# ========================================
# Step 2: Xcode Project Configuration
# ========================================
echo "📋 Step 2/6: Xcode Project Configuration"
echo "----------------------------------------"
echo ""

# Check if Xcode is already open with our project
if pgrep -f "Xcode.*Package.swift" > /dev/null; then
    echo "✅ Xcode already open"
else
    echo "Opening Xcode project..."
    open Package.swift
    echo "⏳ Waiting for Xcode to load (5 seconds)..."
    sleep 5
fi

echo ""
echo "📖 Opening Xcode configuration guide..."
open -a TextEdit CERTIFICATE_SETUP_INSTRUCTIONS.md

echo ""
echo "Please configure Xcode Signing & Capabilities:"
echo "1. Select '${APP_NAME}' target"
echo "2. Go to 'Signing & Capabilities' tab"
echo "3. Select Team: Your Apple Developer Team"
echo "4. Signing Certificate: '${DISTRIBUTION_IDENTITY}'"
echo "5. Bundle Identifier: ${BUNDLE_ID}"
echo "6. Add capabilities: App Sandbox, Hardened Runtime"
echo ""
echo "Press Enter when Xcode configuration is complete..."
read

echo "✅ Xcode configuration completed"
echo ""
echo "=========================================="

# ========================================
# Step 3: Build App
# ========================================
echo "📋 Step 3/6: Building App"
echo "----------------------------------------"
echo ""

echo "🔨 Building TimeDonut..."
swift build
./create-app-bundle.sh

echo "✅ App built successfully"
echo ""
echo "=========================================="

# ========================================
# Step 4: Screenshots
# ========================================
echo "📋 Step 4/6: Screenshots"
echo "----------------------------------------"
echo ""

# Create screenshots directory
mkdir -p AppStoreMetadata/Screenshots

# Check if screenshots already exist
SCREENSHOT_COUNT=$(ls -1 AppStoreMetadata/Screenshots/*.png 2>/dev/null | wc -l)
if [ $SCREENSHOT_COUNT -ge 3 ]; then
    echo "✅ Screenshots already exist (${SCREENSHOT_COUNT} files)"
    read -p "Do you want to retake screenshots? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing screenshots"
    else
        echo "🚀 Launching app for screenshots..."
        open TimeDonut.app
        sleep 3
        echo ""
        echo "📸 Ready to take screenshots"
        ./take-screenshots.sh
    fi
else
    echo "🚀 Launching app for screenshots..."
    open TimeDonut.app
    sleep 3
    echo ""
    echo "📸 Ready to take screenshots"
    ./take-screenshots.sh
fi

echo "✅ Screenshots ready"
echo ""
echo "=========================================="

# ========================================
# Step 5: Build for App Store
# ========================================
echo "📋 Step 5/6: Building for App Store"
echo "----------------------------------------"
echo ""

if [ "$CERT_READY" = true ]; then
    echo "🏪 Building and signing for App Store..."

    # Clean previous build
    echo "Cleaning previous builds..."
    rm -rf build/
    mkdir -p build

    # Build in release mode
    echo "Building in release mode..."
    swift build -c release

    # Create app bundle
    echo "Creating app bundle..."
    ./create-app-bundle.sh

    # Sign the app
    echo "Signing app with: ${DISTRIBUTION_IDENTITY}"
    codesign --force --deep \
        --sign "${DISTRIBUTION_IDENTITY}" \
        --entitlements Sources/Resources/TimeDonut.entitlements \
        --options runtime \
        --timestamp \
        TimeDonut.app

    # Verify signature
    echo "Verifying signature..."
    codesign --verify --deep --strict --verbose=2 TimeDonut.app

    echo "✅ App signed successfully"

    # Create archive for submission
    echo "Creating archive..."
    ditto -c -k --keepParent TimeDonut.app build/TimeDonut.zip

    echo "✅ Archive created: build/TimeDonut.zip"
else
    echo "⚠️  Skipping App Store build (certificate not ready)"
fi

echo ""
echo "=========================================="

# ========================================
# Step 6: App Store Connect Setup
# ========================================
echo "📋 Step 6/6: App Store Connect"
echo "----------------------------------------"
echo ""

echo "Opening App Store Connect..."
open "https://appstoreconnect.apple.com/apps"

echo ""
echo "📖 Opening App Store Connect setup guide..."
open APP_STORE_CONNECT_SETUP.md

echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. ✅ Certificate installed: ${DISTRIBUTION_IDENTITY}"
echo "2. ✅ App built and signed"
echo "3. ✅ Screenshots ready: AppStoreMetadata/Screenshots/"
echo "4. 📖 Follow APP_STORE_CONNECT_SETUP.md to:"
echo "   - Create app in App Store Connect"
echo "   - Upload metadata and screenshots"
echo "   - Submit for review"
echo ""
echo "To upload to App Store:"
echo "  Option 1: Use Xcode Organizer (Product → Archive)"
echo "  Option 2: Use command line (./upload-to-appstore.sh)"
echo ""
echo "All setup files:"
echo "  - CSR: ${CSR_FILE}"
echo "  - Private Key: TimeDonut_Private.key"
echo "  - App Bundle: TimeDonut.app"
echo "  - Archive: build/TimeDonut.zip"
echo "  - Screenshots: AppStoreMetadata/Screenshots/"
echo "  - Metadata: AppStoreMetadata/"
echo ""
echo "Good luck with your App Store submission! 🍩"
echo ""
