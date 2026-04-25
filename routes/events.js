const express = require('express');
const router = express.Router();
const eventsController = require('../controllers/eventsController');
const { authorizeRole, authenticateToken } = require('../config/constents');
const { uploadTo } = require('../middlewares/uploadMiddleware');

router.use(authenticateToken); // Protect all event routes

router.get('/', authorizeRole.fullAdmin(), eventsController.getAllEvents);
router.get('/:id',authorizeRole.fullAdmin(), eventsController.getEventById);

router.post('/', authorizeRole.subAdmin(), uploadTo('events', 'img_url'), eventsController.createEvent);
router.post('/:id/cancel', authorizeRole.subAdmin(), eventsController.cancelEvent);

router.put('/:id', authorizeRole.subAdmin(), uploadTo('events', 'img_url'), eventsController.updateEvent);
router.put('/:id/status', authorizeRole.subAdmin(), eventsController.updateEventStatus);

router.delete('/:id', authorizeRole.subAdmin(), eventsController.deleteEvent);

module.exports = router;
