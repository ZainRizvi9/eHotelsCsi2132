/**
 * Handle API requests related to the Customer table.
 *
 * @author Zain
 */

const express = require('express');
const pool = require("../db");
const router = express.Router();

/**
 * Create a new customer
 */
router.post("/", async (req, res) => {
    try {
        const { customerID, SIN, registrationdate, firstname, lastname } = req.body;

        const newCustomer = await pool.query(
            `INSERT INTO Customer (CustomerID, SIN, RegistrationDate, FirstName, LastName)
             VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [customerID, SIN, registrationdate, firstname, lastname]
        );

        res.status(201).json(newCustomer.rows[0]);
    } catch (err) {
        console.error("Error adding customer:", err.message);
        res.status(500).json({ error: "Failed to add customer" });
    }
});

// Get all customers
router.get("/", async (req, res) => {
    try {
        const allCustomers = await pool.query("SELECT * FROM Customer");
        res.json(allCustomers.rows);
    } catch (err) {
        console.error("Error retrieving customers:", err.message);
        res.status(500).json({ error: "Failed to get customers" });
    }
});

// Get specific customer
router.get("/specific", async (req, res) => {
    try {
        const custid = req.body.customerid;
        const customer = await pool.query("SELECT * FROM Customer WHERE CustomerID = $1", [custid]);
        res.json(customer.rows);
    } catch (err) {
        console.error("Error retrieving specific customer:", err.message);
        res.status(500).json({ error: "Failed to get customer" });
    }
});

// Delete customer
router.delete("/", async (req, res) => {
    try {
        const custid = req.body.customerid;
        await pool.query("DELETE FROM Customer WHERE CustomerID = $1", [custid]);
        res.json("Customer was deleted!");
    } catch (err) {
        console.error("Error deleting customer:", err.message);
        res.status(500).json({ error: "Failed to delete customer" });
    }
});

// Utility update handler
const createUpdateRoute = (field, column) => {
    router.put(`/${field}`, async (req, res) => {
        try {
            const customerid = req.body.customerid;
            const value = req.body[field];
            const updateCustomer = await pool.query(
                `UPDATE Customer SET ${column} = $1 WHERE CustomerID = $2 RETURNING *`,
                [value, customerid]
            );
            res.json(updateCustomer.rows);
        } catch (err) {
            console.error(`Error updating ${field}:`, err.message);
            res.status(500).json({ error: `Failed to update ${field}` });
        }
    });
};

// Define all update routes
createUpdateRoute("sin", "SIN");
createUpdateRoute("registrationdate", "RegistrationDate");
createUpdateRoute("firstname", "FirstName");
createUpdateRoute("lastname", "LastName");

module.exports = router;
