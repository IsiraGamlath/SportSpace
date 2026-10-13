const express = require('express');
const router = express.Router();
const controller = require('../controllers/eventsController');

router.get('/', controller.getEvents);
router.get('/:id', controller.getEventById);
router.post('/', controller.createEvent);
router.put('/:id', controller.updateEvent);
router.patch('/:id/cancel', controller.cancelEvent);
router.delete('/:id', controller.deleteEvent);

module.exports = router;
