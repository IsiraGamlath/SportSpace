const express = require('express');
const { syncProfile, getProfile } = require('../controllers/usersController');
const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

const router = express.Router();

router.get('/profile', requireFirebaseUser, getProfile);
router.post('/profile', requireFirebaseUser, syncProfile);

module.exports = router;
