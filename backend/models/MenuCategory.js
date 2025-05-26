const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  class MenuCategory extends Model {
    static associate(models) {
      MenuCategory.hasMany(models.MenuItem, {
        foreignKey: 'category_id',
        as: 'menu_items'
      });
    }
  }

  MenuCategory.init({
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    sequelize,
    modelName: 'MenuCategory',
    tableName: 'menu_categories',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });

  return MenuCategory;
}; 