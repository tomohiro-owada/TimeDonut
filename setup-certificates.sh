#!/bin/bash

# TimeDonut - Certificate Setup Script
# Creates Certificate Signing Request and guides through certificate creation

set -e

BUNDLE_ID="com.timedonut.app"
TEAM_NAME="TimeDonut Team"
EMAIL="oowada.tomohiro@gmail.com"  # Update with your email
CSR_FILE="TimeDonut_CSR.certSigningRequest"
CERT_TYPE="Mac App Distribution"

echo "🔐 TimeDonut - Certificate Setup"
echo "=================================="
echo ""

# Check current certificates
echo "📋 現在インストールされている証明書:"
security find-identity -v -p codesigning
echo ""

# Check if distribution certificate already exists
if security find-identity -v -p codesigning | grep -q "Mac App Distribution"; then
    echo "✅ Mac App Distribution証明書は既にインストールされています"
    IDENTITY=$(security find-identity -v -p codesigning | grep "Mac App Distribution" | head -1 | awk -F'"' '{print $2}')
    echo "   Identity: $IDENTITY"
    echo ""
    read -p "新しい証明書を作成しますか？ (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "スキップしました"
        exit 0
    fi
fi

echo "======================================"
echo "証明書署名要求（CSR）の作成"
echo "======================================"
echo ""
echo "ステップ1: Keychain Accessでの操作が必要です"
echo ""
echo "1. 'Keychain Access'アプリを開く:"
echo "   open /System/Applications/Utilities/Keychain\ Access.app"
echo ""
echo "2. メニューバーから:"
echo "   Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority..."
echo ""
echo "3. 以下の情報を入力:"
echo "   User Email Address: ${EMAIL}"
echo "   Common Name: ${TEAM_NAME}"
echo "   Request is: Saved to disk"
echo "   ✓ Let me specify key pair information"
echo ""
echo "4. Key Pair Information:"
echo "   Key Size: 2048 bits"
echo "   Algorithm: RSA"
echo ""
echo "5. 保存場所:"
echo "   $(pwd)/${CSR_FILE}"
echo ""

read -p "Keychain AccessでCSRを作成する準備ができましたか？ (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "📝 Keychain Accessを開きます..."
    open /System/Applications/Utilities/Keychain\ Access.app
    echo ""
    echo "CSRファイルを作成したら、Enterキーを押してください..."
    read

    # Check if CSR was created
    if [ ! -f "${CSR_FILE}" ]; then
        echo "⚠️  ${CSR_FILE} が見つかりません"
        echo "CSRファイルを $(pwd)/ に保存してください"
        read -p "保存したらEnterキーを押してください..."
    fi

    if [ -f "${CSR_FILE}" ]; then
        echo "✅ CSRファイルを確認しました: ${CSR_FILE}"
    fi
fi

echo ""
echo "======================================"
echo "ステップ2: Apple Developer Portalでの作業"
echo "======================================"
echo ""
echo "1. Apple Developer Portalにアクセス:"
echo "   https://developer.apple.com/account/resources/certificates/list"
echo ""
echo "2. '+' ボタンをクリック"
echo ""
echo "3. 'Mac App Distribution' を選択 → Continue"
echo ""
echo "4. CSRファイルをアップロード:"
if [ -f "${CSR_FILE}" ]; then
    echo "   ファイル: $(pwd)/${CSR_FILE}"
else
    echo "   ファイル: ${CSR_FILE} (このディレクトリに保存してください)"
fi
echo ""
echo "5. 証明書をダウンロード (例: distribution.cer)"
echo ""
echo "6. ダウンロードした証明書をダブルクリックしてインストール"
echo ""

read -p "証明書をダウンロードしてインストールしましたか？ (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "✅ インストール完了"
    echo ""
    echo "📋 更新された証明書リスト:"
    security find-identity -v -p codesigning
    echo ""
fi

echo ""
echo "======================================"
echo "ステップ3: App IDの登録"
echo "======================================"
echo ""
echo "1. Identifiers ページにアクセス:"
echo "   https://developer.apple.com/account/resources/identifiers/list"
echo ""
echo "2. '+' ボタンをクリック"
echo ""
echo "3. 'App IDs' を選択 → Continue"
echo ""
echo "4. 設定:"
echo "   Platform: macOS"
echo "   Description: TimeDonut"
echo "   Bundle ID: Explicit"
echo "   Bundle ID: ${BUNDLE_ID}"
echo ""
echo "5. Capabilities:"
echo "   ✓ App Groups (必要に応じて)"
echo "   ✓ Keychain Sharing"
echo ""
echo "6. Continue → Register"
echo ""

read -p "App IDを登録しましたか？ (y/n) " -n 1 -r
echo

echo ""
echo "======================================"
echo "✅ 証明書セットアップ完了"
echo "======================================"
echo ""
echo "次のステップ:"
echo "1. Xcodeでプロジェクトを開く:"
echo "   open Package.swift"
echo ""
echo "2. Signing & Capabilities タブで:"
echo "   - Team を選択"
echo "   - Signing Certificate: '${CERT_TYPE}' を選択"
echo ""
echo "3. または、CLIでビルド:"
echo "   make appstore"
echo ""
