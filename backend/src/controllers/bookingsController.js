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
    const { slotId, courtName, paymentMethod, paymentIntentId } = req.body;
    
    // Create new booking
    const newBooking = await Booking.create({
      slot: slotId,
      courtName: courtName || 'Badminton Court 1',
      paymentMethod: paymentMethod || 'card',
      paymentIntentId,
      bookingId: `SS-${Math.floor(10000 + Math.random() * 90000)}`
    });

    const populatedBooking = await Booking.findById(newBooking._id).populate('slot');
    res.status(201).json({ message: 'Booking created successfully', booking: populatedBooking });
  } catch (error) {
    res.status(500).json({ message: 'Error creating booking' });
  }
};

const stripe = process.env.STRIPE_SECRET_KEY
  ? require('stripe')(process.env.STRIPE_SECRET_KEY)
  : null;

exports.cancelBooking = async (req, res) => {
  try {
    const { id } = req.params;
    const booking = await Booking.findById(id).populate('slot');

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    if (booking.status === 'cancelled') {
      return res.status(400).json({ message: 'Booking is already cancelled' });
    }

    // Process refund if paid with card
    if (booking.paymentMethod === 'card' && booking.paymentIntentId) {
      if (!stripe) {
        return res.status(503).json({
          message: 'Payment service is not configured',
        });
      }

      try {
        const refund = await stripe.refunds.create({
          payment_intent: booking.paymentIntentId
        });
        booking.refundId = refund.id;
      } catch (stripeError) {
        console.error('Stripe refund failed:', stripeError);
        // Continue to cancel booking locally even if Stripe refund fails 
        // to prevent being stuck in a bad state, or handle it based on policy.
      }
    }

    // Update booking status
    booking.status = 'cancelled';
    await booking.save();

    // Make slot available again
    if (booking.slot) {
      const slot = await Slot.findById(booking.slot._id);
      if (slot) {
        slot.status = 'available';
        await slot.save();
      }
    }

    res.status(200).json({ message: 'Booking cancelled successfully', booking });
  } catch (error) {
    console.error('Error cancelling booking:', error);
    res.status(500).json({ message: 'Error cancelling booking', error: error.message });
  }
};

exports.rescheduleBooking = async (req, res) => {
  try {
    const { id } = req.params;
    const { newSlotId } = req.body;
    
    const booking = await Booking.findById(id).populate('slot');
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    if (booking.status !== 'confirmed' && booking.status !== 'rescheduled') return res.status(400).json({ message: 'Can only reschedule active bookings' });
    
    const newSlot = await Slot.findById(newSlotId);
    if (!newSlot) return res.status(404).json({ message: 'New slot not found' });
    if (newSlot.status === 'booked') return res.status(400).json({ message: 'New slot is already booked' });
    
    // Mark old slot available
    if (booking.slot) {
      const oldSlot = await Slot.findById(booking.slot._id);
      if (oldSlot) {
        oldSlot.status = 'available';
        await oldSlot.save();
      }
    }
    
    // Mark new slot booked
    newSlot.status = 'booked';
    await newSlot.save();
    
    // Update booking
    booking.slot = newSlot._id;
    booking.status = 'rescheduled';
    await booking.save();
    
    res.status(200).json({ message: 'Booking rescheduled', booking });
  } catch (err) {
    console.error('Error rescheduling booking:', err);
    res.status(500).json({ message: 'Error rescheduling booking', error: err.message });
  }
};
