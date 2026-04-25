const express = require('express');
const router = express.Router();
const suppliersController = require('../controllers/suppliersController');
const userController = require('../controllers/userController');
const { authorizeRole, authenticateToken } = require('../config/constents');
const { uploadTo } = require('../middlewares/uploadMiddleware');

router.use(authenticateToken);

router.get('/my-services', authorizeRole.onlyAdminAnd('supplier'), suppliersController.getMyServices);
router.get('/services/:serviceId', authorizeRole.onlyAdminAnd('supplier'), suppliersController.getAllByServiceId);
router.get('/', authorizeRole.fullAdmin(), (req, res) => {
    req.params.role = 'supplier';
    userController.getAllUsersByRole(req, res);
});
router.get('/rated-by-coordinator/:coordinatorId', authorizeRole.fullAdmin(), suppliersController.getSuppliersWithCoordinatorRating);
router.get('/:id', authorizeRole.fullAdmin(), userController.getUserById);

router.get('/:id/services/:serviceId', authorizeRole.onlyAdminAnd('supplier'), suppliersController.getByIdAndServiceId);

// Notification Routes (Redirected to unified controller)
router.get('/:id/notifications', authorizeRole.onlyAdminAnd('supplier'), userController.getNotifications);

router.post('/', authorizeRole.onlyAdmin(), uploadTo('users', 'img_url'), (req, res) => {
    req.body.role_name = 'supplier';
    userController.create(req, res);
});
router.post('/assign-service', authorizeRole.onlyAdminAnd('supplier'), suppliersController.assignServiceToSupplier);
router.post('/remove-service', authorizeRole.onlyAdminAnd('supplier'), suppliersController.removeServiceFromSupplier);

router.put('/:id', authorizeRole.onlyAdminAnd('supplier'), uploadTo('users', 'img_url'), userController.update);

router.delete('/:id', authorizeRole.onlyAdmin(), userController.delete);
router.delete('/:id/services', authorizeRole.onlyAdminAnd('supplier'), suppliersController.clearAllServices);
router.delete('/:id/notifications/:notificationId', authorizeRole.onlyAdminAnd('supplier'), userController.deleteNotification);
router.delete('/:id/notifications', authorizeRole.onlyAdminAnd('supplier'), userController.clearAllNotifications);

module.exports = router;
