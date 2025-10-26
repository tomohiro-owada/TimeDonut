/**
 * OAuthコールバックエンドポイント
 * Googleから認証コードを受け取り、トークンに交換してFirestoreに保存
 */
const { google } = require('googleapis');
const { Firestore } = require('@google-cloud/firestore');

const firestore = new Firestore();

exports.callback = async (req, res) => {
  const { code, state } = req.query;

  if (!code) {
    return res.status(400).send('Missing authorization code');
  }

  try {
    const oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
      process.env.REDIRECT_URI
    );

    // 認証コードをトークンに交換
    const { tokens } = await oauth2Client.getToken(code);
    oauth2Client.setCredentials(tokens);

    // ユーザー情報を取得
    const oauth2 = google.oauth2({ version: 'v2', auth: oauth2Client });
    const { data: userInfo } = await oauth2.userinfo.get();

    // Firestoreにトークンを保存
    await firestore.collection('users').doc(userInfo.id).set({
      email: userInfo.email,
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      expiryDate: tokens.expiry_date,
      updatedAt: new Date()
    });

    // 成功画面を表示（または認証完了メッセージ）
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>TimeDonut - 認証完了</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: #f5f5f5;
          }
          .container {
            text-align: center;
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
          }
          h1 { color: #4CAF50; }
          p { color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>✅ 認証成功！</h1>
          <p>TimeDonutアプリに戻ってください。</p>
          <p>このウィンドウは閉じても構いません。</p>
        </div>
        <script>
          // 5秒後に自動でウィンドウを閉じる
          setTimeout(() => window.close(), 5000);
        </script>
      </body>
      </html>
    `);
  } catch (error) {
    console.error('Error during OAuth callback:', error);
    res.status(500).send('Authentication failed: ' + error.message);
  }
};
