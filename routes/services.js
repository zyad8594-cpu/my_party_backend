const express = require('express');
const router = express.Router();
const servicesController = require('../controllers/servicesController');
const { authorizeRole, authenticateToken } = require('../config/constents');


router.use(authenticateToken);

// Standard CRUD
router.get('/', authorizeRole.fullAdmin(), servicesController.getAllServices);
router.get('/:id', authorizeRole.fullAdmin(), servicesController.getServiceById);
router.post('/', authorizeRole.onlyAdmin(), servicesController.createService);
router.put('/:id', authorizeRole.onlyAdmin(), servicesController.updateService);
router.delete('/:id', authorizeRole.onlyAdmin(), servicesController.deleteService);

// Supplier-Service Relationships
router.get('/all/suppliers', authorizeRole.fullAdmin(), servicesController.getAllSuppliersAndServices);
router.get('/supplier/:supplierId', authorizeRole.fullAdmin(), servicesController.getServicesForSupplier);
router.get('/service/:serviceId', authorizeRole.fullAdmin(), servicesController.getSuppliersForService);

// Service Requests
router.post('/requests', authorizeRole.onlyAdminAnd('supplier'), servicesController.createRequest);
router.get('/requests/all', authorizeRole.onlyAdmin(), servicesController.getAllRequests);
router.get('/requests/my', authorizeRole.onlyAdminAnd('supplier'), servicesController.getMyRequests);
router.put('/requests/:id/status', authorizeRole.onlyAdmin(), servicesController.updateRequestStatus);
router.post('/requests/:id/approve', authorizeRole.onlyAdmin(), servicesController.approveServiceRequest);
router.delete('/requests/:id/withdraw', authorizeRole.onlyAdminAnd('supplier'), servicesController.withdrawRequest);

module.exports = router;
