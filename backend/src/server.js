const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5000;

// Connect to Database
connectDB().then(() => {
  const { seedSlots } = require('./controllers/slotsController');
  seedSlots();
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

app.use("/api/slots", require("./routes/slots"));
app.use("/api/bookings", require("./routes/bookings"));

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
