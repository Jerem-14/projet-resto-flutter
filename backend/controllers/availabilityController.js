const db = require('../models');
const { Op } = require('sequelize');
const Reservation = db.Reservation;
const Timeslot = db.Timeslot;
const RestaurantConfig = db.RestaurantConfig;

// Helper function to format date for display (DD/MM/YYYY)
const formatDate = (date) => {
  const day = date.getDate().toString().padStart(2, '0');
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const year = date.getFullYear();
  return `${day}/${month}/${year}`;
};

// Helper function to get day name in French
const getDayName = (dayIndex) => {
  const days = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  return days[dayIndex];
};

// Helper function to format time from HH:MM:SS to HH:MM
const formatTime = (timeString) => {
  return timeString.substring(0, 5);
};

exports.getAvailability = async (req, res) => {
  try {
    // Get restaurant capacity
    const restaurantConfig = await RestaurantConfig.findOne();
    if (!restaurantConfig) {
      return res.status(500).json({ error: 'Configuration du restaurant non trouvée.' });
    }
    const totalCapacity = restaurantConfig.total_capacity;

    // Get all active timeslots
    const timeslots = await Timeslot.findAll({
      where: { is_active: true },
      order: [['start_time', 'ASC']]
    });

    if (timeslots.length === 0) {
      return res.status(404).json({ error: 'Aucun créneau horaire disponible.' });
    }

    // Generate next 7 days starting from today
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Reset time to start of day
    
    const availabilityData = [];

    for (let i = 0; i < 7; i++) {
      const currentDate = new Date(today);
      currentDate.setDate(today.getDate() + i);
      
      // Format date for database query (YYYY-MM-DD)
      const dateString = currentDate.toISOString().split('T')[0];
      
      // Get all reservations for this date
      const reservations = await Reservation.findAll({
        where: {
          reservation_date: dateString,
          is_cancelled: false
        },
        include: [{
          model: Timeslot,
          as: 'timeslot'
        }]
      });

      // Calculate availability for each timeslot
      const timeslotData = timeslots.map(timeslot => {
        // Sum up guests for this timeslot on this date
        const reservedGuests = reservations
          .filter(reservation => reservation.timeslot_id === timeslot.id)
          .reduce((sum, reservation) => sum + reservation.number_of_guests, 0);

        const availablePlaces = Math.max(0, totalCapacity - reservedGuests);

        return {
          id: timeslot.id,
          time: formatTime(timeslot.start_time),
          total_places: totalCapacity,
          available_places: availablePlaces
        };
      });

      // Add day data
      availabilityData.push({
        date: dateString,
        display_date: formatDate(currentDate),
        day_name: getDayName(currentDate.getDay()),
        timeslots: timeslotData
      });
    }

    return res.json(availabilityData);

  } catch (error) {
    console.error('Erreur lors de la récupération des disponibilités:', error);
    return res.status(500).json({ 
      error: 'Erreur serveur lors de la récupération des disponibilités',
      details: error.message 
    });
  }
}; 