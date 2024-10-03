# Specify the path to the log file
$logFilePath = "C:\Users\Admin\OneDrive\Documents\CS-474\Individual Project\Geolocator\access_log_20241003-101534.log"

# Check if the log file exists
if (-Not (Test-Path $logFilePath)) {
    Write-Host "Log file not found: $logFilePath"
    exit
}

# Regular expression to parse the log entry
$logPattern = '^(?<ip>\d+\.\d+\.\d+\.\d+)\s-\s-\s\[(?<datetime>.+?)\]\s"(?<request_type>\w+)\s(?<request_resource>.*?)\sHTTP\/\d\.\d"\s(?<http_response_code>\d+)\s(?<object_size>\d+)\s"(?<referrer>.*?)"\s"(?<user_agent>.*?)"$'

# Read the log file line by line
Get-Content $logFilePath | ForEach-Object {
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

        # Displaying the parsed information
        Write-Host "IP Address: $ipAddress"
        Write-Host "Date/Time: $datetime"
        Write-Host "Request Type: $requestType"
        Write-Host "Request Resource: $requestResource"
        Write-Host "HTTP Response Code: $httpResponseCode"
        Write-Host "Object Size: $objectSize"
        Write-Host "Referrer: $referrer"
        Write-Host "User Agent: $userAgent"
        Write-Host "-----------------------------------"
    }
    else {
        Write-Host "No match found for entry: $logEntry"
    }
}
