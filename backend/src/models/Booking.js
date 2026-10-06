const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  courtName: { type: String, required: true },
  slot: { type: mongoose.Schema.Types.ObjectId, ref: 'Slot', required: true },
  status: { type: String, enum: ['confirmed', 'cancelled', 'rescheduled', 'pending_verification'], default: 'confirmed' },
  bookingId: { type: String, required: true },
  paymentMethod: { type: String, required: true, default: 'card' },
  paymentIntentId: { type: String },
  refundId: { type: String },
  slipUrl: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);
