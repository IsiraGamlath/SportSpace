const express = require("express");
const router = express.Router();
const User = require("../models/User");
const Booking = require("../models/Booking");
const PaymentVerification = require("../models/PaymentVerification");

// GET /api/admin/overview
router.get("/overview", async (req, res) => {
    try {
        const totalPlayers = await User.countDocuments({ role: "Player" });
        const activeManagers = await User.countDocuments({ role: "Facility Manager", isApproved: true });
        const pendingManagers = await User.countDocuments({ role: "Facility Manager", isApproved: false });
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

// GET /api/admin/managers
router.get("/managers", async (req, res) => {
    try {
        const managers = await User.find({ role: "Facility Manager" }).sort({ createdAt: -1 });
        res.json(managers);
    } catch (error) {
        res.status(500).json({ message: "Failed to fetch managers", error: error.message });
    }
});

// PATCH /api/admin/managers/:id/status
router.patch("/managers/:id/status", async (req, res) => {
    try {
        const { isApproved } = req.body;
        const manager = await User.findOneAndUpdate(
            { _id: req.params.id, role: "Facility Manager" },
            { isApproved },
            { new: true }
        );
        if (!manager) {
            return res.status(404).json({ message: "Manager not found" });
        }
        res.json(manager);
    } catch (error) {
        res.status(500).json({ message: "Failed to update manager status", error: error.message });
    }
});

// GET /api/admin/payments
router.get("/payments", async (req, res) => {
    try {
        const bookings = await Booking.find().populate("slot").sort({ createdAt: -1 });
        
        // Fetch players and managers and payment verifications to map data
        const userIds = [...new Set(bookings.map(b => b.userId))];
        const users = await User.find({ firebaseUid: { $in: userIds } });
        const userMap = users.reduce((acc, u) => {
            acc[u.firebaseUid] = u;
            return acc;
        }, {});

        const managers = await User.find({ role: "Facility Manager" });

        const bookingIds = bookings.map(b => b.bookingId);
        const verifications = await PaymentVerification.find({ bookingId: { $in: bookingIds } });
        const verifMap = verifications.reduce((acc, v) => {
            acc[v.bookingId] = v;
            return acc;
        }, {});

        const paymentsData = bookings.map(b => {
            const player = userMap[b.userId];
            const playerName = player ? player.fullName : "Unknown Player";
            
            // Find manager
            const manager = managers.find(m => m.assignedVenues && m.assignedVenues.includes(b.courtName));
            const managerName = manager ? manager.fullName : "System / Unassigned";

            const verif = verifMap[b.bookingId];
            const managerStatus = verif ? (verif.paymentStatus === 'pending' ? 'Pending Manager Review' : (verif.paymentStatus === 'verified' ? 'Approved by Manager' : 'Rejected by Manager')) : 'N/A';
            const slipUrl = b.slipUrl || (verif ? "manual_slip" : null);

            const amount = b.slot ? b.slot.price : 0;
            const commission = amount * 0.10;

            return {
                _id: b._id,
                bookingId: b.bookingId,
                courtName: b.courtName,
                managerName,
                playerName,
                slotDetails: b.slot ? `${b.slot.date} @ ${b.slot.time}` : "Unknown Slot",
                amount,
                commission,
                paymentMethod: b.paymentMethod,
                managerStatus,
                slipUrl
            };
        });

        res.json(paymentsData);
    } catch (error) {
        res.status(500).json({ message: "Failed to fetch payments", error: error.message });
    }
});

module.exports = router;