const express = require('express');
const router = express.Router();
const incomeController = require('../controllers/incomeController');
const { authorizeRole, authenticateToken } = require('../config/constents');
const { uploadTo } = require('../middlewares/uploadMiddleware');

router.use(authenticateToken);

router.get('/', authorizeRole.subAdmin(), incomeController.getAllIncomes);
router.get('/:id',authorizeRole.subAdmin(), incomeController.getIncomeById);
router.post('/', authorizeRole.subAdmin(), uploadTo('incomes', 'url_image'), incomeController.createIncome);
router.put('/:id', authorizeRole.subAdmin(), uploadTo('incomes', 'url_image'), incomeController.updateIncome);
router.delete('/:id', authorizeRole.subAdmin(), incomeController.deleteIncome);

module.exports = router;