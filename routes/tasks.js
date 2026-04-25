const express = require('express');
const router = express.Router();
const tasksController = require('../controllers/tasksController');
const { authorizeRole, authenticateToken } = require('../config/constents');
const { uploadTo } = require('../middlewares/uploadMiddleware');

router.use(authenticateToken);

router.get('/', authorizeRole.fullAdmin(), tasksController.getAllTasks);
router.get('/:id', authorizeRole.fullAdmin(), tasksController.getTaskById);
router.get('/event/:eventId',authorizeRole.subAdmin(), tasksController.getTasksByEventId);

router.post('/', authorizeRole.subAdmin(), uploadTo('tasks', 'url_image'), tasksController.createTask);
router.post('/:id/rating', authorizeRole.subAdmin(), tasksController.addTaskRating);
router.post('/:id/reminders', tasksController.addTaskReminder);
router.put('/:id/reminders', tasksController.updateTaskReminder);
router.delete('/:id/reminders', tasksController.deleteTaskReminder);

router.put('/:id', authorizeRole.fullAdmin(), uploadTo('tasks', 'url_image'), tasksController.updateTask);
router.put('/:id/status', authorizeRole.fullAdmin(), uploadTo('tasks', 'url_image'), tasksController.updateTaskStatus);

router.delete('/:id', authorizeRole.fullAdmin(), tasksController.deleteTask);

module.exports = router;
