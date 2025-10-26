#!/bin/bash

# TimeDonut Build and Archive Script
# Builds the app for App Store distribution

set -e

# Configuration
APP_NAME="TimeDonut"
SCHEME="${APP_NAME}"
CONFIGURATION="Release"
ARCHIVE_PATH="build/${APP_NAME}.xcarchive"
EXPORT_PATH="build/AppStore"
BUNDLE_ID="com.timedonut.app"

echo "🍩 TimeDonut - App Store Build Script"
echo "======================================"
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcodeがインストールされていません"
    exit 1
fi

echo "✅ Xcode version: $(xcodebuild -version | head -1)"
echo ""

# Check for signing identity
echo "🔐 署名証明書を確認中..."
DISTRIBUTION_IDENTITY=$(security find-identity -v -p codesigning | grep "Mac App Distribution" | head -1 | awk -F'"' '{print $2}')

if [ -z "$DISTRIBUTION_IDENTITY" ]; then
    echo "⚠️  Mac App Distribution証明書が見つかりません"
    echo ""
    echo "以下の手順で証明書を作成してください:"
    echo "1. https://developer.apple.com/account/resources/certificates にアクセス"
    echo "2. + ボタンをクリック"
    echo "3. 'Mac App Distribution' を選択"
    echo "4. CSRファイルをアップロード（Keychain Accessで作成）"
    echo "5. 証明書をダウンロードしてインストール"
    echo ""

    # Show available identities
    echo "利用可能な署名証明書:"
    security find-identity -v -p codesigning
    echo ""

    read -p "開発用証明書でビルドを続行しますか？ (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi

    # Use development identity for now
    DISTRIBUTION_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Development" | head -1 | awk -F'"' '{print $2}')

    if [ -z "$DISTRIBUTION_IDENTITY" ]; then
        echo "❌ 署名証明書が見つかりません"
        exit 1
    fi

    echo "⚠️  開発用証明書を使用: $DISTRIBUTION_IDENTITY"
    echo "注意: App Storeへのアップロードには配布用証明書が必要です"
else
    echo "✅ 配布用証明書: $DISTRIBUTION_IDENTITY"
fi

echo ""

# Clean build directory
echo "🧹 ビルドディレクトリをクリーン..."
rm -rf build/
mkdir -p build

# Build using swift build first
echo "📦 Swiftパッケージをビルド中..."
swift build -c release

# Create .app bundle
echo "🎁 .appバンドルを作成中..."
./create-app-bundle.sh

# Sign the app bundle
echo "🔏 アプリに署名中..."
codesign --force --deep --sign "$DISTRIBUTION_IDENTITY" \
    --entitlements Sources/Resources/TimeDonut.entitlements \
    --options runtime \
    --timestamp \
    TimeDonut.app

# Verify signature
echo "✅ 署名を検証中..."
codesign --verify --deep --strict --verbose=2 TimeDonut.app

echo ""
echo "======================================"
echo "✅ ビルド完了"
echo ""
echo "次のステップ:"
echo ""
echo "1. アプリをテスト:"
echo "   open TimeDonut.app"
echo ""
echo "2. DMGを作成（オプション）:"
echo "   ./create-dmg.sh"
echo ""
echo "3. App Store Connectにアップロード:"
echo "   Xcodeで Package.swift を開き、Archive を作成してください"
echo "   または、notarytool を使用してください"
echo ""
echo "4. Notarization（公証）:"
echo "   xcrun notarytool submit TimeDonut.app.zip --keychain-profile \"AC_PASSWORD\" --wait"
echo ""
