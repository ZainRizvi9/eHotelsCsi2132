const express = require('express');
const pool = require("../db");
const router = express.Router();

// Create new Hotel
router.post("/", async (req, res) => {
  try {
    const hotel = req.body;
    const address = hotel.address;

    const newHotel = await pool.query(
      `INSERT INTO Hotel 
      (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
      [
        hotel.hotelID, hotel.companyName, hotel.category, hotel.numberOfRooms,
        address.streetNumber, address.streetName, address.aptNumber,
        address.city, address.state, address.postalCode
      ]
    );

    res.json(newHotel.rows);
  } catch (err) {
    console.error("Error creating hotel:", err.message);
    res.status(500).json({ error: "Failed to create hotel" });
  }
});

// Get all hotels
router.get("/", async (req, res) => {
  try {
    const allHotels = await pool.query("SELECT * FROM Hotel");
    res.json(allHotels.rows);
  } catch (err) {
    console.error("Error fetching hotels:", err.message);
    res.status(500).json({ error: "Failed to fetch hotels" });
  }
});

// Get hotel by primary key
router.get("/specific", async (req, res) => {
  const { hotelID, companyName } = req.query;
  try {
    const result = await pool.query(
      "SELECT * FROM Hotel WHERE HotelID = $1 AND CompanyName = $2",
      [hotelID, companyName]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to get specific hotel" });
  }
});

// Update hotel category
router.put("/category", async (req, res) => {
  const { hotelID, companyName, category } = req.body;
  try {
    await pool.query(
      "UPDATE Hotel SET Category = $1 WHERE HotelID = $2 AND CompanyName = $3",
      [category, hotelID, companyName]
    );
    res.json("Hotel category updated!");
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to update hotel category" });
  }
});

// Delete hotel
router.delete("/", async (req, res) => {
  const { hotelID, companyName } = req.body;
  try {
    await pool.query(
      "DELETE FROM Hotel WHERE HotelID = $1 AND CompanyName = $2",
      [hotelID, companyName]
    );
    res.json("Hotel deleted!");
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to delete hotel" });
  }
});

// Hotel phone routes
router.post("/phone", async (req, res) => {
  const { hotelID, companyName, phoneNumber } = req.body;
  try {
    const result = await pool.query(
      "INSERT INTO HotelPhone (HotelID, CompanyName, phoneNumber) VALUES ($1, $2, $3) RETURNING *",
      [hotelID, companyName, phoneNumber]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to add phone number" });
  }
});

router.delete("/phone", async (req, res) => {
  const { hotelID, companyName, phoneNumber } = req.body;
  try {
    await pool.query(
      "DELETE FROM HotelPhone WHERE HotelID = $1 AND CompanyName = $2 AND phoneNumber = $3",
      [hotelID, companyName, phoneNumber]
    );
    res.json("Phone number deleted!");
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to delete phone number" });
  }
});

router.get("/phone", async (req, res) => {
  const { hotelID, companyName } = req.query;
  try {
    const phones = await pool.query(
      "SELECT * FROM HotelPhone WHERE HotelID = $1 AND CompanyName = $2",
      [hotelID, companyName]
    );
    res.json(phones.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to get phones" });
  }
});

// Hotel email routes
router.post("/email", async (req, res) => {
  const { hotelID, companyName, email } = req.body;
  try {
    const result = await pool.query(
      "INSERT INTO HotelEmail (HotelID, CompanyName, email) VALUES ($1, $2, $3) RETURNING *",
      [hotelID, companyName, email]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to add email" });
  }
});

router.delete("/email", async (req, res) => {
  const { hotelID, companyName, email } = req.body;
  try {
    await pool.query(
      "DELETE FROM HotelEmail WHERE HotelID = $1 AND CompanyName = $2 AND email = $3",
      [hotelID, companyName, email]
    );
    res.json("Email deleted!");
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to delete email" });
  }
});

// Get HQ emails
router.get("/email/headquarters", async (req, res) => {
  const { companyName } = req.query;
  try {
    const emails = await pool.query(
      "SELECT * FROM HeadquartersEmail WHERE CompanyName = $1",
      [companyName]
    );
    res.json(emails.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to fetch headquarters emails" });
  }
});

module.exports = router;
