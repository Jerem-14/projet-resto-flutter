const { Timeslot } = require('../models');

const timeslotController = {
  // Créer un nouveau créneau
  async create(req, res) {
    try {
      const { start_time, is_active } = req.body;
      const timeslot = await Timeslot.create({
        start_time,
        is_active: is_active ?? true
      });
      res.status(201).json(timeslot);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  // Modifier un créneau
  async update(req, res) {
    try {
      const { id } = req.params;
      const { start_time, is_active } = req.body;
      
      const timeslot = await Timeslot.findByPk(id);
      if (!timeslot) {
        return res.status(404).json({ message: 'Créneau non trouvé' });
      }

      await timeslot.update({ start_time, is_active });
      res.json(timeslot);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  // Supprimer un créneau
  async delete(req, res) {
    try {
      const { id } = req.params;
      const timeslot = await Timeslot.findByPk(id);
      
      if (!timeslot) {
        return res.status(404).json({ message: 'Créneau non trouvé' });
      }

      await timeslot.destroy();
      res.status(204).send();
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  }
};

module.exports = timeslotController;