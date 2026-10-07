const fs = require('fs');
const path = require('path');
const { cert, getApps, initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

let initialized = false;

function getFirebaseAdmin() {
  if (initialized) return { auth: getAuth };

  const configuredPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  if (!configuredPath) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_PATH is not configured');
  }

  const serviceAccountPath = path.resolve(__dirname, '../../', configuredPath);
  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(`Firebase service account file not found: ${serviceAccountPath}`);
  }

  const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
  if (getApps().length === 0) {
    initializeApp({ credential: cert(serviceAccount) });
  }
  initialized = true;
  return { auth: getAuth };
}

module.exports = { getFirebaseAdmin };
