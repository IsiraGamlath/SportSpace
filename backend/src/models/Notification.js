const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    targetRole: {
      type: String,
      enum: ['player', 'facilityManager', 'communityMember', 'all'],
      required: true,
    },
    userId: {
      type: String,
      default: null,
    },
    category: {
      type: String,
      enum: ['event', 'schedule', 'facility', 'payment', 'reminder', 'request'],
      default: 'event',
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    message: {
      type: String,
      required: true,
      trim: true,
    },
    accentColor: {
      type: String,
      default: 'orange', // 'orange', 'green', 'red', 'teal'
    },
    isRead: {
      type: Boolean,
      default: false,
    },
    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Notification', notificationSchema);
