const PaymentVerification = require('../models/PaymentVerification');
const Booking = require('../models/Booking');
const Slot = require('../models/Slot');
const User = require('../models/User');
const { dispatchNotification } = require('./notificationsController');

// Helper to format output
const formatVerification = (doc) => {
  const obj = doc.toObject ? doc.toObject() : { ...doc };
  obj.id = obj._id.toString();
  if (obj.bookingRef && obj.bookingRef.slot) {
    obj.slotDate = obj.bookingRef.slot.date || obj.slotDate || 'Tomorrow';
    obj.slotTime =
      obj.bookingRef.slot.durationRange ||
      obj.bookingRef.slot.time ||
      obj.slotTime ||
      '6:00 PM – 7:00 PM';
  }
  return obj;
};

// Helper to resolve player details from actual registered users
const getPlayerDetails = async (booking, index = 0) => {
  if (booking && booking.userId) {
    const u = await User.findOne({ firebaseUid: booking.userId });
    if (u) {
      return {
        playerName: u.fullName || u.name || 'Player',
        playerEmail: u.email || '',
        playerPhone: '077 ' + Math.floor(1000000 + Math.random() * 9000000).toString().substring(0, 7),
      };
    }
  }

  // Use registered Player users from DB
  const players = await User.find({ role: 'Player' });
  if (players && players.length > 0) {
    const seed = booking && booking.bookingId
      ? (parseInt(booking.bookingId.replace(/\D/g, ''), 10) || index)
      : index;
    const player = players[seed % players.length];
    const phones = [
      '077 345 6789',
      '071 889 2341',
      '076 554 1234',
      '070 234 5678',
      '078 456 7890',
      '075 123 4567',
      '072 345 6789',
      '077 987 6543',
    ];
    return {
      playerName: player.fullName || 'Player',
      playerEmail: player.email || '',
      playerPhone: phones[seed % phones.length],
    };
  }

  return {
    playerName: 'Pavan Rathnayake',
    playerEmail: 'pavanrathnakaye@gmail.com',
    playerPhone: '077 345 6789',
  };
};

// Seed / clean payment verification records to use real registered users
exports.seedPaymentVerifications = async () => {
  try {
    const kasunRecords = await PaymentVerification.find({ playerName: 'Kasun Perera' });
    const players = await User.find({ role: 'Player' });
    for (let i = 0; i < kasunRecords.length; i++) {
      const rec = kasunRecords[i];
      const p = (players && players.length > 0)
        ? players[i % players.length]
        : { fullName: 'Pavan Rathnayake', email: 'pavanrathnakaye@gmail.com' };
      rec.playerName = p.fullName || 'Pavan Rathnayake';
      rec.playerEmail = p.email || 'pavanrathnakaye@gmail.com';
      rec.playerPhone = `077 ${Math.floor(100 + i * 23)} ${Math.floor(1000 + i * 137)}`;
      await rec.save();
    }
  } catch (err) {
    console.error('Error seeding payment verifications:', err);
  }
};

// Helper to find by Mongo ID or bookingId (e.g. SS-20481)
const findVerification = async (idOrBookingId) => {
  let doc = null;
  if (/^[0-9a-fA-F]{24}$/.test(idOrBookingId)) {
    doc = await PaymentVerification.findById(idOrBookingId).populate({
      path: 'bookingRef',
      populate: { path: 'slot' },
    });
  }
  if (!doc) {
    doc = await PaymentVerification.findOne({ bookingId: idOrBookingId }).populate({
      path: 'bookingRef',
      populate: { path: 'slot' },
    });
  }
  return doc;
};

// Sync real bookings into PaymentVerification records using registered players
let lastSyncTime = 0;
const syncBookingsWithPaymentVerifications = async (force = false) => {
  const now = Date.now();
  if (!force && now - lastSyncTime < 30000) {
    return;
  }
  lastSyncTime = now;

  try {
    const [bookings, existingPvs, players] = await Promise.all([
      Booking.find().populate('slot'),
      PaymentVerification.find(),
      User.find({ role: 'Player' }),
    ]);

    const pvMap = new Map(existingPvs.map((p) => [p.bookingId, p]));
    const saves = [];

    for (let i = 0; i < bookings.length; i++) {
      const b = bookings[i];
      if (!b.bookingId) continue;
      let pv = pvMap.get(b.bookingId);

      const isCancelled = b.status === 'cancelled';
      const isVerified = b.status === 'confirmed';
      const isPending =
        !isCancelled &&
        !isVerified &&
        (b.status === 'pending_verification' ||
          (b.paymentMethod === 'bank' && b.status !== 'confirmed'));

      const pStatus = isCancelled
        ? 'unpaid'
        : isVerified
        ? 'verified'
        : 'pending';
      const slotPrice = b.slot && b.slot.price ? b.slot.price : 2500;
      const cName =
        b.courtName || (b.slot && b.slot.courtName) || 'Badminton Court 1';
      const sDate = (b.slot && b.slot.date) || 'Tomorrow';
      const sTime = (b.slot && (b.slot.durationRange || b.slot.time)) || '6:00 PM – 7:00 PM';

      if (!pv) {
        const playerInfo = await getPlayerDetails(b, i);
        saves.push(
          PaymentVerification.create({
            bookingId: b.bookingId,
            bookingRef: b._id,
            courtName: b.slot ? b.slot.facilityType : 'Court',
            facilityName: b.slot ? b.slot.courtName : 'SportSpace Facility',
            slotDate: sDate,
            slotTime: sTime,
            playerName: playerInfo.playerName,
            playerPhone: playerInfo.playerPhone,
            playerEmail: playerInfo.playerEmail,
            amount: slotPrice,
            paymentMethod: b.paymentMethod || 'card',
            paymentRef:
              b.paymentIntentId ||
              `PMT-${
                b.bookingId.replace(/\D/g, '') ||
                Math.floor(10000 + Math.random() * 90000)
              }`,
            paymentStatus: pStatus,
            slipUrl: b.slipUrl || null,
            managerId: b.managerId || null,
          })
        );
      } else {
        let changed = false;
        const playerInfo = await getPlayerDetails(b, i);
        if (pv.playerName !== playerInfo.playerName || pv.playerEmail !== playerInfo.playerEmail) {
          pv.playerName = playerInfo.playerName;
          pv.playerEmail = playerInfo.playerEmail;
          pv.playerPhone = playerInfo.playerPhone;
          changed = true;
        }
        if (b.slipUrl && pv.slipUrl !== b.slipUrl) {
          pv.slipUrl = b.slipUrl;
          changed = true;
        }
        if (!pv.bookingRef) {
          pv.bookingRef = b._id;
          changed = true;
        }
        if (pv.managerId !== b.managerId) {
          pv.managerId = b.managerId;
          changed = true;
        }
        if (!pv.slotDate || pv.slotDate !== sDate) {
          pv.slotDate = sDate;
          changed = true;
        }
        if (!pv.slotTime || pv.slotTime !== sTime) {
          pv.slotTime = sTime;
          changed = true;
        }
        const expectedFacility = b.slot ? b.slot.courtName : 'SportSpace Facility';
        if (pv.facilityName !== expectedFacility) {
          pv.facilityName = expectedFacility;
          changed = true;
        }
        const expectedCourt = b.slot ? b.slot.facilityType : 'Court';
        if (pv.courtName !== expectedCourt) {
          pv.courtName = expectedCourt;
          changed = true;
        }
        if (
          pv.paymentStatus !== pStatus &&
          (b.status === 'pending_verification' || b.status === 'cancelled')
        ) {
          pv.paymentStatus = pStatus;
          changed = true;
        }
        if (changed) {
          saves.push(pv.save());
        }
      }
    }
    if (saves.length > 0) {
      await Promise.all(saves);
    }
  } catch (err) {
    console.error('Error syncing bookings with payment verifications:', err);
  }
};

// GET /api/payment-verifications
exports.getPaymentVerifications = async (req, res) => {
  try {
    await syncBookingsWithPaymentVerifications();
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

// GET /api/payment-verifications/manager
exports.getManagerPaymentVerifications = async (req, res) => {
  try {
    await syncBookingsWithPaymentVerifications();
    const { paymentStatus, courtName, bookingId } = req.query;
    const query = { managerId: req.firebaseUser.uid };

    if (paymentStatus) query.paymentStatus = paymentStatus;
    if (courtName) query.courtName = courtName;
    if (bookingId) query.bookingId = bookingId;

    const list = await PaymentVerification.find(query).sort({ createdAt: -1 });
    res.status(200).json(list.map(formatVerification));
  } catch (error) {
    res.status(500).json({
      message: 'Error fetching manager payment verifications',
      error: error.message,
    });
  }
};

// GET /api/payment-verifications/:id/status
exports.getVerificationStatus = async (req, res) => {
  try {
    const { id } = req.params;
    let doc = await findVerification(id);

    // If not found yet, sync with bookings and retry
    if (!doc) {
      await syncBookingsWithPaymentVerifications();
      doc = await findVerification(id);
    }

    if (!doc) {
      const booking = await Booking.findOne({ bookingId: id });
      if (booking) {
        const playerInfo = await getPlayerDetails(booking);
        doc = await PaymentVerification.create({
          bookingId: booking.bookingId,
          bookingRef: booking._id,
          courtName: booking.courtName || 'Badminton Court 1',
          playerName: playerInfo.playerName,
          playerPhone: playerInfo.playerPhone,
          playerEmail: playerInfo.playerEmail,
          amount: 2500,
          paymentMethod: booking.paymentMethod || 'card',
          paymentRef: `PMT-${Math.floor(10000 + Math.random() * 90000)}`,
          paymentStatus: booking.status === 'pending_verification'
            ? 'pending'
            : (booking.status === 'confirmed'
              ? 'verified'
              : (booking.status === 'cancelled' ? 'unpaid' : 'pending')),
          slipUrl: booking.slipUrl || null,
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
      const booking = await Booking.findOne({ bookingId: id });
      doc = await PaymentVerification.create({
        bookingId: id,
        bookingRef: booking ? booking._id : null,
        courtName: booking ? booking.courtName : 'Badminton Court 1',
        paymentMethod: booking ? booking.paymentMethod : 'card',
        slipUrl: booking ? booking.slipUrl : null,
        paymentStatus: 'pending',
      });
    }

    doc.paymentStatus = 'verified';
    doc.verifiedAt = new Date();
    doc.verifiedBy = verifiedBy;
    doc.verificationNotes = notes || 'Payment verified by Manager';

    const bookingIdToMatch = doc.bookingId;
    const bookingRefToMatch = doc.bookingRef && doc.bookingRef._id ? doc.bookingRef._id : doc.bookingRef;
    let slotIdToUpdate = null;
    if (doc.bookingRef && doc.bookingRef.slot) {
      slotIdToUpdate = doc.bookingRef.slot._id || doc.bookingRef.slot;
    }

    const tasks = [doc.save()];

    if (bookingIdToMatch || bookingRefToMatch) {
      const bFilter = [];
      if (bookingIdToMatch) bFilter.push({ bookingId: bookingIdToMatch });
      if (bookingRefToMatch) bFilter.push({ _id: bookingRefToMatch });
      tasks.push(
        Booking.findOneAndUpdate(
          { $or: bFilter },
          { $set: { status: 'confirmed' } },
          { new: true }
        ).exec()
      );
    }

    if (slotIdToUpdate) {
      tasks.push(Slot.updateOne({ _id: slotIdToUpdate }, { $set: { status: 'booked' } }).exec());
    }

    const [savedDoc, updatedBooking] = await Promise.all(tasks);

    if (!slotIdToUpdate && updatedBooking && updatedBooking.slot) {
      Slot.updateOne({ _id: updatedBooking.slot }, { $set: { status: 'booked' } }).exec().catch(() => {});
    }

    // Requirement 8: when facility manager confirm a payment, show to the player who made the booking
    const confirmedPlayerId = updatedBooking ? updatedBooking.userId : (doc.bookingRef ? doc.bookingRef.userId : null);
    await dispatchNotification({
      targetRoles: 'player',
      userId: confirmedPlayerId,
      category: 'payment',
      title: 'Payment Confirmed',
      message: `Your payment for booking ${doc.bookingId || id} has been confirmed. Your court reservation is confirmed!`,
      accentColor: 'green',
      metadata: { bookingId: doc.bookingId || id, action: 'confirmed' },
    });

    res.status(200).json({
      message: 'Payment Confirmed! Booking status updated to Paid.',
      verification: formatVerification(savedDoc || doc),
      booking: updatedBooking || doc.bookingRef,
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
      const booking = await Booking.findOne({ bookingId: id });
      doc = await PaymentVerification.create({
        bookingId: id,
        bookingRef: booking ? booking._id : null,
        courtName: booking ? booking.courtName : 'Badminton Court 1',
        paymentMethod: booking ? booking.paymentMethod : 'card',
        slipUrl: booking ? booking.slipUrl : null,
        paymentStatus: 'pending',
      });
    }

    doc.paymentStatus = 'unpaid';
    doc.verifiedAt = new Date();
    doc.verifiedBy = verifiedBy;
    doc.verificationNotes = notes || 'Marked as unpaid by Manager';

    const bookingIdToMatch = doc.bookingId;
    const bookingRefToMatch = doc.bookingRef && doc.bookingRef._id ? doc.bookingRef._id : doc.bookingRef;
    let slotIdToUpdate = null;
    if (doc.bookingRef && doc.bookingRef.slot) {
      slotIdToUpdate = doc.bookingRef.slot._id || doc.bookingRef.slot;
    }

    const tasks = [doc.save()];

    if (bookingIdToMatch || bookingRefToMatch) {
      const bFilter = [];
      if (bookingIdToMatch) bFilter.push({ bookingId: bookingIdToMatch });
      if (bookingRefToMatch) bFilter.push({ _id: bookingRefToMatch });
      tasks.push(
        Booking.findOneAndUpdate(
          { $or: bFilter },
          { $set: { status: 'cancelled' } },
          { new: true }
        ).exec()
      );
    }

    if (slotIdToUpdate) {
      tasks.push(Slot.updateOne({ _id: slotIdToUpdate }, { $set: { status: 'available' } }).exec());
    }

    const [savedDoc, updatedBooking] = await Promise.all(tasks);

    if (!slotIdToUpdate && updatedBooking && updatedBooking.slot) {
      Slot.updateOne({ _id: updatedBooking.slot }, { $set: { status: 'available' } }).exec().catch(() => {});
    }

    // Requirement 9: when facility manager mark as unpaid a payment, show to the player who made the booking
    const unpaidPlayerId = updatedBooking ? updatedBooking.userId : (doc.bookingRef ? doc.bookingRef.userId : null);
    await dispatchNotification({
      targetRoles: 'player',
      userId: unpaidPlayerId,
      category: 'payment',
      title: 'Payment Marked Unpaid',
      message: `Your payment for booking ${doc.bookingId || id} was marked as unpaid. Please review or complete payment.`,
      accentColor: 'red',
      metadata: { bookingId: doc.bookingId || id, action: 'unpaid' },
    });

    res.status(200).json({
      message: 'Booking payment marked as Unpaid.',
      verification: formatVerification(savedDoc || doc),
      booking: updatedBooking || doc.bookingRef,
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
      playerName,
      playerPhone,
      playerEmail,
      amount = 2500,
      paymentMethod = 'card',
      paymentRef,
      paymentStatus = 'pending',
      notes,
    } = req.body;

    if (!bookingId) {
      return res.status(400).json({ message: 'bookingId is required' });
    }

    const defaultPlayer = await getPlayerDetails({ bookingId });

    const doc = await PaymentVerification.create({
      bookingId,
      bookingRef,
      courtName,
      playerName: playerName || defaultPlayer.playerName,
      playerPhone: playerPhone || defaultPlayer.playerPhone,
      playerEmail: playerEmail || defaultPlayer.playerEmail,
      amount,
      paymentMethod,
      paymentRef: paymentRef || `PMT-${Math.floor(10000 + Math.random() * 90000)}`,
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
