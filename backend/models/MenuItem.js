const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  class MenuItem extends Model {
    static associate(models) {
      MenuItem.belongsTo(models.MenuCategory, {
        foreignKey: 'category_id',
        as: 'category'
      });
    }
  }

  MenuItem.init({
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    category_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'menu_categories', // Assurez-vous que cette table existe ou correspond au nom de table de MenuCategory
        key: 'id'
      }
    },
    name: {
      type: DataTypes.STRING(150),
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    price: {
      type: DataTypes.DECIMAL(8, 2),
      allowNull: false,
      validate: {
        min: 0
      }
    },
    is_available: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    sequelize,
    modelName: 'MenuItem',
    tableName: 'menu_items', // Nom de la table dans la base de données
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });

  return MenuItem;
}; 