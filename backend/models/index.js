const fs = require('fs');
const path = require('path');
const Sequelize = require('sequelize');
const basename = path.basename(__filename);
const env = process.env.NODE_ENV || 'development';
const config = require(__dirname + '/../config/database.js')[env];
const db = {};

let sequelize;
if (config.use_env_variable) {
  sequelize = new Sequelize(process.env[config.use_env_variable], config);
} else {
  sequelize = new Sequelize(config.database, config.username, config.password, config);
}

fs
  .readdirSync(__dirname)
  .filter(file => {
    return (file.indexOf('.') !== 0) && (file !== basename) && (file.slice(-3) === '.js') && (file.indexOf('.test.js') === -1);
  })
  .forEach(file => {
    const fullPath = path.join(__dirname, file);
    console.log(`[Model Loader] Processing file: ${file} (Full path: ${fullPath})`);

    // Tenter de supprimer du cache si le fichier est MenuItem.js
    if (file === 'MenuItem.js' && require.cache[fullPath]) {
      console.log(`[Model Loader] Deleting ${fullPath} from require cache.`);
      delete require.cache[fullPath];
    }

    const modelDefinition = require(fullPath);
    if (typeof modelDefinition === 'function') {
      const model = modelDefinition(sequelize);
      db[model.name] = model;
      // Si c'est notre MenuItem simplifié, on logue le succès de l'appel
      if (model.name === 'MenuItem_Test') {
        console.log(`[DEBUG] MenuItem_Test factory function was successfully called and processed.`);
      }
    } else {
      console.warn(`[Model Loader] ${file} does not export a function or is not a Sequelize model, skipping.`);
    }
  });

Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db; 