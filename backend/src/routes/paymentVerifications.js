const express = require('express');
const router = express.Router();
const controller = require('../controllers/paymentVerificationController');

// Payment verification routes
router.get('/', controller.getPaymentVerifications);
router.post('/', controller.createPaymentVerification);
router.get('/:id/status', controller.getVerificationStatus);
router.patch('/:id/verify', controller.verifyPayment);
router.patch('/:id/unpaid', controller.markPaymentUnpaid);

module.exports = router;
