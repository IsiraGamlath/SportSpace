const ContactRequest = require('../models/ContactRequest');
const { dispatchNotification } = require('./notificationsController');

const formatRequest = (doc) => {
  const obj = doc.toObject ? doc.toObject() : { ...doc };
  obj.id = obj._id ? obj._id.toString() : obj.id;
  return obj;
};

// GET /api/contact-requests
exports.getContactRequests = async (req, res) => {
  try {
    const { userId, facilityId } = req.query;
    const filter = {};
    if (userId) filter.userId = userId;
    if (facilityId) filter.facilityId = facilityId;

    const requests = await ContactRequest.find(filter).sort({ createdAt: -1 });
    res.status(200).json(requests.map(formatRequest));
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
    const { facilityId, facilityName, userId = 'guest', type, message } = req.body;

    if (!facilityId || !type || !message) {
      return res.status(400).json({
        message: 'facilityId, type, and message are required',
      });
    }

    const doc = await ContactRequest.create({
      facilityId,
      facilityName: facilityName || '',
      userId,
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
      userId: userId,
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
    const { type, message, status } = req.body;

    const request = await ContactRequest.findById(id);
    if (!request) {
      return res.status(404).json({ message: 'Request not found' });
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
    const removed = await ContactRequest.findByIdAndDelete(id);
    if (!removed) {
      return res.status(404).json({ message: 'Request not found' });
    }
    res.status(200).json({ message: 'Request deleted successfully' });
  } catch (error) {
    res.status(500).json({
      message: 'Failed to delete contact request',
      error: error.message,
    });
  }
};
