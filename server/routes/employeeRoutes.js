/**
 * Handle API requests related to the Employee table.
 *
 * @author Zain Gunin
 */

// Setup
const express = require('express');
const pool = require("../db");
const bodyParser = require("body-parser");
const router = express.Router();

/**
 * Employee API Routes
 */

/**
 * Create a new employee
 * 
 * Endpoint: /api/employee
 * Request Type: POST
 * Request Body:
 *  {
 *      "employeeID": 1,
 *      "SIN": "12234334",
 *      "hotelID": 1,
 *      "companyName": "Mariott",
 *      "name": {
 *          "firstName": "Bob",
 *          "middleName": "A", (OPTIONAL)
 *          "lastName": "LastName"
 *      },
 *      "address": {
 *          "streetNumber": 12,
 *          "streetName": "Mariott Way",
 *          "aptNumber": 12 (OPTIONAL),
 *          "city": "New York",
 *          "state": "New York",
 *          "postalCode": "00000"
 *      }
 *  }
 */
router.post("/employee", async(req, res)=> {
    try {
        const employee = req.body;
        const name = req.body.name; 
        const address = req.body.address;
        
        console.log("Adding Employee with employee ID: "+employee.employeeid+" to database.");

        const newEmployee = await pool.query(
            "INSERT INTO Employee (employeeid, SIN, HotelID, CompanyName, FirstName, MiddleName, LastName, StreetNumber, StreetName, AptNumber, City, State, PostalCode) \
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) RETURNING *", 
            [employee.employeeid, employee.sin, employee.hotelid, employee.companyName, name.firstName, name.middleName, name.lastName, address.streetNumber, address.streetName, address.aptNumber, address.city, address.state, address.postalCode]
        );

        res.json(newEmployee.rows);

    } catch (err) {
        console.error(err.message);
    }
});

// Get all employees
router.get("/employee", async(req, res)=>{
    try {
        console.debug("Retriving all Employee from database.");

        const allEmployee = await pool.query("Select * from Employee");
        res.json(allEmployee.rows);

    } catch (err) {
        console.error(err.message);
    }
});

/**
 * Get a specific employee
 * 
 * Endpoint: /api/employee/specific
 * Request Type: GET
 * Request Body:
 *  {
 *      "employeeID": 1,
 *      "hotelID": 1,
 *      "companyName": "Mariott"
 *  }
 */
router.get("/employee/specific", async(req, res)=>{

    try {
        const requestBody = req.body;

        const employee = await pool.query("SELECT * FROM Employee WHERE (EmployeeID = $1 AND HotelID = $2 AND CompanyName = $3)", 
            [requestBody.employeeid, requestBody.hotelid, requestBody.companyName]);

        console.debug("Retrieving employee: "+JSON.stringify(requestBody));
        res.json(employee.rows);

    } catch (err) {
        console.error(err.message);
    }
    
});

/**
 * Update employee address
 * 
 * Endpoint: /api/employee/address
 * Request Type: PUT
 * Request Body:
 *  {
 *      "employeeID": 1,
 *      "hotelID": 1,
 *      "companyName": "Mariott",
 *      "address": {
 *          "streetNumber": 12,
 *          "streetName": "Mariott Way",
 *          "aptNumber": 12 (OPTIONAL),
 *          "city": "New York",
 *          "state": "New York",
 *          "postalCode": "00000"
 *      }
 *  }
 */
router.put("/employee/address", async(req, res)=>{

    try {
        const requestBody = req.body;
        const address =  req.body.address;
        console.debug("Updating address of Employee with new streetName: "+address.streetName+".");
        const updateEmployee = await pool.query("UPDATE Employee \
            SET StreetNumber = $1, StreetName = $2, AptNumber = $3, City = $4, State = $5, PostalCode = $6\
            WHERE (EmployeeID = $7 AND HotelID = $8 AND CompanyName = $9)",
            [address.streetNumber, address.streetName, address.aptNumber, address.city, address.state, address.postalCode,
            requestBody.employeeid, requestBody.hotelid, requestBody.companyName]);
        res.json(updateEmployee.rows);

    } catch (err) {
        console.error(err.message);
    }
    
});

//Update empoyee Name
router.put("/employee/name", async(req, res)=>{

    try {
        const info = req.body;
        const name = req.body.name;
        console.debug("Updating name of Employee with new firstName: "+name.firstName+".");
        const updateEmployeeName = await pool.query("UPDATE Employee SET firstname = $1, middlename = $2, lastname = $3 WHERE (EmployeeID = $4 AND HotelID = $5 AND CompanyName = $6) RETURNING *", [name.firstName, name.middleName, name.lastName , info.employeeid, info.hotelid, info.companyName]);
        res.json(updateEmployeeName.rows);

    } catch (err) {
        console.error(err.message);
    }
    
});



router.delete("/employee", async(req, res)=>{

    try {
        const employeeid = req.body.employeeid;
        console.debug("Deleting Employee with ID: "+employeeid+".")

        const deleteEmployee = await pool.query("DELETE FROM Employee WHERE EmployeeID = $1", [employeeid]);
        res.json("Employee was deleted!");

    } catch (err) {
        console.error(err.message);
    }
    
});



module.exports = router;