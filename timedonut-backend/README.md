# TimeDonut Backend

Google Cloud Functions を使用したTimeDonutのバックエンドAPI

## セットアップ

### 1. 依存関係インストール

```bash
cd timedonut-backend
npm install
```

### 2. Google Cloud設定

```bash
# プロジェクトIDを設定
gcloud config set project YOUR_PROJECT_ID

# Firestore有効化
gcloud firestore databases create --region=asia-northeast1

# Cloud Functions API有効化
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### 3. 環境変数設定

```bash
export GOOGLE_CLIENT_ID="your-client-id.apps.googleusercontent.com"
export GOOGLE_CLIENT_SECRET="your-client-secret"
export REDIRECT_URI="https://asia-northeast1-YOUR_PROJECT.cloudfunctions.net/callback"
```

### 4. デプロイ

```bash
chmod +x deploy.sh
./deploy.sh
```

## API エンドポイント

### `GET /auth`
OAuth認証を開始します。

**パラメータ:**
- `state` (optional): CSRFトークン

**レスポンス:**
- GoogleのOAuth画面にリダイレクト

---

### `GET /callback`
OAuth認証のコールバック（Googleから呼ばれる）

**パラメータ:**
- `code`: 認証コード
- `state`: CSRFトークン

**処理:**
1. トークン取得
2. Firestoreに保存
3. 成功画面表示

---

### `GET /events`
カレンダーイベントを取得します。

**ヘッダー:**
- `Authorization: Bearer <user_id>`

**レスポンス:**
```json
{
  "events": [
    {
      "id": "...",
      "summary": "ミーティング",
      "startTime": "2025-10-26T12:00:00Z",
      "endTime": "2025-10-26T13:00:00Z"
    }
  ]
}
```

## コスト

Google Cloud Functionsの無料枠：
- 呼び出し: 200万回/月
- 実行時間: 400,000 GB-秒/月
- ネットワーク: 5GB/月

**TimeDonutの使用量（推定）:**
- 1ユーザー: ~1,000呼び出し/月
- 無料枠で2,000ユーザーまで対応可能
- **実質コスト: $0/月**

## セキュリティ

- Client SecretはCloud Functionsの環境変数に保存
- アプリには含まれない
- FirestoreでTokenを安全に管理
- HTTPSのみ対応
