# TimeDonut - App Store申請ガイド

## 📱 アプリ情報

### 基本情報
- **アプリ名**: TimeDonut
- **Bundle ID**: com.timedonut.app
- **バージョン**: 1.0.0
- **ビルド番号**: 1
- **カテゴリ**: Productivity（生産性）
- **最小macOSバージョン**: 13.0 (Ventura)

### 価格
- **価格**: 無料

### プライバシーとURL
- **プライバシーポリシーURL**: https://tomohiro-owada.github.io/TimeDonut/privacy.html
- **利用規約URL**: https://tomohiro-owada.github.io/TimeDonut/terms.html
- **サポートURL**: https://github.com/tomohiro-owada/TimeDonut/issues
- **マーケティングURL**: https://tomohiro-owada.github.io/TimeDonut/

---

## 🎯 App Store申請手順

### ステップ1: Apple Developer Programの確認
1. https://developer.apple.com にアクセス
2. Apple Developer Programに登録済みであることを確認
3. Certificates, Identifiers & Profilesにアクセス

### ステップ2: App IDの登録
1. **Identifiers** → **+** をクリック
2. **App IDs** を選択
3. **Bundle ID**: `com.timedonut.app`
4. **Capabilities**で以下を有効化:
   - ✅ Network Extensions (必要に応じて)
   - ✅ Outgoing Connections (Client)

### ステップ3: Xcodeでプロジェクトを開く
```bash
# Xcodeでプロジェクトを開く
open Package.swift
```

または、Finderから`Package.swift`をXcodeで開く

### ステップ4: Signing & Capabilitiesの設定
1. Xcodeでプロジェクトを開く
2. **TimeDonut** ターゲットを選択
3. **Signing & Capabilities** タブを開く
4. **Team**: Apple Developer Programのチームを選択
5. **Bundle Identifier**: `com.timedonut.app` であることを確認
6. **Signing Certificate**: "Mac App Distribution" を選択
7. **Hardened Runtime**を有効化
8. **App Sandbox**を有効化し、以下を許可:
   - ✅ Outgoing Connections (Client)
   - ✅ Network Client

### ステップ5: Archiveの作成
1. Xcodeメニュー → **Product** → **Destination** → **Any Mac**
2. **Product** → **Archive** をクリック
3. アーカイブが完成するまで待つ

### ステップ6: App Store Connectでアプリを登録
1. https://appstoreconnect.apple.com にアクセス
2. **マイApp** → **+** → **新規App**
3. 以下の情報を入力:
   - **プラットフォーム**: macOS
   - **名前**: TimeDonut
   - **主言語**: 日本語
   - **Bundle ID**: com.timedonut.app
   - **SKU**: com.timedonut.app (任意の一意な値)
   - **ユーザーアクセス**: フルアクセス

### ステップ7: アプリ情報の入力

#### App情報
- **名前**: TimeDonut
- **サブタイトル**: Googleカレンダーをドーナツ時計で表示
- **カテゴリ**: 生産性
- **サブカテゴリ**: (なし)

#### 説明文
```
TimeDonutは、Googleカレンダーの予定を美しいドーナツ型の24時間時計で可視化するmacOS専用のメニューバーアプリです。

【主な機能】
🕐 24時間ドーナツ時計 - 予定を24時間時計のドーナツ型で表示
⏱️ カウントダウン表示 - 次の予定までの残り時間をリアルタイム表示
📅 Googleカレンダー連携 - 自動同期で最新の予定を取得
🎨 カラフルな予定表示 - Googleカレンダーの色分けをそのまま反映
📜 マーキー表示 - 長い予定名もメニューバーでスクロール表示
🔐 セキュアな認証 - Google Cloud Functionsによる安全なOAuth認証

【使い方】
1. Googleアカウントでサインイン
2. カレンダーアクセスを許可
3. メニューバーで予定を確認
4. アイコンをクリックして詳細を表示

【プライバシー】
- Googleカレンダーへの読み取り専用アクセスのみ
- データは暗号化して保存
- 第三者とデータを共有することはありません

時間管理をよりスムーズに、TimeDonutで一日の予定を一目で把握しましょう！
```

#### キーワード
```
カレンダー,予定,時計,メニューバー,Google,生産性,タイムマネジメント,時間管理,スケジュール,ドーナツ
```

#### サポートURL
```
https://github.com/tomohiro-owada/TimeDonut/issues
```

#### マーケティングURL
```
https://tomohiro-owada.github.io/TimeDonut/
```

#### プライバシーポリシーURL
```
https://tomohiro-owada.github.io/TimeDonut/privacy.html
```

### ステップ8: スクリーンショット

必要なスクリーンショット:
- **macOS**: 1280x800, 1440x900, または 2880x1800 ピクセル
- **必要枚数**: 最低1枚、最大10枚

**撮影するスクリーンショット:**
1. メニューバーにアイコンが表示されている状態
2. ポップオーバーでドーナツ時計を表示
3. 予定リストの表示
4. サインイン画面

### ステップ9: App Privacy（プライバシー）

**データ収集**:
- ✅ ユーザーIDを収集
- ✅ カレンダーデータを収集

**データの使用目的**:
- アプリの機能提供のため

**データの共有**:
- ❌ 第三者とデータを共有しない

**詳細設定**:
1. App Store Connect → アプリ → **App Privacy**
2. **Get Started** をクリック
3. 質問に以下のように回答:

**Does your app collect data?** → Yes

**Data Types**:
- **User Content** → **Calendar Events**
  - Purpose: App Functionality
  - Linked to User: No
  - Used for Tracking: No

- **Contact Info** → **Email Address**
  - Purpose: App Functionality
  - Linked to User: Yes
  - Used for Tracking: No

- **Identifiers** → **User ID**
  - Purpose: App Functionality
  - Linked to User: Yes
  - Used for Tracking: No

### ステップ10: アップロードと審査申請

1. **Xcode Organizer**からアプリをアップロード
2. App Store Connectで「このビルドを使用」を選択
3. **Export Compliance**:
   - 暗号化を使用: Yes（HTTPS通信のため）
   - 免除対象: Yes（標準的なHTTPS通信のみ）
4. **Advertising Identifier (IDFA)**:
   - 使用しない: No
5. **審査情報**を入力:
   - サインイン情報（テスト用Googleアカウント）
   - 審査メモ
6. **審査に提出** をクリック

### ステップ11: 審査待ち

- 審査には通常1〜3日かかります
- ステータスは App Store Connect で確認できます
- 質問があれば App Store Review Team から連絡が来ます

---

## 🔧 トラブルシューティング

### コード署名エラー
```bash
# 署名証明書を確認
security find-identity -v -p codesigning
```

### Notarization失敗
- Hardened Runtimeが有効になっているか確認
- App Sandboxが適切に設定されているか確認
- Entitlementsファイルを確認

### 審査リジェクト
- App Store Review Guidelinesを再確認
- リジェクト理由に対応
- Resolution Centerで質問

---

## 📋 チェックリスト

### 申請前
- [ ] Apple Developer Programに登録済み
- [ ] App IDを登録
- [ ] 署名証明書を作成
- [ ] Provisioning Profileを作成
- [ ] Xcodeでプロジェクトを開いて署名設定完了
- [ ] アプリをビルドしてテスト
- [ ] スクリーンショットを撮影
- [ ] プライバシーポリシーURLを確認
- [ ] App Store Connectでアプリ登録
- [ ] アプリ情報（説明、キーワード等）を入力
- [ ] App Privacyを設定

### 申請時
- [ ] Archiveを作成
- [ ] App Store Connectにアップロード
- [ ] ビルドを選択
- [ ] Export Complianceを設定
- [ ] 審査情報を入力
- [ ] 審査に提出

### 審査後
- [ ] 審査結果を確認
- [ ] リジェクトされた場合は対応
- [ ] 承認されたらリリース

---

## 📞 サポート

問題が発生した場合:
1. [Apple Developer Forums](https://developer.apple.com/forums/)
2. [App Store Connect Help](https://help.apple.com/app-store-connect/)
3. GitHubのIssues: https://github.com/tomohiro-owada/TimeDonut/issues
