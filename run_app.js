const express = require('express');     // Create server endpoints
const mariadb = require('mariadb');     // Connects and interacts with MariaDB database
const util = require('util');           // Provides utility functions and creates custom events
const { exec } = require('child_process'); // Executes child processes, shell commands, and scripts
const cors = require('cors');           // Access API from different origins
const path = require('path');           // Access file and directory paths


// Instance of Express application
const app = express(); 

// For efficient error handling
const execPromise = util.promisify(exec); 

// Access static files in project server
app.use(express.static(path.join(__dirname)));

// Allows access from different ports and origins
app.use(cors());


// Set up connection pool to MariaDB
const eliyahdb = mariadb.createPool({
    host: '127.0.0.1',
    user: 'root',
    password: 'Eliyah21!!',
    database: 'IP Address', 
    port: 3306,
});

// Function to insert into ip_id_table 
//Allows function to concurrently perform times-saving insertion operations
const insertIpAddress = async (ipAddress) => {      
    const insertSql = 'INSERT INTO ip_id_table (ip_address) VALUES (?)';
    const values = [ipAddress];
    let conn;

    try {
        conn = await eliyahdb.getConnection();      // Asynchronously gets connection from database connection instance

        // Insert the IP Address if it doesn't exist
        const result = await conn.query(insertSql, values);
        return result.insertId; // Return the generated ip_id
    } catch (error) {
        console.error('Error inserting IP Address:', error); 
        return null;
    } finally {
        if (conn) conn.end();
    }
};

// Function to insert into table_id
const insertTableId = async (ip_id) => {
    const logId = Math.floor(Math.random() * 1000000); // Generate random log_id
    const sql = 'INSERT INTO table_id (log_id, ip_id) VALUES (?, ?)';
    const values = [logId, ip_id];

    let conn;
    try {
        conn = await eliyahdb.getConnection();
        await conn.query(sql, values);
        return logId; // Return the generated log_id
    } catch (error) {
        console.error('Error inserting into table_id:', error);
        return null;
    } finally {
        if (conn) conn.end();
    }
};

// Function to insert into log_query
const insertLogQuery = async (logId, logData) => {
    const sql = `
        INSERT INTO log_query (
            log_id, ip_address, city, region,
            country, postal_code, latitude, longitude, query_date, query_time,
            request_type, request_resource,
            HTTP_response_code, object_size, user_agent
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    const logQueryValues = [
        logId,
        logData.IPAddress,
        logData.City,
        logData.Region,
        logData.Country,
        logData.Postal,
        logData.Latitude,
        logData.Longitude,
        logData.QueryDate,
        logData.QueryTime, 
        logData.RequestType,
        logData.RequestResource,
        logData.HTTPResponseCode,
        logData.ObjectSize,
        logData.UserAgent
    ];

    let conn;
    try {
        conn = await eliyahdb.getConnection();
        await conn.query(sql, logQueryValues);
    } catch (insertError) {
        console.error('Error inserting log query:', insertError);
    } finally {
        if (conn) conn.end();
    }
};

// Endpoint to insert data
app.post('/insertData', async (req, res) => {
    console.log("Insert data endpoint hit"); // Add this line
    
    try {
        // Execute PowerShell script
        const { stdout, stderr } = await execPromise(`powershell -ExecutionPolicy Bypass -File "C:\\Users\\Admin\\OneDrive\\Documents\\CS-474\\Individual Project\\Geolocator\\IP.ps1"`);

        if (stderr) {
            console.error(`PowerShell stderr: ${stderr}`);
        }

        let logDataArray;
        try {
            logDataArray = JSON.parse(stdout); // Parse the JSON output from PowerShell
        } catch (parseError) {
            console.error('Error parsing PowerShell output:', parseError);
        }

        // Iterate over each log entry and insert into the database
        for (const logData of logDataArray) {
            const ip_id = await insertIpAddress(logData.IPAddress);
            const logId = await insertTableId(ip_id);
    
            await insertLogQuery(logId, logData);
        }

        // Execute R script after all data is processed
        const rScriptPath = 'C:\\Users\\Admin\\OneDrive\\Documents\\CS-474\\Individual Project\\Geolocator\\Data Visualization.r'; 
        const { rStdout, rStderr } = await execPromise(`Rscript "${rScriptPath}"`);

        if (rStderr) {
            console.error(`R script stderr: ${rStderr}`);
            return res.status(500).json({ error: 'R script error', details: rStderr });
        }

        console.log(`R script stdout: ${rStdout}`);

        return res.status(200).json({ message: 'Data processed and inserted successfully' });
    } catch (error) {
        return res.status(500).json({ error: 'Error executing script', details: error.message });
    }
});


app.delete('/deleteData', async (req, res) => {
    let conn;

    try {
        // Get a connection from the pool
        conn = await eliyahdb.getConnection();

        // Start a transaction
        await conn.beginTransaction();

        // Execute delete commands
        await conn.query('DELETE FROM log_query');
        await conn.query('DELETE FROM table_id');
        await conn.query('DELETE FROM ip_id_table');
        await conn.query('ALTER TABLE table_id AUTO_INCREMENT = 1');
        await conn.query('ALTER TABLE ip_id_table AUTO_INCREMENT = 1');

        // Commit the transaction
        await conn.commit();

        // Send success response
        res.status(200).json({ message: 'Data deleted successfully.' });
    } catch (error) {
        
        console.error('Error during delete:', error);
        res.status(500).json({ message: 'Error deleting data. Please try again.' });
    } finally {
        // Close the connection
        if (conn) {
            conn.end();
        }
    }
});


const port = 5500;
app.listen(port, '127.0.0.1', () => {
    console.log(`App running on port ${port}`);
});
