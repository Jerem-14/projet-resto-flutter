const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  class Timeslot extends Model {
    static associate(models) {
      Timeslot.hasMany(models.Reservation, {
        foreignKey: 'timeslot_id',
        as: 'reservations'
      });
    }
  }

  Timeslot.init({
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    start_time: {
      type: DataTypes.TIME,
      allowNull: false
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    sequelize,
    modelName: 'Timeslot',
    tableName: 'timeslots',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });

  return Timeslot;
}; 