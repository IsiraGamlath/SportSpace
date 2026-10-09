const express = require('express');
const router = express.Router();
const facilityController = require('../controllers/facilityController');
const multer = require('multer');
const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

// Memory storage allows flexible upload of file bytes or base64 directly to Cloudinary
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
});

router.get('/', facilityController.getFacilities);
router.get('/manager', requireFirebaseUser, facilityController.getManagerFacilities);
router.post('/upload-photo', requireFirebaseUser, upload.single('photo'), facilityController.uploadPhoto);
router.get('/:id', facilityController.getFacilityById);
router.post('/', requireFirebaseUser, facilityController.createFacility);
router.put('/:id', requireFirebaseUser, facilityController.updateFacility);
router.delete('/:id', requireFirebaseUser, facilityController.deleteFacility);

module.exports = router;
