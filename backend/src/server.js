const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
const path = require("path");
const adminRoutes = require("./routes/adminRoutes");
require("dotenv").config({ path: path.resolve(__dirname, "../../.env") });

const app = express();
const PORT = process.env.PORT || 5000;

if (!process.env.JWT_SECRET) {
  console.warn("JWT_SECRET is not configured; registration and login will be unavailable.");
}

// Connect to Database
connectDB().then(() => {
  const { seedSlots } = require('./controllers/slotsController');
  const { seedMaintenance } = require('./controllers/maintenanceController');
  const { seedPaymentVerifications } = require('./controllers/paymentVerificationController');
  const { seedFacilities } = require('./controllers/facilityController');
  seedSlots();
  seedMaintenance();
  seedPaymentVerifications();
  seedFacilities();
});

// Middlewares
app.use(cors());
app.use(express.json());

// Routes & Health Check
app.get("/api/health", (req, res) => {
  res
    .status(200)
    .json({ status: "OK", message: "SportSpace Backend API Running" });
});

app.use("/api/auth", require("./routes/auth"));
app.use("/api/users", require("./routes/users"));
app.use("/api/slots", require("./routes/slots"));
app.use("/api/facilities", require("./routes/facilities"));
app.use("/api/bookings", require("./routes/bookings"));
app.use("/api/payments", require("./routes/payments"));
app.use("/api/maintenance", require("./routes/maintenance"));
app.use("/api/payment-verifications", require("./routes/paymentVerifications"));
app.use("/api/reviews", require("./routes/reviews"));
app.use("/api/contact-requests", require("./routes/contactRequests"));
app.use("/api/notifications", require("./routes/notifications"));
app.use("/api/events", require("./routes/events"));
app.use("/api/saved-events", require("./routes/savedEvents"));

// admin routes
app.use("/api/admin", adminRoutes);


app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
