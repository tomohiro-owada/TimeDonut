#!/bin/bash

# TimeDonut - App Store Connect Upload Script
# Uploads the app to App Store Connect using altool or notarytool

set -e

APP_NAME="TimeDonut"
BUNDLE_ID="com.timedonut.app"
APP_PATH="${APP_NAME}.app"

echo "📤 TimeDonut - App Store Connect Upload"
echo "======================================="
echo ""

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ ${APP_PATH} が見つかりません"
    echo "先に ./build-for-appstore.sh を実行してください"
    exit 1
fi

# Check app signature
echo "🔐 アプリの署名を確認中..."
codesign --verify --deep --strict --verbose=2 "$APP_PATH" 2>&1

if [ $? -ne 0 ]; then
    echo "❌ アプリの署名が無効です"
    exit 1
fi

echo "✅ 署名確認完了"
echo ""

# Create zip for notarization
ZIP_FILE="${APP_NAME}.zip"
echo "📦 ZIPファイルを作成中..."
ditto -c -k --keepParent "$APP_PATH" "$ZIP_FILE"
echo "✅ 作成完了: $ZIP_FILE"
echo ""

echo "======================================"
echo "次のステップ:"
echo ""
echo "方法1: Xcodeを使用（推奨）"
echo "------------------------------------"
echo "1. Xcodeで Package.swift を開く:"
echo "   open Package.swift"
echo ""
echo "2. Product → Archive を実行"
echo ""
echo "3. Organizer で 'Distribute App' をクリック"
echo ""
echo "4. 'App Store Connect' を選択してアップロード"
echo ""
echo ""
echo "方法2: xcrun notarytool を使用"
echo "------------------------------------"
echo "1. App Store Connect API Keyを作成:"
echo "   https://appstoreconnect.apple.com/access/api"
echo ""
echo "2. API Keyを保存:"
echo "   xcrun notarytool store-credentials \"AC_PASSWORD\" \\"
echo "     --apple-id \"your@email.com\" \\"
echo "     --team-id \"TEAM_ID\" \\"
echo "     --password \"app-specific-password\""
echo ""
echo "3. Notarization（公証）を実行:"
echo "   xcrun notarytool submit $ZIP_FILE \\"
echo "     --keychain-profile \"AC_PASSWORD\" \\"
echo "     --wait"
echo ""
echo "4. Staple（ステープル）を実行:"
echo "   xcrun stapler staple $APP_PATH"
echo ""
echo ""
echo "方法3: Transporter アプリを使用"
echo "------------------------------------"
echo "1. App Store Connect で .pkg を作成"
echo ""
echo "2. Transporter アプリで .pkg をアップロード"
echo "   https://apps.apple.com/app/transporter/id1450874784"
echo ""
echo ""
echo "ファイル準備完了:"
echo "  - ${APP_PATH}"
echo "  - ${ZIP_FILE}"
echo ""
