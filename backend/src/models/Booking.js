const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  courtName: { type: String, required: true },
  slot: { type: mongoose.Schema.Types.ObjectId, ref: 'Slot', required: true },
  status: { type: String, enum: ['confirmed', 'cancelled'], default: 'confirmed' },
  bookingId: { type: String, required: true },
  paymentMethod: { type: String, required: true, default: 'card' },
}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);
