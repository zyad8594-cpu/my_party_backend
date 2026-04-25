const express = require('express');
const router = express.Router();
const clientController = require('../controllers/clientController');
const { authorizeRole, authenticateToken } = require('../config/constents');
const { uploadTo } = require('../middlewares/uploadMiddleware');

router.use(authenticateToken);

router.get('/', authorizeRole.fullAdmin(),  clientController.getAllClients);
router.get('/:id', authorizeRole.fullAdmin(), clientController.getClientById);
router.post('/', authorizeRole.subAdmin(), uploadTo('clients', 'img_url'), clientController.createClient);
router.put('/:id',  authorizeRole.subAdmin(), uploadTo('clients', 'img_url'), clientController.updateClient);
router.delete('/:id',  authorizeRole.subAdmin(), clientController.deleteClient);
router.put('/:id/restore',  authorizeRole.subAdmin(), clientController.restoreClient);

module.exports = router;