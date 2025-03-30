/**
 * Define databse connection.
 *
 * @author Eric Van De Lande.
 * @since  March, 2023
 */

// Setup
const Pool = require("pg").Pool;

const pool = new Pool({
    user: "postgres",
    host: "localhost",
    password: "Juicer!17",
    port: 5432,
    database: "ehotels"
});

module.exports = pool;