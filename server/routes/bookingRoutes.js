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
// GET /api/bookings - Get all bookings (admin/debug)
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

// ------------------------------------------------------
// PUT /api/bookings/convert/:bookingId - Convert to Renting
// ------------------------------------------------------
router.put("/bookings/convert/:bookingId", authenticate, async (req, res) => {
  if (req.user.userType !== 'employee') return res.sendStatus(403);

  const { bookingId } = req.params;
  const { paymentAmount, paymentMethod } = req.body;
  const employeeId = req.user.id;

  try {
    const bookingRes = await pool.query(
      "SELECT * FROM Booking WHERE BookingID = $1 AND Status = 'RESERVED'",
      [bookingId]
    );
    if (bookingRes.rows.length === 0) {
      return res.status(404).json({ error: "No RESERVED booking found with this ID" });
    }

    const booking = bookingRes.rows[0];
    const rentalDate = new Date();
    const checkoutDate = booking.enddate;

    const empRes = await pool.query(
      "SELECT hotelid, companyname FROM Employee WHERE employeeid = $1",
      [employeeId]
    );
    if (empRes.rows.length === 0) {
      return res.status(400).json({ error: "Employee not found" });
    }

    const { hotelid: empHotelId, companyname: empCompanyName } = empRes.rows[0];

    const roomCheck = await pool.query(
      `SELECT * FROM Room WHERE RoomNumber = $1 AND HotelID = $2 AND CompanyName = $3`,
      [booking.roomnumber, empHotelId, empCompanyName]
    );
    if (roomCheck.rows.length === 0) {
      return res.status(400).json({ error: "Room not found in your hotel" });
    }

    const rentingRes = await pool.query(
      `INSERT INTO Renting (BookingID, RoomNumber, HotelID, CompanyName, CustomerID, EmployeeID, RentalDate, CheckoutDate)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [
        booking.bookingid,
        booking.roomnumber,
        empHotelId,
        empCompanyName,
        booking.customerid,
        employeeId,
        rentalDate,
        checkoutDate
      ]
    );

    await pool.query("UPDATE Booking SET Status = 'RENTED' WHERE BookingID = $1", [bookingId]);

    if (paymentAmount && paymentMethod) {
      await pool.query(
        `INSERT INTO Payment (RentalID, Amount, PaymentMethod) VALUES ($1, $2, $3)`,
        [rentingRes.rows[0].rentalid, paymentAmount, paymentMethod]
      );
    }

    res.json({
      message: "Booking converted to rental",
      renting: rentingRes.rows[0]
    });
  } catch (err) {
    console.error("Conversion error:", err.message);
    res.status(500).json({ error: "Failed to convert booking to renting" });
  }
});

// ------------------------------------------------------
// POST /api/bookings/walkin - Walk-in Rental
// ------------------------------------------------------
router.post("/bookings/walkin", authenticate, async (req, res) => {
  if (req.user.userType !== 'employee') return res.sendStatus(403);

  const { roomNumber, customerId, startDate, endDate, paymentAmount, paymentMethod } = req.body;
  const employeeId = req.user.id;

  try {
    const empRes = await pool.query(
      "SELECT hotelid, companyname FROM Employee WHERE employeeid = $1",
      [employeeId]
    );
    if (empRes.rows.length === 0) {
      return res.status(400).json({ error: "Employee not found" });
    }

    const { hotelid: empHotelId, companyname: empCompanyName } = empRes.rows[0];

    const roomCheck = await pool.query(
      `SELECT * FROM Room WHERE RoomNumber = $1 AND HotelID = $2 AND CompanyName = $3`,
      [roomNumber, empHotelId, empCompanyName]
    );
    if (roomCheck.rows.length === 0) {
      return res.status(400).json({ error: "Room not found in your hotel" });
    }

    const rentingRes = await pool.query(
      `INSERT INTO Renting (RoomNumber, HotelID, CompanyName, CustomerID, EmployeeID, RentalDate, CheckoutDate)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [roomNumber, empHotelId, empCompanyName, customerId, employeeId, startDate, endDate]
    );

    if (paymentAmount && paymentMethod) {
      await pool.query(
        `INSERT INTO Payment (RentalID, Amount, PaymentMethod) VALUES ($1, $2, $3)`,
        [rentingRes.rows[0].rentalid, paymentAmount, paymentMethod]
      );
    }

    res.status(201).json({
      message: "Walk-in rental created",
      renting: rentingRes.rows[0]
    });
  } catch (err) {
    console.error("Walk-in rental error:", err.message);
    res.status(500).json({ error: "Failed to create walk-in rental" });
  }
});

module.exports = router;
