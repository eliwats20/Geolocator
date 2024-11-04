# Select log file 
$logFile = "C:\Users\Admin\OneDrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241027-230150.log"

# Define the log pattern using regex expression
$logPattern = '^(?<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - - \[(?<datetime>[^\]]+)\] "(?<request_type>\w+) (?<request_resource>[^ ]+) HTTP[^"]+" (?<http_response_code>\d{3}) (?<object_size>\d+) "(?<referrer>[^"]*)" "(?<user_agent>[^"]+)"';

# Create an array of hashtables to match OS types from patterns
$osTypes = @(
    @{ OS = "Windows"; Pattern = "Windows" },
    @{ OS = "macOS"; Pattern = "Mac OS|Macintosh" },
    @{ OS = "Linux"; Pattern = "Linux|X11" },
    @{ OS = "Android"; Pattern = "Android" },
    @{ OS = "iOS"; Pattern = "iPhone|iPad" }
)


# Read log file line by line
$logEntries = Get-Content $logFile

# Array to store parsed data from API
$parsedData = @()

# Array to store IP addresses
$ipAddresses = @() 

foreach ($logEntry in $logEntries) { 
    # Checks if each line in log file matches regex pattern
    if ($logEntry -match $logPattern) {
        # Extract fields using named captures
        $ipAddress = $matches['ip']
        $datetime = $matches['datetime']

        # Reformat date and time
        $datetimeFormatted = $datetime.Trim() -replace '(\d{2})/(\w{3})/(\d{4}):(\d{2}:\d{2}:\d{2})', '$3-$1-$2 $4'

        # Get date format from cmdlet to recognize user-defined format
        $queryDate = Get-Date $datetimeFormatted -Format "yyyy-MM-dd"
        $queryTime = Get-Date $datetimeFormatted -Format "HH:mm:ss"
        
        $requestType = $matches['request_type']
        $requestResource = $matches['request_resource']
        $httpResponseCode = $matches['http_response_code']
        $objectSize = $matches['object_size']
        $referrer = $matches['referrer']
        $userAgent = $matches['user_agent']


        # Iterate through the list of OS types to check for a match
        foreach ($os in $osTypes) {
            # If the user agent matches the current OS pattern
            if ($userAgent -match $os.Pattern) {
                # Assign the detected operating system to the variable                
                $detectedOS = $os.OS
                break
            }
        }

        $ipAddresses += $ipAddress
        
        # Store un-parsed log entry in a hashtable
        $entry = @{
            IPAddress        = $ipAddress
            QueryDate        = $queryDate   
            QueryTime        = $queryTime
            RequestType      = $requestType
            RequestResource  = $requestResource
            HTTPResponseCode = $httpResponseCode
            ObjectSize       = $objectSize
            Referrer         = $referrer
            UserAgent        = $detectedOS
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
$ipList = $ipAddresses

# Make the batch request
try {
    $apiResponse = Invoke-RestMethod -Uri $apiUrl -Method Post -Body ($ipList | ConvertTo-Json) -ContentType 'application/json'
    
    # Validate API response and extract fields
    foreach ($response in $apiResponse) {
        $ip = $response.query
        $country = if ($response.country) { $response.country } else { "N/A" }
        $city = if ($response.city) { $response.city } else { "N/A" }
        $region = if ($response.region) { $response.region } else { "N/A" }
        $latitude = if ($response.lat) { $response.lat } else { "N/A" }
        $longitude = if ($response.lon) { $response.lon }  else { "N/A" }
        $postal = if ($response.zip) { $response.zip } else { "N/A" }

        # Find corresponding parsed data entry
        $entry = $parsedData | Where-Object { $_.IPAddress -eq $ip }
        if ($entry) {
            $entry.Country = $country
            $entry.City = $city
            $entry.Region = $region
            $entry.Latitude = $latitude
            $entry.Longitude = $longitude
            $entry.Postal = $postal
        }
    }
}
catch {
    Write-Host "Error fetching IP-API information: $_"
}

# Output the merged parsed data as JSON
$jsonOutput = $parsedData | ConvertTo-Json
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Output $jsonOutput

