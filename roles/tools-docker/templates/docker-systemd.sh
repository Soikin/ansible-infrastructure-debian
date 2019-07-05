#!/bin/bash

# Make sure only special user can run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Create autostart config for systemctl."
read -p "Enter docker project: " DIR

if [ "`systemctl is-active docker@${DIR}.service`" == "active" ]; then
   echo docker@${DIR} service is exist
   exit 0
else
   echo docker@${DIR} service is not exist
fi

if [ -f "${DIR}/docker-compose.yml" ]; then
   systemctl start docker@${DIR}.service
   systemctl enable docker@${DIR}.service
   #systemctl is-enabled docker@${DIR}.service
   echo "$(tput setaf 2)Done! Systemd is a watcher for a your subproject. $(tput sgr0)"
else
   echo "$(tput setaf 1)${DIR} does not exist! $(tput sgr0)"
fi
