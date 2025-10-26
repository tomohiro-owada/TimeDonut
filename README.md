# TimeDonut

macOSメニューバー常駐型Googleカレンダーアプリ

## 概要

TimeDonutは、Googleカレンダーの予定をmacOSメニューバーに表示し、アナログ時計とドーナツグラフで視覚化するアプリケーションです。

<img width="689" height="394" alt="スクリーンショット 2025-10-26 14 06 09" src="https://github.com/user-attachments/assets/3ec1c221-7992-4294-8fb9-b12c66f3fbf4" />


## 主な機能

- メニューバーに次の予定までの時間を表示
- クリックでアナログ時計 + ドーナツグラフのポップオーバー表示
- Google OAuth 2.0認証
- 5分ごとの自動カレンダー同期
- 常駐型アプリ（Dockに表示しない）

## 必要要件

- macOS 13 Ventura以降
- Googleアカウント
- インターネット接続

## ビルド方法

### クイックスタート（Make使用）

```bash
# ヘルプを表示
make help

# アプリをビルドして実行
make run

# App Store用にビルド（署名付き）
make appstore

# DMGファイルを作成
make dmg

# スクリーンショットを撮影
make screenshots
```

### 手動ビルド

#### 1. 依存関係の解決

```bash
swift package resolve
```

#### 2. ビルド

```bash
swift build -c release
```

#### 3. .appバンドルの作成

```bash
./create-app-bundle.sh
```

#### 4. 実行

```bash
open TimeDonut.app
```

### App Store配布用ビルド

```bash
# App Store用にビルド（署名・公証付き）
./build-for-appstore.sh

# DMGファイルを作成
./create-dmg.sh

# App Store Connectにアップロード
./upload-to-appstore.sh
```

## 開発

### プロジェクト構成

```
TimeDonut/
├── Package.swift                # Swift Package Manager設定
├── Sources/
│   ├── App/                     # アプリケーションエントリーポイント
│   ├── Models/                  # ドメインモデル
│   ├── ViewModels/              # ビジネスロジック
│   ├── Views/                   # UI (SwiftUI)
│   ├── Managers/                # インフラ層
│   └── Utils/                   # ユーティリティ
└── Tests/                       # テスト
```

### アーキテクチャ

MVVM (Model-View-ViewModel)パターンを採用

### テストの実行

```bash
swift test
```

### デバッグビルド

```bash
swift build
swift run
```

## App Store申請

### 準備
詳細な手順は [`APP_STORE_GUIDE.md`](APP_STORE_GUIDE.md) を参照してください。

### 必要なもの
- Apple Developer Program登録（$99/年）
- Mac App Distribution証明書
- Provisioning Profile

### クイックガイド

1. **スクリーンショット撮影**
   ```bash
   make screenshots
   # または
   ./take-screenshots.sh
   ```

2. **App Store用ビルド**
   ```bash
   make appstore
   # または
   ./build-for-appstore.sh
   ```

3. **App Store Connectで設定**
   - https://appstoreconnect.apple.com
   - アプリ情報を入力（`AppStoreMetadata/` から）
   - スクリーンショットをアップロード
   - プライバシーポリシーURLを設定

4. **アップロード**
   ```bash
   ./upload-to-appstore.sh
   ```
   または Xcode で Archive → Distribute App

### プライバシーポリシー
https://tomohiro-owada.github.io/TimeDonut/privacy.html

### 利用規約
https://tomohiro-owada.github.io/TimeDonut/terms.html

## Google API設定

詳細は `GoogleCloudConsole設定手順.md` を参照してください。

## ドキュメント

- [要件定義書](要件定義書.md)
- [仕様書](仕様書.md)
- [設計書](設計書.md)
- [Google Cloud Console設定手順](GoogleCloudConsole設定手順.md)
- [App Store申請ガイド](APP_STORE_GUIDE.md)
- [スクリーンショット撮影ガイド](AppStoreMetadata/SCREENSHOT_GUIDE.md)

## ライセンス

Private Project

## 作成者

TimeDonut Team
