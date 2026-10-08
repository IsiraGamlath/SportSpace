const mongoose = require('mongoose');

const facilitySchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Facility name is required'],
      trim: true,
      unique: true,
    },
    type: {
      type: String,
      required: [true, 'Facility type is required'],
      default: 'Badminton', // Badminton, Tennis, Basketball, Futsal, Swimming Pool, Squash, Cricket, etc.
    },
    description: {
      type: String,
      default: '',
    },
    hourlyRate: {
      type: Number,
      required: [true, 'Hourly rate is required'],
      default: 2500,
    },
    openingTime: {
      type: String,
      default: '06:00 AM',
    },
    closingTime: {
      type: String,
      default: '10:00 PM',
    },
    status: {
      type: String,
      enum: ['active', 'maintenance', 'inactive'],
      default: 'active',
    },
    capacity: {
      type: Number,
      default: 4,
    },
    surface: {
      type: String,
      default: 'Wooden / Synthetic',
    },
    isIndoor: {
      type: Boolean,
      default: true,
    },
    centreName: {
      type: String,
      default: 'Colombo Sports Centre',
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Facility', facilitySchema);
