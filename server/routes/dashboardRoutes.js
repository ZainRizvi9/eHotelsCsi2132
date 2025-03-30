const express = require('express');
const router = express.Router();
const pool = require('../db');
const authenticate = require('../middleware/authenticate');

// ------------------------------------------------------------------
// Get bookings for the logged-in customer
// ------------------------------------------------------------------
router.get('/customer/bookings', authenticate, async (req, res) => {
  if (req.user.userType !== 'customer') return res.sendStatus(403);
  try {
    const bookings = await pool.query(
      `SELECT B.*, R.Price, R.RoomNumber, H.City 
       FROM Booking B
       JOIN Room R ON B.RoomNumber = R.RoomNumber AND B.HotelID = R.HotelID AND B.CompanyName = R.CompanyName
       JOIN Hotel H ON R.HotelID = H.HotelID AND R.CompanyName = H.CompanyName
       WHERE B.CustomerID = $1
       ORDER BY B.StartDate DESC`,
      [req.user.id]
    );
    res.json(bookings.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// ------------------------------------------------------------------
// Get rentals handled by this employee
// ------------------------------------------------------------------
router.get('/employee/rentals', authenticate, async (req, res) => {
  if (req.user.userType !== 'employee') return res.sendStatus(403);
  try {
    const rentals = await pool.query(
      `SELECT R.*, C.FirstName, C.LastName, Ro.RoomNumber, H.City 
       FROM Renting R
       JOIN Customer C ON R.CustomerID = C.CustomerID
       JOIN Room Ro ON R.RoomNumber = Ro.RoomNumber AND R.HotelID = Ro.HotelID AND R.CompanyName = Ro.CompanyName
       JOIN Hotel H ON Ro.HotelID = H.HotelID AND Ro.CompanyName = H.CompanyName
       WHERE R.EmployeeID = $1
       ORDER BY R.RentalDate DESC`,
      [req.user.id]
    );
    res.json(rentals.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// ------------------------------------------------------------------
// View issues related to rooms in this employee's hotel
// ------------------------------------------------------------------
router.get('/employee/issues', authenticate, async (req, res) => {
  if (req.user.userType !== 'employee') return res.sendStatus(403);
  try {
    const result = await pool.query(
      `SELECT RI.RoomNumber, RI.HotelID, RI.CompanyName, RI.Issue
       FROM RoomIssue RI
       JOIN Employee E ON RI.HotelID = E.HotelID AND RI.CompanyName = E.CompanyName
       WHERE E.EmployeeID = $1`,
      [req.user.id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error("Employee issues error:", err.message);
    res.status(500).send("Server error");
  }
});

// ------------------------------------------------------------------
// View amenities for rooms in this employee's hotel
// ------------------------------------------------------------------
router.get('/employee/amenities', authenticate, async (req, res) => {
  if (req.user.userType !== 'employee') return res.sendStatus(403);
  try {
    const result = await pool.query(
      `SELECT RA.RoomNumber, RA.HotelID, RA.CompanyName, RA.Amenity
       FROM RoomAmenity RA
       JOIN Employee E ON RA.HotelID = E.HotelID AND RA.CompanyName = E.CompanyName
       WHERE E.EmployeeID = $1`,
      [req.user.id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error("Employee amenities error:", err.message);
    res.status(500).send("Server error");
  }
});

// ------------------------------------------------------------------
// Get available rooms with advanced filters
// ------------------------------------------------------------------
router.get('/available-rooms', authenticate, async (req, res) => {
  const {
    startDate,
    endDate,
    capacity,
    city,
    companyName,
    category,
    totalRooms,
    minPrice,
    maxPrice
  } = req.query;

  try {
    const result = await pool.query(
      `SELECT r.*, h.city, h.category, h.numberofrooms
       FROM Room r
       JOIN Hotel h ON r.hotelID = h.hotelID AND r.companyName = h.companyName
       WHERE
         ($1::text IS NULL OR r.capacity ILIKE $1)
         AND ($2::text IS NULL OR h.city ILIKE $2)
         AND ($3::text IS NULL OR h.companyName ILIKE $3)
         AND ($4::text IS NULL OR h.category ILIKE $4)
         AND ($5::int IS NULL OR h.numberofrooms >= $5)
         AND ($6::numeric IS NULL OR r.price >= $6)
         AND ($7::numeric IS NULL OR r.price <= $7)
         AND NOT EXISTS (
           SELECT 1 FROM Booking b
           WHERE b.roomNumber = r.roomNumber
             AND b.hotelID = r.hotelID
             AND b.companyName = r.companyName
             AND NOT (
               b.endDate <= $8 OR b.startDate >= $9
             )
         )
       ORDER BY r.roomNumber`,
      [
        capacity || null,
        city || null,
        companyName || null,
        category || null,
        totalRooms || null,
        minPrice || null,
        maxPrice || null,
        startDate || null,
        endDate || null
      ]
    );

    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching available rooms:', err);
    res.status(500).send('Error fetching available rooms');
  }
});

module.exports = router;
