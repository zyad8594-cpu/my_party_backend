const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');
const { authorizeRole, authenticateToken } = require('../config/constents');


router.use(authenticateToken);

router.get('/admin_stats',  authorizeRole.onlyAdmin(), dashboardController.getAdminStats);
router.get('/home-stats',  authorizeRole.fullAdmin(), dashboardController.getHomeStats);
router.get('/supplier-stats', authorizeRole.onlyAdminAnd('supplier'), dashboardController.getSupplierHomeStats);
router.get('/report-stats', authorizeRole.fullAdmin(),  dashboardController.getReportStats);


module.exports = router;



