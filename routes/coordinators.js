const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authorizeRole, authenticateToken } = require('../config/constents');
const { uploadTo } = require('../middlewares/uploadMiddleware');

router.use(authenticateToken);

router.get('/', authorizeRole.fullAdmin(), (req, res) => {
    req.params.role = 'coordinator';
    userController.getAllUsersByRole(req, res);
});
router.get('/:id', authorizeRole.fullAdmin(), userController.getUserById);
router.post('/', authorizeRole.onlyAdmin(), uploadTo('users', 'img_url'), (req, res) => {
    req.body.role_name = 'coordinator';
    userController.create(req, res);
});
router.put('/:id', authorizeRole.subAdmin(), uploadTo('users', 'img_url'), userController.update);
router.put('/admin/:id', authorizeRole.onlyAdmin(), uploadTo('users', 'img_url'), userController.update);
router.delete('/:id', authorizeRole.onlyAdmin(), userController.delete);

module.exports = router;