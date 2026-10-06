const express = require('express');
const router = express.Router();
const bookingsController = require('../controllers/bookingsController');

router.get('/', bookingsController.getBookings);
router.post('/', bookingsController.createBooking);
router.post('/:id/cancel', bookingsController.cancelBooking);
router.post('/:id/reschedule', bookingsController.rescheduleBooking);

module.exports = router;
