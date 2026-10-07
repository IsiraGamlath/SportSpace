const Slot = require('../models/Slot');
const Booking = require('../models/Booking');

const mockSlots = [
  {
    courtName: 'Badminton Court 1',
    facilityType: 'Badminton',
    time: '5:00 PM',
    durationRange: '5:00 PM – 6:00 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    courtName: 'Badminton Court 1',
    facilityType: 'Badminton',
    time: '5:30 PM',
    durationRange: '5:30 PM – 6:30 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    courtName: 'Badminton Court 1',
    facilityType: 'Badminton',
    time: '6:00 PM',
    durationRange: '6:00 PM – 7:00 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    courtName: 'Badminton Court 2',
    facilityType: 'Badminton',
    time: '6:00 PM',
    durationRange: '6:00 PM – 7:00 PM',
    status: 'pending',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    courtName: 'Tennis Court 1',
    facilityType: 'Tennis',
    time: '5:30 PM',
    durationRange: '5:30 PM – 6:30 PM',
    status: 'available',
    price: 3000,
    date: 'Tomorrow'
  },
  {
    courtName: 'Tennis Court 1',
    facilityType: 'Tennis',
    time: '6:45 PM',
    durationRange: '6:45 PM – 7:45 PM',
    status: 'blocked',
    blockedReason: 'Tennis Court 1 — Under Maintenance',
    price: 3000,
    date: 'Tomorrow'
  },
  {
    courtName: 'Basketball Court',
    facilityType: 'Basketball',
    time: '6:30 PM',
    durationRange: '6:30 PM – 7:30 PM',
    status: 'booked',
    price: 2800,
    date: 'Tomorrow'
  },
  {
    courtName: 'Badminton Court 1',
    facilityType: 'Badminton',
    time: '7:00 PM',
    durationRange: '7:00 PM – 8:00 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    courtName: 'Badminton Court 1',
    facilityType: 'Badminton',
    time: '5:00 PM',
    durationRange: '5:00 PM – 6:00 PM',
    status: 'available',
    price: 2500,
    date: 'Today'
  },
  {
    courtName: 'Badminton Court 1',
    facilityType: 'Badminton',
    time: '6:00 PM',
    durationRange: '6:00 PM – 7:00 PM',
    status: 'available',
    price: 2500,
    date: 'Today'
  }
];

// Helper to map _id to id for responses
const formatSlot = (slot) => {
  const obj = slot.toObject ? slot.toObject() : { ...slot };
  obj.id = obj._id.toString();
  return obj;
};

exports.seedSlots = async () => {
  try {
    const count = await Slot.countDocuments();
    if (count === 0) {
      await Slot.insertMany(mockSlots);
      console.log('Database seeded with mock facility slots');
    } else {
      // If slots exist but without courtName, update them with default
      await Slot.updateMany(
        { courtName: { $exists: false } },
        { $set: { courtName: 'Badminton Court 1', facilityType: 'Badminton' } }
      );
    }
  } catch (err) {
    console.error('Error seeding slots:', err);
  }
};

// GET /api/slots
// Supports filtering by: date, courtName, facilityType, status, managerView
exports.getSlots = async (req, res) => {
  try {
    const { date, courtName, facilityType, status, managerView } = req.query;
    let query = {};

    if (date) {
      query.date = date;
    }

    if (courtName) {
      query.courtName = courtName;
    }

    if (facilityType) {
      query.facilityType = facilityType;
    }

    if (status) {
      query.status = status;
    } else if (managerView !== 'true') {
      // Player view: Automatically hide blocked slots and facilities under maintenance
      query.status = { $ne: 'blocked' };
    }

    const slots = await Slot.find(query).sort({ time: 1 });
    const mappedSlots = slots.map(formatSlot);

    res.status(200).json(mappedSlots);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching slots', error: error.message });
  }
};

// GET /api/slots/:id
exports.getSlotById = async (req, res) => {
  try {
    const { id } = req.params;
    const slot = await Slot.findById(id);
    if (!slot) {
      return res.status(404).json({ message: 'Slot not found' });
    }
    res.status(200).json(formatSlot(slot));
  } catch (error) {
    res.status(500).json({ message: 'Error fetching slot', error: error.message });
  }
};

// POST /api/slots (Create facility slot)
exports.createSlot = async (req, res) => {
  try {
    const {
      time,
      durationRange,
      status = 'available',
      price,
      date,
      courtName = 'Badminton Court 1',
      facilityType = 'Badminton',
      blockedReason,
      isConflictTrigger = false,
    } = req.body;

    if (!time || !durationRange || price === undefined || !date) {
      return res.status(400).json({
        message: 'Missing required slot fields: time, durationRange, price, and date are required',
      });
    }

    const newSlot = await Slot.create({
      time,
      durationRange,
      status,
      price,
      date,
      courtName,
      facilityType,
      blockedReason: status === 'blocked' ? (blockedReason || 'Blocked by Manager') : null,
      isConflictTrigger,
    });

    res.status(201).json({
      message: 'Facility slot created successfully',
      slot: formatSlot(newSlot),
    });
  } catch (error) {
    res.status(500).json({ message: 'Error creating slot', error: error.message });
  }
};

// PUT /api/slots/:id (Update facility slot)
exports.updateSlot = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = { ...req.body };

    // If status is updated to blocked and no reason is provided, set a default
    if (updateData.status === 'blocked' && !updateData.blockedReason) {
      updateData.blockedReason = 'Blocked by Manager';
    } else if (updateData.status === 'available') {
      updateData.blockedReason = null;
      updateData.maintenanceId = null;
    }

    const updatedSlot = await Slot.findByIdAndUpdate(id, updateData, { new: true });
    if (!updatedSlot) {
      return res.status(404).json({ message: 'Slot not found' });
    }

    res.status(200).json({
      message: 'Slot updated successfully',
      slot: formatSlot(updatedSlot),
    });
  } catch (error) {
    res.status(500).json({ message: 'Error updating slot', error: error.message });
  }
};

// DELETE /api/slots/:id (Delete facility slot)
exports.deleteSlot = async (req, res) => {
  try {
    const { id } = req.params;
    const slot = await Slot.findById(id);
    if (!slot) {
      return res.status(404).json({ message: 'Slot not found' });
    }

    await Slot.findByIdAndDelete(id);

    res.status(200).json({
      message: 'Facility slot deleted successfully',
      deletedSlotId: id,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting slot', error: error.message });
  }
};

// PATCH /api/slots/:id/block (Block or Unblock slot)
exports.toggleBlockSlot = async (req, res) => {
  try {
    const { id } = req.params;
    const { blocked, reason } = req.body;

    const slot = await Slot.findById(id);
    if (!slot) {
      return res.status(404).json({ message: 'Slot not found' });
    }

    if (blocked === true || blocked === 'true') {
      slot.status = 'blocked';
      slot.blockedReason = reason || 'Blocked by Manager';
    } else {
      slot.status = 'available';
      slot.blockedReason = null;
      slot.maintenanceId = null;
    }

    await slot.save();

    res.status(200).json({
      message: slot.status === 'blocked' ? 'Slot blocked successfully' : 'Slot unblocked successfully',
      slot: formatSlot(slot),
    });
  } catch (error) {
    res.status(500).json({ message: 'Error toggling slot block state', error: error.message });
  }
};

// POST /api/slots/:id/book (Player books slot)
exports.bookSlot = async (req, res) => {
  try {
    const { id } = req.params;
    const { paymentIntentId, paymentMethod = 'card' } = req.body || {};
    const slot = await Slot.findById(id);

    if (!slot) {
      return res.status(404).json({ message: 'Slot not found' });
    }

    if (slot.status === 'booked') {
      return res.status(409).json({ message: 'Slot already booked' });
    }

    if (slot.status === 'blocked') {
      return res.status(400).json({
        message: `Cannot book slot: ${slot.blockedReason || 'This slot is currently blocked / under maintenance'}`,
      });
    }

    slot.status = 'booked';
    await slot.save();
    let bookingStatus = 'confirmed';
    let slipUrl = null;

    if (req.file) {
      slipUrl = req.file.path;
      bookingStatus = 'pending_verification';
    }

    // Create the booking record
    const Booking = require('../models/Booking');
    const newBooking = await Booking.create({
      userId: req.firebaseUser.uid,
      slot: slot._id,
      courtName: slot.courtName || 'Badminton Court 1',
      paymentMethod,
      paymentIntentId,
      status: bookingStatus,
      slipUrl,
      bookingId: `SS-${Math.floor(10000 + Math.random() * 90000)}`,
    });

    res.status(200).json({
      message: 'Slot booked successfully',
      slot: formatSlot(slot),
      booking: newBooking,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error booking slot', error: error.message });
  }
};
