const express = require('express');
const router = express.Router();
const controller = require('../controllers/contactRequestsController');

router.get('/', controller.getContactRequests);
router.get('/:id', controller.getContactRequestById);
router.post('/', controller.createContactRequest);
router.put('/:id', controller.updateContactRequest);
router.delete('/:id', controller.deleteContactRequest);

module.exports = router;
