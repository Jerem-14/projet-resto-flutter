const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');
const authenticate = require('../middleware/authenticate');

// Middleware pour vérifier le rôle admin
const requireAdmin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    return res.status(403).json({ 
      error: 'Accès refusé. Droits administrateur requis.' 
    });
  }
};

// ===============================
// ROUTES UTILISATEUR (AUTH REQUIRED)
// ===============================

/**
 * @route POST /reservations
 * @desc Créer une nouvelle réservation
 * @access Utilisateur authentifié
 */
router.post('/', authenticate, reservationController.createReservation);

/**
 * @route GET /reservations/my
 * @desc Récupérer les réservations de l'utilisateur connecté
 * @access Utilisateur authentifié
 */
router.get('/my', authenticate, reservationController.getUserReservations);



// ===============================
// ROUTES ADMIN
// ===============================

/**
 * @route GET /reservations/admin/all
 * @desc Récupérer toutes les réservations (avec filtres optionnels)
 * @access Admin uniquement
 */
router.get('/admin/all', authenticate, requireAdmin, reservationController.getAllReservations);

/**
 * @route DELETE /reservations/admin/:id
 * @desc Supprimer une réservation (Admin uniquement)
 * @access Admin uniquement
 */
router.delete('/admin/:id', authenticate, requireAdmin, reservationController.deleteReservation);

module.exports = router; 