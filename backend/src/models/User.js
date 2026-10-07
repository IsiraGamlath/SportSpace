const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    firebaseUid: { type: String, unique: true, sparse: true, trim: true },
    fullName: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    passwordHash: { type: String, select: false },
    role: {
      type: String,
      enum: ['Player', 'Facility Manager', 'Community / Public User'],
      required: true,
    },
    isApproved: { type: Boolean, default: false }, // For Facility Managers
    assignedVenues: [{ type: String }], // e.g. ["Colombo Futsal Club", "Kandy Badminton"]
  },
  { timestamps: true },
);

module.exports = mongoose.model('User', userSchema);
