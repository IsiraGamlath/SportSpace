const PaymentVerification = require('../models/PaymentVerification');
const Booking = require('../models/Booking');

// Helper to format output
const formatVerification = (doc) => {
  const obj = doc.toObject ? doc.toObject() : { ...doc };
  obj.id = obj._id.toString();
  return obj;
};

// Seed sample payment verification record (SS-20481 from Figma design)
exports.seedPaymentVerifications = async () => {
  try {
    const count = await PaymentVerification.countDocuments();
    if (count === 0) {
      // Find matching booking if any exists
      const booking = await Booking.findOne({ bookingId: 'SS-20481' });

      await PaymentVerification.create({
        bookingId: 'SS-20481',
        bookingRef: booking ? booking._id : null,
        courtName: 'Badminton Court 1',
        playerName: 'Kasun Perera',
        playerPhone: '077 123 4567',
        playerEmail: 'kasun.p@email.com',
        amount: 2500,
        paymentMethod: 'card',
        paymentRef: 'PMT-88213',
        paymentStatus: 'pending',
      });
      console.log('Seeded sample PaymentVerification record (SS-20481)');
    }
  } catch (err) {
    console.error('Error seeding payment verifications:', err);
  }
};

// Helper to find by Mongo ID or bookingId (e.g. SS-20481)
const findVerification = async (idOrBookingId) => {
  let doc = null;
  if (/^[0-9a-fA-F]{24}$/.test(idOrBookingId)) {
    doc = await PaymentVerification.findById(idOrBookingId);
  }
  if (!doc) {
    doc = await PaymentVerification.findOne({ bookingId: idOrBookingId });
  }
  return doc;
};

// GET /api/payment-verifications
exports.getPaymentVerifications = async (req, res) => {
  try {
    const { paymentStatus, courtName, bookingId } = req.query;
    const query = {};

    if (paymentStatus) query.paymentStatus = paymentStatus;
    if (courtName) query.courtName = courtName;
    if (bookingId) query.bookingId = bookingId;

    const list = await PaymentVerification.find(query).sort({ createdAt: -1 });
    res.status(200).json(list.map(formatVerification));
  } catch (error) {
    res.status(500).json({
      message: 'Error fetching payment verifications',
      error: error.message,
    });
  }
};

// GET /api/payment-verifications/:id/status
exports.getVerificationStatus = async (req, res) => {
  try {
    const { id } = req.params;
    let doc = await findVerification(id);

    // If not found yet, check if there's a booking with this bookingId and create initial record
    if (!doc) {
      const booking = await Booking.findOne({ bookingId: id });
      if (booking) {
        doc = await PaymentVerification.create({
          bookingId: booking.bookingId,
          bookingRef: booking._id,
          courtName: booking.courtName || 'Badminton Court 1',
          playerName: 'Kasun Perera',
          playerPhone: '077 123 4567',
          playerEmail: 'kasun.p@email.com',
          amount: 2500,
          paymentMethod: booking.paymentMethod || 'card',
          paymentRef: `PMT-${Math.floor(10000 + Math.random() * 90000)}`,
          paymentStatus: 'pending',
        });
      }
    }

    if (!doc) {
      return res.status(404).json({ message: 'Payment verification record not found' });
    }

    res.status(200).json(formatVerification(doc));
  } catch (error) {
    res.status(500).json({
      message: 'Error fetching verification status',
      error: error.message,
    });
  }
};

// PATCH /api/payment-verifications/:id/verify
exports.verifyPayment = async (req, res) => {
  try {
    const { id } = req.params;
    const { verifiedBy = 'Manager', notes } = req.body || {};

    let doc = await findVerification(id);

    if (!doc) {
      // Auto-create verification record for this booking if not yet created
      doc = await PaymentVerification.create({
        bookingId: id,
        courtName: 'Badminton Court 1',
        paymentStatus: 'pending',
      });
    }

    doc.paymentStatus = 'verified';
    doc.verifiedAt = new Date();
    doc.verifiedBy = verifiedBy;
    doc.verificationNotes = notes || 'Payment verified by Manager';

    await doc.save();

    res.status(200).json({
      message: 'Payment Confirmed! Booking status updated to Paid.',
      verification: formatVerification(doc),
    });
  } catch (error) {
    res.status(500).json({
      message: 'Error verifying payment',
      error: error.message,
    });
  }
};

// PATCH /api/payment-verifications/:id/unpaid
exports.markPaymentUnpaid = async (req, res) => {
  try {
    const { id } = req.params;
    const { verifiedBy = 'Manager', notes } = req.body || {};

    let doc = await findVerification(id);

    if (!doc) {
      doc = await PaymentVerification.create({
        bookingId: id,
        courtName: 'Badminton Court 1',
        paymentStatus: 'pending',
      });
    }

    doc.paymentStatus = 'unpaid';
    doc.verifiedAt = new Date();
    doc.verifiedBy = verifiedBy;
    doc.verificationNotes = notes || 'Marked as unpaid by Manager';

    await doc.save();

    res.status(200).json({
      message: 'Booking payment marked as Unpaid.',
      verification: formatVerification(doc),
    });
  } catch (error) {
    res.status(500).json({
      message: 'Error updating payment status to unpaid',
      error: error.message,
    });
  }
};

// POST /api/payment-verifications (Create manually if needed)
exports.createPaymentVerification = async (req, res) => {
  try {
    const {
      bookingId,
      bookingRef,
      courtName = 'Badminton Court 1',
      playerName = 'Kasun Perera',
      playerPhone = '077 123 4567',
      playerEmail = 'kasun.p@email.com',
      amount = 2500,
      paymentMethod = 'card',
      paymentRef = 'PMT-88213',
      paymentStatus = 'pending',
      notes,
    } = req.body;

    if (!bookingId) {
      return res.status(400).json({ message: 'bookingId is required' });
    }

    const doc = await PaymentVerification.create({
      bookingId,
      bookingRef,
      courtName,
      playerName,
      playerPhone,
      playerEmail,
      amount,
      paymentMethod,
      paymentRef,
      paymentStatus,
      verificationNotes: notes,
    });

    res.status(201).json({
      message: 'Payment verification record created successfully',
      verification: formatVerification(doc),
    });
  } catch (error) {
    res.status(500).json({
      message: 'Error creating payment verification',
      error: error.message,
    });
  }
};
