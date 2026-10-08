const express = require('express');
const router = express.Router();
const facilityController = require('../controllers/facilityController');
const multer = require('multer');

// Memory storage allows flexible upload of file bytes or base64 directly to Cloudinary
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
});

router.get('/', facilityController.getFacilities);
router.post('/upload-photo', upload.single('photo'), facilityController.uploadPhoto);
router.get('/:id', facilityController.getFacilityById);
router.post('/', facilityController.createFacility);
router.put('/:id', facilityController.updateFacility);
router.delete('/:id', facilityController.deleteFacility);

module.exports = router;
