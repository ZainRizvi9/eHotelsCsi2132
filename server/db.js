/**
 * Define databse connection.
 *
 * @author zain gunin
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