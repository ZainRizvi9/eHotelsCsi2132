const express = require('express');
const pool = require("../db");
const router = express.Router();
const authenticate = require('../middleware/authenticate');

// ------------------------------------------------------
// POST /api/bookings - Create a new booking (customer only)
// ------------------------------------------------------
router.post("/bookings", authenticate, async (req, res) => {
  if (req.user.userType !== 'customer') return res.sendStatus(403);

  const { startDate, endDate, roomNumber, hotelId, companyName } = req.body;
  const customerId = req.user.id;

  try {
    const result = await pool.query(
      `INSERT INTO Booking (StartDate, EndDate, HotelID, RoomNumber, CustomerID, CompanyName, Status)
       VALUES ($1, $2, $3, $4, $5, $6, 'RESERVED') RETURNING *`,
      [startDate, endDate, hotelId, roomNumber, customerId, companyName]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("Booking creation error:", err.message);
    res.status(500).json({ error: "Failed to create booking" });
  }
});

// ------------------------------------------------------
// GET /api/bookings - Get all bookings (for admin/debug)
// ------------------------------------------------------
router.get("/bookings", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM Booking");
    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching bookings:", err.message);
    res.status(500).json({ error: "Failed to retrieve bookings" });
  }
});

module.exports = router;
