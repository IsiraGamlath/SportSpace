const Slot = require('../models/Slot');

const mockSlots = [
  {
    time: '5:00 PM',
    durationRange: '5:00 PM – 6:00 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    time: '5:30 PM',
    durationRange: '5:30 PM – 6:30 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    time: '6:00 PM',
    durationRange: '6:00 PM – 7:00 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    time: '6:30 PM',
    durationRange: '6:30 PM – 7:30 PM',
    status: 'booked',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    time: '7:00 PM',
    durationRange: '7:00 PM – 8:00 PM',
    status: 'available',
    price: 2500,
    isConflictTrigger: true,
    date: 'Tomorrow'
  },
  {
    time: '7:30 PM',
    durationRange: '7:30 PM – 8:30 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    time: '8:00 PM',
    durationRange: '8:00 PM – 9:00 PM',
    status: 'booked',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    time: '8:30 PM',
    durationRange: '8:30 PM – 9:30 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    time: '9:00 PM',
    durationRange: '9:00 PM – 10:00 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    time: '9:30 PM',
    durationRange: '9:30 PM – 10:30 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    time: '5:00 PM',
    durationRange: '5:00 PM – 6:00 PM',
    status: 'available',
    price: 2500,
    date: 'Today'
  },
  {
    time: '6:00 PM',
    durationRange: '6:00 PM – 7:00 PM',
    status: 'available',
    price: 2500,
    date: 'Today'
  }
];

exports.seedSlots = async () => {
  try {
    const count = await Slot.countDocuments();
    if (count === 0) {
      await Slot.insertMany(mockSlots);
      console.log('Database seeded with mock slots');
    }
  } catch (err) {
    console.error('Error seeding slots:', err);
  }
};

exports.getSlots = async (req, res) => {
  try {
    const { date } = req.query;
    let query = {};
    if (date) {
      query.date = date;
    }
    const slots = await Slot.find(query);
    
    // Map _id to id for the flutter frontend
    const mappedSlots = slots.map(slot => {
      const slotObj = slot.toObject();
      slotObj.id = slotObj._id.toString();
      return slotObj;
    });

    res.status(200).json(mappedSlots);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching slots', error: error.message });
  }
};

exports.bookSlot = async (req, res) => {
  try {
    const { id } = req.params;
    const slot = await Slot.findById(id);

    if (!slot) {
      return res.status(404).json({ message: 'Slot not found' });
    }

    if (slot.status === 'booked') {
      return res.status(409).json({ message: 'Slot already booked' });
    }

    if (slot.isConflictTrigger) {
      slot.status = 'booked';
      slot.isConflictTrigger = false;
      await slot.save();
      return res.status(409).json({ message: 'Slot was just booked by someone else' });
    }

    slot.status = 'booked';
    await slot.save();
    
    // Create the booking record
    const Booking = require('../models/Booking');
    const newBooking = await Booking.create({
      slot: slot._id,
      courtName: 'Badminton Court 1',
      paymentMethod: 'card',
      bookingId: `SS-${Math.floor(10000 + Math.random() * 90000)}`
    });
    
    const slotObj = slot.toObject();
    slotObj.id = slotObj._id.toString();
    
    res.status(200).json({ message: 'Slot booked successfully', slot: slotObj, booking: newBooking });
  } catch (error) {
    res.status(500).json({ message: 'Error booking slot', error: error.message });
  }
};
