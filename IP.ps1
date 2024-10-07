# Specify the path to the log files
$logFileArray = @(
    "C:\Users\Admin\OneDrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-101534.log",
    "C:\Users\Admin\OneDrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-162755.log",
    "C:\Users\Admin\OneDrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-162807.log",  
    "C:\Users\Admin\OneDrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-162814.log",
    "C:\Users\Admin\OneDrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-162829.log",
    "C:\Users\Admin\OneDrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-162831.log"
)

# Select a random file from the array of log files
$randomLogFile = Get-Random -InputObject $logFileArray

# Define the log pattern using regex
$logPattern = '^(?<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - - \[(?<datetime>[^\]]+)\] "(?<request_type>\w+) (?<request_resource>[^ ]+) HTTP[^"]*" (?<http_response_code>\d{3}) (?<object_size>\d+) "(?<referrer>[^"]*)" "(?<user_agent>[^"]*)"' 

# Read the log file line by line
$logEntries = Get-Content $randomLogFile

# Initialize an array to store parsed data
$parsedData = @()
$ipAddresses = @()  # Array to store unique IP addresses

foreach ($logEntry in $logEntries) { 
    if ($logEntry -match $logPattern) {
        # Extract fields using named captures
        $ipAddress = $matches['ip']
        $datetime = $matches['datetime']
        $requestType = $matches['request_type']
        $requestResource = $matches['request_resource']
        $httpResponseCode = $matches['http_response_code']
        $objectSize = $matches['object_size']
        $referrer = $matches['referrer']
        $userAgent = $matches['user_agent']

        # Collect unique IP addresses
        if (-not $ipAddresses.Contains($ipAddress)) {
            $ipAddresses += $ipAddress
        }

        # Store the log entry in a hashtable
        $entry = @{
            IPAddress        = $ipAddress
            DateTime         = $datetime
            RequestType      = $requestType
            RequestResource  = $requestResource
            HTTPResponseCode = $httpResponseCode
            ObjectSize       = $objectSize
            Referrer         = $referrer
            UserAgent        = $userAgent
        }

        # Add to the list of parsed data
        $parsedData += $entry
    }
    else {
        Write-Host "No match found for log entry: $logEntry"
    }
}

# Prepare the batch request for ip-api
$apiUrl = "http://ip-api.com/batch"
$ipList = $ipAddresses | ForEach-Object { @{ query = $_ } }  # Create a JSON array for the batch request

# Make the batch request
try {
    $apiResponse = Invoke-RestMethod -Uri $apiUrl -Method Post -Body ($ipList | ConvertTo-Json) -ContentType 'application/json'
    
    # Validate API response and extract fields
    foreach ($response in $apiResponse) {
        $ip = $response.query
        $country = if ($response.country) { $response.country } else { "N/A" }
        $city = if ($response.city) { $response.city } else { "N/A" }
        $region = if ($response.region) { $response.region } else { "N/A" }
        $location = if ($response.lat -and $response.lon) { "$($response.lat), $($response.lon)" } else { "N/A" }
        $postal = if ($response.zip) { $response.zip } else { "N/A" }

        # Find corresponding parsed data entry
        $entry = $parsedData | Where-Object { $_.IPAddress -eq $ip }
        if ($entry) {
            $entry.Country = $country
            $entry.City = $city
            $entry.Region = $region
            $entry.Location = $location
            $entry.Postal = $postal
        }
    }
}
catch {
    Write-Host "Error fetching GeoIP information: $_"
}

# Output the merged parsed data
$parsedData | Format-Table -AutoSize
