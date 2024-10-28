const express = require('express'); 
const mariadb = require('mariadb'); 
const util = require('util'); 
const { exec } = require('child_process'); 
const cors = require('cors'); 
const path = require('path'); // Import the path module
const fs = require('fs'); // To read the SQL file



const app = express(); 
const execPromise = util.promisify(exec); 

app.use(express.static(path.join(__dirname)));
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// MariaDB pool setup
const pool = mariadb.createPool({
    host: '127.0.0.1',
    user: 'root',
    password: 'Eliyah21!!',
    database: 'IP Address', // Ensure this is the correct database name
    port: 3306,
    connectionLimit: 15,
    ssl: false
});

// Function to insert into ip_id_table
const insertIpAddress = async (ipAddress) => {
    const checkSql = 'SELECT * FROM ip_id_table WHERE ip_address = ?';
    const insertSql = 'INSERT INTO ip_id_table (ip_address) VALUES (?)';
    const values = [ipAddress];
    let conn;

    try {
        conn = await pool.getConnection();
        
        // Check if the IP Address already exists
        const [rows] = await conn.query(checkSql, values);

        // Check if rows is defined and has data
        if (rows && rows.length > 0) {
            console.log(`IP Address ${ipAddress} already exists. Skipping insertion.`);
            return null; // Return null to indicate no insertion happened
        }

        // Insert the IP Address if it doesn't exist
        const result = await conn.query(insertSql, values);
        console.log('Inserted IP Address, ip_id:', result.insertId);
        return result.insertId; // Return the generated ip_id
    } catch (error) {
        console.error('Error inserting IP Address:', error);
        return null;
    } finally {
        if (conn) conn.end();
    }
};

// Function to insert into table_id
const insertIntoTableId = async (ip_id) => {
    const logId = Math.floor(Math.random() * 1000000).toString(); // Generate random log_id
    const sql = 'INSERT INTO table_id (log_id, ip_id) VALUES (?, ?)';
    const values = [logId, ip_id];

    let conn;
    try {
        conn = await pool.getConnection();
        await conn.query(sql, values);
        console.log('Inserted into table_id, log_id:', logId);
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
            country, postal_code, loc, query_date, query_time,
            request_type, request_resource,
            HTTP_response_code, object_size, user_agent
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    const logQueryValues = [
        logId,
        logData.IPAddress,
        logData.City,
        logData.Region,
        logData.Country,
        logData.Postal,
        logData.Location,
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
        conn = await pool.getConnection();
        await conn.query(sql, logQueryValues);
        console.log('Inserted into log_query for log_id:', logId);
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
            return res.status(500).json({ error: 'PowerShell script error', details: stderr });
        }

        let logDataArray;
        try {
            logDataArray = JSON.parse(stdout); // Parse the JSON output from PowerShell
        } catch (parseError) {
            console.error('Error parsing PowerShell output:', parseError);
            return res.status(500).json({ error: 'Error parsing PowerShell output', details: parseError.message });
        }

        // Iterate over each log entry and insert into the database
        for (const logData of logDataArray) {
            const ip_id = await insertIpAddress(logData.IPAddress);
            if (!ip_id) {
                continue; // Skip this entry but continue with others
            }
        
            const logId = await insertIntoTableId(ip_id);
            if (!logId) {
                continue; // Skip this entry but continue with others
            }
        
            await insertLogQuery(logId, logData);
        }

        // Execute R script after all data is processed
        const rScriptPath = 'C:\\Users\\Admin\\OneDrive\\Documents\\CS-474\\Individual Project\\Geolocator\\Data Visualization.r'; // Adjust the path to your R script
        const { rStdout, rStderr } = await execPromise(`Rscript "${rScriptPath}"`);

        if (rStderr) {
            console.error(`R script stderr: ${rStderr}`);
            return res.status(500).json({ error: 'R script error', details: rStderr });
        }

        console.log(`R script stdout: ${rStdout}`);

        console.log('All data processed successfully');
        return res.status(200).json({ message: 'Data processed and inserted successfully' });
    } catch (error) {
        console.error(`Error executing script: ${error.message}`);
        return res.status(500).json({ error: 'Error executing script', details: error.message });
    }
});


app.delete('/deleteData', async (req, res) => {
    console.log("Delete data endpoint hit");

    let conn;
    try {
        // Read the SQL file content
        const deleteSqlPath = path.join(__dirname, 'DeleteQueries.sql');
        const deleteSql = fs.readFileSync(deleteSqlPath, 'utf-8');

        // Connect to the database
        conn = await pool.getConnection();
        
        // Execute the SQL commands from the file
        await conn.query(deleteSql);

        console.log('SQL file executed and data deleted successfully');
        res.status(200).json({ message: 'Data deleted successfully via SQL file' });
    } catch (error) {
        console.error(`Error executing SQL file: ${error.message}`);
        res.status(500).json({ error: 'Error executing SQL file', details: error.message });
    } finally {
        if (conn) conn.end();
    }
});


const port = 5500;
app.listen(port, '127.0.0.1', () => {
    console.log(`App running on port ${port}`);
});
