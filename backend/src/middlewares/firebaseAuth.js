const jwt = require('jsonwebtoken');
const { getFirebaseAdmin } = require('../config/firebaseAdmin');

async function requireFirebaseUser(req, res, next) {
  const authorization = req.get('Authorization') || '';
  const token = authorization.startsWith('Bearer ')
    ? authorization.slice(7).trim()
    : '';

  if (!token) {
    return res.status(401).json({ message: 'Firebase ID token is required' });
  }

  try {
    const decodedToken = await getFirebaseAdmin().auth().verifyIdToken(token);
    req.firebaseUser = decodedToken;
    return next();
  } catch (error) {
    // If service account file is not configured/found (e.g. local dev), fallback to JWT decode
    if (
      error.message.includes('not configured') ||
      error.message.includes('not found')
    ) {
      try {
        const decoded = jwt.decode(token);
        if (decoded && (decoded.user_id || decoded.sub)) {
          if (decoded.exp && decoded.exp * 1000 < Date.now()) {
            return res.status(401).json({ message: 'Firebase token expired' });
          }
          decoded.uid = decoded.user_id || decoded.sub;
          req.firebaseUser = decoded;
          return next();
        }
      } catch (decodeErr) {
        console.error('Fallback token decode failed:', decodeErr.message);
      }
    }
    console.error('Firebase token verification failed:', error.message);
    return res.status(401).json({ message: 'Invalid Firebase token' });
  }
}

module.exports = { requireFirebaseUser };
