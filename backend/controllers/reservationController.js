const db = require('../models');
const { Op } = require('sequelize');
const Reservation = db.Reservation;
const Timeslot = db.Timeslot;
const RestaurantConfig = db.RestaurantConfig;
const User = db.User;

// Create a new reservation
exports.createReservation = async (req, res) => {
  try {
    const { timeslot_id, reservation_date, number_of_guests } = req.body;
    const user_id = req.user.id; // From authentication middleware

    // Validation
    if (!timeslot_id || !reservation_date || !number_of_guests) {
      return res.status(400).json({ 
        error: 'Les champs timeslot_id, reservation_date et number_of_guests sont obligatoires' 
      });
    }

    if (number_of_guests < 1) {
      return res.status(400).json({ 
        error: 'Le nombre de personnes doit être au moins 1' 
      });
    }

    // Check if timeslot exists and is active
    const timeslot = await Timeslot.findByPk(timeslot_id);
    if (!timeslot || !timeslot.is_active) {
      return res.status(404).json({ 
        error: 'Créneau horaire non trouvé ou inactif' 
      });
    }

    // Get restaurant capacity
    const restaurantConfig = await RestaurantConfig.findOne();
    if (!restaurantConfig) {
      return res.status(500).json({ 
        error: 'Configuration du restaurant non trouvée' 
      });
    }

    // Check availability for this timeslot and date
    const existingReservations = await Reservation.findAll({
      where: {
        timeslot_id: timeslot_id,
        reservation_date: reservation_date,
        is_cancelled: false
      }
    });

    const totalReservedGuests = existingReservations.reduce(
      (sum, reservation) => sum + reservation.number_of_guests, 
      0
    );

    const availablePlaces = restaurantConfig.total_capacity - totalReservedGuests;

    if (number_of_guests > availablePlaces) {
      return res.status(400).json({ 
        error: `Pas assez de places disponibles. Places disponibles: ${availablePlaces}` 
      });
    }

    // Check if user already has a reservation for this date and timeslot
    const existingUserReservation = await Reservation.findOne({
      where: {
        user_id: user_id,
        timeslot_id: timeslot_id,
        reservation_date: reservation_date,
        is_cancelled: false
      }
    });

    if (existingUserReservation) {
      return res.status(400).json({ 
        error: 'Vous avez déjà une réservation pour ce créneau' 
      });
    }

    // Create the reservation
    const reservation = await Reservation.create({
      user_id: user_id,
      timeslot_id: timeslot_id,
      reservation_date: reservation_date,
      number_of_guests: number_of_guests
    });

    // Fetch the complete reservation with associations
    const completeReservation = await Reservation.findByPk(reservation.id, {
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'first_name', 'last_name', 'email']
        },
        {
          model: Timeslot,
          as: 'timeslot',
          attributes: ['id', 'start_time']
        }
      ]
    });

    return res.status(201).json({
      message: 'Réservation créée avec succès',
      reservation: completeReservation
    });

  } catch (error) {
    console.error('Erreur lors de la création de la réservation:', error);
    return res.status(500).json({ 
      error: 'Erreur serveur lors de la création de la réservation',
      details: error.message 
    });
  }
};

// Get user's reservations
exports.getUserReservations = async (req, res) => {
  try {
    const user_id = req.user.id;

    const reservations = await Reservation.findAll({
      where: {
        user_id: user_id,
        is_cancelled: false
      },
      include: [
        {
          model: Timeslot,
          as: 'timeslot',
          attributes: ['id', 'start_time']
        }
      ],
      order: [['reservation_date', 'ASC'], [{ model: Timeslot, as: 'timeslot' }, 'start_time', 'ASC']]
    });

    return res.json(reservations);

  } catch (error) {
    console.error('Erreur lors de la récupération des réservations:', error);
    return res.status(500).json({ 
      error: 'Erreur serveur lors de la récupération des réservations',
      details: error.message 
    });
  }
};

// Admin: Delete a reservation
exports.deleteReservation = async (req, res) => {
  try {
    const { id } = req.params;

    const reservation = await Reservation.findByPk(id, {
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'first_name', 'last_name', 'email']
        },
        {
          model: Timeslot,
          as: 'timeslot',
          attributes: ['id', 'start_time']
        }
      ]
    });

    if (!reservation) {
      return res.status(404).json({ 
        error: 'Réservation non trouvée' 
      });
    }

    // Delete the reservation permanently
    await reservation.destroy();

    return res.json({
      message: 'Réservation supprimée avec succès',
      deletedReservation: {
        id: reservation.id,
        user: reservation.user,
        timeslot: reservation.timeslot,
        reservation_date: reservation.reservation_date,
        number_of_guests: reservation.number_of_guests
      }
    });

  } catch (error) {
    console.error('Erreur lors de la suppression de la réservation:', error);
    return res.status(500).json({ 
      error: 'Erreur serveur lors de la suppression de la réservation',
      details: error.message 
    });
  }
};

// Admin: Get all reservations
exports.getAllReservations = async (req, res) => {
  try {
    const { date, timeslot_id } = req.query;
    
    let whereClause = { is_cancelled: false };
    
    if (date) {
      whereClause.reservation_date = date;
    }
    
    if (timeslot_id) {
      whereClause.timeslot_id = timeslot_id;
    }

    const reservations = await Reservation.findAll({
      where: whereClause,
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'first_name', 'last_name', 'email', 'phone']
        },
        {
          model: Timeslot,
          as: 'timeslot',
          attributes: ['id', 'start_time']
        }
      ],
      order: [['reservation_date', 'ASC'], [{ model: Timeslot, as: 'timeslot' }, 'start_time', 'ASC']]
    });

    return res.json(reservations);

  } catch (error) {
    console.error('Erreur lors de la récupération des réservations:', error);
    return res.status(500).json({ 
      error: 'Erreur serveur lors de la récupération des réservations',
      details: error.message 
    });
  }
}; 