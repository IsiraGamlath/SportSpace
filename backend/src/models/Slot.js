const mongoose = require('mongoose');

const slotSchema = new mongoose.Schema({
  time: { type: String, required: true },
  durationRange: { type: String, required: true },
  status: { type: String, enum: ['available', 'booked', 'selected'], default: 'available' },
  price: { type: Number, required: true },
  date: { type: String, required: true },
  isConflictTrigger: { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('Slot', slotSchema);
