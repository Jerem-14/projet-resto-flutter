const db = require('../models');
const Restaurant = db.RestaurantConfig;

exports.listRestaurants = async (req, res) => {
  try {
    const restaurants = await Restaurant.findAll();
    res.json(restaurants);
  } catch (err) {
    res.status(500).json({ error: 'Erreur serveur', details: err.message });
  }
};

exports.getRestaurant = async (req, res) => {
  try {
    const { id } = req.params;
    const restaurant = await Restaurant.findByPk(id);
    if (!restaurant) return res.status(404).json({ error: 'Restaurant non trouvé' });
    res.json(restaurant);
  } catch (err) {
    res.status(500).json({ error: 'Erreur serveur', details: err.message });
  }
};

exports.createRestaurant = async (req, res) => {
  try {
    const { restaurant_name, total_capacity, phone, address, description } = req.body;
    if (!restaurant_name || !total_capacity || !phone || !address) {
      return res.status(400).json({ error: 'Champs requis manquants' });
    }
    const restaurant = await Restaurant.create({ restaurant_name, total_capacity, phone, address, description });
    res.status(201).json(restaurant);
  } catch (err) {
    res.status(500).json({ error: 'Erreur serveur', details: err.message });
  }
};

exports.updateRestaurant = async (req, res) => {
  try {
    const { id } = req.params;
    const restaurant = await Restaurant.findByPk(id);
    if (!restaurant) return res.status(404).json({ error: 'Restaurant non trouvé' });
    const { restaurant_name, total_capacity, phone, address, description } = req.body;
    if (restaurant_name) restaurant.restaurant_name = restaurant_name;
    if (total_capacity) restaurant.total_capacity = total_capacity;
    if (phone) restaurant.phone = phone;
    if (address) restaurant.address = address;
    if (description !== undefined) restaurant.description = description;
    await restaurant.save();
    res.json(restaurant);
  } catch (err) {
    res.status(500).json({ error: 'Erreur serveur', details: err.message });
  }
};

exports.deleteRestaurant = async (req, res) => {
  try {
    const { id } = req.params;
    const restaurant = await Restaurant.findByPk(id);
    if (!restaurant) return res.status(404).json({ error: 'Restaurant non trouvé' });
    await restaurant.destroy();
    res.json({ message: 'Restaurant supprimé' });
  } catch (err) {
    res.status(500).json({ error: 'Erreur serveur', details: err.message });
  }
}; 