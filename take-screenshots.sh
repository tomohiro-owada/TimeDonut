#!/bin/bash

# TimeDonut Screenshot Tool
# Automates screenshot capture for App Store submission

set -e

SCREENSHOTS_DIR="AppStoreMetadata/Screenshots"
mkdir -p "${SCREENSHOTS_DIR}"

echo "📸 TimeDonut Screenshot Tool"
echo "=============================="
echo ""
echo "このスクリプトはApp Store用のスクリーンショットを撮影します。"
echo ""
echo "準備:"
echo "1. TimeDonutアプリを起動してください"
echo "2. Googleカレンダーに複数の予定を追加してください"
echo "3. デスクトップを整理してください"
echo ""

# Check if app is running
if ! pgrep -x "TimeDonut" > /dev/null; then
    echo "⚠️  TimeDonutが起動していません。"
    read -p "今すぐ起動しますか？ (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open TimeDonut.app
        echo "✅ アプリを起動しました。5秒待機します..."
        sleep 5
    else
        echo "❌ アプリを起動してから再度実行してください。"
        exit 1
    fi
fi

echo ""
echo "スクリーンショットを撮影します。"
echo "各撮影の前に準備する時間があります。"
echo ""

# Screenshot 1: Menu Bar
echo "📸 スクリーンショット 1/4: メニューバー表示"
echo "準備: メニューバーのTimeDonutアイコンが見えるようにしてください"
read -p "準備ができたらEnterキーを押してください..."
echo "3秒後に撮影します..."
sleep 3

# Use screencapture with interactive mode
screencapture -i "${SCREENSHOTS_DIR}/1_menubar_temp.png"

if [ -f "${SCREENSHOTS_DIR}/1_menubar_temp.png" ]; then
    # Resize to App Store requirements (2880x1800)
    sips -z 1800 2880 "${SCREENSHOTS_DIR}/1_menubar_temp.png" --out "${SCREENSHOTS_DIR}/1_menubar.png" > /dev/null 2>&1
    rm "${SCREENSHOTS_DIR}/1_menubar_temp.png"
    echo "✅ 保存: ${SCREENSHOTS_DIR}/1_menubar.png"
else
    echo "⚠️  スキップされました"
fi

echo ""

# Screenshot 2: Donut Clock (Popover)
echo "📸 スクリーンショット 2/4: ドーナツ時計（ポップオーバー）"
echo "準備: メニューバーアイコンをクリックしてポップオーバーを開いてください"
read -p "準備ができたらEnterキーを押してください..."
echo "3秒後に撮影します..."
sleep 3

screencapture -i "${SCREENSHOTS_DIR}/2_donut_clock_temp.png"

if [ -f "${SCREENSHOTS_DIR}/2_donut_clock_temp.png" ]; then
    sips -z 1800 2880 "${SCREENSHOTS_DIR}/2_donut_clock_temp.png" --out "${SCREENSHOTS_DIR}/2_donut_clock.png" > /dev/null 2>&1
    rm "${SCREENSHOTS_DIR}/2_donut_clock_temp.png"
    echo "✅ 保存: ${SCREENSHOTS_DIR}/2_donut_clock.png"
else
    echo "⚠️  スキップされました"
fi

echo ""

# Screenshot 3: Event List
echo "📸 スクリーンショット 3/4: 予定リスト"
echo "準備: ポップオーバーで予定リストが見えるようにスクロールしてください"
read -p "準備ができたらEnterキーを押してください..."
echo "3秒後に撮影します..."
sleep 3

screencapture -i "${SCREENSHOTS_DIR}/3_event_list_temp.png"

if [ -f "${SCREENSHOTS_DIR}/3_event_list_temp.png" ]; then
    sips -z 1800 2880 "${SCREENSHOTS_DIR}/3_event_list_temp.png" --out "${SCREENSHOTS_DIR}/3_event_list.png" > /dev/null 2>&1
    rm "${SCREENSHOTS_DIR}/3_event_list_temp.png"
    echo "✅ 保存: ${SCREENSHOTS_DIR}/3_event_list.png"
else
    echo "⚠️  スキップされました"
fi

echo ""

# Screenshot 4: Sign In (Optional)
echo "📸 スクリーンショット 4/4: サインイン画面（オプション）"
echo "準備: サインアウトしてサインイン画面を表示してください"
read -p "このスクリーンショットをスキップしますか？ (y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    read -p "準備ができたらEnterキーを押してください..."
    echo "3秒後に撮影します..."
    sleep 3

    screencapture -i "${SCREENSHOTS_DIR}/4_signin_temp.png"

    if [ -f "${SCREENSHOTS_DIR}/4_signin_temp.png" ]; then
        sips -z 1800 2880 "${SCREENSHOTS_DIR}/4_signin_temp.png" --out "${SCREENSHOTS_DIR}/4_signin.png" > /dev/null 2>&1
        rm "${SCREENSHOTS_DIR}/4_signin_temp.png"
        echo "✅ 保存: ${SCREENSHOTS_DIR}/4_signin.png"
    else
        echo "⚠️  スキップされました"
    fi
else
    echo "⏭️  スキップしました"
fi

echo ""
echo "=============================="
echo "📸 スクリーンショット撮影完了"
echo ""
echo "撮影されたファイル:"
ls -1 "${SCREENSHOTS_DIR}"/*.png 2>/dev/null || echo "  なし"
echo ""
echo "次のステップ:"
echo "1. 撮影されたスクリーンショットを確認してください"
echo "2. 必要に応じて再撮影してください"
echo "3. App Store Connectにアップロードしてください"
