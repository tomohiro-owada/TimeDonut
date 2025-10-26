#!/bin/bash

# TimeDonut DMG Creator
# Creates a distributable DMG file for the app

set -e

APP_NAME="TimeDonut"
DMG_NAME="${APP_NAME}-1.0.0"
VOLUME_NAME="${APP_NAME}"

echo "💿 TimeDonut DMG Creator"
echo "========================"
echo ""

# Check if app bundle exists
if [ ! -d "${APP_NAME}.app" ]; then
    echo "❌ ${APP_NAME}.app が見つかりません"
    echo "先に ./build-for-appstore.sh を実行してください"
    exit 1
fi

# Create temporary directory
TMP_DMG_DIR="tmp_dmg"
rm -rf "${TMP_DMG_DIR}"
mkdir -p "${TMP_DMG_DIR}"

echo "📦 DMGを準備中..."

# Copy app to temp directory
cp -r "${APP_NAME}.app" "${TMP_DMG_DIR}/"

# Create Applications symlink
ln -s /Applications "${TMP_DMG_DIR}/Applications"

# Add README
cat > "${TMP_DMG_DIR}/README.txt" << 'EOF'
TimeDonut をインストールするには:

1. TimeDonut.app を Applications フォルダにドラッグ&ドロップ
2. Applications フォルダから TimeDonut を起動
3. Googleアカウントでサインイン

詳細: https://tomohiro-owada.github.io/TimeDonut/

サポート: https://github.com/tomohiro-owada/TimeDonut/issues
EOF

echo "💿 DMGを作成中..."

# Create DMG
hdiutil create -volname "${VOLUME_NAME}" \
    -srcfolder "${TMP_DMG_DIR}" \
    -ov \
    -format UDZO \
    "${DMG_NAME}.dmg"

# Clean up
rm -rf "${TMP_DMG_DIR}"

echo ""
echo "✅ DMG作成完了: ${DMG_NAME}.dmg"
echo ""
echo "次のステップ:"
echo "1. DMGをテスト:"
echo "   open ${DMG_NAME}.dmg"
echo ""
echo "2. DMGを配布またはGitHub Releasesにアップロード"
echo ""
