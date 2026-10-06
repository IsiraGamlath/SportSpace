const mongoose = require('mongoose');

const slotSchema = new mongoose.Schema({
  time: { type: String, required: true },
  durationRange: { type: String, required: true },
  status: {
    type: String,
    enum: ['available', 'booked', 'selected', 'blocked', 'pending'],
    default: 'available',
  },
  price: { type: Number, required: true },
  date: { type: String, required: true },
  courtName: { type: String, default: 'Badminton Court 1' },
  facilityType: { type: String, default: 'Badminton' }, // Badminton, Tennis, Basketball, etc.
  blockedReason: { type: String, default: null },
  isConflictTrigger: { type: Boolean, default: false },
  maintenanceId: { type: mongoose.Schema.Types.ObjectId, ref: 'Maintenance', default: null },
}, { timestamps: true });

module.exports = mongoose.model('Slot', slotSchema);
