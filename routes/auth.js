const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { uploadTo } = require('../middlewares/uploadMiddleware');

router.post('/login', authController.login);
router.post('/register', uploadTo('users', 'img_url'), authController.register);

module.exports = router;
