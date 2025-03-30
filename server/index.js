/**
 * Mount API routes and start backend server.
 *
 * @author Zain, Gunin
 */

const express = require("express");
const cors = require("cors");
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Route modules
const bookingRoutes = require("./routes/bookingRoutes");
const customerRoutes = require("./routes/customerRoutes");
const employeeRoleRoutes = require("./routes/employeeRoleRoutes");
const employeeRoutes = require("./routes/employeeRoutes");
const headquartersRoutes = require("./routes/headquartersRoutes");
const hotelRoutes = require("./routes/hotelRoutes");
const roomRoutes = require("./routes/roomRoutes");
const authRoutes = require("./routes/authRoutes");
const dashboardRoutes = require("./routes/dashboardRoutes");

// Mount routes
app.use("/api", bookingRoutes); // ✅ Fixed: allows /api/bookings to work
app.use("/api/customer", customerRoutes);
app.use("/api/employeerole", employeeRoleRoutes);
app.use("/api/employee", employeeRoutes);
app.use("/api/headquarters", headquartersRoutes);
app.use("/api/hotel", hotelRoutes);
app.use("/api/room", roomRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/dashboard", dashboardRoutes);

// Start server
app.listen(5001, () => {
  console.log("✅ Server running on http://localhost:5001");
});
