const Booking = require('../models/Booking');
const Review = require('../models/Review');
const User = require('../models/User');

exports.getReviews = async (req, res) => {
  try {
    const facilityName = (req.query.facilityName || '').trim();
    if (!facilityName) {
      return res.status(400).json({ message: 'Facility name is required' });
    }

    const reviews = await Review.find({ facilityName }).sort({ createdAt: -1 });
    const summary = await Review.aggregate([
      { $match: { facilityName } },
      {
        $group: {
          _id: null,
          averageRating: { $avg: '$rating' },
          reviewCount: { $sum: 1 },
        },
      },
    ]);

    return res.status(200).json({
      averageRating: summary[0]?.averageRating || 0,
      reviewCount: summary[0]?.reviewCount || 0,
      reviews,
    });
  } catch (error) {
    console.error('Error fetching reviews:', error);
    return res.status(500).json({ message: 'Error fetching reviews' });
  }
};

exports.createReview = async (req, res) => {
  try {
    const facilityName = (req.body.facilityName || '').trim();
    const comment = (req.body.comment || '').trim();
    const rating = Number(req.body.rating);

    if (!facilityName || !comment || !Number.isInteger(rating) || rating < 1 || rating > 5) {
      return res.status(400).json({
        message: 'Facility name, a rating from 1 to 5, and a review are required',
      });
    }

    const user = await User.findOne({ firebaseUid: req.firebaseUser.uid });
    if (!user || user.role !== 'Player') {
      return res.status(403).json({ message: 'Only Player accounts can submit reviews' });
    }

    const booking = await Booking.findOne({
      userId: req.firebaseUser.uid,
      status: { $in: ['confirmed', 'rescheduled'] },
    });
    if (!booking) {
      return res.status(403).json({ message: 'You can review a facility after booking it' });
    }

    const review = await Review.findOneAndUpdate(
      { facilityName, userId: req.firebaseUser.uid },
      {
        $set: {
          userName: user.fullName,
          rating,
          comment,
        },
      },
      { new: true, upsert: true, runValidators: true, setDefaultsOnInsert: true },
    );

    return res.status(200).json({ review });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({ message: 'You have already reviewed this facility' });
    }
    console.error('Error saving review:', error);
    return res.status(500).json({ message: 'Error saving review' });
  }
};

exports.updateReview = async (req, res) => {
  try {
    const rating = Number(req.body.rating);
    const comment = (req.body.comment || '').trim();
    if (!Number.isInteger(rating) || rating < 1 || rating > 5 || comment.length < 3) {
      return res.status(400).json({ message: 'A rating from 1 to 5 and a review are required' });
    }

    const review = await Review.findOneAndUpdate(
      { _id: req.params.id, userId: req.firebaseUser.uid },
      { $set: { rating, comment } },
      { new: true, runValidators: true },
    );
    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }
    return res.status(200).json({ review });
  } catch (error) {
    console.error('Error updating review:', error);
    return res.status(500).json({ message: 'Error updating review' });
  }
};

exports.deleteReview = async (req, res) => {
  try {
    const review = await Review.findOneAndDelete({
      _id: req.params.id,
      userId: req.firebaseUser.uid,
    });
    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }
    return res.status(204).send();
  } catch (error) {
    console.error('Error deleting review:', error);
    return res.status(500).json({ message: 'Error deleting review' });
  }
};
