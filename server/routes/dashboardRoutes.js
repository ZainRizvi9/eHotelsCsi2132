const express = require('express');
const router = express.Router();
const pool = require('../db');
const authenticate = require('../middleware/authenticate');

// Get bookings for the logged-in customer
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

// Get rentals handled by this employee
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

// View issues related to rooms in this employee's hotel
router.get('/employee/issues', authenticate, async (req, res) => {
  if (req.user.userType !== 'employee') return res.sendStatus(403);
  try {
    const result = await pool.query(`
      SELECT RI.RoomNumber, RI.HotelID, RI.CompanyName, RI.Issue
      FROM RoomIssue RI
      JOIN Employee E ON RI.HotelID = E.HotelID AND RI.CompanyName = E.CompanyName
      WHERE E.EmployeeID = $1
    `, [req.user.id]);
    res.json(result.rows);
  } catch (err) {
    console.error("Employee issues error:", err.message);
    res.status(500).send("Server error");
  }
});

// View amenities for rooms in this employee's hotel
router.get('/employee/amenities', authenticate, async (req, res) => {
  if (req.user.userType !== 'employee') return res.sendStatus(403);
  try {
    const result = await pool.query(`
      SELECT RA.RoomNumber, RA.HotelID, RA.CompanyName, RA.Amenity
      FROM RoomAmenity RA
      JOIN Employee E ON RA.HotelID = E.HotelID AND RA.CompanyName = E.CompanyName
      WHERE E.EmployeeID = $1
    `, [req.user.id]);
    res.json(result.rows);
  } catch (err) {
    console.error("Employee amenities error:", err.message);
    res.status(500).send("Server error");
  }
});

module.exports = router;
