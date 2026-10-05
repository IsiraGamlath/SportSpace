const express = require('express');
const router = express.Router();
const maintenanceController = require('../controllers/maintenanceController');

// Summary overview
router.get('/overview/summary', maintenanceController.getMaintenanceSummary);

// Maintenance CRUD
router.get('/', maintenanceController.getMaintenanceFlags);
router.post('/', maintenanceController.createMaintenanceFlag);
router.get('/:id', maintenanceController.getMaintenanceById);
router.put('/:id', maintenanceController.updateMaintenanceFlag);
router.delete('/:id', maintenanceController.deleteMaintenanceFlag);

// Resolve maintenance flag
router.patch('/:id/resolve', maintenanceController.resolveMaintenanceFlag);
router.post('/:id/resolve', maintenanceController.resolveMaintenanceFlag);

module.exports = router;
