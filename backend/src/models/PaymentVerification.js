const mongoose = require('mongoose');

const paymentVerificationSchema = new mongoose.Schema({
  bookingId: { type: String, required: true }, // e.g. "SS-20481"
  bookingRef: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', default: null },
  courtName: { type: String, default: 'Badminton Court 1' },
  facilityName: { type: String, default: 'Colombo Sports Centre' },
  slotDate: { type: String, default: 'Tomorrow' },
  slotTime: { type: String, default: '6:00 PM – 7:00 PM' },
  playerName: { type: String, default: 'Player' },
  playerPhone: { type: String, default: '' },
  playerEmail: { type: String, default: '' },
  amount: { type: Number, default: 2500 },
  paymentMethod: { type: String, default: 'card' },
  paymentRef: { type: String, default: '' },
  paymentStatus: {
    type: String,
    enum: ['pending', 'verified', 'unpaid', 'refunded'],
    default: 'pending',
  },
  verifiedBy: { type: String, default: null },
  verifiedAt: { type: Date, default: null },
  verificationNotes: { type: String, default: null },
  slipUrl: { type: String, default: null },
}, { timestamps: true });

module.exports = mongoose.model('PaymentVerification', paymentVerificationSchema);
