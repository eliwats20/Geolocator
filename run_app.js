const { exec } = require('child_process');
const mysql = require('mysql');

// Create a connection to the database
const connection = mysql.createConnection({
    host: '127.0.0.1',           
    user: 'root',          
    password: 'Eliyah21!!',      
    database: 'MySQL',
    port: 3307
});

// Run your PowerShell script to process a random log file
exec('powershell -File "C:\\Users\\Admin\\Onedrive\\Documents\\CS-474\\Individual Project\\Geolocator\\IP.ps1"', (error, stdout, stderr) => {
    if (error) {
        console.error(`Error: ${error.message}`);
        return;
    }
    if (stderr) {
        console.error(`stderr: ${stderr}`);
        return;
    }

    // Parse the output as JSON
    const data = JSON.parse(stdout); // `data` now holds the structured output from PowerShell

    // Prepare your SQL queries using the parsed data
    const insertIpQuery = `
        INSERT INTO ip_id_table (ip_id, ip_address) 
        VALUES (?, ?) 
        ON DUPLICATE KEY UPDATE ip_address=?;
    `;

    const insertTableQuery = `
        INSERT INTO table_id (ip_id, log_id) 
        VALUES (?, ?);
    `;

    const insertLogQuery = `
        INSERT INTO log_query (log_id, city, region, country, postal_code, latitude, longitude, query_time, request_type, request_resource, HTTP_response_code, object_size) 
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), ?, ?, ?, ?);
    `;

    // Execute the SQL queries with the data from PowerShell
    connection.execute(insertIpQuery, [data.ipId, data.ipAddress, data.ipAddress], (error, results) => {
        if (error) {
            return console.error('Error executing insertIpQuery: ', error);
        }
        console.log('Inserted IP data:', results);

        connection.execute(insertTableQuery, [data.ipId, data.logId], (error, results) => {
            if (error) {
                return console.error('Error executing insertTableQuery: ', error);
            }
            console.log('Inserted Table ID data:', results);

            connection.execute(insertLogQuery, [data.logId, data.city, data.region, data.country, data.postal, data.latitude, data.longitude, data.requestType, data.requestResource, data.httpResponseCode, data.objectSize], (error, results) => {
                if (error) {
                    return console.error('Error executing insertLogQuery: ', error);
                }
                console.log('Inserted Log data:', results);

                // Close the connection
                connection.end();
            });
        });
    });
});
