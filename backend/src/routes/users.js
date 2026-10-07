const express = require('express');
const { syncProfile } = require('../controllers/usersController');
const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

const router = express.Router();

router.post('/profile', requireFirebaseUser, syncProfile);

module.exports = router;
