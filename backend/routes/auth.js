const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const authenticate = require('../middleware/authenticate');

// Register
router.post('/register', authController.register);
// Login
router.post('/login', authController.login);
// Profile
router.get('/profile', authenticate, authController.profile);
// Logout (optionnel, pour le front)
router.post('/logout', authenticate, authController.logout);

module.exports = router; 