const mysql = require('mysql');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'Eliyah2003',
  password: 'Eliyah21!!',
  database: 'WebServerLogs'
});

connection.connect(function(err) {
  if (err) throw err;
  console.log("Connected to the MySQL database!");
  connection.query('SELECT * FROM log_query', function (error, results) {
    if (error) throw error;
    console.log(results); // Display query results
  });
});
