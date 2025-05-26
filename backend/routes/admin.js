const express = require('express');
const router = express.Router();
const timeslotController = require('../controllers/timeslotController');
const authenticate = require('../middleware/authenticate');

// Routes pour les créneaux horaires
router.get('/timeslots', authenticate, timeslotController.getAll);
router.post('/timeslots', authenticate, timeslotController.create);
router.patch('/timeslots/:id', authenticate, timeslotController.update);
router.delete('/timeslots/:id', authenticate, timeslotController.delete);

module.exports = router;