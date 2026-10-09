const express = require('express');
const { syncProfile, getProfile, updateProfile } = require('../controllers/usersController');
const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

const router = express.Router();

router.get('/profile', requireFirebaseUser, getProfile);
router.post('/profile', requireFirebaseUser, syncProfile);
router.patch('/profile', requireFirebaseUser, updateProfile);

module.exports = router;
