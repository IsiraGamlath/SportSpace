const SavedEvent = require('../models/SavedEvent');

// GET /api/saved-events
exports.getSavedEvents = async (req, res) => {
  try {
    const { userId = 'guest' } = req.query;
    const docs = await SavedEvent.find({ userId });
    res.status(200).json(
      docs.map((doc) => ({
        id: doc._id.toString(),
        userId: doc.userId,
        eventId: doc.eventId,
        createdAt: doc.createdAt,
      }))
    );
  } catch (error) {
    res.status(500).json({
      message: 'Failed to fetch saved events',
      error: error.message,
    });
  }
};

// POST /api/saved-events
exports.saveEvent = async (req, res) => {
  try {
    const { eventId, userId = 'guest' } = req.body;
    if (!eventId) {
      return res.status(400).json({ message: 'eventId is required' });
    }

    const existing = await SavedEvent.findOne({ userId, eventId });
    if (existing) {
      return res.status(200).json({
        id: existing._id.toString(),
        userId: existing.userId,
        eventId: existing.eventId,
        createdAt: existing.createdAt,
      });
    }

    const doc = await SavedEvent.create({ userId, eventId });
    res.status(201).json({
      id: doc._id.toString(),
      userId: doc.userId,
      eventId: doc.eventId,
      createdAt: doc.createdAt,
    });
  } catch (error) {
    res.status(500).json({
      message: 'Failed to save event',
      error: error.message,
    });
  }
};

// DELETE /api/saved-events/:eventId
exports.unsaveEvent = async (req, res) => {
  try {
    const { eventId } = req.params;
    const { userId = 'guest' } = req.query;

    await SavedEvent.findOneAndDelete({ userId, eventId });
    res.status(200).json({ message: 'Event unsaved successfully' });
  } catch (error) {
    res.status(500).json({
      message: 'Failed to unsave event',
      error: error.message,
    });
  }
};
