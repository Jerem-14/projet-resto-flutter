const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  class Reservation extends Model {
    static associate(models) {
      Reservation.belongsTo(models.User, {
        foreignKey: 'user_id',
        as: 'user'
      });
      Reservation.belongsTo(models.Timeslot, {
        foreignKey: 'timeslot_id',
        as: 'timeslot'
      });
    }
  }

  Reservation.init({
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    timeslot_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'timeslots',
        key: 'id'
      }
    },
    reservation_date: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    number_of_guests: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1
      }
    },
    is_cancelled: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  }, {
    sequelize,
    modelName: 'Reservation',
    tableName: 'reservations',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });

  return Reservation;
}; 