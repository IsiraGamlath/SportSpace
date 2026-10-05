const express = require('express');
const router = express.Router();
const paymentsController = require('../controllers/paymentsController');

router.post('/create-intent', paymentsController.createPaymentIntent);

module.exports = router;
