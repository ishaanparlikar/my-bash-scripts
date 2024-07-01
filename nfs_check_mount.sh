#!/bin/bash

# Replace these variables with your NFS server details and mount point
NFS_SERVER=172.16.0.6
NFS_MOUNT_POINT=/mnt/media-tank
DOCKER_SERVICE=docker
LOG_FILE=/var/log/nfs_check_and_mount.log

# Function to log messages
log_message() {
    local log_time=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[$log_time] $1" >> $LOG_FILE
}

# Function to check if NFS server is reachable
check_nfs_server() {
    if ping -c 1 -W 1 $NFS_SERVER > /dev/null 2>&1; then
        return 0  # Server reachable
    else
        return 1  # Server unreachable
    fi
}

# Function to check if NFS mount exists
check_nfs_mount() {
    mount | grep -q "$NFS_SERVER:$NFS_MOUNT_POINT"
}

# Function to restart Docker service
restart_docker_service() {
    log_message "Restarting Docker service..."
    systemctl restart $DOCKER_SERVICE
}

# Main script
log_message "=== Starting NFS check and mount script ==="

# Loop until NFS server is reachable and storage is mounted
while true; do
    # Check if NFS server is reachable
    if ! check_nfs_server; then
        log_message "NFS server $NFS_SERVER is not reachable. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Check if NFS mount exists
    if check_nfs_mount; then
        log_message "NFS storage is already mounted."
        break  # Exit loop if NFS storage is mounted
    else
        log_message "NFS storage is not mounted. Mounting now..."
        mount -t nfs $NFS_SERVER:$NFS_MOUNT_POINT $NFS_MOUNT_POINT
        
        # Check if mount was successful
        if [ $? -eq 0 ]; then
            log_message "NFS storage successfully mounted."
            restart_docker_service
            break  # Exit loop if NFS storage is mounted
        else
            log_message "Failed to mount NFS storage. Check NFS server and mount point. Retrying in 10 seconds..."
            sleep 10
        fi
    fi
done

log_message "=== NFS check and mount script completed ==="

