const mysql = require('mysql');

const connection = mysql.createConnection({
  host: '127.0.0.1',
  user: 'root',
  password: 'Eliyah21!!',
  database: 'MySQL',
  port: 3307
});

connection.connect(function(err) {
  if (err) throw err;
  console.log("Connected to the MySQL database!");
  connection.query('SELECT * FROM log_query', function (error, results) {
    if (error) throw error;
    console.log(results); // Display query results
  });
});
