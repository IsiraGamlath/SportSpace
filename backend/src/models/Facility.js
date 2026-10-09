const mongoose = require('mongoose');

const facilitySchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Facility name is required'],
      trim: true,
      unique: true,
    },
    location: {
      type: String,
      default: 'Colombo 07, Reid Avenue',
      trim: true,
    },
    description: {
      type: String,
      default: '',
    },
    openTime: {
      type: String,
      default: '06:00 AM – 10:00 PM',
    },
    openingTime: {
      type: String,
      default: '06:00 AM',
    },
    closingTime: {
      type: String,
      default: '10:00 PM',
    },
    availableSports: {
      type: [String],
      default: ['Badminton'],
    },
    amenities: {
      type: [String],
      default: ['Parking', 'Changing Rooms', 'Showers', 'Lockers'],
    },
    accessibility: {
      type: [String],
      default: ['Wheelchair Accessible', 'Ground Floor Access'],
    },
    contactNumber: {
      type: String,
      default: '+94 11 269 1111',
      trim: true,
    },
    photos: {
      type: [String],
      default: [],
    },
    photoUrl: {
      type: String,
      default: '',
    },
    hourlyRate: {
      type: Number,
      required: [true, 'Hourly rate is required'],
      default: 2500,
    },
    type: {
      type: String,
      default: 'Badminton',
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
    managerId: {
      type: String,
      default: null,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Facility', facilitySchema);
