const express = require('express');
const router = express.Router();
const bookingsController = require('../controllers/bookingsController');
const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

router.get('/manager', requireFirebaseUser, bookingsController.getManagerBookings);
router.get('/', requireFirebaseUser, bookingsController.getBookings);
router.post('/', requireFirebaseUser, bookingsController.createBooking);
router.post('/:id/cancel', requireFirebaseUser, bookingsController.cancelBooking);
router.post('/:id/reschedule', requireFirebaseUser, bookingsController.rescheduleBooking);

module.exports = router;
