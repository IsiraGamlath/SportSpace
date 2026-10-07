const express = require('express');
<<<<<<< Updated upstream
const { syncProfile, getProfile } = require('../controllers/usersController');
=======
const { getProfile, syncProfile } = require('../controllers/usersController');
>>>>>>> Stashed changes
const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

const router = express.Router();

router.get('/profile', requireFirebaseUser, getProfile);
router.post('/profile', requireFirebaseUser, syncProfile);
router.get('/profile', requireFirebaseUser, getProfile);

module.exports = router;
