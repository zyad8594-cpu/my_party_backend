const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { authorizeRole, authenticateToken } = require('../config/constents');


router.use(authenticateToken);

router.get('/', authorizeRole.fullAdmin(), notificationController.getNotifications);
router.get('/last/:date', authorizeRole.fullAdmin(), notificationController.getLastNotifications)
router.put('/:id', authorizeRole.fullAdmin(), notificationController.markAsRead);
router.delete('/:id', authorizeRole.fullAdmin(), notificationController.deleteNotification);
router.delete('/', authorizeRole.fullAdmin(), notificationController.clearAllNotifications);

module.exports = router;
