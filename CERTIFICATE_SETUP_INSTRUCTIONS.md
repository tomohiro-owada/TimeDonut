# Mac App Distribution証明書のセットアップ手順

## 現在の状態
✅ CSRファイル作成済み: `/Users/oowadatomohiro/TimeDonut/TimeDonut_CSR.certSigningRequest`
✅ Apple Developer Portal - 証明書作成ページを開きました
✅ Apple Developer Portal - App ID登録ページを開きました

## ステップ1: Mac App Distribution証明書の作成

ブラウザで開いたページで以下の操作を行ってください:

### 証明書作成ページで:
1. **"Mac App Distribution"** を選択 → **Continue**
2. CSRファイルのアップロード:
   - **Choose File** をクリック
   - ファイル選択: `/Users/oowadatomohiro/TimeDonut/TimeDonut_CSR.certSigningRequest`
   - **Continue** をクリック
3. 証明書をダウンロード:
   - **Download** ボタンをクリック
   - ファイル名: `distribution.cer` (自動命名)
4. ダウンロードした `distribution.cer` をダブルクリックしてインストール

## ステップ2: App IDの登録

App ID登録ページで以下の操作を行ってください:

1. **Platform**: **macOS** を選択 → **Continue**
2. **Description**: `TimeDonut`
3. **Bundle ID**:
   - **Explicit** を選択
   - Bundle ID: `com.timedonut.app`
4. **Capabilities** (必要に応じて):
   - ✓ Keychain Sharing (推奨)
5. **Continue** → **Register** をクリック

## 証明書インストール確認

証明書をインストールしたら、以下のコマンドで確認できます:

```bash
security find-identity -v -p codesigning
```

**"Mac App Distribution"** が表示されればOKです。

## 次のステップ

証明書のインストールが完了したら、ターミナルに戻って **Enter** キーを押してください。
自動的に次のステップ（Xcodeプロジェクト設定）に進みます。
