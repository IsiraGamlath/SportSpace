const express = require('express');
const { register, login, checkEmail } = require('../controllers/authController');

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.get('/check-email', checkEmail);

module.exports = router;
