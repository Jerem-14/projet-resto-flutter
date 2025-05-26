const express = require('express');
const router = express.Router();
const db = require('../models');

// Route pour tester la connexion à la base de données
router.get('/test', async (req, res) => {
  try {
    // Tester la connexion à la base de données
    await db.sequelize.authenticate();
    
    res.json({
      status: 'success',
      message: 'Connexion à la base de données réussie',
      timestamp: new Date().toISOString(),
      database: {
        name: db.sequelize.config.database,
        dialect: db.sequelize.getDialect(),
        host: db.sequelize.config.host,
        port: db.sequelize.config.port
      }
    });
  } catch (error) {
    console.error('Erreur de connexion à la base de données:', error);
    res.status(500).json({
      status: 'error',
      message: 'Erreur de connexion à la base de données',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Une erreur est survenue'
    });
  }
});

module.exports = router; 