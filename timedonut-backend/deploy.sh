#!/bin/bash

# TimeDonut Backend - Google Cloud Functions デプロイスクリプト

set -e

# 環境変数チェック
if [ -z "$GOOGLE_CLIENT_ID" ] || [ -z "$GOOGLE_CLIENT_SECRET" ] || [ -z "$REDIRECT_URI" ]; then
  echo "Error: 環境変数が設定されていません"
  echo "以下を設定してください："
  echo "  export GOOGLE_CLIENT_ID='your-client-id'"
  echo "  export GOOGLE_CLIENT_SECRET='your-client-secret'"
  echo "  export REDIRECT_URI='https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/callback'"
  exit 1
fi

PROJECT_ID=$(gcloud config get-value project)
REGION="asia-northeast1"  # 東京リージョン

echo "🚀 Deploying TimeDonut Backend to Google Cloud Functions..."
echo "   Project: $PROJECT_ID"
echo "   Region: $REGION"

# 1. OAuth認証開始
echo "📦 Deploying auth function..."
gcloud functions deploy auth \
  --gen2 \
  --runtime=nodejs20 \
  --region=$REGION \
  --source=./functions \
  --entry-point=auth \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars="GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID,GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET,REDIRECT_URI=$REDIRECT_URI"

# 2. OAuthコールバック
echo "📦 Deploying callback function..."
gcloud functions deploy callback \
  --gen2 \
  --runtime=nodejs20 \
  --region=$REGION \
  --source=./functions \
  --entry-point=callback \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars="GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID,GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET,REDIRECT_URI=$REDIRECT_URI"

# 3. イベント取得
echo "📦 Deploying events function..."
gcloud functions deploy events \
  --gen2 \
  --runtime=nodejs20 \
  --region=$REGION \
  --source=./functions \
  --entry-point=events \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars="GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID,GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET,REDIRECT_URI=$REDIRECT_URI"

echo ""
echo "✅ デプロイ完了！"
echo ""
echo "📝 エンドポイント："
echo "   Auth:     https://$REGION-$PROJECT_ID.cloudfunctions.net/auth"
echo "   Callback: https://$REGION-$PROJECT_ID.cloudfunctions.net/callback"
echo "   Events:   https://$REGION-$PROJECT_ID.cloudfunctions.net/events"
echo ""
echo "⚠️  次のステップ："
echo "1. Google Cloud ConsoleでRedirect URIを更新："
echo "   https://$REGION-$PROJECT_ID.cloudfunctions.net/callback"
echo "2. TimeDonutアプリ側のコードを更新"
