// backend/config/firebase.js
const admin = require('firebase-admin');
const https = require('https');

// Disable HTTP/2 keep-alive to prevent session reuse errors (ETIMEDOUT)
// on subsequent FCM requests after the first one.
https.globalAgent.keepAlive = false;

// Replace with your service account key file path
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

/**
 * Send push notification to specific FCM tokens (with retry on network error)
 * @param {string[]} tokens - Array of FCM tokens
 * @param {Object} payload - Notification data (title, body, data)
 * @param {number} retries - Number of retry attempts left
 */
const sendPushNotification = async (tokens, payload, retries = 2) => {
  if (!tokens || tokens.length === 0) return;

  const message = {
    notification: {
      title: payload.title,
      body: payload.message,
    },
    data: payload.data || {},
    tokens: tokens,
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`📤 FCM: تم إرسال ${response.successCount} رسالة بنجاح.`);
    
    if (response.failureCount > 0) {
      console.log(`⚠️ FCM: فشل إرسال ${response.failureCount} رسالة.`);
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const token = tokens[idx];
          console.error(`❌ FCM: فشل التوكن [${token.substring(0, 10)}...]:`, resp.error.message);
        }
      });
    }
  } catch (error) {
    const isNetworkError = error.errorInfo?.code === 'messaging/app/network-error';
    if (isNetworkError && retries > 0) {
      console.log(`🔄 FCM: خطأ في الشبكة، جاري إعادة المحاولة... (${retries} محاولات متبقية)`);
      await new Promise(resolve => setTimeout(resolve, 1500));
      return sendPushNotification(tokens, payload, retries - 1);
    }
    console.error('❌ FCM Error:', error.errorInfo?.message || error.message);
  }
};

module.exports = {
  admin,
  sendPushNotification,
};
