# App Store Connect アプリ登録手順

ブラウザで開いたApp Store Connectで以下の操作を行います。

## ステップ1: 新規アプリの作成

1. **App Store Connectにログイン**
   - 開いたページでログイン（必要に応じて）

2. **「＋」ボタンをクリック** → **「新規App」**

3. **アプリ情報を入力:**

   - **プラットフォーム**: macOS
   - **名前**: TimeDonut
   - **プライマリ言語**: 日本語
   - **バンドルID**: com.timedonut.app
   - **SKU**: timedonut-app-001 (任意の一意の文字列)
   - **ユーザーアクセス**: フルアクセス

4. **作成** をクリック

## ステップ2: アプリ情報の入力

### 2.1 App情報

- **名前**: TimeDonut
- **サブタイトル**: スケジュールを美しく可視化
- **カテゴリ**:
  - プライマリ: 仕事効率化
  - セカンダリ: ユーティリティ（オプション）

### 2.2 価格および配信状況

- **価格**: 無料
- **配信可能地域**: すべての地域

### 2.3 App Privacy

- **プライバシーポリシーURL**: https://tomohiro-owada.github.io/TimeDonut/privacy.html

**データ収集の質問に回答:**
1. **データを収集しますか?** はい
2. **収集するデータタイプ:**
   - ✓ カレンダーイベント（Google Calendar経由）
   - ✓ ユーザーID（OAuth認証用）
3. **データの使用目的:**
   - カレンダーイベントの表示
   - アプリ機能の提供
4. **データの共有:** なし（第三者と共有しない）
5. **データの保持:** ローカルのみ（サーバーに保存しない）

### 2.4 App情報 - メタデータ

**英語版（Primary）:**
- **App名**: TimeDonut
- **サブタイトル**: Visualize your schedule beautifully
- **プロモーションテキスト**:
  ```
  🎉 Revolutionize your time management with TimeDonut!
  Beautiful donut-shaped 24-hour clock shows your Google Calendar events at a glance. Real-time countdown to your next event keeps you on track. Download free and start smarter time management today!
  ```
- **説明**: `AppStoreMetadata/description_en.txt` の内容をコピー
- **キーワード**: calendar,schedule,time,menu bar,Google,productivity,time management,planner,clock,donut
- **サポートURL**: https://github.com/tomohiro-owada/TimeDonut/issues
- **マーケティングURL**: https://tomohiro-owada.github.io/TimeDonut/

**日本語版（Localized）:**
- **App名**: TimeDonut
- **サブタイトル**: スケジュールを美しく可視化
- **プロモーションテキスト**: `AppStoreMetadata/promotional_text.txt` の内容をコピー
- **説明**: `AppStoreMetadata/description_ja.txt` の内容をコピー
- **キーワード**: `AppStoreMetadata/keywords_ja.txt` の内容をコピー

### 2.5 スクリーンショット

**必要な画像サイズ**: 2880 x 1800 pixels (5K Retina Display)

**アップロードするスクリーンショット:**
1. メニューバー表示（ドーナツ時計が見える状態）
2. ポップオーバー展開（24時間ドーナツビュー全体）
3. カレンダーイベント表示（イベントがある状態）
4. カウントダウン表示（次のイベントまでの時間）
5. 設定画面（オプション）

📸 スクリーンショットは以下のコマンドで撮影:
```bash
make screenshots
```

撮影後、`AppStoreMetadata/Screenshots/` フォルダ内の画像をApp Store Connectにアップロードしてください。

### 2.6 ビルド

**ビルドアップロード後:**
1. ビルド番号を選択
2. 輸出コンプライアンス情報:
   - **Does your app use encryption?** No (または該当する場合はYes)
3. **保存**

### 2.7 レビュー用情報

- **連絡先情報**:
  - 名前: Tomohiro Oowada
  - メール: oowada.tomohiro@gmail.com
  - 電話: （あなたの電話番号）

- **レビュー用メモ**:
  ```
  TimeDonutは、Googleカレンダーと連携するメニューバーアプリです。

  テストアカウント情報:
  - Googleアカウントでの認証が必要です
  - OAuth経由でカレンダーデータにアクセスします

  テスト手順:
  1. アプリを起動
  2. Googleアカウントでログイン
  3. カレンダーアクセスを許可
  4. メニューバーのドーナツアイコンをクリック
  5. 24時間ビューでイベントを確認
  ```

- **デモアカウント**: （必要に応じてテスト用Googleアカウントを提供）

### 2.8 バージョン情報

- **バージョン**: 1.0.0
- **著作権**: © 2025 Tomohiro Oowada
- **利用規約URL**: https://tomohiro-owada.github.io/TimeDonut/terms.html

## ステップ3: 審査への提出

すべての情報を入力したら:
1. **保存**
2. **審査に提出** をクリック
3. 確認ダイアログで **提出** をクリック

## 審査期間

通常 **1-3営業日** で審査結果が通知されます。

## 審査後

- **承認された場合**: 自動的にApp Storeで公開されます
- **却下された場合**: 理由を確認して修正し、再提出してください

---

## 参考リンク

- App Store Connect: https://appstoreconnect.apple.com/
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- macOS Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/macos
