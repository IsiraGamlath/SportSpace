const express = require('express');
const router = express.Router();
const slotsController = require('../controllers/slotsController');

// Facility Slot CRUD & Management Routes
router.get('/', slotsController.getSlots);
router.post('/', slotsController.createSlot);
router.get('/:id', slotsController.getSlotById);
router.put('/:id', slotsController.updateSlot);
router.delete('/:id', slotsController.deleteSlot);

// Block/Unblock toggle
router.patch('/:id/block', slotsController.toggleBlockSlot);

// Player booking route
router.post('/:id/book', slotsController.bookSlot);

module.exports = router;
