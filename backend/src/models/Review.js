const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    facilityName: { type: String, required: true, trim: true },
    userId: { type: String, required: true, index: true },
    userName: { type: String, required: true, trim: true },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String, required: true, trim: true, minlength: 3, maxlength: 1000 },
  },
  { timestamps: true },
);

reviewSchema.index({ facilityName: 1, userId: 1 }, { unique: true });

module.exports = mongoose.model('Review', reviewSchema);
