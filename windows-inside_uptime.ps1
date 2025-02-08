# Internet reachability check IP
$TARGET_IP = "8.8.8.8"

# Log file name
$logFile = "Disconnections.txt"

function Handle-Down {
    # Record start date/time in "dd-MM-yyyy HH:mm:ss" format
    $startDateTime = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    # Get epoch time (in seconds)
    $startSec = [int]((Get-Date).ToUniversalTime() - [datetime]"1970-01-01T00:00:00Z").TotalSeconds

    Write-Output "Disconnection detected: $startDateTime"
    "Disconnection detected: $startDateTime" | Out-File -Append $logFile

    # Print custom message when disconnection occurs
    Write-Output "Internet down!"

    # Wait for reconnection, suppressing errors
    while (-not (Test-Connection $TARGET_IP -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 5
    }

    # Once reconnected, record date/time and calculate downtime
    $endDateTime = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $endSec = [int]((Get-Date).ToUniversalTime() - [datetime]"1970-01-01T00:00:00Z").TotalSeconds

    $diffSec = $endSec - $startSec
    $timespan = [TimeSpan]::FromSeconds($diffSec)
    $duration = $timespan.ToString("hh\:mm\:ss")

    $msg = "Reconnected at $endDateTime - Downtime duration: $duration"
    $msg | Out-File -Append $logFile
    "---------------------------------------" | Out-File -Append $logFile
}

# Main loop: monitor connection
while ($true) {
    if (Test-Connection $TARGET_IP -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        Write-Output "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') No connection issues"
        Start-Sleep -Seconds 5
    }
    else {
        Handle-Down
        Write-Output "[DEBUG] Returning from Handle-Down"
    }
}
