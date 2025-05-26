const express = require('express');
const router = express.Router();
const availabilityController = require('../controllers/availabilityController');

// Get availability for the next 7 days
router.get('/', availabilityController.getAvailability);

module.exports = router; 