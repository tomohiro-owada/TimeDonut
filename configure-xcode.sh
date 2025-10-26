#!/bin/bash

# TimeDonut - Xcode Configuration Script
# Configures Xcode project settings via CLI

set -e

BUNDLE_ID="com.timedonut.app"
APP_NAME="TimeDonut"

echo "⚙️  TimeDonut - Xcode Configuration"
echo "===================================="
echo ""

# Open Xcode project
echo "📂 Xcodeでプロジェクトを開いています..."
open Package.swift

echo ""
echo "⏳ Xcodeがプロジェクトを読み込むまで5秒待機..."
sleep 5

echo ""
echo "======================================"
echo "Xcodeでの設定手順"
echo "======================================"
echo ""
echo "Xcodeが開いたら、以下の設定を行ってください:"
echo ""
echo "【1. プロジェクトナビゲーター】"
echo "   - 左側のファイルツリーで 'Package.swift' をダブルクリック"
echo "   - または Product → Scheme → Edit Scheme"
echo ""
echo "【2. ターゲット選択】"
echo "   - 左側のペインで '${APP_NAME}' を選択"
echo "   - 上部のタブで 'Signing & Capabilities' を選択"
echo ""
echo "【3. Signing設定】"
echo "   - Team: 自分のApple Developer Teamを選択"
echo "   - Signing Certificate: 'Mac App Distribution' を選択"
echo "   - Bundle Identifier: ${BUNDLE_ID} (自動入力されているはず)"
echo "   ✓ Automatically manage signing のチェックを外す"
echo ""
echo "【4. Capabilities追加】"
echo "   - '+ Capability' ボタンをクリック"
echo ""
echo "   a) App Sandbox を追加:"
echo "      - Network: Outgoing Connections (Client) ✓"
echo "      - Hardware: (何も選択しない)"
echo "      - App Data: (何も選択しない)"
echo ""
echo "   b) Hardened Runtime を追加:"
echo "      - Runtime Exceptions: (何も選択しない)"
echo "      - Resource Access: (何も選択しない)"
echo ""
echo "【5. Entitlements確認】"
echo "   - 'TimeDonut.entitlements' が自動的に作成されます"
echo "   - または既存の 'Sources/Resources/TimeDonut.entitlements' を使用"
echo ""
echo "【6. Build Settings（オプション）】"
echo "   - 'Build Settings' タブを選択"
echo "   - Code Signing Identity (Debug): Apple Development"
echo "   - Code Signing Identity (Release): Mac App Distribution"
echo "   - Code Signing Entitlements: Sources/Resources/TimeDonut.entitlements"
echo ""

read -p "設定が完了したらEnterキーを押してください..."

echo ""
echo "======================================"
echo "ビルド設定の確認"
echo "======================================"
echo ""

# Try to get team ID
TEAM_ID=$(security find-certificate -a | grep "alis.*Apple Development" | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "")

if [ -n "$TEAM_ID" ]; then
    echo "✅ Team ID: $TEAM_ID"
else
    echo "⚠️  Team IDを自動検出できませんでした"
fi

echo ""
echo "証明書の状態:"
security find-identity -v -p codesigning

echo ""
echo "======================================"
echo "次のステップ"
echo "======================================"
echo ""
echo "1. Xcodeで Archive を作成:"
echo "   Product → Archive"
echo ""
echo "2. Organizer が開いたら:"
echo "   - 'Distribute App' をクリック"
echo "   - 'App Store Connect' を選択"
echo "   - 'Upload' を選択"
echo ""
echo "3. または、CLIでビルド:"
echo "   make appstore"
echo ""
