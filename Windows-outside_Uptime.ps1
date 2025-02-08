# Target IP to monitor
$TARGET_IP = "CHANGE_ME"

# Log file name
$logFile = "Disconnections.txt"

# Gotify parameters
$GotifyToken = "CHANGE_ME"
$GotifyServer = "CHANGE_ME"
$GotifyPort = "CHANGE_ME"
$NOTIFY_ENABLED = $true  # Enable (true) or disable (false) Gotify notifications

# Telegram parameters
$TELEGRAM_ENABLED = $true  # Enable (true) or disable (false) Telegram notifications
$TELEGRAM_BOT_TOKEN = "CHANGE_ME"
$TELEGRAM_CHAT_ID = "CHANGE_ME"

# Function to send notifications to Gotify
function Send-GotifyNotification {
    param (
        [string]$Title,
        [string]$Message
    )

    if (-not $NOTIFY_ENABLED) { return }

    $body = @{
        title   = $Title
        message = $Message
    } | ConvertTo-Json -Compress

    $url = "$GotifyServer`:$GotifyPort/message?token=$GotifyToken"

    Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -ErrorAction SilentlyContinue | Out-Null
}

# Function to send notifications to Telegram
function Send-TelegramNotification {
    param (
        [string]$Message
    )

    if (-not $TELEGRAM_ENABLED) { return }

    $url = "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage"
    $body = @{
        chat_id = $TELEGRAM_CHAT_ID
        text    = $Message
    }

    Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -ErrorAction SilentlyContinue | Out-Null
}

function Handle-Down {
    # Register start date/time in "dd-MM-yyyy HH:mm:ss" format
    $startDateTime = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    # Get epoch time (in seconds)
    $startSec = [int]((Get-Date).ToUniversalTime() - [datetime]"1970-01-01T00:00:00Z").TotalSeconds

    Write-Output "Disconnection detected: $startDateTime"
    "Disconnection detected: $startDateTime" | Out-File -Append $logFile

    # Send Gotify and Telegram notifications for disconnection
    Send-GotifyNotification "CONNECTION LOST" "Disconnection detected: $startDateTime"
    Send-TelegramNotification "⚠️ CONNECTION LOST: $startDateTime"

    # Print custom message on disconnection
    Write-Output "Internet down!"

    # Wait for reconnection, without showing errors
    while (-not (Test-Connection $TARGET_IP -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 5
    }

    # Once reconnected, register date/time and calculate downtime
    $endDateTime = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $endSec = [int]((Get-Date).ToUniversalTime() - [datetime]"1970-01-01T00:00:00Z").TotalSeconds

    $diffSec = $endSec - $startSec
    $timespan = [TimeSpan]::FromSeconds($diffSec)
    $duration = $timespan.ToString("hh\:mm\:ss")

    $msg = "Reconnected at $endDateTime - Downtime duration: $duration"
    $msg | Out-File -Append $logFile
    "---------------------------------------" | Out-File -Append $logFile

    # Send Gotify and Telegram notifications for reconnection
    Send-GotifyNotification "CONNECTION RESTORED" $msg
    Send-TelegramNotification "✅ CONNECTION RESTORED: $msg"
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
