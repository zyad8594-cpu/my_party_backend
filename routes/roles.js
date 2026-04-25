const express = require('express');
const router = express.Router();
const rolesController = require('../controllers/rolesController');
const { authenticateToken, authorizeRole } = require('../middlewares/auth');


// Protect all role routes (Admin Only)
router.use(authenticateToken);
router.use(authorizeRole(['admin']));


router.get('/', rolesController.getRoles);
router.post('/', rolesController.createRole);
router.delete('/:id', rolesController.deleteRole);
router.post('/:id/permissions', rolesController.assignPermissionsToRole);
router.get('/permissions/all', rolesController.getAllPermissions);


module.exports = router;





