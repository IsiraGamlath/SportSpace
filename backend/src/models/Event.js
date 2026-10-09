const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    sport: {
      type: String,
      required: true,
      trim: true,
    },
    date: {
      type: String,
      required: true,
      trim: true,
    },
    time: {
      type: String,
      required: true,
      trim: true,
    },
    eventDate: {
      type: Date,
      default: Date.now,
    },
    location: {
      type: String,
      default: 'Colombo Sports Hub, Colombo',
      trim: true,
    },
    facility: {
      type: String,
      default: 'Colombo Sports Hub',
      trim: true,
    },
    facilityId: {
      type: String,
      default: 'colombo_sports_hub',
      trim: true,
    },
    eventType: {
      type: String,
      default: 'Tournament',
      trim: true,
    },
    status: {
      type: String,
      enum: ['Open', 'Confirmed', 'Cancelled', 'Rescheduled'],
      default: 'Open',
    },
    imageUrl: {
      type: String,
      default: 'assets/images/badminton.jpg',
    },
    description: {
      type: String,
      default: '',
    },
    organizerName: {
      type: String,
      default: 'Colombo Community Sports Association',
    },
    organizerInitials: {
      type: String,
      default: 'CC',
    },
    createdBy: {
      type: String,
      default: 'player', // 'player', 'facilityManager', etc.
    },
    timeline: {
      type: [
        {
          time: String,
          label: String,
        },
      ],
      default: [],
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Event', eventSchema);
