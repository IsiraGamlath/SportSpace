const User = require('../models/User');

const allowedRoles = new Set([
  'Player',
  'Facility Manager',
  'Community / Public User',
]);

async function syncProfile(req, res) {
  const { fullName, role } = req.body;
  const email = (req.firebaseUser.email || '').trim().toLowerCase();
  const normalizedName = (fullName || req.firebaseUser.name || email.split('@')[0] || 'User').trim();
  const normalizedRole = allowedRoles.has(role) ? role : 'Player';

  if (!email) {
    return res.status(400).json({ message: 'Firebase account email is required' });
  }

  const user = await User.findOneAndUpdate(
    { $or: [{ firebaseUid: req.firebaseUser.uid }, { email }] },
    {
      $set: {
        firebaseUid: req.firebaseUser.uid,
        fullName: normalizedName,
        email,
        role: normalizedRole,
      },
      $unset: { passwordHash: 1 },
    },
    { new: true, upsert: true, runValidators: true, setDefaultsOnInsert: true },
  );

  return res.status(200).json({
    user: {
      id: user._id,
      firebaseUid: user.firebaseUid,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
    },
  });
}

module.exports = { syncProfile };
