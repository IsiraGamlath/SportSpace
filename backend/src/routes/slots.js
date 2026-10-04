const express = require('express');
const router = express.Router();
const slotsController = require('../controllers/slotsController');

router.get('/', slotsController.getSlots);
router.post('/:id/book', slotsController.bookSlot);

module.exports = router;
