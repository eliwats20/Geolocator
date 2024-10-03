# Specify the path to the log file
$logFileArray = @(
    "C:\Users\Admin\Onedrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-101534.log",
    "C:\Users\Admin\Onedrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-162755.log",
    "C:\Users\Admin\Onedrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-162807.log",
    "C:\Users\Admin\Onedrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-162814.log",
    "C:\Users\Admin\Onedrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-162829.log",
    "C:\Users\Admin\Onedrive\Documents\CS-474\Individual Project\Geolocator\Log Files\access_log_20241003-162831.log"
)

# Select a random file from the array of log files
$randomLogFile = Get-Random -InputObject $logFileArray

# # Check if the log file exists
# if (-Not (Test-Path $randomLogFile)) {
#     Write-Host "Log file not found: $randomLogFile"
#     exit
# }

# Regular expression to parse the log entry
$logPattern = '^(?<ip>\d+\.\d+\.\d+\.\d+)\s-\s-\s\[(?<datetime>.+?)\]\s"(?<request_type>\w+)\s(?<request_resource>.*?)\sHTTP\/\d\.\d"\s(?<http_response_code>\d+)\s(?<object_size>\d+)\s"(?<referrer>.*?)"\s"(?<user_agent>.*?)"$'

# API endpoint (you can replace it with your choice of GeoIP API)
$ipInfoApiUrl = "https://ipinfo.io/{0}/json"

# Create a list to hold the parsed data
$parsedData = @()

# Read the log file line by line
Get-Content $randomLogFile | ForEach-Object {
    $logEntry = $_

    # Match the log entry against the pattern
    if ($logEntry -match $logPattern) {
        # Extracting the parsed values using named captures
        $ipAddress = $matches['ip']
        $datetime = $matches['datetime']
        $requestType = $matches['request_type']
        $requestResource = $matches['request_resource']
        $httpResponseCode = $matches['http_response_code']
        $objectSize = $matches['object_size']
        $referrer = $matches['referrer']
        $userAgent = $matches['user_agent']

        # Get GeoIP information
        $geoIpResponse = Invoke-RestMethod -Uri ($ipInfoApiUrl -f $ipAddress)
        $country = $geoIpResponse.country
        $city = $geoIpResponse.city
        $region = $geoIpResponse.region
        $location = $geoIpResponse.loc
        $postal = $geoIpResponse.postal

        # sets up the list of data for insertion
        $entry = @{
            IPAddress        = $ipAddress
            DateTime         = $datetime
            RequestType      = $requestType
            RequestResource  = $requestResource
            HTTPResponseCode = $httpResponseCode
            ObjectSize       = $objectSize
            Referrer         = $referrer
            UserAgent        = $userAgent
            Country          = $country
            City             = $city
            Region           = $region
            Location         = $location
            Postal           = $postal
        }

        # Add to the list of data
        $parsedData += $entry
    }
    else {
        Write-Host "No match found for entry: $logEntry"
    }
}

# Output parsed data for verification (Debug check)
$parsedData | Format-Table -AutoSize


# MySQL connection parameters
$connectionString = "Server=localhost; Database=; User ID=Eliyah2003; Password=Eliyah21!!; "

# Insert each entry into the database
$parsedData | ForEach-Object {
    $query = "INSERT INTO log_query (ip_address, city, region, loc, postal_code) VALUES ('$($_.IP)', '$($_.City)', '$($_.Region)', '$($_.Location)', '$($_.Postal)')"
    # $displayQuery = "SELECT * FROM log_query"
    # Execute the query
    Invoke-Sqlcmd -Query $query -ConnectionString $connectionString
    # Invoke-Sqlcmd -Query $displayQuery -ConnectionString $connectionString
}
