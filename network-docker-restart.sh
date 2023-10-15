#!bin/bash

# Check for a network connection
while ! ping -c1 google.com &>/dev/null; do
  # If no connection, restart the network service
  systemctl restart dhcpcd.service
  systemctl restart NetworkManager.service
  sleep 5
done

# If a connection is established, start or restart Docker
systemctl is-active --quiet docker.service && systemctl restart docker.service || systemctl start docker.service
/
