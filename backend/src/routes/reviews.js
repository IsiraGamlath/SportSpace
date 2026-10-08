const express = require('express');
const reviewsController = require('../controllers/reviewsController');
const { requireFirebaseUser } = require('../middlewares/firebaseAuth');

const router = express.Router();

router.get('/', reviewsController.getReviews);
router.post('/', requireFirebaseUser, reviewsController.createReview);
router.put('/:id', requireFirebaseUser, reviewsController.updateReview);
router.delete('/:id', requireFirebaseUser, reviewsController.deleteReview);

module.exports = router;
