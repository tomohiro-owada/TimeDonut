/**
 * OAuth認証開始エンドポイント
 * TimeDonutアプリから呼ばれ、GoogleのOAuth画面にリダイレクト
 */
const { google } = require('googleapis');

exports.auth = (req, res) => {
  const oauth2Client = new google.auth.OAuth2(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET,
    process.env.REDIRECT_URI
  );

  const scopes = [
    'https://www.googleapis.com/auth/calendar.readonly',
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile'
  ];

  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: scopes,
    state: req.query.state || 'default' // CSRFトークン
  });

  res.redirect(authUrl);
};
