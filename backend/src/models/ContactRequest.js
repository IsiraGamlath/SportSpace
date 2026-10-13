const mongoose = require('mongoose');

const contactRequestSchema = new mongoose.Schema(
  {
    facilityId: {
      type: String,
      required: true,
      trim: true,
    },
    facilityName: {
      type: String,
      default: '',
    },
    userId: {
      type: String,
      default: 'guest',
      trim: true,
    },
    type: {
      type: String,
      enum: ['generalEnquiry', 'accessibilityRequest'],
      required: true,
    },
    message: {
      type: String,
      required: true,
      trim: true,
    },
    status: {
      type: String,
      enum: ['pending', 'in_review', 'resolved'],
      default: 'pending',
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('ContactRequest', contactRequestSchema);
