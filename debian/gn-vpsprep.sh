#!/bin/bash
# This script will prepare your VPS for the installation of an ethoFS node
# Note: This script does not install the ethoFS node. It run all the prelimiary commands to get the VPS ready.
#       To execute you either need to log in as root or run by prepending the "sudo" command.
#       You will then need to logoff as root and login as "ether1node" user and run the node installation script
#       to complete the installation.
# Example: sudo ./vpsprep.sh
# Version VPSprep v1.0

# Variables
#PORT22="$(sudo lsof -i tcp:22 -s tcp:listen)"
PORT80="$(sudo lsof -i tcp:80 -s tcp:listen)"
PORT4001="$(sudo lsof -i tcp:4001 -s tcp:listen)"
PORT30305="$(sudo lsof -i tcp:30305 -s tcp:listen)"

# Color Codes
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'
STOP='\e[0m'

#countdown "00:00:30" is a 30 second countdown
countdown()
(
  IFS=:
  set -- $*
  secs=$(( ${1#0} * 3600 + ${2#0} * 60 + ${3#0} ))
  while [ $secs -gt 0 ]
  do
    sleep 1 &
    printf "\r%02d:%02d:%02d" $((secs/3600)) $(( (secs/60)%60)) $((secs%60))
    secs=$(( $secs - 1 ))
    wait
  done
  echo -e "\033[1K"
)

clear
echo -e "${YELLOW}==========================================================="
echo -e "Ether-1 VPS Prep, v1.0"
echo -e "${YELLOW}===========================================================${NC}"
echo -e "${BLUE}2 Dec 2019, by Goose-Tech${NC}"
echo -e
echo -e "${CYAN}VPS preparation starting, press [CTRL-C] to cancel.${NC}"
countdown "00:00:04"
echo -e

# Verify necessary ports are available 
echo -e "${GREEN}Verifying all necessary ports are available...${NC}"
if [ -z "${PORT80}" ] && [ -z "${PORT4001}" ] && [ -z "${PORT30305}" ]; then
	echo -e "${YELLOW}All ports are available.${NC}"
else
	echo -e "${CYAN}One or more ports are in use by another process.\nPlease disable any processes on ports listed below.\n\n${NC}"
	echo -e "${GREEN}Output from port check:${NC}"
	echo -e "${GREEN}Port 80:${NC}\n${PORT80}"
	echo -e "${GREEN}Port 4001:${NC}\n${PORT4001}"
	echo -e "${GREEN}Port 30305:${NC}\n${PORT30305}"
	exit
fi

# Distro upgrade
echo -e "${GREEN}Updating OS...${NC}"
apt-get update
apt-get dist-upgrade -y

# Install & Configure Fail2Ban
echo -e "${GREEN}Setting up Fail2Ban...${NC}"
mkdir /var/run/fail2ban
apt-get install sudo ufw fail2ban nano -y
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl restart fail2ban
countdown "00:00:04"
fail2ban-client status

# Create ether2node user
echo -e "${GREEN}Creating new user called ${YELLOW}ether1node${GREEN}.\nWhen prompted, please set a secure password.${NC}"
adduser ether1node
adduser ether1node sudo
adduser ether1node systemd-journal

# Setting up Firewall
#ufw reset
#ufw allow 22/tcp
#ufw allow 80/tcp
#ufw allow 4001/tcp
#ufw allow 30305/tcp
#ufw allow 30305/udp
#ufw enable

# Download & prepare for ethoFS setup
echo -e "${GREEN}Downloading ethoFS installation script...\n${NC}"
mkdir -p /tmp/ether1 && cd /tmp/ether1
rm -rf setupETHOFS.sh && wget https://raw.githubusercontent.com/Ether1Project/ether1-node-scripts/master/debian/setupETHOFS.sh
chmod +x setupETHOFS.sh
echo -e "${YELLOW}Preparation complete. Please logoff and login as ${CYAN}ether1node${YELLOW}.\nThen type the following commands to complete installation.\n${NC}"
echo -e "${CYAN}/tmp/ether1/setupETHOFS.sh -gatewaynode${NC}"
