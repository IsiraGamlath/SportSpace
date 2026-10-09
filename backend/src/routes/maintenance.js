const express = require('express');
const router = express.Router();
const maintenanceController = require('../controllers/maintenanceController');

const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

// Summary overview
router.get('/overview/summary', requireFirebaseUser, maintenanceController.getManagerMaintenanceSummary);

// Maintenance CRUD
router.get('/', maintenanceController.getMaintenanceFlags);
router.get('/manager', requireFirebaseUser, maintenanceController.getManagerMaintenanceFlags);
router.post('/', requireFirebaseUser, maintenanceController.createMaintenanceFlag);
router.get('/:id', maintenanceController.getMaintenanceById);
router.put('/:id', requireFirebaseUser, maintenanceController.updateMaintenanceFlag);
router.delete('/:id', requireFirebaseUser, maintenanceController.deleteMaintenanceFlag);

// Resolve maintenance flag
router.patch('/:id/resolve', requireFirebaseUser, maintenanceController.resolveMaintenanceFlag);
router.post('/:id/resolve', requireFirebaseUser, maintenanceController.resolveMaintenanceFlag);

module.exports = router;
