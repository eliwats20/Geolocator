const mysql = require('mysql');

// Create a connection to the database
const connection = mysql.createConnection({
    host: 'localhost',        // Host Name
    user: 'root',            // Database Username
    password: 'password',        // Database Password
    database: 'testdb'        // Database Name
});

connection.connect((err) => {
    if (err) throw err;
    console.log('Connected to the MySQL database!');
});