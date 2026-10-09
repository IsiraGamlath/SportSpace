const Event = require('../models/Event');
const { dispatchNotification } = require('./notificationsController');

const formatEvent = (e) => {
  const obj = e.toObject ? e.toObject() : { ...e };
  obj.id = obj._id ? obj._id.toString() : obj.id;
  return obj;
};

// Seed default events if database is empty
const seedDefaultEvents = async () => {
  try {
    const count = await Event.countDocuments();
    if (count > 0) return;

    const defaults = [
      {
        title: 'Colombo Community Badminton Open',
        sport: 'Badminton',
        date: '20 September 2026',
        time: '9:00 AM – 5:00 PM',
        eventDate: new Date('2026-09-20T09:00:00.000Z'),
        location: 'Colombo Sports Hub, Colombo',
        facility: 'Colombo Sports Hub',
        facilityId: 'colombo_sports_hub',
        eventType: 'Tournament',
        status: 'Open',
        imageUrl: 'assets/images/badminton.jpg',
        description:
          'An open community badminton tournament welcoming players of all skill levels, with singles and doubles categories and on-site equipment rental.',
        organizerName: 'Colombo Community Sports Association',
        organizerInitials: 'CC',
        timeline: [
          { time: '09:00 AM', label: 'Registration' },
          { time: '10:00 AM', label: 'Opening Matches' },
          { time: '12:30 PM', label: 'Lunch Break' },
          { time: '01:30 PM', label: 'Quarter Finals' },
          { time: '04:00 PM', label: 'Finals' },
        ],
      },
      {
        title: 'Youth Football Training Day',
        sport: 'Football',
        date: '22 September 2026',
        time: '4:00 PM – 7:00 PM',
        eventDate: new Date('2026-09-22T16:00:00.000Z'),
        location: 'City Sports Ground, Colombo',
        facility: 'City Sports Ground',
        facilityId: 'city_sports_ground',
        eventType: 'Training',
        status: 'Confirmed',
        imageUrl: 'assets/images/football.jpg',
        description:
          'A structured training session for youth players focused on fundamentals, drills, and a friendly scrimmage to close the day.',
        organizerName: 'City Youth Football Club',
        organizerInitials: 'CY',
        timeline: [
          { time: '04:00 PM', label: 'Warm-up' },
          { time: '04:30 PM', label: 'Skills Drills' },
          { time: '06:00 PM', label: 'Scrimmage Match' },
          { time: '06:45 PM', label: 'Cool Down & Feedback' },
        ],
      },
      {
        title: 'Weekend Basketball League',
        sport: 'Basketball',
        date: '19 September 2026',
        time: '2:00 PM – 6:00 PM',
        eventDate: new Date('2026-09-19T14:00:00.000Z'),
        location: 'Downtown Arena, Colombo',
        facility: 'Downtown Arena',
        facilityId: 'downtown_arena',
        eventType: 'League',
        status: 'Open',
        imageUrl:
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1200&q=80',
        description:
          'Weekly league matches open to registered teams, with standings updated after every round.',
        organizerName: 'Downtown Basketball League',
        organizerInitials: 'DB',
        timeline: [
          { time: '02:00 PM', label: 'Check-in' },
          { time: '02:30 PM', label: 'Round 1 Matches' },
          { time: '04:30 PM', label: 'Round 2 Matches' },
          { time: '05:45 PM', label: 'Standings & Close' },
        ],
      },
    ];

    await Event.insertMany(defaults);
  } catch (err) {
    console.warn('Event seeding skipped:', err.message);
  }
};

// GET /api/events
exports.getEvents = async (req, res) => {
  try {
    await seedDefaultEvents();
    const { sport, status, search } = req.query;
    const filter = {};

    if (sport && sport !== 'All') {
      filter.sport = { $regex: `^${sport}$`, $options: 'i' };
    }
    if (status && status !== 'All') {
      filter.status = status;
    }
    if (search && search.trim()) {
      filter.$or = [
        { title: { $regex: search.trim(), $options: 'i' } },
        { location: { $regex: search.trim(), $options: 'i' } },
        { facility: { $regex: search.trim(), $options: 'i' } },
        { sport: { $regex: search.trim(), $options: 'i' } },
      ];
    }

    const events = await Event.find(filter).sort({ eventDate: 1, createdAt: -1 });
    res.status(200).json(events.map(formatEvent));
  } catch (error) {
    res.status(500).json({
      message: 'Failed to fetch events',
      error: error.message,
    });
  }
};

// GET /api/events/:id
exports.getEventById = async (req, res) => {
  try {
    const { id } = req.params;
    const event = await Event.findById(id);
    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }
    res.status(200).json(formatEvent(event));
  } catch (error) {
    res.status(500).json({
      message: 'Failed to fetch event',
      error: error.message,
    });
  }
};

// POST /api/events
exports.createEvent = async (req, res) => {
  try {
    const {
      title,
      sport,
      date,
      time,
      location,
      facility,
      facilityId,
      eventType,
      description,
      organizerName,
      organizerInitials,
      imageUrl,
      createdBy = 'player',
      timeline,
    } = req.body;

    if (!title || !sport || !date || !time) {
      return res.status(400).json({
        message: 'title, sport, date, and time are required',
      });
    }

    const newEvent = await Event.create({
      title: title.trim(),
      sport: sport.trim(),
      date: date.trim(),
      time: time.trim(),
      location: location ? location.trim() : 'Colombo Sports Hub, Colombo',
      facility: facility ? facility.trim() : 'Colombo Sports Hub',
      facilityId: facilityId || 'colombo_sports_hub',
      eventType: eventType || 'Tournament',
      description: description || '',
      organizerName: organizerName || 'Colombo Sports Community',
      organizerInitials: organizerInitials || 'CS',
      imageUrl: imageUrl || 'assets/images/badminton.jpg',
      createdBy,
      timeline: timeline || [],
    });

    const formatted = formatEvent(newEvent);

    // Requirement 5: when player creates an event, notify player, facility manager, and community member
    await dispatchNotification({
      targetRoles: ['player', 'facilityManager', 'communityMember'],
      category: 'schedule',
      title: 'New Event Scheduled',
      message: `${formatted.title} has been scheduled for ${formatted.date} (${formatted.time}).`,
      accentColor: 'orange',
      metadata: { eventId: formatted.id, action: 'create' },
    });

    res.status(201).json(formatted);
  } catch (error) {
    res.status(500).json({
      message: 'Failed to create event',
      error: error.message,
    });
  }
};

// PUT /api/events/:id
exports.updateEvent = async (req, res) => {
  try {
    const { id } = req.params;
    const event = await Event.findById(id);
    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    const fields = [
      'title',
      'sport',
      'date',
      'time',
      'location',
      'facility',
      'facilityId',
      'eventType',
      'description',
      'status',
      'imageUrl',
      'timeline',
    ];

    fields.forEach((field) => {
      if (req.body[field] !== undefined) {
        event[field] = req.body[field];
      }
    });

    await event.save();
    const formatted = formatEvent(event);

    // Requirement 5: when event edited, notify player, facility manager, and community member
    await dispatchNotification({
      targetRoles: ['player', 'facilityManager', 'communityMember'],
      category: 'schedule',
      title: 'Schedule Updated',
      message: `${formatted.title} — start time/details changed (${formatted.time}).`,
      accentColor: 'orange',
      metadata: { eventId: formatted.id, action: 'edit' },
    });

    res.status(200).json(formatted);
  } catch (error) {
    res.status(500).json({
      message: 'Failed to update event',
      error: error.message,
    });
  }
};

// PATCH /api/events/:id/cancel
exports.cancelEvent = async (req, res) => {
  try {
    const { id } = req.params;
    const event = await Event.findById(id);
    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    event.status = 'Cancelled';
    await event.save();
    const formatted = formatEvent(event);

    // Requirement 5: when event cancelled, notify player, facility manager, and community member
    await dispatchNotification({
      targetRoles: ['player', 'facilityManager', 'communityMember'],
      category: 'event',
      title: 'Event Cancelled',
      message: `${formatted.title} has been postponed or cancelled.`,
      accentColor: 'red',
      metadata: { eventId: formatted.id, action: 'cancel' },
    });

    res.status(200).json(formatted);
  } catch (error) {
    res.status(500).json({
      message: 'Failed to cancel event',
      error: error.message,
    });
  }
};

// DELETE /api/events/:id
exports.deleteEvent = async (req, res) => {
  try {
    const { id } = req.params;
    const removed = await Event.findByIdAndDelete(id);
    if (!removed) {
      return res.status(404).json({ message: 'Event not found' });
    }

    await dispatchNotification({
      targetRoles: ['player', 'facilityManager', 'communityMember'],
      category: 'event',
      title: 'Event Cancelled',
      message: `${removed.title} has been removed from the schedule.`,
      accentColor: 'red',
      metadata: { eventId: id, action: 'delete' },
    });

    res.status(200).json({ message: 'Event deleted successfully' });
  } catch (error) {
    res.status(500).json({
      message: 'Failed to delete event',
      error: error.message,
    });
  }
};
