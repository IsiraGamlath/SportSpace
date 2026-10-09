const express = require('express');
const router = express.Router();
const controller = require('../controllers/savedEventsController');

router.get('/', controller.getSavedEvents);
router.post('/', controller.saveEvent);
router.delete('/:eventId', controller.unsaveEvent);

module.exports = router;
