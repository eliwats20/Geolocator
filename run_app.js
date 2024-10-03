const { exec } = require('child_process');

// Run your PowerShell script
exec('powershell -File "C:\\Users\\Admin\\Onedrive\\Documents\\CS-474\\Individual Project\\Geolocator\\IP.ps1"', (error, stdout, stderr) => {
    if (error) {
        console.error(`Error: ${error.message}`);
        return;
    }
    if (stderr) {
        console.error(`stderr: ${stderr}`);
        return;
    }
    console.log(`Output: ${stdout}`);
});

