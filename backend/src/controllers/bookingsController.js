const Booking = require('../models/Booking');
const Slot = require('../models/Slot');

exports.getBookings = async (req, res) => {
  try {
    const bookings = await Booking.find().populate('slot').sort({ createdAt: -1 });
    res.status(200).json(bookings);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching bookings' });
  }
};

exports.createBooking = async (req, res) => {
  try {
    const { slotId, courtName, paymentMethod } = req.body;
    
    // Create new booking
    const newBooking = await Booking.create({
      slot: slotId,
      courtName: courtName || 'Badminton Court 1',
      paymentMethod: paymentMethod || 'card',
      bookingId: `SS-${Math.floor(10000 + Math.random() * 90000)}`
    });

    const populatedBooking = await Booking.findById(newBooking._id).populate('slot');
    res.status(201).json({ message: 'Booking created successfully', booking: populatedBooking });
  } catch (error) {
    res.status(500).json({ message: 'Error creating booking' });
  }
};
