let slots = [
  {
    id: 'slot_1',
    time: '5:00 PM',
    durationRange: '5:00 PM – 6:00 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    id: 'slot_2',
    time: '5:30 PM',
    durationRange: '5:30 PM – 6:30 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    id: 'slot_3',
    time: '6:00 PM',
    durationRange: '6:00 PM – 7:00 PM',
    status: 'available', // changed to available by default for the demo
    price: 2500,
    date: 'Tomorrow'
  },
  {
    id: 'slot_4',
    time: '6:30 PM',
    durationRange: '6:30 PM – 7:30 PM',
    status: 'booked',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    id: 'slot_5',
    time: '7:00 PM',
    durationRange: '7:00 PM – 8:00 PM',
    status: 'available',
    price: 2500,
    isConflictTrigger: true,
    date: 'Tomorrow'
  },
  {
    id: 'slot_6',
    time: '7:30 PM',
    durationRange: '7:30 PM – 8:30 PM',
    status: 'available',
    price: 2500,
    date: 'Tomorrow'
  },
  {
    id: 'slot_7',
    time: '8:00 PM',
    durationRange: '8:00 PM – 9:00 PM',
    status: 'booked',
    price: 2500,
    date: 'Tomorrow'
  }
];

exports.getSlots = (req, res) => {
  const { date } = req.query;
  let filteredSlots = slots;
  if (date) {
    filteredSlots = slots.filter(s => s.date === date);
  }
  res.status(200).json(filteredSlots);
};

exports.bookSlot = (req, res) => {
  const { id } = req.params;
  const slotIndex = slots.findIndex(s => s.id === id);

  if (slotIndex === -1) {
    return res.status(404).json({ message: 'Slot not found' });
  }

  if (slots[slotIndex].status === 'booked') {
    return res.status(409).json({ message: 'Slot already booked' });
  }

  // Handle conflict demo trigger
  if (slots[slotIndex].isConflictTrigger) {
    // Simulate it getting booked right before the user books it
    slots[slotIndex].status = 'booked';
    slots[slotIndex].isConflictTrigger = false;
    return res.status(409).json({ message: 'Slot was just booked by someone else' });
  }

  slots[slotIndex].status = 'booked';
  res.status(200).json({ message: 'Slot booked successfully', slot: slots[slotIndex] });
};
