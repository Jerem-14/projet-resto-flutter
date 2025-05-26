const express = require('express');
const router = express.Router();
const restaurantController = require('../controllers/restaurantController');
const authenticate = require('../middleware/authenticate');
const isAdmin = require('../middleware/isAdmin');

// Lister tous les restaurants
router.get('/', restaurantController.listRestaurants);
// Voir un restaurant
router.get('/:id', restaurantController.getRestaurant);
// Créer un restaurant (admin)
router.post('/', authenticate, isAdmin, restaurantController.createRestaurant);
// Modifier un restaurant (admin)
router.patch('/:id', authenticate, isAdmin, restaurantController.updateRestaurant);
// Supprimer un restaurant (admin)
router.delete('/:id', authenticate, isAdmin, restaurantController.deleteRestaurant);

module.exports = router; 