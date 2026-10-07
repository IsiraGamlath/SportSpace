const express = require('express');
const { syncProfile, getProfile } = require('../controllers/usersController');
const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

const router = express.Router();

router.post('/profile', requireFirebaseUser, syncProfile);
router.get('/profile', requireFirebaseUser, getProfile);

module.exports = router;
