const mongoose = require('mongoose');

const maintenanceSchema = new mongoose.Schema({
  facilityName: { type: String, required: true }, // e.g. "Tennis Court 1", "Badminton Court 2", "Swimming Pool"
  facilityType: { type: String, default: 'Court' }, // Tennis, Badminton, Basketball, Swimming Pool, etc.
  issue: { type: String, required: true }, // e.g. "Net damaged"
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium',
  },
  status: {
    type: String,
    enum: ['required', 'scheduled', 'available', 'resolved'],
    default: 'required',
  },
  reportedAt: { type: Date, default: Date.now },
  reportedBy: { type: String, default: 'Manager' },
  scheduledRepairTime: { type: String, default: null }, // e.g. "Today, 2:00 PM"
  notes: { type: String, default: '' },
  affectedSlots: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Slot' }],
  resolvedAt: { type: Date, default: null },
  resolutionNotes: { type: String, default: null },
  managerId: { type: String, default: null },
}, { timestamps: true });

module.exports = mongoose.model('Maintenance', maintenanceSchema);
