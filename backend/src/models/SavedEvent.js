const mongoose = require('mongoose');

const savedEventSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      trim: true,
    },
    eventId: {
      type: String,
      required: true,
      trim: true,
    },
  },
  { timestamps: true }
);

savedEventSchema.index({ userId: 1, eventId: 1 }, { unique: true });

module.exports = mongoose.model('SavedEvent', savedEventSchema);
