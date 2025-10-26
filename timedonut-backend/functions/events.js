/**
 * カレンダーイベント取得エンドポイント
 * TimeDonutアプリから呼ばれ、Googleカレンダーのイベントを返す
 */
const { google } = require('googleapis');
const { Firestore } = require('@google-cloud/firestore');

const firestore = new Firestore();

exports.events = async (req, res) => {
  // CORS設定
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).send('');
  }

  try {
    // Authorization ヘッダーからユーザーIDを取得
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Missing or invalid authorization header' });
    }

    const userId = authHeader.substring(7); // "Bearer " を除去

    // Firestoreからトークンを取得
    const userDoc = await firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userDoc.data();
    const oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
      process.env.REDIRECT_URI
    );

    oauth2Client.setCredentials({
      access_token: userData.accessToken,
      refresh_token: userData.refreshToken,
      expiry_date: userData.expiryDate
    });

    // トークンが期限切れなら自動更新
    if (oauth2Client.isTokenExpiring()) {
      const { credentials } = await oauth2Client.refreshAccessToken();
      oauth2Client.setCredentials(credentials);

      // 更新されたトークンをFirestoreに保存
      await firestore.collection('users').doc(userId).update({
        accessToken: credentials.access_token,
        refreshToken: credentials.refresh_token || userData.refreshToken,
        expiryDate: credentials.expiry_date,
        updatedAt: new Date()
      });
    }

    // Google Calendar APIでイベント取得
    const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

    // クエリパラメータから時間範囲を取得（なければデフォルト値）
    const timeMin = req.query.timeMin || new Date().toISOString();
    const timeMax = req.query.timeMax || new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString();

    const response = await calendar.events.list({
      calendarId: 'primary',
      timeMin: timeMin,
      timeMax: timeMax,
      singleEvents: true,
      orderBy: 'startTime',
      maxResults: 50
    });

    const events = response.data.items.map(event => ({
      id: event.id,
      summary: event.summary || '(タイトルなし)',
      start: {
        dateTime: event.start.dateTime || null,
        date: event.start.date || null
      },
      end: {
        dateTime: event.end.dateTime || null,
        date: event.end.date || null
      },
      status: event.status || 'confirmed',
      calendarId: 'primary',
      colorId: event.colorId || null,
      location: event.location || null,
      description: event.description || null
    }));

    res.json({ events });
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({
      error: 'Failed to fetch events',
      message: error.message
    });
  }
};
