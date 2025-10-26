# TimeDonut

macOSメニューバー常駐型Googleカレンダーアプリ

## 概要

TimeDonutは、Googleカレンダーの予定をmacOSメニューバーに表示し、アナログ時計とドーナツグラフで視覚化するアプリケーションです。

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

### 1. 依存関係の解決

```bash
swift package resolve
```

### 2. ビルド

```bash
swift build -c release
```

### 3. 実行

```bash
swift run
```

または

```bash
.build/release/TimeDonut
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

## Google API設定

詳細は `GoogleCloudConsole設定手順.md` を参照してください。

## ドキュメント

- [要件定義書](要件定義書.md)
- [仕様書](仕様書.md)
- [設計書](設計書.md)
- [Google Cloud Console設定手順](GoogleCloudConsole設定手順.md)

## ライセンス

Private Project

## 作成者

TimeDonut Team
