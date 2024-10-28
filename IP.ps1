# Define the log pattern using regex
$logPattern = '^(?<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - - \[(?<datetime>[^\]]+)\] "(?<request_type>\w+) (?<request_resource>[^ ]+) HTTP[^"]*" (?<http_response_code>\d{3}) (?<object_size>\d+) "(?<referrer>[^"]*)" "(?<user_agent>[^"]*)"' 

# Create an array that defines OS types for User Agent
$osTypes = @(
    @{ OS = "Windows"; Pattern = "Windows" },
    @{ OS = "macOS"; Pattern = "Mac OS|Macintosh" },
    @{ OS = "Linux"; Pattern = "Linux|X11" },
    @{ OS = "Android"; Pattern = "Android" },
    @{ OS = "iOS"; Pattern = "iPhone|iPad" }
)

$logFile = "C:\Users\Admin\OneDrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241024-151153.log"
# Read the log file line by line
$logEntries = Get-Content $logFile

# Initialize an array to store parsed data
$parsedData = @()
$ipAddresses = @()  # Array to store unique IP addresses

foreach ($logEntry in $logEntries) { 
    if ($logEntry -match $logPattern) {
        # Extract fields using named captures
        $ipAddress = $matches['ip']
        $datetime = $matches['datetime'] -replace '\s-\d{4}$'

        $datetimeFormatted = ($datetime -replace '\s-\d{4}$').Trim() -replace '(\d{2})/(\w{3})/(\d{4}):(\d{2}:\d{2}:\d{2})', '$3-$1-$2 $4'
        
        try {
            $queryDate = Get-Date $datetimeFormatted -Format "yyyy-MM-dd"
            $queryTime = Get-Date $datetimeFormatted -Format "HH:mm:ss"
        }
        catch {
            Write-Host "Failed to parse date/time: $_"
            continue  # Skip to the next log entry
        }
        

        $requestType = $matches['request_type']
        $requestResource = $matches['request_resource']
        $httpResponseCode = $matches['http_response_code']
        $objectSize = $matches['object_size']
        $referrer = $matches['referrer']
        $userAgent = $matches['user_agent']



        $detectedOS = "Unknown"

        foreach ($os in $osTypes) {
            if ($userAgent -match $os.Pattern) {
                $detectedOS = $os.OS
                break
            }
        }

        # Collect unique IP addresses
        if (-not $ipAddresses.Contains($ipAddress)) {
            $ipAddresses += $ipAddress
        }

        # Store the log entry in a hashtable
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

# Output the merged parsed data as JSON

$jsonOutput = $parsedData | ConvertTo-Json
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Output $jsonOutput

