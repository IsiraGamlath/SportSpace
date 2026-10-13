const mongoose = require('mongoose');
const ContactRequest = require('../models/ContactRequest');
const User = require('../models/User');
const { dispatchNotification } = require('./notificationsController');

const formatRequest = (doc) => {
  const obj = doc.toObject ? doc.toObject() : { ...doc };
  obj.id = obj._id ? obj._id.toString() : obj.id;
  return obj;
};

// GET /api/contact-requests
exports.getContactRequests = async (req, res) => {
  try {
    const authUserId = req.firebaseUser?.uid;
    const { userId, facilityId } = req.query;
    const filter = {};

    // Isolate by userId if explicitly requested or authenticated
    const targetUserId = userId || authUserId;
    if (targetUserId) {
      filter.userId = targetUserId;
    }
    if (facilityId) filter.facilityId = facilityId;

    const requests = await ContactRequest.find(filter).sort({ createdAt: -1 });

    // Collect all unique userIds to lookup details
    const uniqueUserIds = [...new Set(requests.map(r => r.userId).filter(Boolean))];
    const objectIds = uniqueUserIds.filter(id => mongoose.isValidObjectId(id));

    const matchedUsers = await User.find({
      $or: [
        { firebaseUid: { $in: uniqueUserIds } },
        { _id: { $in: objectIds } }
      ]
    }).lean();

    const userMap = new Map();
    matchedUsers.forEach(u => {
      if (u.firebaseUid) userMap.set(u.firebaseUid, u);
      if (u._id) userMap.set(u._id.toString(), u);
    });

    const enriched = requests.map(doc => {
      const formatted = formatRequest(doc);
      const user = userMap.get(formatted.userId);
      if (user) {
        formatted.userName = user.fullName;
        formatted.userEmail = user.email;
        formatted.userRole = user.role || 'Community / Public User';
      } else if (formatted.userId === 'guest') {
        formatted.userName = 'Guest User';
        formatted.userEmail = '';
        formatted.userRole = 'Community / Public User';
      } else {
        formatted.userName = 'Community Member';
        formatted.userEmail = '';
        formatted.userRole = 'Community / Public User';
      }
      return formatted;
    });

    res.status(200).json(enriched);
  } catch (error) {
    res.status(500).json({
      message: 'Failed to fetch contact requests',
      error: error.message,
    });
  }
};

// GET /api/contact-requests/:id
exports.getContactRequestById = async (req, res) => {
  try {
    const { id } = req.params;
    const request = await ContactRequest.findById(id);
    if (!request) {
      return res.status(404).json({ message: 'Request not found' });
    }
    res.status(200).json(formatRequest(request));
  } catch (error) {
    res.status(500).json({
      message: 'Failed to fetch contact request',
      error: error.message,
    });
  }
};

// POST /api/contact-requests
exports.createContactRequest = async (req, res) => {
  try {
    const authUserId = req.firebaseUser?.uid;
    const { facilityId, facilityName, userId, type, message } = req.body;

    if (!facilityId || !type || !message) {
      return res.status(400).json({
        message: 'facilityId, type, and message are required',
      });
    }

    // Associate with authenticated user ID, explicitly passed userId, or default to guest
    const effectiveUserId = (userId && userId !== 'guest')
      ? userId
      : (authUserId || userId || 'guest');

    const doc = await ContactRequest.create({
      facilityId,
      facilityName: facilityName || '',
      userId: effectiveUserId,
      type,
      message: message.trim(),
    });

    const formatted = formatRequest(doc);

    // Requirement 13: notify the submitting community member
    const readableType =
      type === 'accessibilityRequest'
        ? 'Accessibility Request'
        : 'Contact Enquiry';
    const targetFacility = facilityName || facilityId;

    await dispatchNotification({
      targetRoles: 'communityMember',
      userId: effectiveUserId,
      category: 'request',
      title: 'Request Submitted',
      message: `Your ${readableType} for ${targetFacility} has been submitted successfully.`,
      accentColor: 'green',
      metadata: { requestId: formatted.id, facilityId },
    });

    res.status(201).json(formatted);
  } catch (error) {
    res.status(500).json({
      message: 'Failed to create contact request',
      error: error.message,
    });
  }
};

// PUT /api/contact-requests/:id
exports.updateContactRequest = async (req, res) => {
  try {
    const { id } = req.params;
    const authUserId = req.firebaseUser?.uid;
    const { type, message, status } = req.body;

    const request = await ContactRequest.findById(id);
    if (!request) {
      return res.status(404).json({ message: 'Request not found' });
    }

    if (authUserId && request.userId && request.userId !== 'guest' && request.userId !== authUserId) {
      return res.status(403).json({ message: 'Unauthorized to update this request' });
    }

    if (type !== undefined) request.type = type;
    if (message !== undefined) request.message = message.trim();
    if (status !== undefined) request.status = status;

    await request.save();
    res.status(200).json(formatRequest(request));
  } catch (error) {
    res.status(500).json({
      message: 'Failed to update contact request',
      error: error.message,
    });
  }
};

// DELETE /api/contact-requests/:id
exports.deleteContactRequest = async (req, res) => {
  try {
    const { id } = req.params;
    const authUserId = req.firebaseUser?.uid;

    const request = await ContactRequest.findById(id);
    if (!request) {
      return res.status(404).json({ message: 'Request not found' });
    }

    if (authUserId && request.userId && request.userId !== 'guest' && request.userId !== authUserId) {
      return res.status(403).json({ message: 'Unauthorized to delete this request' });
    }

    const removed = await ContactRequest.findByIdAndDelete(id);

    const readableType =
      removed.type === 'accessibilityRequest'
        ? 'Accessibility Request'
        : 'Contact Enquiry';

    await dispatchNotification({
      targetRoles: 'communityMember',
      userId: removed.userId,
      category: 'facility',
      title: 'Request Deleted',
      message: `Your ${readableType} for ${removed.facilityId || 'facility'} has been deleted.`,
      accentColor: 'red',
      metadata: { requestId: removed._id.toString() },
    });

    res.status(200).json({ message: 'Request deleted successfully' });
  } catch (error) {
    res.status(500).json({
      message: 'Failed to delete contact request',
      error: error.message,
    });
  }
};
