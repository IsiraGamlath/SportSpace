const express = require('express');
const router = express.Router();
const controller = require('../controllers/paymentVerificationController');

const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

// Payment verification routes
router.get('/', controller.getPaymentVerifications);
router.get('/manager', requireFirebaseUser, controller.getManagerPaymentVerifications);
router.post('/', requireFirebaseUser, controller.createPaymentVerification);
router.get('/:id/status', controller.getVerificationStatus);
router.patch('/:id/verify', requireFirebaseUser, controller.verifyPayment);
router.patch('/:id/unpaid', requireFirebaseUser, controller.markPaymentUnpaid);

module.exports = router;
