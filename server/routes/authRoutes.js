const express = require('express');
const pool = require("../db");
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const router = express.Router();

const JWT_SECRET = 'your_jwt_secret';

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { userType, email, password } = req.body;

  try {
    if (userType === 'employee') {
      const result = await pool.query("SELECT * FROM Employee WHERE Email = $1", [email]);
      if (result.rows.length === 0) return res.status(401).json({ error: 'Invalid credentials' });

      const employee = result.rows[0];
      const validPassword = await bcrypt.compare(password, employee.password);
      if (!validPassword) return res.status(401).json({ error: 'Invalid credentials' });

      const token = jwt.sign({ id: employee.employeeid, userType: 'employee' }, JWT_SECRET, { expiresIn: '1h' });
      return res.json({ token, userType: 'employee' });

    } else if (userType === 'customer') {
      const result = await pool.query("SELECT * FROM Customer WHERE Email = $1", [email]);
      if (result.rows.length === 0) return res.status(401).json({ error: 'Invalid credentials' });

      const customer = result.rows[0];
      const validPassword = await bcrypt.compare(password, customer.password);
      if (!validPassword) return res.status(401).json({ error: 'Invalid credentials' });

      const token = jwt.sign({ id: customer.customerid, userType: 'customer' }, JWT_SECRET, { expiresIn: '1h' });
      return res.json({ token, userType: 'customer' });

    } else {
      return res.status(400).json({ error: 'Invalid user type' });
    }
  } catch (err) {
    console.error("Auth error:", err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

// POST /api/auth/signup
router.post('/signup', async (req, res) => {
  const { userType, email, password, firstName, lastName, address, idType, idNumber, hotelId, companyName } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    if (userType === 'employee') {
      await pool.query(
        `INSERT INTO Employee (FirstName, LastName, Address, SIN, Password, HotelID, CompanyName, Email) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [firstName, lastName, address, idNumber, hashedPassword, hotelId, companyName, email]
      );
    } else if (userType === 'customer') {
      await pool.query(
        `INSERT INTO Customer (FirstName, LastName, Address, IDType, IDNumber, Password, Email) 
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [firstName, lastName, address, idType, idNumber, hashedPassword, email]
      );
    } else {
      return res.status(400).json({ error: 'Invalid user type' });
    }

    res.status(201).json({ message: 'User registered successfully!' });
  } catch (err) {
    console.error("Signup error:", err.message);
    res.status(500).json({ error: 'Signup failed' });
  }
});

module.exports = router;
