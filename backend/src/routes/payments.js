const express = require('express');
const router = express.Router();
const paymentsController = require('../controllers/paymentsController');
const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

router.post('/create-intent', requireFirebaseUser, paymentsController.createPaymentIntent);

module.exports = router;
