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

    // デスクトップアプリ（localhost:8080）にリダイレクト
    res.redirect(`http://localhost:8080/callback?user_id=${userInfo.id}`);
  } catch (error) {
    console.error('Error during OAuth callback:', error);
    res.status(500).send('Authentication failed: ' + error.message);
  }
};
