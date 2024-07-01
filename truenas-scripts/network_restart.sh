#!/bin/bash

logfile="./restart_logs.txt"

# Clear the logfile at the start
> "$logfile"

# Function to log messages to both stdout and the logfile
log() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> "$logfile"
}

log "Starting network connection check and service restart loop..."

# Check for a network connection
while ! ping -c1 google.com &>/dev/null; do
    log "No network connection detected. Restarting network services..."
    systemctl restart dhcpcd.service
    systemctl restart NetworkManager.service
    sleep 5
done

log "Network connection established. Starting or restarting Docker..."

# If a connection is established, start or restart K3S service
if systemctl is-active --quiet k3s.service; then
    systemctl restart k3s.service
    log "Restarted k3s.service"
else
    systemctl start k3s.service
    log "Started k3s.service"
fi

log "Script execution complete."

