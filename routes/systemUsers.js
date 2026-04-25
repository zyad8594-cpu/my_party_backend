const express = require('express');
const router = express.Router();
const systemUsersController = require('../controllers/systemUsersController');
const { authenticateToken, authorizeRole } = require('../middlewares/auth');


// Protect all system user management routes (Admin Only)
router.use(authenticateToken);
router.use(authorizeRole(['admin']));


router.get('/', systemUsersController.getAllUsers);
router.put('/:id/status', systemUsersController.toggleUserStatus);
router.put('/:id/role', systemUsersController.changeUserRole);


module.exports = router;





