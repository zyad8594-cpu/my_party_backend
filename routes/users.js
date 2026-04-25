// backend/routes/users.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authorizeRole, authenticateToken } = require('../config/constents');
const { uploadTo } = require('../middlewares/uploadMiddleware');

router.use(authenticateToken);

router.get('/', authorizeRole.fullAdmin(), userController.getAllUsers);
router.get('/role/:role', authorizeRole.fullAdmin(), userController.getAllUsersByRole); // New Role-based route

// Notification Routes (Unified)
router.get('/notifications', authorizeRole.full(), userController.getNotifications);
router.put('/notifications-read-all', authorizeRole.full(), userController.markAllAsRead);
router.put('/notifications/:notificationId', authorizeRole.full(), userController.markAsRead);
router.delete('/notifications/:notificationId', authorizeRole.full(), userController.deleteNotification);
router.delete('/notifications-clear', authorizeRole.full(), userController.clearAllNotifications);

router.post('/fcm-token', authorizeRole.full(), userController.updateFCMToken);
router.delete('/fcm-token', authorizeRole.full(), userController.removeFCMToken);

router.post('/', authorizeRole.onlyAdmin(), uploadTo('users', 'img_url'), userController.create);
router.put('/change-password/:userId', authorizeRole.full(), userController.changePassword);

router.get('/:id', authorizeRole.fullAdmin(), userController.getUserById);
router.put('/:id', authorizeRole.full(), uploadTo('users', 'img_url'), userController.update);
router.put('/:id/set_active', authorizeRole.onlyAdmin(), userController.set_active);
router.delete('/:id', authorizeRole.onlyAdmin(), userController.delete);

module.exports = router;