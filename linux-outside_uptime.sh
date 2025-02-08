#!/bin/bash
# Set target IP
TARGET_IP="IP TO MONITOR"

# Log file name
LOGFILE="Disconnections.txt"

# Gotify parameters (modifiable for easy future management)
GotifyToken="CHANGE_ME"
GotifyServer="CHANGE_ME"
GotifyPort="CHANGE_ME"

# Enable (true) or disable (false) Gotify notifications
NOTIFY_ENABLED=true

# Telegram parameters
TELEGRAM_ENABLED=true
TELEGRAM_BOT_TOKEN="CHANGE_ME"
TELEGRAM_CHAT_ID="CHANGE_ME"

# Function to send notifications to Gotify
send_notification_gotify() {
    # If Gotify notifications are disabled, exit the function
    if [ "$NOTIFY_ENABLED" != "true" ]; then
        return
    fi

    local title="$1"
    local message="$2"
    curl -s -X POST -H "Content-Type: application/json" \
         -d "{\"title\": \"${title}\", \"message\": \"${message}\"}" \
         "${GotifyServer}:${GotifyPort}/message?token=${GotifyToken}" > /dev/null 2>&1
}

# Function to send notifications to Telegram
send_notification_telegram() {
    # If Telegram notifications are disabled, exit the function
    if [ "$TELEGRAM_ENABLED" != "true" ]; then
        return
    fi

    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
         -d "chat_id=${TELEGRAM_CHAT_ID}&text=${message}" > /dev/null 2>&1
}

handle_down() {
    # Get current date/time in "dd-mm-yyyy HH:MM:SS" format
    startDateTime=$(date "+%d-%m-%Y %H:%M:%S")
    # Get epoch time (in seconds)
    startSec=$(date +%s)

    # Disconnection message
    msg_down="Disconnection detected: $startDateTime"
    echo "$msg_down"
    echo "$msg_down" >> "$LOGFILE"

    # Send Gotify and Telegram notifications for the disconnection
    send_notification_gotify "CONNECTION LOST" "$msg_down"
    send_notification_telegram "⚠️ CONNECTION LOST: $msg_down"

    # Custom message indicating that the connection is down
    echo "Internet down!"

    # Wait for the connection to be restored: keep pinging every 5 seconds
    while ! ping -c 1 -W 1 "$TARGET_IP" > /dev/null 2>&1; do
        sleep 5
    done

    # Once the connection is restored, log the end time and duration
    endDateTime=$(date "+%d-%m-%Y %H:%M:%S")
    endSec=$(date +%s)

    # Calculate downtime duration in seconds
    diffSec=$(( endSec - startSec ))

    # Convert duration to HH:MM:SS format
    hh=$(( diffSec / 3600 ))
    mm=$(( (diffSec % 3600) / 60 ))
    ss=$(( diffSec % 60 ))
    duration=$(printf "%02d:%02d:%02d" $hh $mm $ss)

    recon_msg="Reconnected at $endDateTime - Downtime duration: $duration"
    echo "$recon_msg" >> "$LOGFILE"
    echo "---------------------------------------" >> "$LOGFILE"

    # Send Gotify and Telegram notifications for connection restoration
    send_notification_gotify "CONNECTION RESTORED" "$recon_msg"
    send_notification_telegram "✅ CONNECTION RESTORED: $recon_msg"
}

# Main loop: check connection
while true; do
    if ping -c 1 -W 1 "$TARGET_IP" > /dev/null 2>&1; then
        echo "$(date +%T) No connection issues"
        sleep 5
    else
        handle_down
        echo "[DEBUG] Returning from handle_down"
    fi
done
