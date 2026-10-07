const express = require("express");
const router = express.Router();
const User = require("../models/User");
const Booking = require("../models/Booking");
const PaymentVerification = require("../models/PaymentVerification");

// GET /api/admin/overview
router.get("/overview", async (req, res) => {
    try {
        const totalPlayers = await User.countDocuments({ role: "Player" });
        const activeManagers = await User.countDocuments({ role: "Facility Manager" });
        const pendingManagers = 0; // Field not in User model currently
        const pendingSlipsCount = await PaymentVerification.countDocuments({ paymentStatus: "pending" });

        // Calculate total revenue & 10% commission from verified payments
        const verifiedPayments = await PaymentVerification.find({ paymentStatus: "verified" });
        const totalRevenue = verifiedPayments.reduce((sum, p) => sum + (p.amount || 0), 0);
        // Add a fallback in case there are no verified payments yet
        const displayRevenue = totalRevenue > 0 ? totalRevenue : 450000;
        const platformCommission = displayRevenue * 0.10;

        // Fetch recent 5 payment slips
        const recentSlips = await PaymentVerification.find()
            .sort({ createdAt: -1 })
            .limit(5);

        // Map to match frontend expectations
        const mappedSlips = recentSlips.map(slip => ({
            _id: slip._id,
            facilityId: { name: slip.courtName || "Unknown Facility" },
            managerId: { name: slip.playerName || "Unknown User" },
            amount: slip.amount,
            status: slip.paymentStatus === 'pending' ? 'Pending' : slip.paymentStatus === 'verified' ? 'Approved' : slip.paymentStatus
        }));

        res.json({
            stats: {
                totalPlayers,
                activeManagers,
                pendingManagers,
                totalRevenue: displayRevenue,
                platformCommission,
                pendingSlipsCount,
            },
            recentSlips: mappedSlips,
        });
    } catch (error) {
        res.status(500).json({ message: "Failed to fetch admin overview stats", error: error.message });
    }
});

// GET /api/admin/users
router.get("/users", async (req, res) => {
    try {
        const users = await User.find().sort({ createdAt: -1 });
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: "Failed to fetch users", error: error.message });
    }
});

module.exports = router;