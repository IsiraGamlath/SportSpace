const Notification = require('../models/Notification');

// Formatter to match mobile JSON needs
const formatNotification = (n) => {
  const obj = n.toObject ? n.toObject() : { ...n };
  obj.id = obj._id ? obj._id.toString() : obj.id;

  // Compute a human-readable timeAgo if not provided
  if (!obj.timeAgo && obj.createdAt) {
    const diffMs = Date.now() - new Date(obj.createdAt).getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMins / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffMins < 1) obj.timeAgo = 'Just now';
    else if (diffMins < 60) obj.timeAgo = `${diffMins} minutes ago`;
    else if (diffHours < 24) obj.timeAgo = `${diffHours} hours ago`;
    else if (diffDays === 1) obj.timeAgo = 'Yesterday';
    else obj.timeAgo = `${diffDays} days ago`;
  } else if (!obj.timeAgo) {
    obj.timeAgo = 'Just now';
  }

  return obj;
};

// Internal notification dispatcher that can be called from other controllers
exports.dispatchNotification = async ({
  targetRoles, // e.g. ['player', 'facilityManager', 'communityMember'] or single string
  userId = null,
  category = 'event',
  title,
  message,
  accentColor = 'orange',
  metadata = {},
}) => {
  try {
    const roles = Array.isArray(targetRoles) ? targetRoles : [targetRoles || 'all'];
    const created = [];

    for (const role of roles) {
      const doc = await Notification.create({
        targetRole: role,
        userId: userId || null,
        category,
        title,
        message,
        accentColor,
        metadata,
      });
      created.push(formatNotification(doc));
    }
    return created;
  } catch (error) {
    console.error('Failed to dispatch notification:', error.message);
    return [];
  }
};

// Seed default initial notifications if empty
const seedDefaultNotifications = async () => {
  try {
    const count = await Notification.countDocuments();
    if (count > 0) return;

    const defaults = [
      {
        targetRole: 'all',
        category: 'schedule',
        title: 'Schedule Updated',
        message: 'Colombo Community Badminton Open — start time changed from 9:00 AM to 10:00 AM.',
        accentColor: 'orange',
        createdAt: new Date(Date.now() - 10 * 60 * 1000), // 10 mins ago
      },
      {
        targetRole: 'all',
        category: 'event',
        title: 'Event Reminder',
        message: 'Youth Football Training Day starts tomorrow at 4:00 PM.',
        accentColor: 'green',
        createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
      },
      {
        targetRole: 'all',
        category: 'facility',
        title: 'Facility Update',
        message: 'Parking area at City Sports Ground will be temporarily unavailable on 22 Sep.',
        accentColor: 'orange',
        createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 day ago
      },
      {
        targetRole: 'all',
        category: 'event',
        title: 'Event Cancelled',
        message: 'Community Swimming Meet has been postponed due to maintenance.',
        accentColor: 'red',
        createdAt: new Date(Date.now() - 48 * 60 * 60 * 1000), // 2 days ago
      },
    ];

    await Notification.insertMany(defaults);
  } catch (err) {
    console.warn('Notification seeding skipped:', err.message);
  }
};

// GET /api/notifications
exports.getNotifications = async (req, res) => {
  try {
    await seedDefaultNotifications();

    const { role, userId, category } = req.query;
    const filter = {};

    if (role && role !== 'all') {
      filter.$or = [
        { targetRole: role },
        { targetRole: 'all' },
      ];
    }

    if (userId) {
      if (filter.$or) {
        filter.$and = [
          { $or: filter.$or },
          { $or: [{ userId: null }, { userId }] },
        ];
        delete filter.$or;
      } else {
        filter.$or = [{ userId: null }, { userId }];
      }
    }

    if (category && category !== 'All') {
      filter.category = category.toLowerCase();
    }

    const docs = await Notification.find(filter).sort({ createdAt: -1 }).limit(50);
    res.status(200).json(docs.map(formatNotification));
  } catch (error) {
    res.status(500).json({
      message: 'Failed to fetch notifications',
      error: error.message,
    });
  }
};

// POST /api/notifications
exports.createNotification = async (req, res) => {
  try {
    const { targetRole, userId, category, title, message, accentColor, metadata } = req.body;
    if (!title || !message) {
      return res.status(400).json({ message: 'Title and message are required' });
    }

    const doc = await Notification.create({
      targetRole: targetRole || 'all',
      userId: userId || null,
      category: category || 'event',
      title: title.trim(),
      message: message.trim(),
      accentColor: accentColor || 'orange',
      metadata: metadata || {},
    });

    res.status(201).json(formatNotification(doc));
  } catch (error) {
    res.status(500).json({
      message: 'Failed to create notification',
      error: error.message,
    });
  }
};

// PATCH /api/notifications/:id/read
exports.markAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await Notification.findByIdAndUpdate(
      id,
      { $set: { isRead: true } },
      { new: true }
    );
    if (!updated) {
      return res.status(404).json({ message: 'Notification not found' });
    }
    res.status(200).json(formatNotification(updated));
  } catch (error) {
    res.status(500).json({
      message: 'Failed to update notification',
      error: error.message,
    });
  }
};

// DELETE /api/notifications/:id
exports.deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const removed = await Notification.findByIdAndDelete(id);
    if (!removed) {
      return res.status(404).json({ message: 'Notification not found' });
    }
    res.status(200).json({ message: 'Notification deleted successfully' });
  } catch (error) {
    res.status(500).json({
      message: 'Failed to delete notification',
      error: error.message,
    });
  }
};
