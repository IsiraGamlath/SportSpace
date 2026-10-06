const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

const connectDB = require('../src/config/db');
const User = require('../src/models/User');
const { getFirebaseAdmin } = require('../src/config/firebaseAdmin');

async function listAllFirebaseUsers() {
  const users = [];
  let pageToken;
  do {
    const page = await getFirebaseAdmin().auth().listUsers(1000, pageToken);
    users.push(...page.users);
    pageToken = page.pageToken;
  } while (pageToken);
  return users;
}

async function syncUsers() {
  await connectDB();
  const firebaseUsers = await listAllFirebaseUsers();
  let synced = 0;

  for (const firebaseUser of firebaseUsers) {
    if (!firebaseUser.email) continue;
    await User.findOneAndUpdate(
      { $or: [{ firebaseUid: firebaseUser.uid }, { email: firebaseUser.email.toLowerCase() }] },
      {
        $set: {
          firebaseUid: firebaseUser.uid,
          fullName: firebaseUser.displayName || firebaseUser.email.split('@')[0],
          email: firebaseUser.email.toLowerCase(),
          role: 'Player',
        },
        $unset: { passwordHash: 1 },
      },
      { upsert: true, runValidators: true, setDefaultsOnInsert: true },
    );
    synced += 1;
  }

  console.log(`Synchronized ${synced} Firebase users to MongoDB.`);
  process.exit(0);
}

syncUsers().catch((error) => {
  console.error('Firebase user synchronization failed:', error.message);
  process.exit(1);
});
