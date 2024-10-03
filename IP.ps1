# set the path to your log file
$logFilePath = "C:\Users\Admin\OneDrive\Documents\CS-474\Individual Project\Geolocator\access_log_20241003-101534.log"

# read the log file and extract the IPv4 addresses
$ipAddresses = Get-Content $logFilePath | ForEach-Object {
    if ($_ -match '^(?<ip>\d{1,3}(?:\.\d{1,3}){3})') {
        $matches['ip']
    }
}

# iterate through each extracted IP address and make API call
foreach ($ip in $ipAddresses) {
    # Replace YOUR_API_URL with your actual API URL
    $apiUrl = "https://ipinfo.io/$ip/json"
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get

    # Output the response
    $response
}
