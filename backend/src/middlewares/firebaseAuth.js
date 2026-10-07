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
    if (error.message.includes('not configured') || error.message.includes('not found')) {
      return res.status(503).json({ message: error.message });
    }
    console.error('Firebase token verification failed:', error.message);
    return res.status(401).json({ message: 'Invalid Firebase token' });
  }
}

module.exports = { requireFirebaseUser };
