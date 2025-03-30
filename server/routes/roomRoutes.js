const express = require('express');
const pool = require("../db");
const router = express.Router();

// Create a new room
router.post("/", async (req, res) => {
  try {
    const room = req.body;
    const newRoom = await pool.query(
      `INSERT INTO Room (roomNumber, companyName, hotelid, viewtype, price, capacity, expandable)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [room.roomNumber, room.companyname, room.hotelid, room.viewtype, room.price, room.capacity, room.expandable]
    );
    res.json(newRoom.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to add room" });
  }
});

// Get all rooms
router.get("/", async (req, res) => {
  try {
    const allRooms = await pool.query('SELECT * FROM Room');
    res.json(allRooms.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to fetch rooms" });
  }
});

// Get a specific room
router.get("/specific", async (req, res) => {
  try {
    const { roomNumber, hotelID, companyName } = req.body;
    const room = await pool.query(
      `SELECT * FROM Room WHERE roomNumber = $1 AND hotelid = $2 AND companyname = $3`,
      [roomNumber, hotelID, companyName]
    );
    res.json(room.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to fetch room" });
  }
});

// Update room price
router.put("/price", async (req, res) => {
  try {
    const { roomNumber, hotelID, companyName, price } = req.body;
    const updateRoom = await pool.query(
      `UPDATE Room SET price = $1 WHERE roomNumber = $2 AND hotelID = $3 AND companyName = $4 RETURNING *`,
      [price, roomNumber, hotelID, companyName]
    );
    res.json(updateRoom.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to update price" });
  }
});

// Update room capacity
router.put("/capacity", async (req, res) => {
  try {
    const { roomNumber, hotelID, companyName, capacity } = req.body;
    const updateRoom = await pool.query(
      `UPDATE Room SET capacity = $1 WHERE roomNumber = $2 AND hotelID = $3 AND companyName = $4 RETURNING *`,
      [capacity, roomNumber, hotelID, companyName]
    );
    res.json(updateRoom.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to update capacity" });
  }
});

// Update room viewtype
router.put("/viewtype", async (req, res) => {
  try {
    const { roomNumber, hotelID, companyName, viewtype } = req.body;
    const updateRoom = await pool.query(
      `UPDATE Room SET viewtype = $1 WHERE roomNumber = $2 AND hotelID = $3 AND companyName = $4 RETURNING *`,
      [viewtype, roomNumber, hotelID, companyName]
    );
    res.json(updateRoom.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to update viewtype" });
  }
});

// Delete a room
router.delete("/", async (req, res) => {
  try {
    const { roomNumber, hotelid, companyname } = req.body;
    await pool.query(
      `DELETE FROM Room WHERE roomNumber = $1 AND hotelid = $2 AND companyName = $3`,
      [roomNumber, hotelid, companyname]
    );
    res.json({ message: "Room was deleted" });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to delete room" });
  }
});

// Add a room issue
router.post("/issue", async (req, res) => {
  try {
    const { issue, roomNumber, hotelID, companyName } = req.body;
    const newIssue = await pool.query(
      `INSERT INTO RoomIssue (Issue, RoomNumber, HotelID, CompanyName) VALUES ($1, $2, $3, $4) RETURNING *`,
      [issue, roomNumber, hotelID, companyName]
    );
    res.json(newIssue.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to add issue" });
  }
});

// Delete a room issue
router.delete("/issue", async (req, res) => {
  try {
    const { issue, roomNumber, hotelID, companyName } = req.body;
    await pool.query(
      `DELETE FROM RoomIssue WHERE Issue = $1 AND RoomNumber = $2 AND HotelID = $3 AND CompanyName = $4`,
      [issue, roomNumber, hotelID, companyName]
    );
    res.json({ message: "Room issue deleted" });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to delete issue" });
  }
});

// Get all issues for a room
router.get("/issue", async (req, res) => {
  try {
    const { roomNumber, hotelID, companyName } = req.body;
    const issues = await pool.query(
      `SELECT * FROM RoomIssue WHERE RoomNumber = $1 AND HotelID = $2 AND CompanyName = $3`,
      [roomNumber, hotelID, companyName]
    );
    res.json(issues.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to get issues" });
  }
});

// Add a room amenity
router.post("/amenity", async (req, res) => {
  try {
    const { amenity, roomNumber, hotelID, companyName } = req.body;
    const newAmenity = await pool.query(
      `INSERT INTO RoomAmenity (Amenity, RoomNumber, HotelID, CompanyName) VALUES ($1, $2, $3, $4) RETURNING *`,
      [amenity, roomNumber, hotelID, companyName]
    );
    res.json(newAmenity.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to add amenity" });
  }
});

// Delete a room amenity
router.delete("/amenity", async (req, res) => {
  try {
    const { amenity, roomNumber, hotelID, companyName } = req.body;
    await pool.query(
      `DELETE FROM RoomAmenity WHERE Amenity = $1 AND RoomNumber = $2 AND HotelID = $3 AND CompanyName = $4`,
      [amenity, roomNumber, hotelID, companyName]
    );
    res.json({ message: "Room amenity deleted" });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to delete amenity" });
  }
});

// Get all amenities for a room
router.get("/amenity", async (req, res) => {
  try {
    const { roomNumber, hotelID, companyName } = req.body;
    const amenities = await pool.query(
      `SELECT * FROM RoomAmenity WHERE RoomNumber = $1 AND HotelID = $2 AND CompanyName = $3`,
      [roomNumber, hotelID, companyName]
    );
    res.json(amenities.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to get amenities" });
  }
});

router.get("/available", async (req, res) => {
    try {
      const availableRooms = await pool.query(
        `SELECT * FROM Room
         WHERE NOT EXISTS (
           SELECT 1 FROM Booking
           WHERE Booking.RoomNumber = Room.RoomNumber
             AND Booking.HotelID = Room.HotelID
             AND Booking.CompanyName = Room.CompanyName
             AND CURRENT_DATE BETWEEN Booking.StartDate AND Booking.EndDate
         )`
      );
      res.json(availableRooms.rows);
    } catch (err) {
      console.error("Error fetching available rooms:", err.message);
      res.status(500).json({ error: "Failed to fetch available rooms" });
    }
});

  

module.exports = router;
