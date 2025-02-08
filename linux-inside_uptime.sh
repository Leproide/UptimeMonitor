#!/bin/bash

# Internet reachability check IP
TARGET_IP="8.8.8.8"

# Log file name
LOGFILE="Disconnections.txt"

handle_down() {
    # Record start date/time in "dd-MM-yyyy HH:mm:ss" format
    startDateTime=$(date "+%d-%m-%Y %H:%M:%S")
    # Get epoch time (in seconds)
    startSec=$(date +%s)

    echo "Disconnection detected: $startDateTime"
    echo "Disconnection detected: $startDateTime" >> "$LOGFILE"

    # Print custom message when disconnection occurs
    echo "Internet down!"

    # Wait for reconnection, suppressing errors
    while ! ping -c 1 -W 1 "$TARGET_IP" > /dev/null 2>&1; do
        sleep 5
    done

    # Once reconnected, record date/time and calculate downtime
    endDateTime=$(date "+%d-%m-%Y %H:%M:%S")
    endSec=$(date +%s)

    diffSec=$(( endSec - startSec ))

    # Convert duration to HH:MM:SS format
    hh=$(( diffSec / 3600 ))
    mm=$(( (diffSec % 3600) / 60 ))
    ss=$(( diffSec % 60 ))
    duration=$(printf "%02d:%02d:%02d" $hh $mm $ss)

    echo "Reconnected at $endDateTime - Downtime duration: $duration" >> "$LOGFILE"
    echo "---------------------------------------" >> "$LOGFILE"
}

# Main loop: monitor connection
while true; do
    if ping -c 1 -W 1 "$TARGET_IP" > /dev/null 2>&1; then
        echo "$(date '+%d-%m-%Y %H:%M:%S') No connection issues"
        sleep 5
    else
        handle_down
        echo "[DEBUG] Returning from handle_down"
    fi
done
