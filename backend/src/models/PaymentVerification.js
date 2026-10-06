const mongoose = require('mongoose');

const paymentVerificationSchema = new mongoose.Schema({
  bookingId: { type: String, required: true }, // e.g. "SS-20481"
  bookingRef: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', default: null },
  courtName: { type: String, default: 'Badminton Court 1' },
  playerName: { type: String, default: 'Kasun Perera' },
  playerPhone: { type: String, default: '077 123 4567' },
  playerEmail: { type: String, default: 'kasun.p@email.com' },
  amount: { type: Number, default: 2500 },
  paymentMethod: { type: String, default: 'card' },
  paymentRef: { type: String, default: 'PMT-88213' },
  paymentStatus: {
    type: String,
    enum: ['pending', 'verified', 'unpaid', 'refunded'],
    default: 'pending',
  },
  verifiedBy: { type: String, default: null },
  verifiedAt: { type: Date, default: null },
  verificationNotes: { type: String, default: null },
}, { timestamps: true });

module.exports = mongoose.model('PaymentVerification', paymentVerificationSchema);
